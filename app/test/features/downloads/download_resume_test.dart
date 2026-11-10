import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../../fakes/fake_connectivity_service.dart';
import '../../fakes/test_helpers.dart';
import 'download_fakes.dart';
import 'download_test_support.dart';

/// Grants from a script: each request takes the next revision and expiry,
/// and repeats the last once the script runs out.
final class ScriptedGrants implements IssueFileService {
  ScriptedGrants(this.bytesByRevision, this.script);

  final Map<int, List<int>> bytesByRevision;
  final List<({int revision, DateTime expiresAt})> script;
  int requests = 0;

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async {
    final ({int revision, DateTime expiresAt}) next =
        script[requests < script.length ? requests : script.length - 1];
    requests++;
    final List<int> bytes = bytesByRevision[next.revision]!;
    return Ok<IssueFileGrant>(
      IssueFileGrant(
        issueId: issueId,
        access: next.revision,
        expiresAt: next.expiresAt,
        sizeBytes: bytes.length,
        contentHash: fakeHash(bytes),
        revision: next.revision,
      ),
    );
  }
}

/// Serves the bytes of the grant's revision, which the access holds.
final class RevisionTransport implements FileTransport {
  RevisionTransport(this.bytesByRevision);

  final Map<int, List<int>> bytesByRevision;
  final List<(int, int)> fetches = <(int, int)>[];

  @override
  Future<Result<void>> fetch(
    IssueFileGrant grant, {
    required int offset,
    required Future<Result<void>> Function(List<int> chunk) onChunk,
  }) async {
    fetches.add((grant.revision, offset));
    final List<int> bytes = bytesByRevision[grant.access as int]!;
    return onChunk(bytes.sublist(offset));
  }
}

