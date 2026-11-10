import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/reader_route.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_download_manager.dart';
import '../fakes/fake_issue_file_service.dart';
import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';
import '../features/reader/reader_screen_test.dart'
    show FakeDocument, FakeRenderer;
import '../fixtures/fx_issue_files.dart';

FakeDownloadManager downloadsFor(TestUser user) {
  final FakeAuthService auth = FakeAuthService(FakeServer(), signedInAs: user);
  return FakeDownloadManager(
    auth,
    FakeIssueFileService(auth, files: fxIssueFiles),
  );
}

Future<void> pumpRoute(
  WidgetTester tester,
  DownloadManager downloads,
  PdfRenderer renderer, {
  int? initialPage,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMfwTheme(),
      home: ReaderRoute(
        issueId: 'fx-iss-01',
        downloads: downloads,
        renderer: renderer,
        titleOf: (String _) async => 'Test Issue 01',
        initialPage: initialPage,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ReaderRoute: MOD-06 hands MOD-07 the copy [MOD06-P3-T03, IC-03]', () {
    testWidgets('a downloaded issue opens in the reader at the page asked '
        'for [FR-DL-007, AC-4.2]', (WidgetTester tester) async {
      final FakeDownloadManager downloads = downloadsFor(fxUsr01);
      await downloads.start('fx-iss-01', mobileDataAccepted: true);
      final FakeRenderer renderer = FakeRenderer(
        Ok<PdfDocumentHandle>(FakeDocument(4)),
      );
      await pumpRoute(tester, downloads, renderer, initialPage: 3);

      expect(renderer.opened.single.issueId, 'fx-iss-01');
      expect(find.text('Test Issue 01'), findsOneWidget);
      expect(find.text('3 / 4'), findsOneWidget);
    });

    testWidgets('the pages open without waiting for the title, which comes '
        'when it can [IC-03]', (WidgetTester tester) async {
      final FakeDownloadManager downloads = downloadsFor(fxUsr01);
      await downloads.start('fx-iss-01', mobileDataAccepted: true);
      final Completer<String> title = Completer<String>();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: ReaderRoute(
            issueId: 'fx-iss-01',
            downloads: downloads,
            renderer: FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(4))),
            titleOf: (String _) => title.future,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 / 4'), findsOneWidget);

      title.complete('Test Issue 01');
      await tester.pumpAndSettle();
      expect(find.text('Test Issue 01'), findsOneWidget);
    });

    testWidgets('with no copy it offers the download in place, and opens '
        'the reader when it completes [DEC-033 pending OQ-08]', (
      WidgetTester tester,
    ) async {
      final FakeDownloadManager downloads = downloadsFor(fxUsr01);
      await pumpRoute(
        tester,
        downloads,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(2))),
      );
      expect(find.text('Download this issue to read it'), findsOneWidget);
      expect(find.byType(DownloadPanel), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Download'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('a copy the reader cannot open is removed and offered '
        'again [FR-READ-010, AC-2.6]', (WidgetTester tester) async {
      final FakeDownloadManager downloads = downloadsFor(fxUsr01);
      await downloads.start('fx-iss-01', mobileDataAccepted: true);
      await pumpRoute(
        tester,
        downloads,
        FakeRenderer(
          const Err<PdfDocumentHandle>(
            AppFailure(FailureCode.fileCorrupt, retryable: true),
          ),
        ),
      );
      await tester.tap(find.text('Download again'));
      await tester.pumpAndSettle();

      expect(await downloads.listDownloaded(), isEmpty);
      expect(
        find.text('The copy on this device was damaged and has been removed.'),
        findsOneWidget,
      );
      expect(find.byType(DownloadPanel), findsOneWidget);
    });
  });
}
