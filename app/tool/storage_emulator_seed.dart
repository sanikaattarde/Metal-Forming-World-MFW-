// Spike T-02.4 on the Firebase Storage emulator: uploads the same synthetic
// file that tool/range_server.dart serves (DEC-024) to the emulator, with
// the resumable protocol, and prints the download link and the hash that
// tool/storage_break_proxy.dart takes. Run on the developer's machine, with
// the emulator started from backend/:
//
//   dart run tool/storage_emulator_seed.dart --size=150000000
//
// Only the emulator is used: the owner token below is the emulator's own
// administrator token, and it means nothing to a real project.

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
  final String host = options['host'] ?? 'http://127.0.0.1:9199';
  final String bucket = options['bucket'] ?? 'demo-mfw.appspot.com';
  final String name = options['name'] ?? 'issues/synthetic-resume/1.pdf';
  final int size = int.parse(options['size'] ?? '150000000');

  final Uint8List content = _content(size);
  final String hash = 'sha256-${sha256.convert(content)}';
  final HttpClient client = HttpClient();
  const Map<String, String> owner = <String, String>{
    'Authorization': 'Bearer owner',
  };

  final HttpClientRequest start = await client.postUrl(
    Uri.parse('$host/v0/b/$bucket/o?name=${Uri.encodeQueryComponent(name)}'),
  );
  owner.forEach(start.headers.set);
  start.headers
    ..set('X-Goog-Upload-Protocol', 'resumable')
    ..set('X-Goog-Upload-Command', 'start')
    ..set('X-Goog-Upload-Header-Content-Length', '$size')
    ..set('X-Goog-Upload-Header-Content-Type', 'application/pdf')
    ..contentType = ContentType.json;
  start.write(
    jsonEncode(<String, String>{
      'name': name,
      'contentType': 'application/pdf',
    }),
  );
  final HttpClientResponse started = await start.close();
  await started.drain<void>();
  final String uploadUrl = started.headers.value('x-goog-upload-url')!;

  // The emulator refuses a single body of about 130 MB, so send 8 MB parts.
  const int part = 8 * 1024 * 1024;
  Map<String, Object?> meta = <String, Object?>{};
  for (int offset = 0; offset < size; offset += part) {
    final int end = offset + part < size ? offset + part : size;
    final HttpClientRequest upload = await client.postUrl(Uri.parse(uploadUrl));
    owner.forEach(upload.headers.set);
    upload.headers
      ..set(
        'X-Goog-Upload-Command',
        end == size ? 'upload, finalize' : 'upload',
      )
      ..set('X-Goog-Upload-Offset', '$offset')
      ..contentLength = end - offset;
    upload.add(Uint8List.sublistView(content, offset, end));
    final HttpClientResponse uploaded = await upload.close();
    final String body = await uploaded.transform(utf8.decoder).join();
    if (uploaded.statusCode != HttpStatus.ok) {
      stderr.writeln('upload failed at $offset: ${uploaded.statusCode} $body');
      exit(1);
    }
    if (end == size) {
      meta = jsonDecode(body) as Map<String, Object?>;
    }
  }
  client.close();

  final String token = (meta['downloadTokens']! as String).split(',').first;
  final String link =
      '$host/v0/b/$bucket/o/${Uri.encodeComponent(name)}'
      '?alt=media&token=$token';
  stdout
    ..writeln('SEED size=${meta['size']} hash=$hash')
    ..writeln('SEED link=$link');
}

/// The content of tool/range_server.dart: a linear congruential generator.
Uint8List _content(int size) {
  final Uint8List bytes = Uint8List(size);
  int state = 0x2545f491;
  for (int i = 0; i < size; i++) {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    bytes[i] = state >> 16;
  }
  return bytes;
}
