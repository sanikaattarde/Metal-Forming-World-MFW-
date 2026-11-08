// Spike T-02.4: resume after a network break on a simulator and an
// emulator, with the real adapters (HttpFileTransport, IoFileStore,
// Sha256Verifier) against tool/range_server.dart on the developer's machine.
// The content is synthetic (DEC-024). Run the server first, then:
//
//   flutter test integration_test/download_resume_test.dart -d <device> \
//     --dart-define=RANGE_URL=http://127.0.0.1:8099
//
// On an Android emulator the host is 10.0.2.2. Each test prints one
// RESUME line with its numbers for the evidence report.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/data/http_file_transport.dart';
import 'package:mfw_app/features/downloads/data/io_file_store.dart';
import 'package:mfw_app/features/downloads/data/sha256_verifier.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

const String _baseUrl = String.fromEnvironment(
  'RANGE_URL',
  defaultValue: 'http://127.0.0.1:8099',
);
const String _issueId = 'issue-resume';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _RangeServer server;
  late Directory root;
  late _Meta meta;

  setUpAll(() async {
    server = _RangeServer(Uri.parse(_baseUrl));
    meta = await server.meta();
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('mfw_resume_');
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  IssueDownloadManager manager({bool ignoreRange = false}) =>
      IssueDownloadManager(
        files: _GrantService(
          Uri.parse('$_baseUrl/issue${ignoreRange ? '?norange=1' : ''}'),
          meta,
        ),
        transport: HttpFileTransport(),
        store: IoFileStore(root),
        verifier: const Sha256Verifier(),
        registry: _MemoryRegistry(),
        connectivity: const _OnWifi(),
        currentUserId: () => 'reader-1',
      );

  Future<DownloadStatus> statusOf(IssueDownloadManager downloads) =>
      downloads.watch(_issueId).first;

  Future<int> lengthOnDisk(IssueDownloadManager downloads) async {
    final Result<LocalIssueFile> local = await downloads.openLocal(_issueId);
    return switch (local) {
      Ok<LocalIssueFile>(:final LocalIssueFile value) => File(
        value.path,
      ).length(),
      Err<LocalIssueFile>() => -1,
    };
  }

  group('resume after a network break [T-02.4, FX-NET-07, AC-4, I-5]', () {
    testWidgets('an unbroken download completes and its hash matches', (
      WidgetTester tester,
    ) async {
      await server.reset(<double>[]);
      final IssueDownloadManager downloads = manager();
      final Stopwatch clock = Stopwatch()..start();

      final Result<void> result = await downloads.start(
        _issueId,
        mobileDataAccepted: false,
      );

      clock.stop();
      final _Stats stats = await server.stats();
      expect(result, isA<Ok<void>>());
      expect(await statusOf(downloads), isA<Downloaded>());
      expect(await lengthOnDisk(downloads), meta.sizeBytes);
      expect(stats.requests, hasLength(1));
      expect(stats.totalSent, meta.sizeBytes);
      _report('whole', meta, stats, clock);
    });

    testWidgets('two breaks: each start resumes from the partial file', (
      WidgetTester tester,
    ) async {
      await server.reset(<double>[0.3, 0.7]);
      final IssueDownloadManager downloads = manager();
      final Stopwatch clock = Stopwatch()..start();
      final List<int> keptAtBreak = <int>[];

      for (int attempt = 0; attempt < 2; attempt++) {
        final Result<void> broken = await downloads.start(
          _issueId,
          mobileDataAccepted: false,
        );
        expect(broken, isA<Err<void>>());
        final DownloadStatus waiting = await statusOf(downloads);
        expect(waiting, isA<WaitingForNetwork>());
        keptAtBreak.add((waiting as WaitingForNetwork).receivedBytes);
      }
      final Result<void> resumed = await downloads.start(
        _issueId,
        mobileDataAccepted: false,
      );

      clock.stop();
      final _Stats stats = await server.stats();
      expect(resumed, isA<Ok<void>>());
      expect(await statusOf(downloads), isA<Downloaded>());
      expect(await lengthOnDisk(downloads), meta.sizeBytes);
      expect(stats.requests, hasLength(3));
      expect(stats.requests[0].range, isNull);
      expect(stats.requests[1].start, keptAtBreak[0]);
      expect(stats.requests[1].range, 'bytes=${keptAtBreak[0]}-');
      expect(stats.requests[1].status, HttpStatus.partialContent);
      expect(stats.requests[2].start, keptAtBreak[1]);
      expect(keptAtBreak[0], greaterThan(0));
      expect(keptAtBreak[1], greaterThan(keptAtBreak[0]));
      _report('two-breaks', meta, stats, clock, kept: keptAtBreak);
    });

    testWidgets('a server that ignores the range sends the file again, and '
        'the copy is still whole', (WidgetTester tester) async {
      await server.reset(<double>[0.5]);
      final IssueDownloadManager downloads = manager(ignoreRange: true);
      final Stopwatch clock = Stopwatch()..start();

      final Result<void> broken = await downloads.start(
        _issueId,
        mobileDataAccepted: false,
      );
      expect(broken, isA<Err<void>>());
      final int kept =
          (await statusOf(downloads) as WaitingForNetwork).receivedBytes;
      final Result<void> resumed = await downloads.start(
        _issueId,
        mobileDataAccepted: false,
      );

      clock.stop();
      final _Stats stats = await server.stats();
      expect(resumed, isA<Ok<void>>());
      expect(await lengthOnDisk(downloads), meta.sizeBytes);
      expect(stats.requests, hasLength(2));
      expect(stats.requests[1].status, HttpStatus.ok);
      expect(stats.requests[1].start, 0);
      expect(stats.requests[1].sent, meta.sizeBytes);
      _report('no-range', meta, stats, clock, kept: <int>[kept]);
    });

    testWidgets('cancel while waiting deletes the partial file, and the next '
        'start begins at byte 0', (WidgetTester tester) async {
      await server.reset(<double>[0.5]);
      final IssueDownloadManager downloads = manager();

      expect(
        await downloads.start(_issueId, mobileDataAccepted: false),
        isA<Err<void>>(),
      );
      expect(await statusOf(downloads), isA<WaitingForNetwork>());
      expect(await downloads.cancel(_issueId), isA<Ok<void>>());

      final Directory partials = Directory('${root.path}/partial');
      expect(
        await partials.exists() ? await partials.list().toList() : <Object>[],
        isEmpty,
      );
      expect(await statusOf(downloads), isA<NotDownloaded>());
      await server.reset(<double>[]);
      expect(
        await downloads.start(_issueId, mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      final _Stats stats = await server.stats();
      expect(stats.requests.single.start, 0);
      _report('cancel', meta, stats, null);
    });
  });
}

void _report(
  String name,
  _Meta meta,
  _Stats stats,
  Stopwatch? clock, {
  List<int> kept = const <int>[],
}) {
  // ignore: avoid_print
  print(
    'RESUME ${jsonEncode(<String, Object?>{
      'test': name,
      'platform': Platform.operatingSystem,
      'sizeBytes': meta.sizeBytes,
      'keptAtBreak': kept,
      'requests': <Map<String, Object?>>[
        for (final _Request request in stats.requests) <String, Object?>{'start': request.start, 'status': request.status, 'sent': request.sent, 'cut': request.cut},
      ],
      'totalSent': stats.totalSent,
      'elapsedMs': clock?.elapsedMilliseconds,
    })}',
  );
}

