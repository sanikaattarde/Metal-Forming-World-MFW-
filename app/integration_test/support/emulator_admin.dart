import 'dart:convert';
import 'dart:io';

/// Writes to the local Firestore emulator as its owner, past the access
/// rules, as the admin panel's functions would (ENV-LOCAL only, DEC-023).
/// The data is synthetic (DEC-024).
final class EmulatorAdmin {
  /// Creates the writer for the emulator at [host].
  EmulatorAdmin({required this.host, this.port = 8080});

  /// The emulator's host as the device sees it.
  final String host;

  /// The Firestore emulator's port (`backend/firebase.json`).
  final int port;

  static const String _project = 'demo-mfw';

  final HttpClient _http = HttpClient();

  Uri _uri(String path) => Uri.parse('http://$host:$port$path');

  /// Deletes every document in the emulator.
  Future<void> clear() => _send(
    'DELETE',
    _uri('/emulator/v1/projects/$_project/databases/(default)/documents'),
  );

  /// Writes [fields] to the document at [path], replacing it.
  Future<void> put(String path, Map<String, Object?> fields) => _send(
    'PATCH',
    _uri('/v1/projects/$_project/databases/(default)/documents/$path'),
    body: <String, Object?>{
      'fields': <String, Object?>{
        for (final MapEntry<String, Object?> entry in fields.entries)
          entry.key: _value(entry.value),
      },
    },
  );

  Future<void> _send(
    String method,
    Uri uri, {
    Map<String, Object?>? body,
  }) async {
    final HttpClientRequest request = await _http.openUrl(method, uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final HttpClientResponse response = await request.close();
    final String text = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 300) {
      throw StateError('emulator $method ${uri.path}: $text');
    }
  }

  static Map<String, Object?> _value(Object? value) => switch (value) {
    null => <String, Object?>{'nullValue': null},
    final bool flag => <String, Object?>{'booleanValue': flag},
    final int number => <String, Object?>{'integerValue': '$number'},
    final String text => <String, Object?>{'stringValue': text},
    final List<Object?> list => <String, Object?>{
      'arrayValue': <String, Object?>{
        'values': <Object?>[for (final Object? item in list) _value(item)],
      },
    },
    _ => throw ArgumentError.value(value, 'value', 'not supported'),
  };
}
