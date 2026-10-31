import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

/// An open fake document with a fixed page count.
final class FakePdfDocument implements PdfDocumentHandle {
  /// Creates a document of [pageCount] pages.
  FakePdfDocument(this.pageCount);

  @override
  final int pageCount;

  /// Whether [close] was called.
  bool closed = false;

  @override
  Future<void> close() async => closed = true;
}

/// Fake PdfRenderer (MOD-07). Files of [damagedIssueIds] stand in for
/// FX-PDF-10 and FX-PDF-11 and fail with `fileCorrupt`; there are no real
/// PDF bytes until WB-05's generator exists.
final class FakePdfRenderer implements PdfRenderer {
  /// Creates the renderer.
  FakePdfRenderer({
    required this.pageCounts,
    Set<String> damagedIssueIds = const <String>{},
  }) : damagedIssueIds = Set<String>.of(damagedIssueIds);

  /// Page count per issue ID.
  final Map<String, int> pageCounts;

  /// Issues whose file is damaged; tests may change it.
  final Set<String> damagedIssueIds;

  /// When set, [open] waits for it, so a test can see the loading state.
  Completer<void>? gate;

  /// Every document opened, in order.
  final List<FakePdfDocument> opened = <FakePdfDocument>[];

  @override
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file) async {
    await gate?.future;
    final int? pages = pageCounts[file.issueId];
    if (pages == null || damagedIssueIds.contains(file.issueId)) {
      return const Err<PdfDocumentHandle>(
        AppFailure(FailureCode.fileCorrupt, retryable: true),
      );
    }
    final FakePdfDocument document = FakePdfDocument(pages);
    opened.add(document);
    return Ok<PdfDocumentHandle>(document);
  }
}