final class _Meta {
  const _Meta(this.sizeBytes, this.contentHash);

  final int sizeBytes;
  final String contentHash;
}

final class _Request {
  _Request(Map<String, Object?> json)
    : range = json['range'] as String?,
      start = json['start']! as int,
      status = json['status']! as int,
      sent = json['sent']! as int,
      cut = json['cut']! as bool;

  final String? range;
  final int start;
  final int status;
  final int sent;
  final bool cut;
}

final class _Stats {
  const _Stats(this.requests, this.totalSent);

  final List<_Request> requests;
  final int totalSent;
}

/// The control endpoints of tool/range_server.dart.
final class _RangeServer {
  _RangeServer(this.base);

  final Uri base;
  final HttpClient _client = HttpClient();

  Future<Map<String, Object?>> _get(String path) async {
    final HttpClientRequest request = await _client.getUrl(base.resolve(path));
    final HttpClientResponse response = await request.close();
    final String body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, Object?>;
  }

  Future<_Meta> meta() async {
    final Map<String, Object?> json = await _get('/meta');
    return _Meta(json['sizeBytes']! as int, json['contentHash']! as String);
  }

  Future<void> reset(List<double> cuts) =>
      _get('/reset?cuts=${cuts.join(',')}');

  Future<_Stats> stats() async {
    final Map<String, Object?> json = await _get('/stats');
    return _Stats(<_Request>[
      for (final Object? entry in json['requests']! as List<Object?>)
        _Request(entry! as Map<String, Object?>),
    ], json['totalSent']! as int);
  }
}

/// Grants a plain URL. The real grant waits for DEC-020.
final class _GrantService implements IssueFileService {
  const _GrantService(this.url, this.meta);

  final Uri url;
  final _Meta meta;

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async =>
      Ok<IssueFileGrant>(
        IssueFileGrant(
          issueId: issueId,
          access: url,
          expiresAt: DateTime.utc(2099),
          sizeBytes: meta.sizeBytes,
          contentHash: meta.contentHash,
          revision: 1,
        ),
      );
}

final class _OnWifi implements ConnectivityService {
  const _OnWifi();

  @override
  Future<ConnectionType> current() async => ConnectionType.wifi;

  @override
  Stream<ConnectionType> watch() =>
      Stream<ConnectionType>.value(ConnectionType.wifi);
}

final class _MemoryRegistry implements DownloadRegistry {
  final Map<(String, String), DownloadedIssue> _rows =
      <(String, String), DownloadedIssue>{};

  @override
  Future<List<DownloadedIssue>> load() async => _rows.values.toList();

  @override
  Future<void> save(DownloadedIssue copy) async =>
      _rows[(copy.ownerUserId, copy.issueId)] = copy;

  @override
  Future<void> remove({
    required String ownerUserId,
    required String issueId,
  }) async => _rows.remove((ownerUserId, issueId));
}
