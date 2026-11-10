import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../../fakes/fake_connectivity_service.dart';

/// A folder in the system's temporary space standing in for the platform's
/// issue folder.
final class TempIssueStorage implements IssueStorage {
  TempIssueStorage(this.directory, {this.free = 1 << 40});

  Directory directory;
  int free;

  @override
  Future<Directory> issueDirectory() async => directory;

  @override
  Future<int> freeBytes(Directory directory) async => free;
}

/// Answers OP-11 from a fixed reply, or refuses with an error.
final class ScriptedBackend implements BackendCalls {
  ScriptedBackend({this.reply, this.error});

  Map<String, Object?>? reply;
  BackendCallError? error;
  final List<(String, Map<String, Object?>)> calls =
      <(String, Map<String, Object?>)>[];

  @override
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  ) async {
    calls.add((operation, data));
    final BackendCallError? refused = error;
    if (refused != null) {
      throw refused;
    }
    return reply ?? <String, Object?>{};
  }
}

/// A local server for one synthetic file, with byte ranges, and a way to
/// answer with a status or cut the connection.
final class FileServer {
  FileServer._(this._server, this.bytes);

  static Future<FileServer> start(List<int> bytes) async => FileServer._(
    await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    bytes,
  ).._serve();

  final HttpServer _server;
  final List<int> bytes;
  int? status;
  int? cutAfter;
  bool stall = false;
  final List<String?> ranges = <String?>[];

  Uri get link => Uri.parse(
    'http://${InternetAddress.loopbackIPv4.address}:'
    '${_server.port}/file?token=secret',
  );

  void _serve() {
    _server.listen((HttpRequest request) async {
      final String? range = request.headers.value(HttpHeaders.rangeHeader);
      ranges.add(range);
      final int? set = status;
      if (set != null) {
        request.response.statusCode = set;
        await request.response.close();
        return;
      }
      int start = 0;
      if (range != null) {
        start = int.parse(range.substring(6, range.length - 1));
        request.response.statusCode = 206;
      }
      final List<int> body = bytes.sublist(start);
      request.response.contentLength = body.length;
      if (stall) {
        request.response.add(body.sublist(0, 10));
        await request.response.flush();
        return; // Never finishes.
      }
      final int? cut = cutAfter;
      if (cut != null) {
        // The headers promise the whole file; the connection then drops.
        final Socket socket = await request.response.detachSocket();
        socket.add(body.sublist(0, cut));
        await socket.flush();
        socket.destroy();
        return;
      }
      request.response.add(body);
      await request.response.close();
    });
  }

  Future<void> close() => _server.close(force: true);
}

List<int> syntheticBytes(int length) =>
    List<int>.generate(length, (int i) => (i * 31 + 7) & 0xff);

IssueFileGrant grantFor(Uri link, List<int> bytes, {String id = 'fx-iss-01'}) =>
    IssueFileGrant(
      issueId: id,
      access: link,
      expiresAt: DateTime.utc(2030),
      sizeBytes: bytes.length,
      contentHash: sha256.convert(bytes).toString(),
      revision: 1,
    );

