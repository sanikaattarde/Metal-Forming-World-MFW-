import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/domain/paged_reader_controller.dart';
import 'package:mfw_app/features/reader/domain/reader_layout.dart';
import 'package:mfw_app/features/reader/presentation/reader_page_source.dart';
import 'package:mfw_app/features/reader/presentation/reader_session.dart';
import 'package:mfw_app/features/reader/presentation/reader_text.dart';
import 'package:mfw_app/features/reader/presentation/zoomable_page.dart';

/// The reader (SCR-A-14): opens a downloaded issue and shows its pages.
///
/// Loading, data and error states (RS FR-STATE-001 to FR-STATE-003). A
/// damaged file shows an error with a retry (FR-READ-010). Pages turn by
/// swiping or with the page buttons (CODING_STANDARDS section 9, item 6).
/// Not built here: the page-turn and swipe modes (T-05.2, OQ-14), tap zones,
/// and the bookmark action (MOD-08).
class ReaderScreen extends StatefulWidget {
  /// Creates the reader for [issueId], starting at [initialPage].
  const ReaderScreen({
    required this.downloads,
    required this.renderer,
    required this.pages,
    required this.issueId,
    required this.mode,
    this.initialPage = 1,
    super.key,
  });

  /// MOD-06, which hands over the local file.
  final DownloadManager downloads;

  /// The library wrapper chosen under DEC-005.
  final PdfRenderer renderer;

  /// Draws the pages.
  final ReaderPageSource pages;

  /// The issue to open.
  final String issueId;

  /// The page-turn mode (OQ-14).
  final ReaderMode mode;

  /// The page to open at, 1-based.
  final int initialPage;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final ReaderSession _session = ReaderSession(
    downloads: widget.downloads,
    renderer: widget.renderer,
    issueId: widget.issueId,
    mode: widget.mode,
    initialPage: widget.initialPage,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_session.open());
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (BuildContext context, Widget? child) =>
          switch (_session.state) {
            ReaderOpening() => const _ReaderLoading(),
            ReaderFailed(:final AppFailure failure) => _ReaderError(
              failure: failure,
              onRetry: () => unawaited(_session.retry()),
            ),
            ReaderReady(
              :final PdfDocumentHandle document,
              :final PagedReaderController controller,
            ) =>
              _ReaderPages(
                key: ObjectKey(controller),
                document: document,
                controller: controller,
                pages: widget.pages,
              ),
          },
    );
  }
}

class _ReaderLoading extends StatelessWidget {
  const _ReaderLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ReaderText.title)),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(ReaderText.loading),
          ],
        ),
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String message = switch (failure.code) {
      FailureCode.fileCorrupt => ReaderText.damaged,
      FailureCode.notFound => ReaderText.notOnDevice,
      _ => ReaderText.failed,
    };
    return Scaffold(
      appBar: AppBar(title: const Text(ReaderText.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message, textAlign: TextAlign.center),
              if (failure.retryable) ...<Widget>[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text(ReaderText.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderPages extends StatefulWidget {
  const _ReaderPages({
    required this.document,
    required this.controller,
    required this.pages,
    super.key,
  });

  final PdfDocumentHandle document;
  final PagedReaderController controller;
  final ReaderPageSource pages;

  @override
  State<_ReaderPages> createState() => _ReaderPagesState();
}

/// Page buttons are at least 48 by 48 (CODING_STANDARDS section 9, item 3).
final ButtonStyle _pageButtonStyle = IconButton.styleFrom(
  minimumSize: const Size.square(48),
);

class _ReaderPagesState extends State<_ReaderPages> {
  PageController? _pageController;
  ReaderLayout? _layout;
  bool _zoomed = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// A new controller when the layout changes, starting on the view that
  /// holds the current page, so turning the device keeps the place.
  PageController _controllerFor(ReaderLayout layout) {
    final PageController? current = _pageController;
    if (current != null && layout == _layout) {
      return current;
    }
    if (current != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => current.dispose());
    }
    final PageController next = PageController(
      initialPage: viewIndexOf(widget.controller.currentPage, layout),
    );
    _pageController = next;
    _layout = layout;
    _zoomed = false;
    return next;
  }

  void _showPage(int page) {
    unawaited(widget.controller.goToPage(page));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ReaderLayout layout = layoutFor(MediaQuery.sizeOf(context));
    final PageController pageController = _controllerFor(layout);
    final List<List<int>> views = spreadsFor(widget.document.pageCount, layout);
    final int page = widget.controller.currentPage;
    final int index = viewIndexOf(page, layout);
    return Scaffold(
      appBar: AppBar(title: const Text(ReaderText.title)),
      body: PageView.builder(
        key: ValueKey<ReaderLayout>(layout),
        controller: pageController,
        physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
        itemCount: views.length,
        onPageChanged: (int view) => _showPage(views[view].first),
        itemBuilder: (BuildContext context, int view) => ZoomablePage(
          onZoomedChanged: (bool zoomed) => setState(() => _zoomed = zoomed),
          child: Row(
            children: <Widget>[
              for (final int shown in views[view])
                Expanded(
                  child: widget.pages.buildPage(
                    context,
                    widget.document,
                    shown,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: ReaderText.previousPage,
              style: _pageButtonStyle,
              icon: const Icon(Icons.chevron_left),
              onPressed: index > 0
                  ? () => pageController.jumpToPage(index - 1)
                  : null,
            ),
            Text(ReaderText.pageOf(page, widget.document.pageCount)),
            IconButton(
              tooltip: ReaderText.nextPage,
              style: _pageButtonStyle,
              icon: const Icon(Icons.chevron_right),
              onPressed: index < views.length - 1
                  ? () => pageController.jumpToPage(index + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
