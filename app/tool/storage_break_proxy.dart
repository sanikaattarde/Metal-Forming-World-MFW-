// Spike T-02.4 on the Firebase Storage emulator (DEC-003, DEC-020): a proxy
// in front of the emulator's download link that breaks the connection at
// set points (FX-NET-07). It answers the same control endpoints as
// tool/range_server.dart, so integration_test/download_resume_test.dart
// runs against it unchanged. Run on the developer's machine, never deployed:
//
//   dart run tool/storage_break_proxy.dart --port=8098 \
//     --upstream='http://127.0.0.1:9199/v0/b/<bucket>/o/<path>?alt=media&token=<t>' \
//     --size=150000000 --hash=sha256-<hex>
//
// GET /meta            {"sizeBytes": n, "contentHash": "sha256-..."}
// GET /reset?cuts=a,b  forget the log, and break the next transfers that
//                      cross the fractions a, b of the file (each once)
// GET /issue           the emulator's answer, with the Range header passed on
// GET /issue?norange=1 the emulator's answer to a request without Range
// GET /stats           the requests served since the last reset
//
// The status, Content-Range and the bytes come from the emulator; the proxy
// only cuts the connection. The file in the emulator is synthetic (DEC-024).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final Map<String, String> options = <String, String>{
    for (final String arg in args)
      if (arg.startsWith('--') && arg.contains('='))
        arg.substring(2, arg.indexOf('=')): arg.substring(arg.indexOf('=') + 1),
  };
  final int port = int.parse(options['port'] ?? '8098');
  final Uri upstream = Uri.parse(options['upstream']!);
  final int size = int.parse(options['size']!);
  final String hash = options['hash']!;
  final _Proxy proxy = _Proxy(upstream, size, hash);
  final HttpServer http = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('STORAGE_PROXY ready port=$port size=$size hash=$hash');
  await for (final HttpRequest request in http) {
    unawaited(proxy.handle(request));
  }
}

final class _Proxy {
  _Proxy(this.upstream, this.size, this.hash);

  final Uri upstream;
  final int size;
  final String hash;
  final HttpClient _client = HttpClient();
  final List<int> _cuts = <int>[];
  final List<Map<String, Object?>> _log = <Map<String, Object?>>[];

  Future<void> handle(HttpRequest request) async {
    final HttpResponse response = request.response;
    switch (request.uri.path) {
      case '/meta':
        _json(response, <String, Object?>{
          'sizeBytes': size,
          'contentHash': hash,
        });
      case '/reset':
        _cuts
          ..clear()
          ..addAll(
            (request.uri.queryParameters['cuts'] ?? '')
                .split(',')
                .where((String part) => part.trim().isNotEmpty)
                .map((String part) => (double.parse(part) * size).round()),
          );
        _log.clear();
        _json(response, <String, Object?>{'cuts': _cuts});
      case '/stats':
        _json(response, <String, Object?>{
          'requests': _log,
          'totalSent': _log.fold<int>(
            0,
            (int sum, Map<String, Object?> entry) =>
                sum + (entry['sent']! as int),
          ),
        });
      case '/issue':
        await _forward(request);
      default:
        response.statusCode = HttpStatus.notFound;
        await response.close();
    }
  }

  void _json(HttpResponse response, Map<String, Object?> body) {
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(body));
    response.close();
  }

  Future<void> _forward(HttpRequest request) async {
    final HttpResponse response = request.response;
    final bool ignoreRange = request.uri.queryParameters['norange'] == '1';
    final String? rangeHeader = ignoreRange
        ? null
        : request.headers.value(HttpHeaders.rangeHeader);

    final HttpClientRequest out = await _client.getUrl(upstream);
    if (rangeHeader != null) {
      out.headers.set(HttpHeaders.rangeHeader, rangeHeader);
    }
    final HttpClientResponse answer = await out.close();

    int start = 0;
    final String? contentRange = answer.headers.value(
      HttpHeaders.contentRangeHeader,
    );
    if (contentRange != null) {
      final RegExpMatch? match = RegExp(r'^bytes (\d+)-')
          .firstMatch(contentRange);
      if (match != null) {
        start = int.parse(match.group(1)!);
      }
      response.headers.set(HttpHeaders.contentRangeHeader, contentRange);
    }
    response.statusCode = answer.statusCode;
    if (answer.contentLength >= 0) {
      response.headers.contentLength = answer.contentLength;
    }
    final String? acceptRanges = answer.headers.value(
      HttpHeaders.acceptRangesHeader,
    );
    if (acceptRanges != null) {
      response.headers.set(HttpHeaders.acceptRangesHeader, acceptRanges);
    }

    int? cut;
    for (final int point in _cuts) {
      if (point > start) {
        cut = point;
        break;
      }
    }
    final Map<String, Object?> entry = <String, Object?>{
      'range': rangeHeader,
      'start': start,
      'status': answer.statusCode,
      'sent': 0,
      'cut': false,
    };
    _log.add(entry);

    final Socket socket = await response.detachSocket();
    int position = start;
    final Completer<void> done = Completer<void>();
    late final StreamSubscription<List<int>> subscription;
    subscription = answer.listen(
      (List<int> data) {
        List<int> part = data;
        final int? point = cut;
        final bool cutsHere = point != null && position + part.length >= point;
        if (cutsHere) {
          part = part.sublist(0, point - position);
        }
        socket.add(part);
        position += part.length;
        entry['sent'] = (entry['sent']! as int) + part.length;
        if (cutsHere) {
          _cuts.remove(point);
          entry['cut'] = true;
          subscription.pause();
          socket.flush().whenComplete(() {
            socket.destroy();
            unawaited(subscription.cancel());
            if (!done.isCompleted) {
              done.complete();
            }
          });
        }
      },
      onError: (Object error) {
        entry['upstreamError'] = '$error';
        socket.destroy();
        if (!done.isCompleted) {
          done.complete();
        }
      },
      onDone: () async {
        try {
          await socket.flush();
          await socket.close();
        } on SocketException {
          entry['clientClosed'] = true;
          socket.destroy();
        }
        if (!done.isCompleted) {
          done.complete();
        }
      },
      cancelOnError: true,
    );
    unawaited(
      socket.done.catchError((Object _) {
        entry['clientClosed'] = true;
        unawaited(subscription.cancel());
        if (!done.isCompleted) {
          done.complete();
        }
      }),
    );
    await done.future;
  }
}
