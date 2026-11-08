import 'dart:io';

import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/network/https_client.dart';

/// An [HttpsGetClient] that answers from [respond] and records each request,
/// so no test reaches a real site (`CODING_STANDARDS.md` section 10).
final class FakeHttpsGetClient implements HttpsGetClient {
  /// Creates the fake.
  FakeHttpsGetClient(this.respond);

  /// The answer to one request.
  final Result<HttpsResponse> Function(Uri uri) respond;

  /// Every address requested, in order.
  final List<Uri> requests = <Uri>[];

  @override
  Future<Result<HttpsResponse>> get(Uri uri) async {
    if (!uri.isScheme('https')) {
      throw ArgumentError.value(uri, 'uri', 'Only HTTPS is allowed');
    }
    requests.add(uri);
    return respond(uri);
  }
}

/// A JSON response with [body], as WordPress sends it.
Result<HttpsResponse> jsonResponse(
  String body, {
  int status = 200,
  Map<String, String> headers = const <String, String>{},
}) {
  return Ok<HttpsResponse>(
    HttpsResponse(
      statusCode: status,
      body: body,
      headers: <String, String>{
        'content-type': 'application/json; charset=UTF-8',
        ...headers,
      },
    ),
  );
}

/// An HTML response with [body], such as a firewall page.
Result<HttpsResponse> htmlResponse(String body, {int status = 200}) {
  return Ok<HttpsResponse>(
    HttpsResponse(
      statusCode: status,
      body: body,
      headers: const <String, String>{
        'content-type': 'text/html; charset=UTF-8',
      },
    ),
  );
}

/// Reads a WordPress fixture under `test/fixtures/wordpress/` as text.
/// Tests run from `app/`.
String wordPressFixture(String name) =>
    File('test/fixtures/wordpress/$name').readAsStringSync();
