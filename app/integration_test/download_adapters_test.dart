// MOD06-P2-T02 on a device: the real download adapters, the `mfw/storage`
// platform channel, the file system and the SHA-256 check. The emulators'
// `getIssueFile` hands out a link that opens nothing (grantIssuer.ts), so
// the grant here points at a server inside the test, serving a synthetic
// file (DEC-024). The refusals of OP-11 are unit-tested.
//
// Run from `app/`:
//   flutter test integration_test/download_adapters_test.dart -d <id>
import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/core/network/connectivity_service.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

const String _host = '127.0.0.1';

List<int> synthetic(int length) =>
    List<int>.generate(length, (int i) => (i * 131 + 17) & 0xff);

final class FixedGrant implements IssueFileService {
  FixedGrant(this.grant);

  final IssueFileGrant grant;

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async =>
      Ok<IssueFileGrant>(grant);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final List<int> bytes = synthetic(5 * 1000 * 1000);
  late HttpServer server;

  /// When set, the next answer drops the connection after this many bytes.
  int? cutAfter;

  /// The `Range` header of each request, in order.
  final List<String?> ranges = <String?>[];

  setUpAll(() async {
    server = await HttpServer.bind(_host, 0);
    server.listen((HttpRequest request) async {
      final String? range = request.headers.value(HttpHeaders.rangeHeader);
      ranges.add(range);
      int start = 0;
      if (range != null) {
        start = int.parse(range.substring(6, range.length - 1));
        request.response.statusCode = HttpStatus.partialContent;
      }
      final List<int> body = bytes.sublist(start);
      request.response.contentLength = body.length;
      final int? cut = cutAfter;
      if (cut != null) {
        cutAfter = null;
        final Socket socket = await request.response.detachSocket();
        socket.add(body.sublist(0, cut));
        await socket.flush();
        socket.destroy();
        return;
      }
      request.response.add(body);
      await request.response.close();
    });
  });

  tearDownAll(() => server.close(force: true));

  IssueFileGrant grant({String? hash}) => IssueFileGrant(
    issueId: 'fx-iss-it',
    access: Uri.parse('http://$_host:${server.port}/file'),
    expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
    sizeBytes: bytes.length,
    contentHash: hash ?? sha256.convert(bytes).toString(),
    revision: 1,
  );

  IssueDownloadManager manager(IssueFileGrant given, IssueStorage storage) =>
      IssueDownloadManager(
        files: FixedGrant(given),
        transport: HttpFileTransport(plainHttpHosts: <String>{_host}),
        store: IoFileStore(storage),
        verifier: const Sha256HashVerifier(),
        registry: JsonDownloadRegistry(storage),
        connectivity: PluginConnectivityService(),
        currentUserId: () => 'fx-usr-it',
      );

  test('the platform gives a private, backed-up-free folder and the free '
      'space [CODING_STANDARDS 8.2, FR-STATE-004]', () async {
    final PlatformIssueStorage storage = PlatformIssueStorage();
    final Directory directory = await storage.issueDirectory();
    expect(await directory.exists(), isTrue);
    expect(
      directory.path,
      Platform.isIOS
          ? endsWith('/Library/Application Support/issues')
          : endsWith('/no_backup/issues'),
    );
    expect(await storage.freeBytes(directory), greaterThan(bytes.length));
  });

  test('downloads, checks and keeps a copy that a restart still lists, then '
      'deletes it [AC-4.1, AC-4.6, AC-4.7]', () async {
    final PlatformIssueStorage storage = PlatformIssueStorage();
    final IssueDownloadManager first = manager(grant(), storage);
    final List<DownloadStatus> seen = <DownloadStatus>[];
    final StreamSubscription<DownloadStatus> watching = first
        .watch('fx-iss-it')
        .listen(seen.add);
    final Result<void> started = await first.start(
      'fx-iss-it',
      mobileDataAccepted: true,
    );
    await Future<void>.delayed(Duration.zero);
    await watching.cancel();
    expect(started, isA<Ok<void>>());
    expect(seen.whereType<InProgress>(), isNotEmpty);
    expect(seen.last, isA<Downloaded>());

    final IssueDownloadManager restarted = manager(grant(), storage);
    final List<DownloadedIssue> listed = await restarted.listDownloaded();
    expect(listed.single.issueId, 'fx-iss-it');
    final LocalIssueFile file =
        (await restarted.openLocal('fx-iss-it') as Ok<LocalIssueFile>).value;
    expect(await File(file.path).length(), bytes.length);

    expect(await restarted.delete('fx-iss-it'), isA<Ok<void>>());
    expect(await File(file.path).exists(), isFalse);
    expect(await manager(grant(), storage).listDownloaded(), isEmpty);
  });

  test('a connection cut mid-file resumes from the bytes held with a byte '
      'range, and the file passes its check [MOD06-P2-T03, FR-DL-006, '
      'AC-4.3]', () async {
    final PlatformIssueStorage storage = PlatformIssueStorage();
    final IssueDownloadManager downloads = IssueDownloadManager(
      files: FixedGrant(grant()),
      transport: HttpFileTransport(plainHttpHosts: <String>{_host}),
      store: IoFileStore(storage),
      verifier: const Sha256HashVerifier(),
      registry: JsonDownloadRegistry(storage),
      connectivity: PluginConnectivityService(),
      currentUserId: () => 'fx-usr-it',
      pending: JsonPendingDownloads(storage),
      sleep: (Duration _) async {},
    );
    ranges.clear();
    cutAfter = 2 * 1000 * 1000;
    final List<DownloadStatus> seen = <DownloadStatus>[];
    final StreamSubscription<DownloadStatus> watching = downloads
        .watch('fx-iss-it')
        .listen(seen.add);
    expect(
      await downloads.start('fx-iss-it', mobileDataAccepted: true),
      isA<Ok<void>>(),
    );
    await Future<void>.delayed(Duration.zero);
    await watching.cancel();

    expect(ranges.first, isNull);
    expect(ranges.last, startsWith('bytes='));
    final int resumedFrom = int.parse(
      ranges.last!.substring(6, ranges.last!.length - 1),
    );
    expect(resumedFrom, greaterThan(0));
    expect(resumedFrom, lessThanOrEqualTo(2 * 1000 * 1000));
    expect(seen.whereType<WaitingForNetwork>(), isNotEmpty);
    expect(seen.last, isA<Downloaded>());
    expect(await JsonPendingDownloads(storage).load(), isEmpty);
    expect(await downloads.delete('fx-iss-it'), isA<Ok<void>>());
  });

  test('a file whose hash does not match is never kept [FR-STATE-006, '
      'FR-READ-010]', () async {
    final PlatformIssueStorage storage = PlatformIssueStorage();
    final IssueDownloadManager downloads = manager(
      grant(hash: '00' * 32),
      storage,
    );
    final Result<void> result = await downloads.start(
      'fx-iss-it',
      mobileDataAccepted: true,
    );
    expect((result as Err<void>).failure.code, FailureCode.fileCorrupt);
    expect(await downloads.listDownloaded(), isEmpty);
    final Directory partial = Directory(
      '${(await storage.issueDirectory()).path}/partial',
    );
    expect(
      partial.listSync().whereType<File>().map((File f) => f.path),
      isEmpty,
    );
  });
}
