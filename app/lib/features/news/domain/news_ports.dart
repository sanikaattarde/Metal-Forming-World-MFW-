import 'package:mfw_app/contracts/contracts.dart';

/// One HTTP response, as the WordPress client reads it.
final class HttpResponse {
  /// Creates a response; header names are kept in lower case.
  HttpResponse({
    required this.statusCode,
    required Map<String, String> headers,
    required this.body,
  }) : headers = Map<String, String>.unmodifiable(<String, String>{
         for (final MapEntry<String, String> header in headers.entries)
           header.key.toLowerCase(): header.value,
       });

  /// HTTP status code.
  final int statusCode;

  /// Headers by lower-case name.
  final Map<String, String> headers;

  /// The body as text.
  final String body;
}

/// Reads from MFW's WordPress site over HTTPS (RS INT-WP-001). Read only;
/// it never authenticates.
///
/// The real adapter waits for a package decision and the site details
/// (OQ-39); tests use fakes over the FX-WP fixtures.
abstract interface class HttpTransport {
  /// GETs [url]. Never throws: a connection that cannot be made or breaks
  /// returns a retryable `network` failure. The client sets the timeout.
  Future<Result<HttpResponse>> get(Uri url);
}
