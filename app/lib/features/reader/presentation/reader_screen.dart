import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/errors/failure_messages.dart';
import '../../../core/ui/content_widgets.dart';
import '../domain/reader_document.dart';
import '../domain/reader_preferences.dart';
import 'page_turn_view.dart';

/// The reader (SCR-A-14): one issue's pages, one at a time, turned by a
/// drag or by the previous and next buttons (RS FR-READ-003;
/// `CODING_STANDARDS.md` section 9 rule 6), with the page number and a
/// slider to move far (FR-READ-001).
///
/// Pages turn with the page-turn effect, or slide in the plain swipe mode,
/// as the reader chose in settings (MOD07-P2-T02, FR-READ-006 to
/// FR-READ-008, OQ-14 working position: page turn first). Zoom and the
/// two-page spread are MOD07-P2-T03. A file that cannot be
/// opened shows why, with a way to download it again when one is given
/// (FR-READ-010).
class ReaderScreen extends StatefulWidget {
  /// Creates the reader for [file].
  const ReaderScreen({
    required this.file,
    required this.title,
    required this.renderer,
    this.initialPage,
    this.onClose,
    this.onDownloadAgain,
    this.actions,
    this.preferences,
    super.key,
  });

  /// The reader's choice of page turning; null opens in the default mode.
  final ReaderPreferences? preferences;

  /// The pages, in either mode, for tests and the reader check.
  static const Key pagesKey = Key('reader-pages');

  /// The complete, verified copy MOD-06 handed over (IC-03).
  final LocalIssueFile file;

  /// The issue title.
  final String title;

  /// MOD-07's renderer.
  final PdfRenderer renderer;

  /// The page to open at, 1-based; clamped to the document. Null opens the
  /// first page.
  final int? initialPage;

  /// Closes the reader.
  final VoidCallback? onClose;

  /// Downloads the issue again after a damaged file (MOD07-P2-T04).
  final VoidCallback? onDownloadAgain;

  /// Actions in the bar, such as the bookmark (MOD08-P2-T01), given the
  /// reader's state.
  final List<Widget> Function(ReaderController reader)? actions;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    implements ReaderController {
  Result<PdfDocumentHandle>? _opened;
  PageController? _pages;
  int _page = 1;
  ReaderMode _mode = ReaderPreferences.defaultMode;
  final StreamController<int> _pageChanges = StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    final ReaderPreferences? preferences = widget.preferences;
    if (preferences != null) {
      _mode = await preferences.mode().catchError(
        (Object _) => ReaderPreferences.defaultMode,
      );
    }
    final Result<PdfDocumentHandle> opened = await widget.renderer.open(
      widget.file,
    );
    if (!mounted) {
      if (opened case Ok<PdfDocumentHandle>(:final PdfDocumentHandle value)) {
        await value.close();
      }
      return;
    }
    if (opened case Ok<PdfDocumentHandle>(:final PdfDocumentHandle value)) {
      final int count = value.pageCount;
      _page = (widget.initialPage ?? 1).clamp(1, count);
      _pages = PageController(initialPage: _page - 1);
    }
    setState(() {
      _opened = opened;
    });
  }

  @override
  void dispose() {
    _pages?.dispose();
    unawaited(_pageChanges.close());
    if (_opened case Ok<PdfDocumentHandle>(:final PdfDocumentHandle value)) {
      unawaited(value.close());
    }
    super.dispose();
  }

  int get _pageCount => switch (_opened) {
    Ok<PdfDocumentHandle>(:final PdfDocumentHandle value) => value.pageCount,
    _ => 0,
  };

  // ReaderController.

  @override
  Stream<int> watchCurrentPage() async* {
    // The page shown now, then each page turned to.
    yield _page;
    yield* _pageChanges.stream;
  }

  @override
  Future<void> goToPage(int page) async {
    final PageController? pages = _pages;
    if (pages == null || _pageCount == 0) {
      return;
    }
    final int target = page.clamp(1, _pageCount);
    if (_mode == ReaderMode.pageTurn) {
      if (target != _page) {
        _shown(target - 1);
      }
      return;
    }
    if (pages.hasClients) {
      pages.jumpToPage(target - 1);
    }
  }

  @override
  ReaderMode get mode => _mode;

  /// The page currently shown, 1-based.
  int get currentPage => _page;

  void _shown(int index) {
    setState(() {
      _page = index + 1;
    });
    _pageChanges.add(_page);
  }

