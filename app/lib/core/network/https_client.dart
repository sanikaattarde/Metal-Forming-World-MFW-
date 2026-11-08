import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../contracts/result.dart';

/// A response read by [HttpsGetClient].
final class HttpsResponse {
  /// Creates a response.
  const HttpsResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, String>{},
  });

  /// The HTTP status code.
  final int statusCode;

  /// Response headers, with names in lower case.
  final Map<String, String> headers;

  /// The body, decoded as UTF-8.
  final String body;
}

/// Reads public resources over HTTPS only (RS NFR-SEC-001), part of
/// MOD01-P2-T03.
///
/// Every status code is returned as [Ok], because what a status means
/// depends on the service; the caller maps it. Failures: `network` and
/// `timeout` (both retryable) and `invalidResponse`.
abstract interface class HttpsGetClient {
  /// Reads [uri]. Throws [ArgumentError] for an address that is not HTTPS,
  /// because that is a programming error.
  Future<Result<HttpsResponse>> get(Uri uri);
}

/// Sends one GET request and reads the whole response.
typedef HttpsSend = Future<HttpsResponse> Function(Uri uri);

/// [HttpsGetClient] on `dart:io`.
///
/// Redirects are not followed, so a redirect to a plain HTTP address is
/// never read; the caller sees the 3xx status.
final class IoHttpsGetClient implements HttpsGetClient {
  /// Creates a client. [send] replaces the network in tests.
  factory IoHttpsGetClient({
    Duration timeout = defaultTimeout,
    HttpsSend? send,
  }) {
    final _IoSender? io = send == null ? _IoSender(timeout) : null;
    return IoHttpsGetClient._(timeout, send ?? io!.send, io);
  }

  IoHttpsGetClient._(this.timeout, this._send, this._io);

  /// How long one request may take in all, from connecting to the last byte
  /// of the body (PROPOSED; no document sets a value).
  static const Duration defaultTimeout = Duration(seconds: 15);

  /// The limit used by this client.
  final Duration timeout;

  final HttpsSend _send;
  final _IoSender? _io;

  /// Closes the connections this client opened. It cannot be used after.
  void close() => _io?.close();

  @override
  Future<Result<HttpsResponse>> get(Uri uri) async {
    if (!uri.isScheme('https')) {
      throw ArgumentError.value(uri, 'uri', 'Only HTTPS is allowed');
    }
    try {
      return Ok<HttpsResponse>(await _send(uri).timeout(timeout));
    } on TimeoutException {
      return const Err<HttpsResponse>(
        AppFailure(FailureCode.timeout, retryable: true, detail: 'timeout'),
      );
    } on SocketException {
      return const Err<HttpsResponse>(
        AppFailure(FailureCode.network, retryable: true, detail: 'socket'),
      );
    } on TlsException {
      return const Err<HttpsResponse>(
        AppFailure(FailureCode.network, retryable: true, detail: 'tls'),
      );
    } on HttpException {
      return const Err<HttpsResponse>(
        AppFailure(FailureCode.network, retryable: true, detail: 'http'),
      );
    } on FormatException {
      return const Err<HttpsResponse>(
        AppFailure(FailureCode.invalidResponse, detail: 'body not UTF-8'),
      );
    }
  }
}

final class _IoSender {
  _IoSender(Duration timeout)
    : _client = HttpClient()..connectionTimeout = timeout;

  final HttpClient _client;

  void close() => _client.close();

  Future<HttpsResponse> send(Uri uri) async {
    final HttpClientRequest request = await _client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final HttpClientResponse response = await request.close();
    final String body = await response.transform(utf8.decoder).join();
    final Map<String, String> headers = <String, String>{};
    response.headers.forEach((String name, List<String> values) {
      headers[name.toLowerCase()] = values.join(',');
    });
    return HttpsResponse(
      statusCode: response.statusCode,
      headers: headers,
      body: body,
    );
  }
}
