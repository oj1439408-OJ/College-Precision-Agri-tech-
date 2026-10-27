import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_agri_app/services/assistant_api_service.dart';

void main() {
  test('sends message and reads Flask response field', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({'response': 'Gemini reply'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = AssistantApiService(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:5000/api/assistant'),
    );
    addTearDown(client.close);

    final reply = await service.sendMessage('Explain soil pH');

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {'message': 'Explain soil pH'});
    expect(reply, 'Gemini reply');
  });

  test('surfaces the backend JSON error for retry UI', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({'error': 'The assistant is temporarily unavailable.'}),
          502,
          headers: {'content-type': 'application/json'},
        ));
    final service = AssistantApiService(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:5000/api/assistant'),
    );
    addTearDown(client.close);

    await expectLater(
      service.sendMessage('Please help'),
      throwsA(
        isA<AssistantApiException>().having(
          (error) => error.message,
          'message',
          'The assistant is temporarily unavailable.',
        ),
      ),
    );
  });

  test('aborts the in-flight request before reporting a timeout', () async {
    final aborted = Completer<void>();
    final client = MockClient.streaming((request, _) async {
      final abortableRequest = request as http.Abortable;
      abortableRequest.abortTrigger!.then((_) => aborted.complete());
      await abortableRequest.abortTrigger;
      throw http.RequestAbortedException(request.url);
    });
    final service = AssistantApiService(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:5000/api/assistant'),
      requestTimeout: const Duration(milliseconds: 10),
    );
    addTearDown(client.close);

    await expectLater(
      service.sendMessage('Try once'),
      throwsA(
        isA<AssistantApiException>().having(
          (error) => error.message,
          'message',
          'The assistant is taking too long to respond. Please retry.',
        ),
      ),
    );
    await aborted.future.timeout(const Duration(seconds: 1));
    expect(aborted.isCompleted, isTrue);
  });
}