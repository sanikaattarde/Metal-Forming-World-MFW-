import 'dart:async';
import 'dart:io';

import 'package:mfw_app/contracts/contracts.dart';

import '../domain/download_ports.dart';

/// The [FileTransport] over HTTPS (RS NFR-SEC-001), streaming the file
/// from a grant's link (DEC-020: a short-lived signed URL) in chunks.
///
/// - Only `https` links are fetched. Plain `http` is allowed only for the
///   hosts in [plainHttpHosts], the local emulators in ENV-LOCAL (DEC-023).
/// - From a byte [offset] above 0 it asks for the rest with a `Range`
///   header and needs a 206 answer (MOD06-P2-T03).
/// - The link is never logged: a failure's detail names the status only.
/// - Failures: a broken or lost connection is `network`, a stalled one
///   `timeout`, both retryable. A refused or expired link (401, 403) is
///   `forbidden`, retryable with a new grant (rule 2). 404 and 410 are
///   `notFound`; 5xx and 429 are `serviceUnavailable`, retryable; anything
///   else, including a range the server ignored, is `invalidResponse`.
final class HttpFileTransport implements FileTransport {
  /// Creates the transport.
  HttpFileTransport({
    HttpClient? client,
    this.connectTimeout = const Duration(seconds: 15),
    this.idleTimeout = const Duration(seconds: 30),
    this.plainHttpHosts = const <String>{},
  }) : _client = client ?? HttpClient()
         ..connectionTimeout = connectTimeout;

  final HttpClient _client;

  /// How long to wait for the connection and the answer's headers.
  final Duration connectTimeout;

  /// How long the transfer may stall before it counts as broken.
  final Duration idleTimeout;

  /// Hosts reached over plain HTTP, the local emulators only.
  final Set<String> plainHttpHosts;

  @override
  Future<Result<void>> fetch(
    IssueFileGrant grant, {
    required int offset,
    required Future<Result<void>> Function(List<int> chunk) onChunk,
  }) async {
    final Object access = grant.access;
    if (access is! Uri || !_allowed(access)) {
      return const Err<void>(
        AppFailure(FailureCode.invalidResponse, detail: 'link not allowed'),
      );
    }
    try {
      final HttpClientRequest request = await _client
          .getUrl(access)
          .timeout(connectTimeout);
      request.followRedirects = true;
      if (offset > 0) {
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
      }
      final HttpClientResponse response = await request.close().timeout(
        connectTimeout,
      );
      final AppFailure? refused = _statusFailure(response.statusCode, offset);
      if (refused != null) {
        await response.drain<void>().catchError((Object _) {});
        return Err<void>(refused);
      }
      await for (final List<int> chunk in response.timeout(idleTimeout)) {
        final Result<void> taken = await onChunk(chunk);
        if (taken is Err<void>) {
          return taken;
        }
      }
      return const Ok<void>(null);
    } on TimeoutException {
      return const Err<void>(
        AppFailure(FailureCode.timeout, retryable: true, detail: 'stalled'),
      );
    } on SocketException {
      return const Err<void>(
        AppFailure(FailureCode.network, retryable: true, detail: 'socket'),
      );
    } on HandshakeException {
      return const Err<void>(
        AppFailure(FailureCode.network, retryable: true, detail: 'tls'),
      );
    } on HttpException {
      return const Err<void>(
        AppFailure(FailureCode.network, retryable: true, detail: 'http'),
      );
    }
  }

  bool _allowed(Uri link) =>
      link.scheme == 'https' ||
      (link.scheme == 'http' && plainHttpHosts.contains(link.host));

  static AppFailure? _statusFailure(int status, int offset) {
    if ((offset == 0 && status == 200) || (offset > 0 && status == 206)) {
      return null;
    }
    final String detail = 'status $status';
    return switch (status) {
      401 ||
      403 => AppFailure(FailureCode.forbidden, retryable: true, detail: detail),
      404 || 410 => AppFailure(FailureCode.notFound, detail: detail),
      429 || >= 500 => AppFailure(
        FailureCode.serviceUnavailable,
        retryable: true,
        detail: detail,
      ),
      _ => AppFailure(FailureCode.invalidResponse, detail: detail),
    };
  }
}
