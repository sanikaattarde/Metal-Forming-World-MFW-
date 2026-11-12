import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/errors/failure_messages.dart';
import '../../../core/ui/content_widgets.dart';
import '../domain/reader_document.dart';
import '../domain/reader_preferences.dart';
import '../domain/spreads.dart';
import 'page_turn_view.dart';
import 'swipe_pages.dart';
import 'zoomable_unit.dart';

/// The reader (SCR-A-14): one issue's pages, one at a time, turned by a
/// drag or by the previous and next buttons (RS FR-READ-003;
/// `CODING_STANDARDS.md` section 9 rule 6), with the page number and a
/// slider to move far (FR-READ-001).
///
/// Pages turn with the page-turn effect, or slide in the plain swipe mode,
/// as the reader chose in settings (MOD07-P2-T02, FR-READ-006 to
/// FR-READ-008, OQ-14 working position: page turn first). Pinch or double
/// tap zooms up to 300%, redrawn sharp once the gesture ends, and a zoomed
/// page pans instead of turning (FR-READ-005). When the reader is wider
/// than it is tall, two pages show side by side after the cover
/// (FR-READ-009, MOD07-P2-T03). A file that cannot be
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
  int _page = 1;
  bool _zoomed = false;
  int _pointers = 0;

  /// What the last build showed, one page or two at a time.
  List<List<int>> _units = const <List<int>>[];
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
    }
    setState(() {
      _opened = opened;
    });
  }

  @override
  void dispose() {
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
    if (_pageCount == 0) {
      return;
    }
    _show(page.clamp(1, _pageCount));
  }

  @override
  ReaderMode get mode => _mode;

  /// The page currently shown, 1-based.
  int get currentPage => _page;

  /// Shows [page], 1-based, and reports it when it changed.
  void _show(int page) {
    if (page == _page) {
      return;
    }
    setState(() {
      _page = page;
      _zoomed = false;
    });
    _pageChanges.add(_page);
  }

  /// A view turned to [unit]: its first page is the one shown.
  void _shownUnit(int unit) {
    if (unit < 0 || unit >= _units.length || _units[unit].contains(_page)) {
      return;
    }
    _show(_units[unit].first);
  }

  void _setZoomed(bool zoomed) {
    if (zoomed != _zoomed) {
      setState(() => _zoomed = zoomed);
    }
  }

  void _pointer(int change) => setState(() {
    _pointers = (_pointers + change).clamp(0, 10);
  });

  /// Whether two pages show side by side: when the screen is wider than
  /// it is tall, on a phone or a tablet (FR-READ-009).
  bool _spread(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  Widget _pages(PdfDocumentHandle document, bool spread) {
    return Builder(
      builder: (BuildContext context) {
        final int index = unitOf(_units, _page);
        // At 100% with one finger down, a drag turns the page; zoomed, or
        // with two fingers down, it moves or zooms the page.
        final bool turning = !_zoomed && _pointers < 2;
        Widget unit(BuildContext context, int i) {
          final List<int> shown = _units[i];
          return ZoomableUnit(
            key: ValueKey<String>('${shown.join('-')} $spread'),
            onZoomed: _setZoomed,
            builder: (BuildContext context, double sharpness) =>
                _unitAt(document, shown, sharpness),
          );
        }

        return Listener(
          key: ReaderScreen.pagesKey,
          onPointerDown: (_) => _pointer(1),
          onPointerUp: (_) => _pointer(-1),
          onPointerCancel: (_) => _pointer(-1),
          child: switch (_mode) {
            ReaderMode.swipe => SwipePages(
              key: ValueKey<bool>(spread),
              page: index,
              pageCount: _units.length,
              enabled: turning,
              onPageChanged: _shownUnit,
              itemBuilder: unit,
            ),
            ReaderMode.pageTurn => PageTurnView(
              key: ValueKey<bool>(spread),
              page: index,
              pageCount: _units.length,
              enabled: turning,
              onPageChanged: _shownUnit,
              itemBuilder: unit,
            ),
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Result<PdfDocumentHandle>? opened = _opened;
    final bool spread = _spread(context);
    if (opened case Ok<PdfDocumentHandle>(:final PdfDocumentHandle value)) {
      _units = readerUnits(
        pageCount: value.pageCount,
        spread: spread,
        isLandscape: value is ReaderDocument ? value.isLandscape : null,
      );
    }
    final int index = unitOf(_units, _page);
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
        Ok<PdfDocumentHandle>(:final PdfDocumentHandle value) => _pages(
          value,
          spread,
        ),
      },
      bottomNavigationBar: opened is Ok<PdfDocumentHandle>
          ? _PageBar(
              unit: _units.isEmpty ? <int>[_page] : _units[index],
              pageCount: _pageCount,
              onPrevious: index > 0
                  ? () => _show(_units[index - 1].first)
                  : null,
              onNext: index < _units.length - 1
                  ? () => _show(_units[index + 1].first)
                  : null,
              onGoTo: (int page) => unawaited(goToPage(page)),
            )
          : null,
    );
  }
}

/// [unit], one page or two, of [document] on the reader's background, so
/// a page turning over another hides it. Two pages meet at the spine.
Widget _unitAt(PdfDocumentHandle document, List<int> unit, double sharpness) {
  Widget page(int number, EdgeInsets padding, Alignment alignment) => Padding(
    padding: padding,
    child: Semantics(
      container: true,
      label: ReaderText.pageOf(number, document.pageCount),
      child: document is ReaderDocument
          ? document.page(number, sharpness: sharpness, alignment: alignment)
          : const SizedBox.expand(),
    ),
  );
  return ColoredBox(
    color: MfwColours.inputFill,
    child: unit.length == 1
        ? page(unit.single, const EdgeInsets.all(MfwSpace.lg), Alignment.center)
        : Row(
            children: <Widget>[
              Expanded(
                child: page(
                  unit.first,
                  const EdgeInsets.fromLTRB(
                    MfwSpace.lg,
                    MfwSpace.lg,
                    0,
                    MfwSpace.lg,
                  ),
                  Alignment.centerRight,
                ),
              ),
              Expanded(
                child: page(
                  unit.last,
                  const EdgeInsets.fromLTRB(
                    0,
                    MfwSpace.lg,
                    MfwSpace.lg,
                    MfwSpace.lg,
                  ),
                  Alignment.centerLeft,
                ),
              ),
            ],
          ),
  );
}

class _PageBar extends StatelessWidget {
  const _PageBar({
    required this.unit,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onGoTo,
  });

  /// The pages shown, one or two.
  final List<int> unit;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    final int page = unit.first;
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
              onPressed: onPrevious,
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
            Text(ReaderText.positionOf(unit, pageCount), style: MfwType.small),
            IconButton(
              tooltip: ReaderText.next,
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
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

  /// The position of one page or two, such as "7 / 64" or "6–7 / 64".
  static String positionOf(List<int> pages, int pageCount) => pages.length == 1
      ? position(pages.single, pageCount)
      : '${pages.first}–${pages.last} / $pageCount';

  /// What a screen reader says for a page, such as "Page 7 of 64".
  static String pageOf(int page, int pageCount) => 'Page $page of $pageCount';
}
