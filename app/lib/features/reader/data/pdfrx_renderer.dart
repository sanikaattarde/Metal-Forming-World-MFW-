import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:pdfrx/pdfrx.dart';

import '../domain/reader_document.dart';

/// The [PdfRenderer] on pdfrx (DEP-64), the library the comparison spike
/// chose (MOD07-P1-T01). YG's position on DEC-005 of 10 November 2026 is
/// pdfrx; DEC-005 stays OPEN until Sanika Attarde agrees and MFW sees the
/// reader test at M2, so this is PROPOSED.
///
/// Opens only a complete local file handed over by MOD-06 (IC-03). A file
/// that is missing is `notFound`; one PDFium cannot open, or with no pages,
/// is `fileCorrupt` with a retry, which downloads it again (FR-READ-010).
/// The path is never logged.
final class PdfrxRenderer implements PdfRenderer {
  /// Creates the renderer.
  const PdfrxRenderer();

  @override
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file) async {
    if (!await File(file.path).exists()) {
      return const Err<PdfDocumentHandle>(
        AppFailure(FailureCode.notFound, detail: 'no local file'),
      );
    }
    final PdfDocument document;
    try {
      await pdfrxFlutterInitialize();
      document = await PdfDocument.openFile(file.path);
    } on Exception {
      return const Err<PdfDocumentHandle>(
        AppFailure(FailureCode.fileCorrupt, retryable: true, detail: 'open'),
      );
    }
    if (document.pages.isEmpty) {
      await document.dispose();
      return const Err<PdfDocumentHandle>(
        AppFailure(FailureCode.fileCorrupt, retryable: true, detail: 'empty'),
      );
    }
    return Ok<PdfDocumentHandle>(_PdfrxDocument(document));
  }
}

final class _PdfrxDocument implements ReaderDocument {
  _PdfrxDocument(this._document);

  final PdfDocument _document;

  @override
  int get pageCount => _document.pages.length;

  @override
  bool isLandscape(int pageNumber) {
    final PdfPage page = _document.pages[pageNumber - 1];
    return page.width > page.height;
  }

  @override
  Widget page(int pageNumber) =>
      PdfPageView(document: _document, pageNumber: pageNumber);

  @override
  Future<void> close() => _document.dispose();
}
