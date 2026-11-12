// MOD06-P3-T01: Read opens a temporary copy, Download keeps one (RS
// FR-READ-002, FR-DL-001, FR-DL-008; OQ-08 working position of 12 November
// 2026, PROVISIONAL). Synthetic values only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/reader_route.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../../fakes/fake_reader_preferences.dart';
import '../reader/reader_screen_test.dart'
    show FakeDocument, FakeRenderer, phone, useSize;
import 'download_fakes.dart';
import 'download_test_support.dart';

void main() {
  group('a temporary copy [Read]', () {
    test('opens, is not listed, and leaves no pending download', () async {
      final DownloadRig rig = DownloadRig();

      expect(
        await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true),
        isA<Ok<void>>(),
      );

      expect(
        await rig.manager.openLocal('fx-iss-01'),
        isA<Ok<LocalIssueFile>>(),
      );
      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.manager.isTemporary('fx-iss-01'), isTrue);
      expect(await rig.manager.watch('fx-iss-01').first, isA<Downloaded>());
      expect(await rig.pending.load(), isEmpty);
      expect(await rig.registry.load(), isEmpty);
    });

    test('goes when the reader closes it', () async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true);

      await rig.manager.discardTemporary('fx-iss-01');

      expect(rig.store.files, isEmpty);
      expect(rig.manager.isTemporary('fx-iss-01'), isFalse);
      final Result<LocalIssueFile> gone = await rig.manager.openLocal(
        'fx-iss-01',
      );
      expect((gone as Err<LocalIssueFile>).failure.code, FailureCode.notFound);
      expect(await rig.manager.watch('fx-iss-01').first, isA<NotDownloaded>());
    });

    test('goes at the next start if the app stopped first', () async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true);
      expect(rig.store.files, hasLength(1));

      rig.manager = rig.newManager();
      expect(await rig.manager.listDownloaded(), isEmpty);

      expect(rig.store.files, isEmpty);
      expect(
        await rig.manager.openLocal('fx-iss-01'),
        isA<Err<LocalIssueFile>>(),
      );
    });

    test('a stopped one is not resumed after a restart', () async {
      final DownloadRig rig = DownloadRig();
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
      await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true);

      expect(await rig.pending.load(), isEmpty);
    });
  });

  group('a kept copy [Download]', () {
    test('with a kept copy, Read fetches nothing', () async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: true);
      final int fetches = rig.transport.fetches;

      await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true);

      expect(rig.transport.fetches, fetches);
      expect(rig.manager.isTemporary('fx-iss-01'), isFalse);
    });

    test(
      'Download while reading keeps the same copy without fetching again',
      () async {
        final DownloadRig rig = DownloadRig();
        await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true);
        final int fetches = rig.transport.fetches;

        expect(
          await rig.manager.start('fx-iss-01', mobileDataAccepted: true),
          isA<Ok<void>>(),
        );

        expect(rig.transport.fetches, fetches);
        expect(rig.manager.isTemporary('fx-iss-01'), isFalse);
        expect(
          (await rig.manager.listDownloaded()).map(
            (DownloadedIssue c) => c.issueId,
          ),
          <String>['fx-iss-01'],
        );
        await rig.manager.discardTemporary('fx-iss-01');
        expect(rig.store.files, hasLength(1));
      },
    );

    test(
      'account deletion and a deleted issue remove temporary copies too',
      () async {
        final DownloadRig rig = DownloadRig();
        await rig.manager.startTemporary('fx-iss-01', mobileDataAccepted: true);
        await rig.manager.removeIssues(<String>{'fx-iss-01'});
        expect(rig.store.files, isEmpty);

        await rig.manager.startTemporary('fx-iss-02', mobileDataAccepted: true);
        await rig.manager.removeReader(rig.auth.currentUserId!);
        expect(rig.store.files, isEmpty);
      },
    );
  });

  group('SCR-A-14 with no copy', () {
    testWidgets('Read now opens a temporary copy, and leaving the reader '
        'removes it', (WidgetTester tester) async {
      useSize(tester, phone);
      final DownloadRig rig = DownloadRig();
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: ValueListenableBuilder<bool>(
            valueListenable: open,
            builder: (BuildContext context, bool shown, Widget? _) => shown
                ? ReaderRoute(
                    issueId: 'fx-iss-01',
                    downloads: rig.manager,
                    renderer: FakeRenderer(
                      Ok<PdfDocumentHandle>(FakeDocument(2)),
                    ),
                    titleOf: (String _) async => 'Test Issue 01',
                    preferences: MemoryReaderPreferences(ReaderMode.swipe),
                  )
                : const SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(ReaderRouteText.downloadFirstHeading), findsOneWidget);

      await tester.tap(
        find.widgetWithText(FilledButton, DownloadsText.readNow),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);
      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.store.files, hasLength(1));

      open.value = false;
      await tester.pumpAndSettle();
      expect(rig.store.files, isEmpty);
    });
  });
}
