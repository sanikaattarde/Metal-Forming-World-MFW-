// MOD06-P3-T02: kept copies after sign-out, account deletion, unpublishing
// and permanent deletion (RS FR-DL-010, IC-08; OQ-11 working position of
// 27 October 2026, DEC-033, PROPOSED). Synthetic values only.
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../../fakes/test_users.dart';
import '../account/fake_identity_provider.dart';
import '../account/account_deletion_flow_test.dart' show FakeDeletionBackend;
import 'download_fakes.dart';
import 'download_test_support.dart';

/// OP-03 in memory.
final class FakeDeletedIssues implements DeletedIssueList {
  Set<String> ids = <String>{};
  AppFailure? failure;

  @override
  Future<Result<Set<String>>> deletedIssueIds() async {
    final AppFailure? set = failure;
    return set == null ? Ok<Set<String>>(ids) : Err<Set<String>>(set);
  }
}

Future<void> _keep(DownloadRig rig, String issueId) async {
  expect(
    await rig.manager.start(issueId, mobileDataAccepted: true),
    isA<Ok<void>>(),
  );
}

List<String> _ids(List<DownloadedIssue> copies) => <String>[
  for (final DownloadedIssue copy in copies) copy.issueId,
];

void main() {
  group('sign-out hides the copies until the same reader is back', () {
    test(
      'signed out, none show or open; the reader signs in and finds them',
      () async {
        final DownloadRig rig = DownloadRig();
        await _keep(rig, 'fx-iss-01');

        await rig.auth.signOut();
        expect(await rig.manager.listDownloaded(), isEmpty);
        final Result<LocalIssueFile> closed = await rig.manager.openLocal(
          'fx-iss-01',
        );
        expect(
          (closed as Err<LocalIssueFile>).failure.code,
          FailureCode.unauthenticated,
        );
        expect(rig.store.files, hasLength(1));

        rig.auth.signInAs(fxUsr06);
        expect(await rig.manager.listDownloaded(), isEmpty);

        await rig.auth.signOut();
        rig.auth.signInAs(fxUsr01);
        expect(_ids(await rig.manager.listDownloaded()), <String>['fx-iss-01']);
        expect(
          await rig.manager.openLocal('fx-iss-01'),
          isA<Ok<LocalIssueFile>>(),
        );
      },
    );
  });

  group('account deletion removes the reader\'s copies [IC-08]', () {
    test('only that reader\'s copies and files go', () async {
      final DownloadRig rig = DownloadRig();
      await _keep(rig, 'fx-iss-01');
      await rig.auth.signOut();
      rig.auth.signInAs(fxUsr06);
      await _keep(rig, 'fx-iss-01');
      await _keep(rig, 'fx-iss-02');
      expect(rig.store.files, hasLength(3));

      await rig.manager.removeReader(fxUsr06.userId);

      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.store.files, hasLength(1));
      expect(await rig.manager.watch('fx-iss-02').first, isA<NotDownloaded>());
      await rig.auth.signOut();
      rig.auth.signInAs(fxUsr01);
      expect(_ids(await rig.manager.listDownloaded()), <String>['fx-iss-01']);
      // The registry agrees after a restart.
      rig.manager = rig.newManager();
      expect(_ids(await rig.manager.listDownloaded()), <String>['fx-iss-01']);
    });

    test('a download under way stops and leaves no partial file', () async {
      final DownloadRig rig = DownloadRig(
        sizes: const <String, int>{'fx-iss-01': 400000},
        chunkDelay: const Duration(milliseconds: 1),
      );
      final Future<Result<void>> running = rig.manager.start(
        'fx-iss-01',
        mobileDataAccepted: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));

      await rig.manager.removeReader(fxUsr01.userId);

      expect((await running as Err<void>).failure.code, FailureCode.cancelled);
      expect(rig.store.partials, isEmpty);
      expect(rig.store.files, isEmpty);
      expect(await rig.pending.load(), isEmpty);
    });

    test(
      'through AccountAuthService: OP-12, then the copies, then sign-out',
      () async {
        final FakeIdentityProvider identity = FakeIdentityProvider();
        final AccountAuthService auth = AccountAuthService(
          identity,
          backend: FakeDeletionBackend(),
          requestIds: () => 'request-1',
        );
        final String uid = identity
            .addAccount('reader@example.test', 'right-password', verified: true)
            .uid;
        await identity.signIn(
          email: 'reader@example.test',
          password: 'right-password',
        );
        final _Recording copies = _Recording();
        auth.addDeletionHook(copies.removeReader);

        expect(await auth.deleteAccount(), isA<Ok<void>>());
        expect(copies.readers, <String>[uid]);
        expect(identity.currentUser, isNull);
      },
    );
  });

  group('unpublishing leaves a kept copy', () {
    test(
      'the copy still opens: the manager never asks the catalogue',
      () async {
        final DownloadRig rig = DownloadRig();
        await _keep(rig, 'fx-iss-01');
        rig.manager = rig.newManager();

        expect(
          await rig.manager.openLocal('fx-iss-01'),
          isA<Ok<LocalIssueFile>>(),
        );
      },
    );
  });

  group('permanent deletion removes every copy once OP-03 lists it', () {
    test('every reader\'s copy of the issue goes, and nothing else', () async {
      final DownloadRig rig = DownloadRig();
      await _keep(rig, 'fx-iss-01');
      await _keep(rig, 'fx-iss-02');
      await rig.auth.signOut();
      rig.auth.signInAs(fxUsr06);
      await _keep(rig, 'fx-iss-01');
      final FakeDeletedIssues deleted = FakeDeletedIssues()
        ..ids = <String>{'fx-iss-01', 'fx-iss-99'};

      expect(await sweepDeletedIssues(deleted, rig.manager), 2);

      expect(await rig.manager.listDownloaded(), isEmpty);
      await rig.auth.signOut();
      rig.auth.signInAs(fxUsr01);
      expect(_ids(await rig.manager.listDownloaded()), <String>['fx-iss-02']);
      expect(rig.store.files, hasLength(1));
    });

    test(
      'a stopped download of a deleted issue is dropped with its bytes',
      () async {
        final DownloadRig rig = DownloadRig(
          sizes: const <String, int>{'fx-iss-01': 4000},
        );
        rig.transport.failNext.add(
          const AppFailure(FailureCode.network, retryable: true),
        );
        rig.manager = IssueDownloadManager(
          files: rig.files,
          transport: rig.transport,
          store: rig.store,
          verifier: const FakeHashVerifier(),
          registry: rig.registry,
          connectivity: rig.connectivity,
          currentUserId: () => rig.auth.currentUserId,
          pending: rig.pending,
          sleep: (Duration _) async {},
          maxAttemptsWithoutProgress: 1,
        );
        await rig.manager.start('fx-iss-01', mobileDataAccepted: true);
        expect(await rig.pending.load(), isNotEmpty);

        await rig.manager.removeIssues(<String>{'fx-iss-01'});

        expect(await rig.pending.load(), isEmpty);
        expect(rig.store.partials, isEmpty);
      },
    );

    test('a list that cannot be read removes nothing', () async {
      final DownloadRig rig = DownloadRig();
      await _keep(rig, 'fx-iss-01');
      final FakeDeletedIssues deleted = FakeDeletedIssues()
        ..ids = <String>{'fx-iss-01'}
        ..failure = const AppFailure(FailureCode.network, retryable: true);

      expect(await sweepDeletedIssues(deleted, rig.manager), 0);
      expect(_ids(await rig.manager.listDownloaded()), <String>['fx-iss-01']);
    });
  });
}

final class _Recording {
  final List<String> readers = <String>[];

  Future<void> removeReader(String userId) async => readers.add(userId);
}
