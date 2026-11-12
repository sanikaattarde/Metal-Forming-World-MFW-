// MOD07-P2-T04: a damaged file shows an error with a way to download it
// again, and the new copy opens (RS FR-READ-010, AC-2.6, IC-03). End to end
// on the real download manager over fake storage: MOD-06 hands the copy to
// MOD-07, which cannot open it, and the reader's "Download again" goes back
// through MOD-06. On a device, PDFium refusing the truncated FX-PDF-10 is
// checked by `integration_test/reader_pdfrx_test.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/reader_route.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../fakes/fake_reader_preferences.dart';
import '../features/downloads/download_test_support.dart';
import '../features/reader/reader_screen_test.dart'
    show FakeDocument, phone, useSize;

/// A renderer that refuses the first [refusals] opens as damaged, as PDFium
/// refuses a truncated file, then opens a three-page document.
final class FlakyRenderer implements PdfRenderer {
  FlakyRenderer({this.refusals = 1});

  int refusals;
  int opens = 0;

  @override
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file) async {
    opens++;
    if (refusals > 0) {
      refusals--;
      return const Err<PdfDocumentHandle>(
        AppFailure(FailureCode.fileCorrupt, retryable: true, detail: 'open'),
      );
    }
    return Ok<PdfDocumentHandle>(FakeDocument(3));
  }
}

Future<void> pumpRoute(
  WidgetTester tester,
  DownloadManager downloads,
  PdfRenderer renderer,
) async {
  useSize(tester, phone);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMfwTheme(),
      home: ReaderRoute(
        issueId: 'fx-iss-01',
        downloads: downloads,
        renderer: renderer,
        titleOf: (String _) async => 'Test Issue 01',
        preferences: MemoryReaderPreferences(ReaderMode.swipe),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AC-2.6: a damaged file, then a working copy', () {
    testWidgets('a copy PDFium cannot open: an error, Download again, and the '
        'new copy opens', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: true);
      final FlakyRenderer renderer = FlakyRenderer();
      await pumpRoute(tester, rig.manager, renderer);

      expect(find.text(ReaderText.damagedHeading), findsOneWidget);
      await tester.tap(find.text(ReaderText.downloadAgain));
      await tester.pumpAndSettle();
      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.store.files, isEmpty);
      expect(find.text(ReaderRouteText.damaged), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Download'));
      await tester.pumpAndSettle();

      expect(renderer.opens, 2);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('a copy damaged on disk (wrong length) is removed before the '
        'reader, and downloads again', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: true);
      final String path = rig.store.files.keys.single;
      rig.store.files[path] = rig.store.files[path]!.sublist(0, 10);
      final FlakyRenderer renderer = FlakyRenderer(refusals: 0);
      await pumpRoute(tester, rig.manager, renderer);

      expect(renderer.opens, 0);
      expect(find.text(ReaderRouteText.damaged), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Download'));
      await tester.pumpAndSettle();

      expect(find.text('1 / 3'), findsOneWidget);
      expect(rig.store.files.values.single, hasLength(1000));
    });

    testWidgets('a copy that stays damaged keeps saying so, with no crash', (
      WidgetTester tester,
    ) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: true);
      final FlakyRenderer renderer = FlakyRenderer(refusals: 2);
      await pumpRoute(tester, rig.manager, renderer);

      await tester.tap(find.text(ReaderText.downloadAgain));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Download'));
      await tester.pumpAndSettle();

      expect(find.text(ReaderText.damagedHeading), findsOneWidget);
      expect(find.text(ReaderText.downloadAgain), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
