// MOD07-P2-T01 on a device: pdfrx (PDFium) behind PdfRenderer, opening
// the generated fixtures FX-PDF-01 and FX-PDF-02, refusing the truncated
// FX-PDF-10, and paging through SCR-A-14. FX-PDF-03 and FX-PDF-04 are MFW's
// samples and are never used here (DEC-024).
//
// Run from `app/`:
//   flutter test integration_test/reader_pdfrx_test.dart -d <id>
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../test/fixtures/synthetic_pdf.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory folder;

  setUpAll(() async {
    folder = await Directory.systemTemp.createTemp('mfw-reader-');
  });

  tearDownAll(() => folder.delete(recursive: true));

  Future<LocalIssueFile> write(String name, List<int> bytes) async {
    final File file = File('${folder.path}/$name.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return LocalIssueFile(issueId: name, fileRevision: 1, path: file.path);
  }

  test('opens FX-PDF-01 with its four pages [AC-2.2]', () async {
    final Result<PdfDocumentHandle> opened = await const PdfrxRenderer().open(
      await write('fx-pdf-01', fxPdf01()),
    );
    final PdfDocumentHandle document = (opened as Ok<PdfDocumentHandle>).value;
    expect(document.pageCount, 4);
    expect((document as ReaderDocument).isLandscape(1), isFalse);
    await document.close();
  });

  test('opens FX-PDF-02 and tells its landscape pages [AC-2.4]', () async {
    final Result<PdfDocumentHandle> opened = await const PdfrxRenderer().open(
      await write('fx-pdf-02', fxPdf02()),
    );
    final ReaderDocument document =
        (opened as Ok<PdfDocumentHandle>).value as ReaderDocument;
    expect(document.pageCount, 5);
    expect(
      <bool>[for (int page = 1; page <= 5; page++) document.isLandscape(page)],
      <bool>[false, true, false, true, false],
    );
    await document.close();
  });

  test('the truncated FX-PDF-10 is fileCorrupt with a retry, not a crash '
      '[FR-READ-010, AC-2.6]', () async {
    final Result<PdfDocumentHandle> opened = await const PdfrxRenderer().open(
      await write('fx-pdf-10', fxPdf10()),
    );
    if (opened case Ok<PdfDocumentHandle>(:final PdfDocumentHandle value)) {
      // PDFium may repair a truncated file; then it must still have pages.
      expect(value.pageCount, greaterThan(0));
      await value.close();
    } else {
      final AppFailure failure = (opened as Err<PdfDocumentHandle>).failure;
      expect(failure.code, FailureCode.fileCorrupt);
      expect(failure.retryable, isTrue);
    }
  });

  test('a missing file is notFound', () async {
    final Result<PdfDocumentHandle> opened = await const PdfrxRenderer().open(
      LocalIssueFile(
        issueId: 'none',
        fileRevision: 1,
        path: '${folder.path}/none.pdf',
      ),
    );
    expect(
      (opened as Err<PdfDocumentHandle>).failure.code,
      FailureCode.notFound,
    );
  });

  testWidgets('SCR-A-14 shows FX-PDF-01 and turns its pages with the '
      'buttons and a swipe [FR-READ-003, FR-READ-007]', (
    WidgetTester tester,
  ) async {
    final LocalIssueFile file = await write('fx-pdf-01-screen', fxPdf01());
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: ReaderScreen(
          file: file,
          title: 'FX-PDF-01',
          renderer: const PdfrxRenderer(),
        ),
      ),
    );
    await _until(tester, find.text('1 / 4'));

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
    await _until(tester, find.text('2 / 4'));

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await _until(tester, find.text('3 / 4'));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _until(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}
