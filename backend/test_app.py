import os
import unittest
from unittest.mock import patch

import app


class AssistantEndpointTest(unittest.TestCase):
    def test_interactions_uses_sdk_step_format_for_history(self):
        client_patcher = patch("app.genai.Client")
        mock_client = client_patcher.start()
        self.addCleanup(client_patcher.stop)
        mock_client.return_value.interactions.create.return_value.output_text = "A reply"
        test_client = app.app.test_client()

        with patch.dict(os.environ, {"GEMINI_API_KEY": "test-only-key"}):
            response = test_client.post(
                "/api/assistant",
                json={
                    "message": "Follow up",
                    "history": [
                        {"role": "user", "content": "Question one"},
                        {"role": "assistant", "content": "Answer one"},
                    ],
                },
            )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {"response": "A reply"})
        mock_client.return_value.interactions.create.assert_called_once_with(
            model="gemini-flash-latest",
            input=[
                {
                    "type": "user_input",
                    "content": [{"type": "text", "text": "Question one"}],
                },
                {
                    "type": "model_output",
                    "content": [{"type": "text", "text": "Answer one"}],
                },
                {
                    "type": "user_input",
                    "content": [{"type": "text", "text": "Follow up"}],
                },
            ],
            system_instruction=app.SYSTEM_INSTRUCTION,
            timeout=app.GEMINI_REQUEST_TIMEOUT_SECONDS,
        )

    def test_connection_error_is_logged_without_exception_details(self):
        connection_error = type("APIConnectionError", (Exception,), {})
        client_patcher = patch("app.genai.Client")
        mock_client = client_patcher.start()
        self.addCleanup(client_patcher.stop)
        mock_client.return_value.interactions.create.side_effect = connection_error(
            "do not log this detail"
        )

        with patch.dict(os.environ, {"GEMINI_API_KEY": "test-only-key"}):
            with self.assertLogs("app", level="WARNING") as captured_logs:
                response = app.app.test_client().post(
                    "/api/assistant", json={"message": "Hello"}
                )

        self.assertEqual(response.status_code, 503)
        self.assertIn("Gemini connection failed", "\n".join(captured_logs.output))
        self.assertNotIn("do not log this detail", "\n".join(captured_logs.output))

    def test_provider_error_logs_type_and_status_only(self):
        provider_error = type(
            "ProviderFailure",
            (Exception,),
            {"status_code": 503},
        )
        client_patcher = patch("app.genai.Client")
        mock_client = client_patcher.start()
        self.addCleanup(client_patcher.stop)
        mock_client.return_value.interactions.create.side_effect = provider_error(
            "sensitive provider body"
        )

        with patch.dict(os.environ, {"GEMINI_API_KEY": "test-only-key"}):
            with self.assertLogs("app", level="ERROR") as captured_logs:
                response = app.app.test_client().post(
                    "/api/assistant", json={"message": "Hello"}
                )

        self.assertEqual(response.status_code, 502)
        logs = "\n".join(captured_logs.output)
        self.assertIn("status=503", logs)
        self.assertNotIn("sensitive provider body", logs)

    def test_provider_timeout_returns_gateway_timeout(self):
        timeout_error = type("APITimeoutError", (Exception,), {})
        client_patcher = patch("app.genai.Client")
        mock_client = client_patcher.start()
        self.addCleanup(client_patcher.stop)
        mock_client.return_value.interactions.create.side_effect = timeout_error(
            "timeout details must not be logged"
        )

        with patch.dict(os.environ, {"GEMINI_API_KEY": "test-only-key"}):
            with self.assertLogs("app", level="WARNING") as captured_logs:
                response = app.app.test_client().post(
                    "/api/assistant", json={"message": "Hello"}
                )

        self.assertEqual(response.status_code, 504)
        self.assertIn("timed out after", "\n".join(captured_logs.output))
        self.assertNotIn("timeout details", "\n".join(captured_logs.output))


if __name__ == "__main__":
    unittest.main()