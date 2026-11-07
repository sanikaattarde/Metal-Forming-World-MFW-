import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fixtures/fx_issue_files.dart';
import 'fake_auth_service.dart';
import 'fake_download_manager.dart';
import 'fake_issue_file_service.dart';
import 'fake_server.dart';
import 'test_helpers.dart';
import 'test_users.dart';

FakeDownloadManager managerFor(
  TestUser? user, {
  Set<String> damagedIssueIds = const <String>{},
  ConnectionType connection = ConnectionType.wifi,
  int freeBytes = 1000000000,
}) {
  final FakeAuthService auth = FakeAuthService(FakeServer(), signedInAs: user);
  return FakeDownloadManager(
    auth,
    FakeIssueFileService(auth, files: fxIssueFiles),
    damagedIssueIds: damagedIssueIds,
    connection: connection,
    freeBytes: freeBytes,
  );
}

void main() {
  group('FakeDownloadManager [IC-03]', () {
    test('implements DownloadManager', () {
      expect(managerFor(fxUsr01), isA<DownloadManager>());
    });

    test('openLocal returns the reader\'s complete copy', () async {
      final FakeDownloadManager manager = managerFor(fxUsr01)
        ..seedCopy(ownerUserId: fxUsr01.userId, issueId: 'fx-iss-01');

      final LocalIssueFile file = valueOf(await manager.openLocal('fx-iss-01'));

      expect(file.issueId, 'fx-iss-01');
      expect(file.fileRevision, 1);
    });

    test('a partial copy is never opened or listed [FR-STATE-004]', () async {
      final FakeDownloadManager manager = managerFor(fxUsr01)
        ..seedPartial(ownerUserId: fxUsr01.userId, issueId: 'fx-iss-01');

      expect(
        failureCodeOf(await manager.openLocal('fx-iss-01')),
        FailureCode.notFound,
      );
      expect(await manager.listDownloaded(), isEmpty);
    });

    test(
      'a damaged copy gives fileCorrupt with a retry [FR-READ-010]',
      () async {
        final FakeDownloadManager manager = managerFor(
          fxUsr01,
          damagedIssueIds: <String>{'fx-iss-01'},
        )..seedCopy(ownerUserId: fxUsr01.userId, issueId: 'fx-iss-01');

        final Result<LocalIssueFile> result = await manager.openLocal(
          'fx-iss-01',
        );

        expect(failureCodeOf(result), FailureCode.fileCorrupt);
        expect(failureOf(result)!.retryable, isTrue);
      },
    );

    test('another reader\'s copy is neither listed nor opened', () async {
      final FakeDownloadManager manager = managerFor(fxUsr01)
        ..seedCopy(ownerUserId: fxUsr06.userId, issueId: 'fx-iss-01');

      expect(await manager.listDownloaded(), isEmpty);
      expect(
        failureCodeOf(await manager.openLocal('fx-iss-01')),
        FailureCode.notFound,
      );
    });

    test(
      'start reports progress and verification, then the copy [FR-DL-005]',
      () async {
        final FakeDownloadManager manager = managerFor(fxUsr01);
        final List<DownloadStatus> seen = recordEvents(
          manager.watch('fx-iss-01'),
        );

        expect(
          await manager.start('fx-iss-01', mobileDataAccepted: false),
          isA<Ok<void>>(),
        );
        await settle();

        expect(seen.map((DownloadStatus status) => status.runtimeType), <Type>[
          NotDownloaded,
          Queued,
          InProgress,
          InProgress,
          Verifying,
          Downloaded,
        ]);
        final List<DownloadedIssue> copies = await manager.listDownloaded();
        expect(copies, hasLength(1));
        expect(copies.single.ownerUserId, fxUsr01.userId);
        expect(copies.single.fileRevision, 1);
        expect(copies.single.contentHash, 'fx-hash-iss-01');
      },
    );

    test(
      'start without full access fails with the grant failure [IC-02]',
      () async {
        final FakeDownloadManager manager = managerFor(fxUsr02);

        expect(
          failureCodeOf(
            await manager.start('fx-iss-01', mobileDataAccepted: false),
          ),
          FailureCode.emailNotVerified,
        );
        expect(await manager.watch('fx-iss-01').first, isA<Failed>());
      },
    );

    test('prepare reports the size, mobile data and free space [FR-DL-003, FR-DL-004]', () async {
      final FakeDownloadManager manager = managerFor(
        fxUsr01,
        connection: ConnectionType.mobile,
        freeBytes: 1000,
      );

      final DownloadPlan plan = valueOf(await manager.prepare('fx-iss-01'));

      expect(plan.sizeBytes, 800000);
      expect(plan.onMobileData, isTrue);
      expect(plan.enoughSpace, isFalse);
    });

    test(
      'delete removes the copy, and a second delete is notFound [FR-DL-009]',
      () async {
        final FakeDownloadManager manager = managerFor(fxUsr01)
          ..seedCopy(ownerUserId: fxUsr01.userId, issueId: 'fx-iss-01');

        expect(await manager.delete('fx-iss-01'), isA<Ok<void>>());
        expect(await manager.listDownloaded(), isEmpty);
        expect(
          failureCodeOf(await manager.delete('fx-iss-01')),
          FailureCode.notFound,
        );
      },
    );
  });
}