  @override
  Widget build(BuildContext context) {
    final Result<PdfDocumentHandle>? opened = _opened;
    return Scaffold(
      backgroundColor: MfwColours.inputFill,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onClose == null
            ? null
            : IconButton(
                tooltip: ReaderText.close,
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
        title: Text(widget.title),
        actions: opened is Ok<PdfDocumentHandle>
            ? widget.actions?.call(this)
            : null,
      ),
      body: switch (opened) {
        null => Center(
          child: CircularProgressIndicator(semanticsLabel: ReaderText.opening),
        ),
        Err<PdfDocumentHandle>(:final AppFailure failure) => _Unopened(
          failure: failure,
          onDownloadAgain: widget.onDownloadAgain,
          onClose: widget.onClose,
        ),
        Ok<PdfDocumentHandle>(:final PdfDocumentHandle value) =>
          switch (_mode) {
            ReaderMode.swipe => PageView.builder(
              key: ReaderScreen.pagesKey,
              controller: _pages,
              itemCount: value.pageCount,
              onPageChanged: _shown,
              itemBuilder: (BuildContext context, int index) =>
                  _pageAt(value, index),
            ),
            ReaderMode.pageTurn => PageTurnView(
              key: ReaderScreen.pagesKey,
              page: _page - 1,
              pageCount: value.pageCount,
              onPageChanged: _shown,
              itemBuilder: (BuildContext context, int index) =>
                  _pageAt(value, index),
            ),
          },
      },
      bottomNavigationBar: opened is Ok<PdfDocumentHandle>
          ? _PageBar(
              page: _page,
              pageCount: _pageCount,
              onGoTo: (int page) => unawaited(goToPage(page)),
            )
          : null,
    );
  }
}

/// Page [index] (0-based) of [document] on the reader's background, so a
/// page turning over another hides it.
Widget _pageAt(PdfDocumentHandle document, int index) => ColoredBox(
  color: MfwColours.inputFill,
  child: Padding(
    padding: const EdgeInsets.all(MfwSpace.lg),
    child: Semantics(
      label: ReaderText.pageOf(index + 1, document.pageCount),
      child: document is ReaderDocument
          ? document.page(index + 1)
          : const SizedBox.expand(),
    ),
  ),
);

class _PageBar extends StatelessWidget {
  const _PageBar({
    required this.page,
    required this.pageCount,
    required this.onGoTo,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        color: MfwColours.surface,
        padding: const EdgeInsets.symmetric(horizontal: MfwSpace.sm),
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: ReaderText.previous,
              icon: const Icon(Icons.chevron_left),
              onPressed: page > 1 ? () => onGoTo(page - 1) : null,
            ),
            Expanded(
              child: pageCount > 1
                  ? Slider(
                      value: page.toDouble(),
                      min: 1,
                      max: pageCount.toDouble(),
                      divisions: pageCount - 1,
                      label: '$page',
                      semanticFormatterCallback: (double value) =>
                          ReaderText.pageOf(value.round(), pageCount),
                      onChanged: (double value) => onGoTo(value.round()),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(ReaderText.position(page, pageCount), style: MfwType.small),
            IconButton(
              tooltip: ReaderText.next,
              icon: const Icon(Icons.chevron_right),
              onPressed: page < pageCount ? () => onGoTo(page + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Unopened extends StatelessWidget {
  const _Unopened({required this.failure, this.onDownloadAgain, this.onClose});

  final AppFailure failure;
  final VoidCallback? onDownloadAgain;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bool damaged = failure.code == FailureCode.fileCorrupt;
    final VoidCallback? again = onDownloadAgain;
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        ContentNotice(messageFor(failure)),
        EmptyState(
          icon: Icons.broken_image_outlined,
          heading: damaged ? ReaderText.damagedHeading : ReaderText.cannotOpen,
          text: damaged ? ReaderText.damagedText : messageFor(failure),
          action: damaged && again != null
              ? FilledButton(
                  onPressed: again,
                  child: const Text(ReaderText.downloadAgain),
                )
              : onClose == null
              ? null
              : OutlinedButton(
                  onPressed: onClose,
                  child: const Text(ReaderText.close),
                ),
        ),
      ],
    );
  }
}

/// User-facing text of SCR-A-14. PLACEHOLDER wording from the reader frames
/// until M2.
abstract final class ReaderText {
  /// Closes the reader.
  static const String close = 'Close';

  /// Spoken while the issue opens.
  static const String opening = 'Opening the issue';

  /// Turns back a page.
  static const String previous = 'Previous page';

  /// Turns forward a page.
  static const String next = 'Next page';

  /// Heading for a damaged file.
  static const String damagedHeading = 'This issue could not be opened';

  /// Line for a damaged file.
  static const String damagedText =
      'The copy on this device is damaged. Download it again to read it.';

  /// Heading for any other failure to open.
  static const String cannotOpen = 'This issue cannot be opened';

  /// Downloads the issue again.
  static const String downloadAgain = 'Download again';

  /// The position shown in the bar, such as "7 / 64".
  static String position(int page, int pageCount) => '$page / $pageCount';

  /// What a screen reader says for a page, such as "Page 7 of 64".
  static String pageOf(int page, int pageCount) => 'Page $page of $pageCount';
}