void main() {
  group('Resume after a network break [MOD06-P2-T03, FR-DL-006]', () {
    test('with the network gone it waits, and goes on from the bytes held '
        'when it returns [rule 1, AC-4.3]', () async {
      final DownloadRig rig = DownloadRig();
      rig.transport.resetAfterBytes = 700;
      final FakeConnectivityService connectivity = rig.connectivity;
      rig.transport.onReset = () => connectivity.type = ConnectionType.none;
      final List<DownloadStatus> seen = <DownloadStatus>[];
      final StreamSubscription<DownloadStatus> watching = rig.manager
          .watch('fx-iss-02')
          .listen(seen.add);
      await settle();

      final Future<Result<void>> running = rig.manager.start(
        'fx-iss-02',
        mobileDataAccepted: false,
      );
      await settle();
      expect(
        await rig.manager.watch('fx-iss-02').first,
        isA<WaitingForNetwork>(),
      );
      expect(rig.transport.fetches, 1);

      connectivity.type = ConnectionType.wifi;
      expect(await running, isA<Ok<void>>());
      await settle();
      await watching.cancel();
      expect(rig.transport.offsets, <int>[0, 700]);
      expect(seen.last, isA<Downloaded>());
    });

    test('when the network returns as mobile data the reader did not accept, '
        'it keeps waiting until Wi-Fi [FR-DL-004]', () async {
      final DownloadRig rig = DownloadRig();
      rig.transport.resetAfterBytes = 500;
      rig.transport.onReset = () =>
          rig.connectivity.type = ConnectionType.mobile;
      final Future<Result<void>> running = rig.manager.start(
        'fx-iss-01',
        mobileDataAccepted: false,
      );
      await settle();
      expect(
        await rig.manager.watch('fx-iss-01').first,
        isA<WaitingForNetwork>(),
      );
      expect(rig.transport.fetches, 1);

      rig.connectivity.type = ConnectionType.wifi;
      expect(await running, isA<Ok<void>>());
      expect(rig.transport.offsets, <int>[0, 500]);
    });

    test('an expired link asks for a new grant and goes on from the same '
        'offset [rule 2]', () async {
      final DownloadRig rig = DownloadRig();
      rig.transport.resetAfterBytes = 400;
      // The next try finds the link expired.
      rig.transport.onReset = () => rig.transport.failNext.add(
        const AppFailure(FailureCode.forbidden, retryable: true),
      );
      expect(
        await rig.manager.start('fx-iss-02', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      expect(rig.files.grantsIssued, 2);
      expect(rig.transport.offsets, <int>[0, 400, 400]);
    });

    test(
      'a grant past its expiry is renewed before it is used [rule 2]',
      () async {
        final List<int> bytes = syntheticFile(1000);
        final ScriptedGrants grants = ScriptedGrants(
          <int, List<int>>{1: bytes},
          <({int revision, DateTime expiresAt})>[
            (revision: 1, expiresAt: DateTime.utc(2025)),
            (revision: 1, expiresAt: DateTime.utc(2030)),
          ],
        );
        final RevisionTransport transport = RevisionTransport(<int, List<int>>{
          1: bytes,
        });
        final DownloadRig rig = DownloadRig();
        final IssueDownloadManager manager = IssueDownloadManager(
          files: grants,
          transport: transport,
          store: rig.store,
          verifier: const FakeHashVerifier(),
          registry: rig.registry,
          connectivity: rig.connectivity,
          currentUserId: () => 'fx-usr-01',
          clock: () => DateTime.utc(2026),
          sleep: (Duration _) async {},
        );
        expect(
          await manager.start('fx-iss-01', mobileDataAccepted: false),
          isA<Ok<void>>(),
        );
        expect(grants.requests, 2);
        expect(transport.fetches, <(int, int)>[(1, 0)]);
      },
    );

    test('a new grant for another revision drops the bytes held and starts '
        'the new file [rule 8]', () async {
      final List<int> first = syntheticFile(1000);
      final List<int> second = List<int>.generate(1200, (int i) => i % 7);
      final ScriptedGrants grants = ScriptedGrants(
        <int, List<int>>{1: first, 2: second},
        <({int revision, DateTime expiresAt})>[
          (revision: 1, expiresAt: DateTime.utc(2030)),
          (revision: 2, expiresAt: DateTime.utc(2030)),
        ],
      );
      final DownloadRig rig = DownloadRig();
      rig.store.partials['issue-fx-iss-01-r1.pdf.part'] = first.sublist(0, 300);
      final FakeFileTransport transport = FakeFileTransport(
        <String, List<int>>{'fx-iss-01': second},
      )..failNext.add(const AppFailure(FailureCode.forbidden, retryable: true));
      final IssueDownloadManager manager = IssueDownloadManager(
        files: grants,
        transport: transport,
        store: rig.store,
        verifier: const FakeHashVerifier(),
        registry: rig.registry,
        connectivity: rig.connectivity,
        currentUserId: () => 'fx-usr-01',
        clock: () => DateTime.utc(2026),
        sleep: (Duration _) async {},
      );
      expect(
        await manager.start('fx-iss-01', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      expect(transport.offsets, <int>[300, 0]);
      final DownloadedIssue copy = (await manager.listDownloaded()).single;
      expect(copy.fileRevision, 2);
      expect(rig.store.partials, isEmpty);
    });

    test('a server that ignores the range makes the file start again, '
        'once', () async {
      final DownloadRig rig = DownloadRig();
      rig.store.partials['issue-fx-iss-01-r1.pdf.part'] = syntheticFile(1000)
          .sublist(0, 200);
      rig.transport.failNext.add(
        const AppFailure(FailureCode.invalidResponse, detail: 'status 200'),
      );
      expect(
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      expect(rig.transport.offsets, <int>[200, 0]);
    });

    test(
      'five tries that move nothing stop with a retry; the bytes and the '
      'record are kept, and the next app start resumes it [rule 6]',
      () async {
        final DownloadRig rig = DownloadRig();
        rig.transport
          ..resetAfterBytes = 300
          ..resetCount = 6;
        final Result<void> first = await rig.manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );
        expect(failureCodeOf(first), FailureCode.network);
        expect(failureOf(first)!.retryable, isTrue);
        expect(rig.store.partials.values.single, hasLength(300));
        expect(await rig.pending.load(), hasLength(1));
        expect(await rig.manager.listDownloaded(), isEmpty);

        // The app is closed and opened again.
        final IssueDownloadManager restarted = rig.newManager();
        await restarted.resumePending();
        await settle();
        expect(await restarted.listDownloaded(), hasLength(1));
        expect(rig.transport.offsets.last, 300);
        expect(await rig.pending.load(), isEmpty);
      },
    );

    test(
      'resumePending leaves another reader\'s downloads alone [rule 7]',
      () async {
        final DownloadRig rig = DownloadRig();
        await rig.pending.save(
          const PendingDownload(
            ownerUserId: 'someone-else',
            issueId: 'fx-iss-01',
            mobileDataAccepted: false,
          ),
        );
        await rig.manager.resumePending();
        await settle();
        expect(rig.transport.fetches, 0);
      },
    );

    test(
      'cancel while waiting for the network keeps nothing (RD-01)',
      () async {
        final DownloadRig rig = DownloadRig();
        rig.transport.resetAfterBytes = 500;
        rig.transport.onReset = () =>
            rig.connectivity.type = ConnectionType.none;
        final Future<Result<void>> running = rig.manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );
        await settle();
        expect(
          await rig.manager.watch('fx-iss-01').first,
          isA<WaitingForNetwork>(),
        );

        await rig.manager.cancel('fx-iss-01');
        expect(failureCodeOf(await running), FailureCode.cancelled);
        expect(rig.store.partials, isEmpty);
        expect(await rig.pending.load(), isEmpty);
      },
    );
  });

  group('Stopped downloads and their files [MOD06-P2-T03]', () {
    IssueDownloadManager managerOver(
      DownloadRig rig, {
      IssueFileService? files,
      PendingDownloads? pending,
      Future<void> Function(Duration delay)? sleep,
    }) => IssueDownloadManager(
      files: files ?? rig.files,
      transport: rig.transport,
      store: rig.store,
      verifier: const FakeHashVerifier(),
      registry: rig.registry,
      connectivity: rig.connectivity,
      currentUserId: () => rig.auth.currentUserId,
      clock: () => DateTime.utc(2026),
      pending: pending ?? rig.pending,
      sleep: sleep ?? (Duration _) async {},
    );

    test('a partial file that holds every byte is checked without another '
        'fetch, as when the app closed before the check [rule 1]', () async {
      final DownloadRig rig = DownloadRig();
      rig.store.partials['issue-fx-iss-01-r1.pdf.part'] = syntheticFile(1000);
      expect(
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      expect(rig.transport.fetches, 0);
      expect(await rig.manager.listDownloaded(), hasLength(1));
    });

    test('a partial file of another revision is removed when the issue '
        'downloads again, and other issues keep theirs [rule 8]', () async {
      final DownloadRig rig = DownloadRig();
      rig.store.partials['issue-fx-iss-01-r7.pdf.part'] = <int>[1, 2, 3];
      rig.store.partials['issue-fx-iss-01x-r1.pdf.part'] = <int>[4];
      expect(
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      expect(rig.store.partials.keys, <String>['issue-fx-iss-01x-r1.pdf.part']);
    });

    test('a stopped download of an issue that is gone is dropped with its '
        'bytes, so it is not tried at every start [FR-MAG-008]', () async {
      final DownloadRig rig = DownloadRig();
      rig.store.partials['issue-fx-iss-01-r1.pdf.part'] = <int>[1, 2, 3];
      await rig.pending.save(
        const PendingDownload(
          ownerUserId: 'fx-usr-01',
          issueId: 'fx-iss-01',
          mobileDataAccepted: false,
        ),
      );
      final IssueDownloadManager manager = managerOver(
        rig,
        files: const GoneIssues(),
      );
      expect(
        failureCodeOf(
          await manager.start('fx-iss-01', mobileDataAccepted: false),
        ),
        FailureCode.notFound,
      );
      expect(rig.store.partials, isEmpty);
      expect(await rig.pending.load(), isEmpty);
    });

    test('cancel during the pause before a retry ends it at once '
        '(RD-01)', () async {
      final DownloadRig rig = DownloadRig();
      rig.transport.failNext.add(
        const AppFailure(FailureCode.serviceUnavailable, retryable: true),
      );
      final IssueDownloadManager manager = managerOver(
        rig,
        // A pause that would never end on its own.
        sleep: (Duration _) => Completer<void>().future,
      );
      final Future<Result<void>> running = manager.start(
        'fx-iss-01',
        mobileDataAccepted: false,
      );
      await settle();
      await manager.cancel('fx-iss-01').timeout(const Duration(seconds: 2));
      expect(failureCodeOf(await running), FailureCode.cancelled);
      expect(rig.transport.fetches, 1);
    });

    test('a storage error fails the download instead of leaving it '
        'queued', () async {
      final DownloadRig rig = DownloadRig();
      final IssueDownloadManager manager = managerOver(
        rig,
        pending: BrokenPendingDownloads(),
      );
      final Result<void> result = await manager.start(
        'fx-iss-01',
        mobileDataAccepted: false,
      );
      expect(failureCodeOf(result), FailureCode.unknown);
      expect(failureOf(result)!.retryable, isTrue);
      expect(await manager.watch('fx-iss-01').first, isA<Failed>());
    });
  });
}

/// Every issue is gone: unpublished or removed (ISSUE_NOT_AVAILABLE).
final class GoneIssues implements IssueFileService {
  const GoneIssues();

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async =>
      const Err<IssueFileGrant>(AppFailure(FailureCode.notFound));
}

/// A pending store whose writes fail, as on a full or broken disk.
final class BrokenPendingDownloads implements PendingDownloads {
  @override
  Future<List<PendingDownload>> load() async => <PendingDownload>[];

  @override
  Future<void> save(PendingDownload pending) async =>
      throw Exception('synthetic storage failure');

  @override
  Future<void> remove({
    required String ownerUserId,
    required String issueId,
  }) async {}
}
