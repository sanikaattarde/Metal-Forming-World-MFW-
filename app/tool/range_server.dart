// Spike T-02.4: a local file server that answers byte-range requests and
// breaks the connection at set points (FX-NET-07). Run on the developer's
// machine, never deployed:
//
//   dart run tool/range_server.dart --port=8099 --size=150000000
//
// GET /meta            {"sizeBytes": n, "contentHash": "sha256-..."}
// GET /reset?cuts=a,b  forget the log, and break the next transfers that
//                      cross the fractions a, b of the file (each once)
// GET /issue           the file; honours "Range: bytes=n-"
// GET /issue?norange=1 the file, ignoring any Range header
// GET /stats           the requests served since the last reset
//
// The content is synthetic and deterministic (a linear congruential
// generator), so no MFW file is involved (DEC-024).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

Future<void> main(List<String> args) async {
  final Map<String, String> options = <String, String>{
    for (final String arg in args)
      if (arg.startsWith('--') && arg.contains('='))
        arg.substring(2, arg.indexOf('=')): arg.substring(arg.indexOf('=') + 1),
  };
  final int port = int.parse(options['port'] ?? '8099');
  final int size = int.parse(options['size'] ?? '150000000');
  final Uint8List content = _content(size);
  final String hash = 'sha256-${sha256.convert(content)}';
  final _Server server = _Server(content, hash);
  final HttpServer http = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('RANGE_SERVER ready port=$port size=$size hash=$hash');
  await for (final HttpRequest request in http) {
    await server.handle(request);
  }
}

Uint8List _content(int size) {
  final Uint8List bytes = Uint8List(size);
  int state = 0x2545f491;
  for (int i = 0; i < size; i++) {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    bytes[i] = state >> 16;
  }
  return bytes;
}

final class _Server {
  _Server(this.content, this.hash);

  final Uint8List content;
  final String hash;
  final List<int> _cuts = <int>[];
  final List<Map<String, Object?>> _log = <Map<String, Object?>>[];

  static const int _chunk = 64 * 1024;

  Future<void> handle(HttpRequest request) async {
    final HttpResponse response = request.response;
    switch (request.uri.path) {
      case '/meta':
        _json(response, <String, Object?>{
          'sizeBytes': content.length,
          'contentHash': hash,
        });
      case '/reset':
        _cuts
          ..clear()
          ..addAll(
            (request.uri.queryParameters['cuts'] ?? '')
                .split(',')
                .where((String part) => part.trim().isNotEmpty)
                .map(
                  (String part) =>
                      (double.parse(part) * content.length).round(),
                ),
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
        await _serveFile(request);
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

  Future<void> _serveFile(HttpRequest request) async {
    final HttpResponse response = request.response;
    final bool ignoreRange = request.uri.queryParameters['norange'] == '1';
    final String? rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    int start = 0;
    if (!ignoreRange && rangeHeader != null) {
      final RegExpMatch? match = RegExp(r'^bytes=(\d+)-$')
          .firstMatch(rangeHeader);
      if (match == null || int.parse(match.group(1)!) >= content.length) {
        response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        await response.close();
        return;
      }
      start = int.parse(match.group(1)!);
      response.statusCode = HttpStatus.partialContent;
      response.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-${content.length - 1}/${content.length}',
      );
    }
    response.headers.contentLength = content.length - start;
    response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    int? cut;
    for (final int point in _cuts) {
      if (point > start) {
        cut = point;
        break;
      }
    }
    final Map<String, Object?> entry = <String, Object?>{
      'range': ignoreRange ? null : rangeHeader,
      'start': start,
      'status': response.statusCode,
      'sent': 0,
      'cut': false,
    };
    _log.add(entry);
    final Socket socket = await response.detachSocket();
    int position = start;
    try {
      while (position < content.length) {
        int end = position + _chunk;
        if (end > content.length) {
          end = content.length;
        }
        if (cut != null && end >= cut) {
          end = cut;
        }
        socket.add(Uint8List.sublistView(content, position, end));
        entry['sent'] = (entry['sent']! as int) + (end - position);
        position = end;
        await socket.flush();
        if (cut != null && position == cut) {
          _cuts.remove(cut);
          entry['cut'] = true;
          socket.destroy();
          return;
        }
      }
      await socket.close();
    } on SocketException {
      entry['clientClosed'] = true;
      socket.destroy();
    }
  }
}
