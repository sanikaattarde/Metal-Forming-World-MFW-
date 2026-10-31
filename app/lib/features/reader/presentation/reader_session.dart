import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/domain/paged_reader_controller.dart';

/// What the reader shows (RS FR-STATE-001 to FR-STATE-003).
sealed class ReaderViewState {
  /// Base constructor for the three states.
  const ReaderViewState();
}

/// The issue is being opened.
final class ReaderOpening extends ReaderViewState {
  /// Creates the state.
  const ReaderOpening();
}

/// The issue is open.
final class ReaderReady extends ReaderViewState {
  /// Creates the state for [document], navigated by [controller].
  const ReaderReady(this.document, this.controller);

  /// The open document.
  final PdfDocumentHandle document;

  /// The page position.
  final PagedReaderController controller;
}

/// The issue could not be opened.
final class ReaderFailed extends ReaderViewState {
  /// Creates the state with [failure].
  const ReaderFailed(this.failure);

  /// Why it failed: `notFound` when there is no complete copy, `fileCorrupt`
  /// when the copy or the PDF is damaged.
  final AppFailure failure;
}

/// Opens one downloaded issue for reading (MOD-07, IC-03).
///
/// The local file comes only from MOD-06 openLocal. A document with no
/// pages counts as damaged.
final class ReaderSession extends ChangeNotifier {
  /// Creates a session for [issueId], starting at [initialPage].
  ReaderSession({
    required this._downloads,
    required this._renderer,
    required this.issueId,
    required this.mode,
    this.initialPage = 1,
  });

  final DownloadManager _downloads;
  final PdfRenderer _renderer;

  /// The issue to open.
  final String issueId;

  /// The page-turn mode, passed to the controller (OQ-14).
  final ReaderMode mode;

  /// The page to open at, 1-based.
  final int initialPage;

  ReaderViewState _state = const ReaderOpening();
  bool _disposed = false;

  /// What the reader shows now.
  ReaderViewState get state => _state;

  /// Opens the issue: [ReaderOpening], then [ReaderReady] or [ReaderFailed].
  Future<void> open() async {
    await _release();
    _set(const ReaderOpening());
    final LocalIssueFile file;
    switch (await _downloads.openLocal(issueId)) {
      case Err<LocalIssueFile>(:final AppFailure failure):
        _set(ReaderFailed(failure));
        return;
      case Ok<LocalIssueFile>(:final LocalIssueFile value):
        file = value;
    }
    final PdfDocumentHandle document;
    switch (await _renderer.open(file)) {
      case Err<PdfDocumentHandle>(:final AppFailure failure):
        _set(ReaderFailed(failure));
        return;
      case Ok<PdfDocumentHandle>(:final PdfDocumentHandle value):
        document = value;
    }
    if (_disposed || document.pageCount < 1) {
      await document.close();
      _set(
        const ReaderFailed(
          AppFailure(FailureCode.fileCorrupt, retryable: true),
        ),
      );
      return;
    }
    _set(
      ReaderReady(
        document,
        PagedReaderController(
          pageCount: document.pageCount,
          mode: mode,
          initialPage: initialPage,
        ),
      ),
    );
  }

  /// Opens the issue again.
  // TODO(yg): RD-06 proposes that retry deletes a damaged copy and downloads
  // it again through MOD-06; wire that in when WB-06 builds the downloads.
  Future<void> retry() => open();

  @override
  void dispose() {
    _disposed = true;
    unawaited(_release());
    super.dispose();
  }

  Future<void> _release() async {
    final ReaderViewState previous = _state;
    if (previous is! ReaderReady) {
      return;
    }
    _state = const ReaderOpening();
    await previous.controller.dispose();
    await previous.document.close();
  }

  void _set(ReaderViewState next) {
    if (_disposed) {
      return;
    }
    _state = next;
    notifyListeners();
  }
}
