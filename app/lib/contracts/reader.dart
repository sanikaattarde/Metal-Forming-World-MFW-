import 'downloads.dart';
import 'result.dart';

/// Wraps the library chosen under DEC-005.
abstract interface class PdfRenderer {
  /// Opens [file]. Fails with `fileCorrupt` when the file is damaged.
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file);
}

/// An open PDF document.
abstract interface class PdfDocumentHandle {
  /// Number of pages.
  int get pageCount;

  /// Closes the document. Page-rendering methods are defined after DEC-005.
  Future<void> close();
}

/// How pages are turned. Switching and the default: OQ-14.
enum ReaderMode {
  /// Page-turn effect (RS FR-READ-006).
  pageTurn,

  /// Plain swipe (RS FR-READ-007).
  swipe,
}

/// Reader state for one open issue (MOD-07).
abstract interface class ReaderController {
  /// Emits the current page, 1-based.
  Stream<int> watchCurrentPage();

  /// Goes to [page], 1-based.
  Future<void> goToPage(int page);

  /// The page-turn mode. Switching and the default: OQ-14.
  ReaderMode get mode;
}
