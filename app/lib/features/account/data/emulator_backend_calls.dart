import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/backend_calls.dart';
import 'firebase_backend_calls.dart';

/// [BackendCalls] for an iPhone that reaches the local Functions emulator at
/// the developer machine's network address (ENV-LOCAL only).
///
/// The Firebase Apple SDK refuses to attach the sign-in token to plain HTTP
/// for any host but the phone itself, and allows it only in debug builds, so
/// every call from a profile build fails as unauthenticated. This client
/// speaks the callable protocol itself: a POST of `{"data": ...}` with the
/// Auth emulator's token, answered by `{"result": ...}` or `{"error": ...}`.
/// The token is the emulator's own, unsigned and valid nowhere else, and
/// `FirebaseSettings` refuses an emulator host outside ENV-LOCAL.
final class EmulatorBackendCalls implements BackendCalls {
  /// Creates the client for the emulator at [origin], such as
  /// `http://192.168.1.10:5001`, and the demo [projectId].
  EmulatorBackendCalls({
    required this._origin,
    required this._projectId,
    required this._idToken,
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  final Uri _origin;
  final String _projectId;
  final Future<String?> Function() _idToken;
  final HttpClient _client;

  /// The callable's own limit, for a call that never answers.
  static const Duration timeout = Duration(seconds: 70);

  @override
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  ) async {
    final Uri uri = _origin.replace(
      path: '/$_projectId/us-central1/$operation',
    );
    final String? token = await _idToken();
    Map<String, Object?> reply;
    try {
      final HttpClientRequest request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.write(jsonEncode(<String, Object?>{'data': data}));
      final HttpClientResponse response = await request.close().timeout(
        timeout,
      );
      final Object? body = jsonDecode(
        await response.transform(utf8.decoder).join().timeout(timeout),
      );
      reply = body is Map ? Map<String, Object?>.from(body) : const {};
    } on TimeoutException {
      throw const BackendCallError('UNAVAILABLE', reason: 'DEADLINE_EXCEEDED');
    } on IOException {
      throw const BackendCallError('UNAVAILABLE');
    } on FormatException {
      throw const BackendCallError('INTERNAL');
    }

    final Object? error = reply['error'];
    if (error is Map) {
      final Object? status = error['status'];
      // The protocol's statuses are the callable codes in upper case with
      // underscores: FAILED_PRECONDITION is failed-precondition.
      final String code = status is String
          ? status.toLowerCase().replaceAll('_', '-')
          : 'unknown';
      throw FirebaseBackendCalls.backendErrorOf(code, error['details']);
    }
    final Object? result = reply['result'];
    return result is Map ? Map<String, Object?>.from(result) : {};
  }
}
