import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

/// [ReaderController] over an open document of [pageCount] pages
/// (API_AND_MODULE_CONTRACTS section 6.7).
///
/// Pages are 1-based (section 4.3). A page outside the document is clamped
/// to it. The mode is given by the caller: switching and the default are
/// OQ-14, and the two modes are built in T-05.2.
final class PagedReaderController implements ReaderController {
  /// Creates the controller at [initialPage], clamped to the document.
  PagedReaderController({
    required this.pageCount,
    required this._mode,
    int initialPage = 1,
  }) : assert(pageCount >= 1, 'a document has at least one page'),
       _page = _clamp(initialPage, pageCount);

  /// Number of pages in the document.
  final int pageCount;

  final ReaderMode _mode;
  int _page;
  final StreamController<int> _changes = StreamController<int>.broadcast(
    sync: true,
  );

  /// The page shown now.
  int get currentPage => _page;

  @override
  ReaderMode get mode => _mode;

  @override
  Stream<int> watchCurrentPage() {
    StreamSubscription<int>? subscription;
    late final StreamController<int> controller;
    controller = StreamController<int>(
      onListen: () {
        controller.add(_page);
        subscription = _changes.stream.listen(controller.add);
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> goToPage(int page) async {
    final int next = _clamp(page, pageCount);
    if (next == _page) {
      return;
    }
    _page = next;
    _changes.add(next);
  }

  /// Ends [watchCurrentPage] updates.
  Future<void> dispose() => _changes.close();

  static int _clamp(int page, int pageCount) =>
      page < 1 ? 1 : (page > pageCount ? pageCount : page);
}
