import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/network/https_client.dart';

AppFailure _failureOf(Result<HttpsResponse> result) => switch (result) {
  Ok<HttpsResponse>() => fail('expected Err'),
  Err<HttpsResponse>(:final AppFailure failure) => failure,
};

void main() {
  final Uri site = Uri.parse('https://news.example.test/wp-json/');

  group('IoHttpsGetClient [NFR-SEC-001]', () {
    test('refuses an address that is not HTTPS, before any request', () {
      int sent = 0;
      final IoHttpsGetClient client = IoHttpsGetClient(
        send: (Uri uri) async {
          sent++;
          return const HttpsResponse(statusCode: 200, body: '');
        },
      );

      expect(
        () => client.get(Uri.parse('http://news.example.test/wp-json/')),
        throwsArgumentError,
      );
      expect(sent, 0);
    });

    test('returns every status code to the caller', () async {
      final IoHttpsGetClient client = IoHttpsGetClient(
        send: (Uri uri) async => const HttpsResponse(statusCode: 503, body: ''),
      );

      final Result<HttpsResponse> result = await client.get(site);

      expect(result, isA<Ok<HttpsResponse>>());
      expect((result as Ok<HttpsResponse>).value.statusCode, 503);
    });

    test('a slow response is a retryable timeout (FX-WP-11)', () async {
      final IoHttpsGetClient client = IoHttpsGetClient(
        timeout: const Duration(milliseconds: 20),
        send: (Uri uri) => Completer<HttpsResponse>().future,
      );

      final AppFailure failure = _failureOf(await client.get(site));

      expect(failure.code, FailureCode.timeout);
      expect(failure.retryable, isTrue);
    });

    test('connection failures are retryable network failures', () async {
      for (final Exception error in <Exception>[
        const SocketException('synthetic'),
        const HandshakeException('synthetic'),
        const TlsException('synthetic'),
        const HttpException('synthetic'),
      ]) {
        final IoHttpsGetClient client = IoHttpsGetClient(
          send: (Uri uri) async => throw error,
        );

        final AppFailure failure = _failureOf(await client.get(site));

        expect(failure.code, FailureCode.network, reason: '$error');
        expect(failure.retryable, isTrue);
      }
    });

    test('a body that is not UTF-8 is invalidResponse', () async {
      final IoHttpsGetClient client = IoHttpsGetClient(
        send: (Uri uri) async => throw const FormatException('synthetic'),
      );

      final AppFailure failure = _failureOf(await client.get(site));

      expect(failure.code, FailureCode.invalidResponse);
    });

    test('the default timeout is 15 seconds (PROPOSED)', () {
      expect(IoHttpsGetClient.defaultTimeout, const Duration(seconds: 15));
    });

    test('a body over the limit is invalidResponse', () async {
      final IoHttpsGetClient client = IoHttpsGetClient(
        send: (Uri uri) async => throw const ResponseTooLarge(),
      );

      final AppFailure failure = _failureOf(await client.get(site));

      expect(failure.code, FailureCode.invalidResponse);
      expect(failure.retryable, isFalse);
    });
  });

  group('readCapped (5 MB limit, PROPOSED)', () {
    Stream<List<int>> chunks(int count, int size) =>
        Stream<List<int>>.fromIterable(
          List<List<int>>.generate(count, (_) => List<int>.filled(size, 65)),
        );

    test('reads a body up to the limit whole', () async {
      final List<int> bytes = await readCapped(chunks(4, 25), maxBytes: 100);

      expect(bytes, hasLength(100));
    });

    test('stops as soon as the body passes the limit', () async {
      await expectLater(
        readCapped(chunks(5, 25), maxBytes: 100),
        throwsA(isA<ResponseTooLarge>()),
      );
    });

    test('the limit is 5 MB', () {
      expect(maxResponseBytes, 5000000);
    });
  });
}