void main() {
  group('FunctionsIssueFileService over OP-11 [MOD06-P2-T02, IC-02]', () {
    final Map<String, Object?> ok = <String, Object?>{
      'url': 'https://storage.example/file?sig=1',
      'expires_at': 1893456000000,
      'revision': 3,
      'size_bytes': 800000,
      'checksum_sha256': 'AB' * 32,
    };

    test('asks for the issue and reads the grant', () async {
      final ScriptedBackend backend = ScriptedBackend(reply: ok);
      final Result<IssueFileGrant> result = await FunctionsIssueFileService(
        backend,
      ).requestIssueFile('fx-iss-01');
      final IssueFileGrant grant = (result as Ok<IssueFileGrant>).value;
      expect(backend.calls.single.$1, 'getIssueFile');
      expect(backend.calls.single.$2, <String, Object?>{
        'issue_id': 'fx-iss-01',
      });
      expect(grant.access, Uri.parse('https://storage.example/file?sig=1'));
      expect(grant.expiresAt, DateTime.utc(2030));
      expect(grant.revision, 3);
      expect(grant.sizeBytes, 800000);
      expect(grant.contentHash, 'ab' * 32);
    });

    for (final String field in <String>[
      'url',
      'expires_at',
      'revision',
      'size_bytes',
      'checksum_sha256',
    ]) {
      test('a reply without $field is invalidResponse [FR-READ-010]', () async {
        final Result<IssueFileGrant> result = await FunctionsIssueFileService(
          ScriptedBackend(reply: Map<String, Object?>.of(ok)..remove(field)),
        ).requestIssueFile('fx-iss-01');
        expect(
          (result as Err<IssueFileGrant>).failure.code,
          FailureCode.invalidResponse,
        );
      });
    }

    for (final (String category, String? reason, FailureCode code)
        in <(String, String?, FailureCode)>[
          ('UNAUTHENTICATED', null, FailureCode.unauthenticated),
          (
            'FAILED_PRECONDITION',
            'EMAIL_NOT_VERIFIED',
            FailureCode.emailNotVerified,
          ),
          (
            'FAILED_PRECONDITION',
            'PROFILE_INCOMPLETE',
            FailureCode.profileIncomplete,
          ),
          ('FAILED_PRECONDITION', 'ISSUE_NOT_AVAILABLE', FailureCode.notFound),
          ('FAILED_PRECONDITION', 'NO_CURRENT_FILE', FailureCode.notFound),
          ('GONE', 'GONE', FailureCode.notFound),
          ('UNAVAILABLE', null, FailureCode.serviceUnavailable),
        ]) {
      test('$category/${reason ?? '-'} is ${code.name}', () async {
        final Result<IssueFileGrant> result = await FunctionsIssueFileService(
          ScriptedBackend(error: BackendCallError(category, reason: reason)),
        ).requestIssueFile('fx-iss-01');
        expect((result as Err<IssueFileGrant>).failure.code, code);
      });
    }
  });

  group('HttpFileTransport [MOD06-P2-T02, NFR-SEC-001]', () {
    final List<int> bytes = syntheticBytes(300000);
    late FileServer server;
    late HttpFileTransport transport;

    setUp(() async {
      server = await FileServer.start(bytes);
      transport = HttpFileTransport(
        idleTimeout: const Duration(milliseconds: 500),
        plainHttpHosts: <String>{InternetAddress.loopbackIPv4.address},
      );
    });

    tearDown(() => server.close());

    Future<(Result<void>, List<int>)> fetch({int offset = 0}) async {
      final List<int> got = <int>[];
      final Result<void> result = await transport.fetch(
        grantFor(server.link, bytes),
        offset: offset,
        onChunk: (List<int> chunk) async {
          got.addAll(chunk);
          return const Ok<void>(null);
        },
      );
      return (result, got);
    }

    test('fetches the whole file in chunks', () async {
      final (Result<void> result, List<int> got) = await fetch();
      expect(result, isA<Ok<void>>());
      expect(got, bytes);
      expect(server.ranges, <String?>[null]);
    });

    test('from an offset it asks for the rest of the file', () async {
      final (Result<void> result, List<int> got) = await fetch(offset: 100000);
      expect(result, isA<Ok<void>>());
      expect(got, bytes.sublist(100000));
      expect(server.ranges, <String?>['bytes=100000-']);
    });

    test('refuses plain HTTP to a host that is not an emulator', () async {
      final Result<void> result = await HttpFileTransport().fetch(
        grantFor(server.link, bytes),
        offset: 0,
        onChunk: (List<int> _) async => const Ok<void>(null),
      );
      expect((result as Err<void>).failure.code, FailureCode.invalidResponse);
      expect(server.ranges, isEmpty);
    });

    for (final (int status, FailureCode code, bool retryable)
        in <(int, FailureCode, bool)>[
          (403, FailureCode.forbidden, true),
          (401, FailureCode.forbidden, true),
          (404, FailureCode.notFound, false),
          (503, FailureCode.serviceUnavailable, true),
          (418, FailureCode.invalidResponse, false),
        ]) {
      test('status $status is ${code.name}', () async {
        server.status = status;
        final (Result<void> result, List<int> _) = await fetch();
        final AppFailure failure = (result as Err<void>).failure;
        expect(failure.code, code);
        expect(failure.retryable, retryable);
        expect(failure.detail, 'status $status');
      });
    }

    test('a cut connection is a retryable network failure '
        '[FX-NET, FR-DL-006]', () async {
      server.cutAfter = 50000;
      final (Result<void> result, List<int> got) = await fetch();
      final AppFailure failure = (result as Err<void>).failure;
      expect(failure.code, FailureCode.network);
      expect(failure.retryable, isTrue);
      expect(got.length, lessThan(bytes.length));
    });

    test('a stalled transfer times out', () async {
      server.stall = true;
      final (Result<void> result, List<int> _) = await fetch();
      expect((result as Err<void>).failure.code, FailureCode.timeout);
    });

    test(
      'a chunk that is refused stops the transfer with its failure',
      () async {
        final Result<void> result = await transport.fetch(
          grantFor(server.link, bytes),
          offset: 0,
          onChunk: (List<int> _) async =>
              const Err<void>(AppFailure(FailureCode.cancelled)),
        );
        expect((result as Err<void>).failure.code, FailureCode.cancelled);
      },
    );

    test('the link never appears in a failure', () async {
      server.status = 403;
      final (Result<void> result, List<int> _) = await fetch();
      expect((result as Err<void>).failure.detail, isNot(contains('secret')));
    });
  });

  group('IoFileStore [MOD06-P2-T02, CODING_STANDARDS 8.2]', () {
    late Directory temp;
    late TempIssueStorage storage;
    late IoFileStore store;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('mfw-store-');
      storage = TempIssueStorage(temp, free: 12345);
      store = IoFileStore(storage);
    });

    tearDown(() => temp.delete(recursive: true));

    test('keeps a partial file apart until it is promoted', () async {
      await store.appendPartial('a.pdf.part', <int>[1, 2, 3]);
      await store.appendPartial('a.pdf.part', <int>[4]);
      expect(await store.partialLength('a.pdf.part'), 4);
      expect(await store.completeFiles(), isEmpty);
      expect(
        await store
            .readPartial('a.pdf.part')
            .expand((List<int> c) => c)
            .toList(),
        <int>[1, 2, 3, 4],
      );

      final String path = (await store.promotePartial(
        'a.pdf.part',
        'a.pdf',
      ) as Ok<String>).value;
      expect(path, '${temp.path}/a.pdf');
      expect(await store.fileLength(path), 4);
      expect(await store.completeFiles(), <String>[path]);
      expect(await store.partialLength('a.pdf.part'), 0);
    });

    test('deletes partial and complete files', () async {
      await store.appendPartial('b.pdf.part', <int>[1]);
      await store.deletePartial('b.pdf.part');
      expect(await store.partialLength('b.pdf.part'), 0);
      await File('${temp.path}/c.pdf').writeAsBytes(<int>[1, 2]);
      await store.deleteFile('${temp.path}/c.pdf');
      expect(await store.fileLength('${temp.path}/c.pdf'), isNull);
    });

    test('reports the platform free space', () async {
      expect(await store.freeBytes(), 12345);
    });
  });

  group('JsonDownloadRegistry [RS DATA-013]', () {
    late Directory temp;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('mfw-registry-');
    });

    tearDown(() => temp.delete(recursive: true));

    DownloadedIssue copy(String issue, String owner, Directory directory) =>
        DownloadedIssue(
          issueId: issue,
          ownerUserId: owner,
          fileRevision: 2,
          localFile: LocalIssueFile(
            issueId: issue,
            fileRevision: 2,
            path: '${directory.path}/issue-$issue-r2.pdf',
          ),
          sizeBytes: 10,
          downloadedAt: DateTime.utc(2026, 11, 10, 9),
          contentHash: 'ab' * 32,
        );

    test('keeps rows across a restart and rebuilds paths in a moved '
        'folder', () async {
      final JsonDownloadRegistry first = JsonDownloadRegistry(
        TempIssueStorage(temp),
      );
      await first.save(copy('a', 'reader-a', temp));
      await first.save(copy('b', 'reader-b', temp));
      await first.remove(ownerUserId: 'reader-b', issueId: 'b');

      final Directory moved = await temp.rename('${temp.path}-moved');
      temp = moved;
      final List<DownloadedIssue> rows = await JsonDownloadRegistry(
        TempIssueStorage(moved),
      ).load();
      expect(rows, hasLength(1));
      expect(rows.single.issueId, 'a');
      expect(rows.single.ownerUserId, 'reader-a');
      expect(rows.single.localFile.path, '${moved.path}/issue-a-r2.pdf');
      expect(rows.single.downloadedAt, DateTime.utc(2026, 11, 10, 9));
      expect(rows.single.contentHash, 'ab' * 32);
    });

    test('an unreadable registry counts as empty', () async {
      await File('${temp.path}/registry.json').writeAsString('{not json');
      expect(
        await JsonDownloadRegistry(TempIssueStorage(temp)).load(),
        isEmpty,
      );
    });

    test('a row with a path in its file name is ignored', () async {
      await File('${temp.path}/registry.json').writeAsString(
        jsonEncode(<String, Object?>{
          'version': 1,
          'rows': <Object?>[
            <String, Object?>{
              'issue_id': 'a',
              'owner_user_id': 'r',
              'file_revision': 1,
              'file_name': '../escape.pdf',
              'size_bytes': 1,
              'downloaded_at': '2026-11-10T00:00:00Z',
              'content_hash': 'x',
            },
          ],
        }),
      );
      expect(
        await JsonDownloadRegistry(TempIssueStorage(temp)).load(),
        isEmpty,
      );
    });
  });

  group('IssueTitles [NFR-OFF-001]', () {
    test('remembers titles across a restart', () async {
      final Directory temp = await Directory.systemTemp.createTemp('mfw-t-');
      addTearDown(() => temp.delete(recursive: true));
      await IssueTitles(TempIssueStorage(temp)).remember('a', 'Title A');
      expect(await IssueTitles(TempIssueStorage(temp)).load(), <String, String>{
        'a': 'Title A',
      });
    });
  });

  group('Sha256HashVerifier', () {
    test('gives lower case hexadecimal SHA-256', () async {
      expect(
        await const Sha256HashVerifier().hashOf(
          Stream<List<int>>.fromIterable(<List<int>>[
            utf8.encode('a'),
            utf8.encode('bc'),
          ]),
        ),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });
  });

  group('IssueDownloadManager on the real adapters [MOD06-P2-T02, AC-4.1]', () {
    test('downloads a file over HTTP into the store, checks it and lists it '
        'after a restart', () async {
      final Directory temp = await Directory.systemTemp.createTemp('mfw-e2e-');
      addTearDown(() => temp.delete(recursive: true));
      final List<int> bytes = syntheticBytes(250000);
      final FileServer server = await FileServer.start(bytes);
      addTearDown(server.close);

      IssueDownloadManager manager() => IssueDownloadManager(
        files: FixedGrant(grantFor(server.link, bytes)),
        transport: HttpFileTransport(
          plainHttpHosts: <String>{InternetAddress.loopbackIPv4.address},
        ),
        store: IoFileStore(TempIssueStorage(temp)),
        verifier: const Sha256HashVerifier(),
        registry: JsonDownloadRegistry(TempIssueStorage(temp)),
        connectivity: FakeConnectivityService(),
        currentUserId: () => 'fx-usr-01',
      );

      final IssueDownloadManager first = manager();
      final List<DownloadStatus> seen = <DownloadStatus>[];
      final StreamSubscription<DownloadStatus> watching = first
          .watch('fx-iss-01')
          .listen(seen.add);
      expect(
        await first.start('fx-iss-01', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      await pumpEventQueue();
      await watching.cancel();
      expect(seen.whereType<InProgress>(), isNotEmpty);
      expect(seen.last, isA<Downloaded>());

      final List<DownloadedIssue> listed = await manager().listDownloaded();
      expect(listed.single.issueId, 'fx-iss-01');
      expect(await File(listed.single.localFile.path).readAsBytes(), bytes);
    });

    test(
      'a file whose hash does not match is not kept [FR-STATE-006]',
      () async {
        final Directory temp = await Directory.systemTemp.createTemp(
          'mfw-bad-',
        );
        addTearDown(() => temp.delete(recursive: true));
        final List<int> bytes = syntheticBytes(1000);
        final FileServer server = await FileServer.start(bytes);
        addTearDown(server.close);
        final IssueFileGrant good = grantFor(server.link, bytes);
        final IssueDownloadManager manager = IssueDownloadManager(
          files: FixedGrant(
            IssueFileGrant(
              issueId: good.issueId,
              access: good.access,
              expiresAt: good.expiresAt,
              sizeBytes: good.sizeBytes,
              contentHash: '00' * 32,
              revision: 1,
            ),
          ),
          transport: HttpFileTransport(
            plainHttpHosts: <String>{InternetAddress.loopbackIPv4.address},
          ),
          store: IoFileStore(TempIssueStorage(temp)),
          verifier: const Sha256HashVerifier(),
          registry: JsonDownloadRegistry(TempIssueStorage(temp)),
          connectivity: FakeConnectivityService(),
          currentUserId: () => 'fx-usr-01',
        );
        final Result<void> result = await manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );
        expect((result as Err<void>).failure.code, FailureCode.fileCorrupt);
        expect(await manager.listDownloaded(), isEmpty);
        expect(
          temp
              .listSync(recursive: true)
              .whereType<File>()
              .map((File f) => f.path),
          everyElement(isNot(endsWith('.pdf'))),
        );
      },
    );
  });
}

/// Hands out one grant.
final class FixedGrant implements IssueFileService {
  FixedGrant(this.grant);

  final IssueFileGrant grant;

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async =>
      Ok<IssueFileGrant>(grant);
}
