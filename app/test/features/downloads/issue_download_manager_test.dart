import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../../fakes/test_helpers.dart';
import '../../fakes/test_users.dart';
import 'download_test_support.dart';

String nameOf(DownloadStatus status) => switch (status) {
  NotDownloaded() => 'notDownloaded',
  Queued() => 'queued',
  InProgress() => 'inProgress',
  WaitingForNetwork() => 'waitingForNetwork',
  Verifying() => 'verifying',
  Downloaded() => 'downloaded',
  Failed(:final AppFailure failure) => 'failed:${failure.code.name}',
};

void main() {
  group('IssueDownloadManager [MOD-06]', () {
    test('implements DownloadManager', () {
      expect(DownloadRig().manager, isA<DownloadManager>());
    });

    group('prepare', () {
      test('reports the size before a download [FR-DL-003, AC-4.4]', () async {
        final DownloadPlan plan = valueOf(
          await DownloadRig().manager.prepare('fx-iss-01'),
        );

        expect(plan.sizeBytes, 1000);
        expect(plan.onMobileData, isFalse);
        expect(plan.enoughSpace, isTrue);
      });

      test('flags mobile data [FR-DL-004]', () async {
        final DownloadPlan plan = valueOf(
          await DownloadRig(connection: ConnectionType.mobile).manager
              .prepare('fx-iss-01'),
        );

        expect(plan.onMobileData, isTrue);
      });

      test('flags too little free space [FR-STATE-004]', () async {
        final DownloadPlan plan = valueOf(
          await DownloadRig(capacityBytes: 999).manager.prepare('fx-iss-01'),
        );

        expect(plan.enoughSpace, isFalse);
      });

      for (final (TestUser? user, FailureCode code)
          in <(TestUser?, FailureCode)>[
            (null, FailureCode.unauthenticated),
            (fxUsr02, FailureCode.emailNotVerified),
            (fxUsr03, FailureCode.profileIncomplete),
          ]) {
        test('passes on the grant refusal ${code.name} [IC-02]', () async {
          expect(
            failureCodeOf(
              await DownloadRig(user: user).manager.prepare('fx-iss-01'),
            ),
            code,
          );
        });
      }
    });

    group('start', () {
      test('shows progress, verifies, then lists the copy [FR-DL-005, '
          'AC-4.1]', () async {
        final DownloadRig rig = DownloadRig();
        final List<DownloadStatus> seen = recordEvents(
          rig.manager.watch('fx-iss-01'),
        );
        await settle();

        expect(
          await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
          isA<Ok<void>>(),
        );
        await settle();

        final List<String> names = seen.map(nameOf).toList();
        expect(names.first, 'notDownloaded');
        expect(names[1], 'queued');
        expect(names.sublist(2, 13), List<String>.filled(11, 'inProgress'));
        expect(names.sublist(13), <String>['verifying', 'downloaded']);
        final List<int> received = seen
            .whereType<InProgress>()
            .map((InProgress p) => p.receivedBytes)
            .toList();
        expect(received, <int>[
          0,
          100,
          200,
          300,
          400,
          500,
          600,
          700,
          800,
          900,
          1000,
        ]);

        final List<DownloadedIssue> copies = await rig.manager.listDownloaded();
        expect(copies.single.issueId, 'fx-iss-01');
        expect(copies.single.ownerUserId, fxUsr01.userId);
        expect(copies.single.sizeBytes, 1000);
        expect(copies.single.fileRevision, 1);
      });

      test('openLocal hands over the verified copy [IC-03]', () async {
        final DownloadRig rig = DownloadRig();
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false);

        final LocalIssueFile file = valueOf(
          await rig.manager.openLocal('fx-iss-01'),
        );

        expect(file.issueId, 'fx-iss-01');
        expect(rig.store.files[file.path], hasLength(1000));
      });

      test('on mobile data, nothing moves until the reader accepts '
          '[FR-DL-004, AC-4.5]', () async {
        final DownloadRig rig = DownloadRig(connection: ConnectionType.mobile);

        expect(
          failureCodeOf(
            await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
          ),
          FailureCode.invalidInput,
        );
        expect(rig.transport.fetches, 0);

        expect(
          await rig.manager.start('fx-iss-01', mobileDataAccepted: true),
          isA<Ok<void>>(),
        );
        expect(await rig.manager.listDownloaded(), hasLength(1));
      });

      test('with no connection it fails with a retry', () async {
        final DownloadRig rig = DownloadRig(connection: ConnectionType.none);

        final Result<void> result = await rig.manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );

        expect(failureCodeOf(result), FailureCode.network);
        expect(failureOf(result)!.retryable, isTrue);
      });

      test(
        'too little space stops before any transfer [FR-STATE-004]',
        () async {
          final DownloadRig rig = DownloadRig(capacityBytes: 999);

          expect(
            failureCodeOf(
              await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
            ),
            FailureCode.insufficientStorage,
          );
          expect(rig.transport.fetches, 0);
        },
      );

      test('FX-NET-06: storage fills during the transfer; nothing partial is '
          'kept or listed [FR-STATE-004]', () async {
        final DownloadRig rig = DownloadRig(capacityBytes: 5000);
        rig.transport.gate = Completer<void>();
        final Future<Result<void>> running = rig.manager.start(
          'fx-iss-02',
          mobileDataAccepted: false,
        );
        await settle();

        rig.store.capacityBytes = 700;
        rig.transport.gate!.complete();

        expect(failureCodeOf(await running), FailureCode.insufficientStorage);
        expect(rig.store.partials, isEmpty);
        expect(await rig.manager.listDownloaded(), isEmpty);
        expect(await rig.manager.watch('fx-iss-02').first, isA<Failed>());
      });

      test('FX-NET-07: a reset mid-transfer fails with a retry, and the retry '
          'completes [FR-STATE-006]', () async {
        final DownloadRig rig = DownloadRig();
        rig.transport.resetAfterBytes = 500;

        final Result<void> first = await rig.manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );
        expect(failureCodeOf(first), FailureCode.network);
        expect(failureOf(first)!.retryable, isTrue);
        expect(rig.store.partials, isEmpty);
        expect(await rig.manager.listDownloaded(), isEmpty);

        expect(
          await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
          isA<Ok<void>>(),
        );
        expect(await rig.manager.listDownloaded(), hasLength(1));
      });

      test('a hash mismatch deletes the partial and reports fileCorrupt with '
          'a retry [FR-READ-010]', () async {
        final DownloadRig rig = DownloadRig();
        rig.transport.corruptOneByte = true;

        final Result<void> result = await rig.manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );

        expect(failureCodeOf(result), FailureCode.fileCorrupt);
        expect(failureOf(result)!.retryable, isTrue);
        expect(rig.store.partials, isEmpty);
        expect(rig.store.files, isEmpty);
        expect(await rig.manager.listDownloaded(), isEmpty);
      });

      test('a size mismatch is fileCorrupt too', () async {
        final DownloadRig rig = DownloadRig();
        rig.transport.stopShortBy = 10;

        expect(
          failureCodeOf(
            await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
          ),
          FailureCode.fileCorrupt,
        );
        expect(await rig.manager.listDownloaded(), isEmpty);
      });

      test(
        'a second start during a transfer runs one transfer (I-4)',
        () async {
          final DownloadRig rig = DownloadRig();
          rig.transport.gate = Completer<void>();

          final Future<Result<void>> first = rig.manager.start(
            'fx-iss-01',
            mobileDataAccepted: false,
          );
          final Future<Result<void>> second = rig.manager.start(
            'fx-iss-01',
            mobileDataAccepted: false,
          );
          rig.transport.gate!.complete();

          expect(await first, isA<Ok<void>>());
          expect(await second, isA<Ok<void>>());
          expect(rig.transport.fetches, 1);
        },
      );

      test('cancel stops the transfer and keeps no partial (RD-01)', () async {
        final DownloadRig rig = DownloadRig();
        rig.transport.gate = Completer<void>();
        final Future<Result<void>> running = rig.manager.start(
          'fx-iss-01',
          mobileDataAccepted: false,
        );
        await settle();

        final Future<Result<void>> cancelled = rig.manager.cancel('fx-iss-01');
        rig.transport.gate!.complete();

        expect(await cancelled, isA<Ok<void>>());
        expect(failureCodeOf(await running), FailureCode.cancelled);
        expect(rig.store.partials, isEmpty);
        expect(
          await rig.manager.watch('fx-iss-01').first,
          isA<NotDownloaded>(),
        );
      });
    });

    group('kept copies', () {
      test('delete frees the space and removes the entry [FR-DL-009, '
          'AC-4.6]', () async {
        final DownloadRig rig = DownloadRig();
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
        final int freeWithCopy = await rig.store.freeBytes();

        expect(await rig.manager.delete('fx-iss-01'), isA<Ok<void>>());

        expect(await rig.store.freeBytes(), freeWithCopy + 1000);
        expect(await rig.manager.listDownloaded(), isEmpty);
        expect(rig.registry.rows, isEmpty);
        expect(
          failureCodeOf(await rig.manager.delete('fx-iss-01')),
          FailureCode.notFound,
        );
      });

      test('two downloads are listed; a partial one is not [FR-DL-008, '
          'AC-4.7]', () async {
        final DownloadRig rig = DownloadRig(
          sizes: const <String, int>{
            'fx-iss-01': 1000,
            'fx-iss-02': 1500,
            'fx-iss-03': 800,
          },
        );
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
        await rig.manager.start('fx-iss-02', mobileDataAccepted: false);
        rig.transport.gate = Completer<void>();
        unawaited(rig.manager.start('fx-iss-03', mobileDataAccepted: false));
        await settle();

        expect(
          (await rig.manager.listDownloaded()).map(
            (DownloadedIssue c) => c.issueId,
          ),
          <String>['fx-iss-01', 'fx-iss-02'],
        );
        rig.transport.gate!.complete();
      });

      test('copies are kept across a restart', () async {
        final DownloadRig rig = DownloadRig();
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false);

        final IssueDownloadManager restarted = rig.newManager();

        expect(await restarted.listDownloaded(), hasLength(1));
        expect(await restarted.watch('fx-iss-01').first, isA<Downloaded>());
      });

      test('another reader sees none of the copies and gets a separate one '
          '(rule 7, RD-05)', () async {
        final DownloadRig rig = DownloadRig();
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false);

        rig.auth.signInAs(fxUsr06);
        expect(await rig.manager.listDownloaded(), isEmpty);
        expect(
          failureCodeOf(await rig.manager.openLocal('fx-iss-01')),
          FailureCode.notFound,
        );

        await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
        expect(rig.store.files, hasLength(2));
        await rig.manager.delete('fx-iss-01');

        rig.auth.signInAs(fxUsr01);
        expect(
          await rig.manager.openLocal('fx-iss-01'),
          isA<Ok<LocalIssueFile>>(),
        );
      });

      test(
        'openLocal drops a copy whose file is missing (section 4.4)',
        () async {
          final DownloadRig rig = DownloadRig();
          await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
          rig.store.files.clear();

          expect(
            failureCodeOf(await rig.manager.openLocal('fx-iss-01')),
            FailureCode.notFound,
          );
          expect(await rig.manager.listDownloaded(), isEmpty);
        },
      );

      test(
        'openLocal treats a copy of the wrong length as damaged [IC-03]',
        () async {
          final DownloadRig rig = DownloadRig();
          await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
          rig.store.files.values.single.removeLast();

          final Result<LocalIssueFile> result = await rig.manager.openLocal(
            'fx-iss-01',
          );

          expect(failureCodeOf(result), FailureCode.fileCorrupt);
          expect(failureOf(result)!.retryable, isTrue);
          expect(rig.store.files, isEmpty);
          expect(await rig.manager.listDownloaded(), isEmpty);
        },
      );
    });
  });

  group('File names [MOD-06]', () {
    test('derive from the issue ID and revision only', () {
      expect(issueFileName('fx-iss-01', 2), 'issue-fx-iss-01-r2.pdf');
      expect(
        issueFileName('fx-iss-01', 2, copy: 3),
        'issue-fx-iss-01-r2-c3.pdf',
      );
    });

    test('cannot name a folder or leave the downloads folder', () {
      final String name = issueFileName('../x/y', 1);

      expect(name, isNot(contains('/')));
      expect(name, startsWith('issue-'));
    });
  });
}
