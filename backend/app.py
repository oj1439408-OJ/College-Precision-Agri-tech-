import logging
import os
import re

from flask import Flask, jsonify, request
from flask_cors import CORS
from google import genai
from google.genai import errors as genai_errors


app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 1 * 1024 * 1024

LOCAL_ORIGIN = re.compile(r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$")
CORS(
    app,
    resources={
        r"/api/assistant": {
            "origins": LOCAL_ORIGIN,
            "methods": ["POST", "OPTIONS"],
            "allow_headers": ["Content-Type"],
        }
    },
)

MODEL_NAME = "gemini-flash-latest"
GEMINI_REQUEST_TIMEOUT_SECONDS = int(os.environ.get("GEMINI_REQUEST_TIMEOUT_SECONDS", "120"))
SYSTEM_INSTRUCTION = (
    "You are a friendly, general-purpose AI assistant. You can also explain "
    "farming, soil health, crops, nutrients, and irrigation in simple, practical "
    "language. Be clear about uncertainty and do not present general guidance as "
    "a substitute for local agricultural advice."
)


def _conversation_contents(history, message):
    contents = []
    for entry in history[-20:]:
        if not isinstance(entry, dict):
            raise ValueError("Each conversation history item must be an object.")

        role = str(entry.get("role", "")).strip().lower()
        text = entry.get("message", entry.get("content", entry.get("text", "")))
        if role == "model":
            role = "assistant"
        if role not in {"user", "assistant"} or not isinstance(text, str):
            raise ValueError("History items need a user or assistant role and text.")
        if text.strip():
            contents.append(
                {
                    "type": "user_input" if role == "user" else "model_output",
                    "content": [{"type": "text", "text": text.strip()}],
                }
            )

    contents.append(
        {
            "type": "user_input",
            "content": [{"type": "text", "text": message}],
        }
    )
    return contents


@app.errorhandler(413)
def request_too_large(_error):
    return jsonify({"error": "That message is too large. Please shorten it and try again."}), 413


@app.post("/api/assistant")
def assistant():
    payload = request.get_json(silent=True)
    if not isinstance(payload, dict):
        return jsonify({"error": "Send a JSON object with a message."}), 400

    message = payload.get("message", payload.get("prompt"))
    if not isinstance(message, str) or not message.strip():
        return jsonify({"error": "Please enter a message before sending."}), 400
    message = message.strip()

    history = payload.get("history", payload.get("conversation_history", []))
    if not isinstance(history, list):
        return jsonify({"error": "Conversation history must be a list."}), 400

    try:
        contents = _conversation_contents(history, message)
    except ValueError as error:
        return jsonify({"error": str(error)}), 400

    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key:
        return jsonify({"error": "The assistant is not configured yet. Set GEMINI_API_KEY and restart the server."}), 503

    try:
        client = genai.Client(api_key=api_key)
        result = client.interactions.create(
            model=MODEL_NAME,
            input=contents,
            system_instruction=SYSTEM_INSTRUCTION,
            timeout=GEMINI_REQUEST_TIMEOUT_SECONDS,
        )
        response_text = (result.output_text or "").strip()
        if not response_text:
            return jsonify({"error": "The assistant could not produce a reply. Please try again."}), 502
        return jsonify({"response": response_text})
    except Exception as error:
        error_type = type(error).__name__
        status_code = getattr(error, "status_code", getattr(error, "code", None))
        if error_type == "APITimeoutError":
            app.logger.warning(
                "Gemini transport timed out after %s seconds",
                GEMINI_REQUEST_TIMEOUT_SECONDS,
            )
            return jsonify({"error": "Gemini took too long to respond. Please retry."}), 504
        if error_type == "APIConnectionError":
            app.logger.warning("Gemini connection failed (APIConnectionError)")
            return jsonify({"error": "Gemini could not be reached. Please retry shortly."}), 503
        if isinstance(error, genai_errors.APIError) or isinstance(status_code, int):
            app.logger.error(
                "Gemini provider error type=%s status=%s",
                error_type,
                status_code if isinstance(status_code, int) else "unknown",
            )
            return jsonify({"error": "Gemini is temporarily unavailable. Please retry."}), 502
        app.logger.error("Unexpected Gemini integration error type=%s", error_type)
        return jsonify({"error": "The assistant is temporarily unavailable. Please try again."}), 502


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    app.run(host="127.0.0.1", port=5000, debug=True)