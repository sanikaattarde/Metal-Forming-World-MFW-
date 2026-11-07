import 'dart:async';
import 'dart:io';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/domain/download_ports.dart';

// Spike T-02.4: an HTTP transport that resumes with a byte range. The real
// mechanism waits for DEC-020, so the grant's access here is a plain URL.

/// [FileTransport] over `dart:io` HTTP, resuming with a `Range` request.
///
/// The grant's [IssueFileGrant.access] must be a [Uri] in this spike. A
/// broken connection or a stall longer than [timeout] fails with `network`
/// or `timeout`, both retryable. When the server ignores the range and sends
/// the whole file, the bytes before the offset are skipped, so the chunks
/// still start at the offset.
final class HttpFileTransport implements FileTransport {
  /// Creates the transport.
  HttpFileTransport({HttpClient? client, this.timeout = _defaultTimeout})
    : _client = client ?? HttpClient();

  static const Duration _defaultTimeout = Duration(seconds: 20);

  final HttpClient _client;

  /// The longest wait for the connection or for the next chunk.
  final Duration timeout;

  @override
  Future<Result<void>> fetch(
    IssueFileGrant grant, {
    required int offset,
    required Future<Result<void>> Function(List<int> chunk) onChunk,
  }) async {
    final Object access = grant.access;
    if (access is! Uri) {
      return const Err<void>(AppFailure(FailureCode.invalidResponse));
    }
    try {
      final HttpClientRequest request = await _client
          .getUrl(access)
          .timeout(timeout);
      if (offset > 0) {
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
      }
      final HttpClientResponse response = await request.close().timeout(
        timeout,
      );
      final int skip;
      switch (response.statusCode) {
        case HttpStatus.partialContent:
          final String? range = response.headers.value(
            HttpHeaders.contentRangeHeader,
          );
          if (range == null || !range.startsWith('bytes $offset-')) {
            await response.drain<void>();
            return const Err<void>(AppFailure(FailureCode.invalidResponse));
          }
          skip = 0;
        case HttpStatus.ok:
          skip = offset;
        case HttpStatus.notFound:
          await response.drain<void>();
          return const Err<void>(AppFailure(FailureCode.notFound));
        case HttpStatus.forbidden:
          await response.drain<void>();
          return const Err<void>(AppFailure(FailureCode.forbidden));
        default:
          await response.drain<void>();
          return const Err<void>(
            AppFailure(FailureCode.serviceUnavailable, retryable: true),
          );
      }
      int toSkip = skip;
      await for (final List<int> data in response.timeout(timeout)) {
        List<int> chunk = data;
        if (toSkip > 0) {
          if (chunk.length <= toSkip) {
            toSkip -= chunk.length;
            continue;
          }
          chunk = chunk.sublist(toSkip);
          toSkip = 0;
        }
        final Result<void> written = await onChunk(chunk);
        if (written is Err<void>) {
          return written;
        }
      }
      return const Ok<void>(null);
    } on TimeoutException {
      return const Err<void>(AppFailure(FailureCode.timeout, retryable: true));
    } on IOException {
      return const Err<void>(AppFailure(FailureCode.network, retryable: true));
    }
  }
}
