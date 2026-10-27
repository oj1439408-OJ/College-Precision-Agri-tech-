import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AssistantApiException implements Exception {
  final String message;

  const AssistantApiException(this.message);
}

class AssistantApiService {
  AssistantApiService({http.Client? client, Uri? endpoint, Duration? requestTimeout})
      : _client = client ?? http.Client(),
        _endpoint = endpoint ?? _defaultEndpoint,
        _requestTimeout = requestTimeout ?? _defaultRequestTimeout,
        _ownsClient = client == null;

  static const int _timeoutSeconds =
      int.fromEnvironment('ASSISTANT_TIMEOUT_SECONDS', defaultValue: 135);
  static const Duration _defaultRequestTimeout = Duration(seconds: _timeoutSeconds);

  final http.Client _client;
  final Uri _endpoint;
  final Duration _requestTimeout;
  final bool _ownsClient;

  static Uri get _defaultEndpoint {
    const configuredUrl = String.fromEnvironment('ASSISTANT_API_URL');
    if (configuredUrl.isNotEmpty) return Uri.parse(configuredUrl);
    if (kIsWeb) return Uri.parse('http://127.0.0.1:5000/api/assistant');
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:5000/api/assistant');
    }
    return Uri.parse('http://127.0.0.1:5000/api/assistant');
  }

  Future<String> sendMessage(String message) async {
    final abortTrigger = Completer<void>();
    final request = http.AbortableRequest(
      'POST',
      _endpoint,
      abortTrigger: abortTrigger.future,
    )
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'message': message});

    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(
            _requestTimeout,
            onTimeout: () {
              if (!abortTrigger.isCompleted) abortTrigger.complete();
              throw TimeoutException('Assistant request timed out.');
            },
          );

      final Object? decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const AssistantApiException(
          'The assistant returned an invalid response. Please retry.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const AssistantApiException(
          'The assistant returned an invalid response. Please retry.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded['error'];
        throw AssistantApiException(
          error is String && error.trim().isNotEmpty
              ? error
              : 'The assistant could not answer. Please retry.',
        );
      }

      final reply = decoded['response'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const AssistantApiException(
          'The assistant returned an empty response. Please retry.',
        );
      }
      return reply.trim();
    } on AssistantApiException {
      rethrow;
    } on TimeoutException {
      throw const AssistantApiException(
        'The assistant is taking too long to respond. Please retry.',
      );
    } on http.ClientException {
      throw const AssistantApiException(
        'Could not connect to Flask. Check that the backend is running, then retry.',
      );
    } catch (_) {
      throw const AssistantApiException(
        'Could not connect to Flask. Check the backend address and retry.',
      );
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}