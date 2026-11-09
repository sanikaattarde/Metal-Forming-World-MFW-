import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/errors/failure_messages.dart';

import 'brand.dart';

import 'model.dart';
import 'widgets.dart';

/// SCR-A-14: page-turn and swipe modes (GS-Q55), two pages in landscape
/// (FR-READ-009), zoom to 300% (FR-READ-004), bookmarks (FR-BKM-001), and
/// the damaged-file error with a retry (FR-READ-010). The page-turn look
/// is set at M2; here both modes page with a swipe.
class ReaderScreen extends StatefulWidget {
  /// Creates the reader for [issue], opened at [initialPage] (1-based).
  const ReaderScreen({required this.issue, this.initialPage = 1, super.key});

  /// The issue.
  final Issue issue;

  /// The page to open at.
  final int initialPage;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialPage - 1,
  );
  late int _page = widget.initialPage;
  late bool _damaged = Proto.read(context).damagedFile;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    if (_damaged) {
      return LofiScreen(
        id: 'SCR-A-14',
        title: widget.issue.title,
        background: MfwColours.inputFill,
        body: ListView(
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: <Widget>[
            Notice(messageFor(const AppFailure(FailureCode.fileCorrupt))),
            FilledButton(
              onPressed: () {
                model.damagedFile = false;
                setState(() => _damaged = false);
              },
              child: const Text('Download it again'),
            ),
          ],
        ),
      );
    }
    final bool bookmarked = model.isBookmarked(widget.issue, _page);
    final bool twoPages =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final int spreads = twoPages
        ? (widget.issue.pages / 2).ceil()
        : widget.issue.pages;
    return LofiScreen(
      id: 'SCR-A-14',
      title: widget.issue.title,
      background: MfwColours.inputFill,
      actions: <Widget>[
        IconButton(
          tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark this page',
          icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
          onPressed: () => model.toggleBookmark(widget.issue, _page),
        ),
        IconButton(
          tooltip: model.swipeMode
              ? 'Switch to page-turn mode'
              : 'Switch to swipe mode',
          icon: Icon(model.swipeMode ? Icons.swipe : Icons.auto_stories),
          onPressed: () => model.swipeMode = !model.swipeMode,
        ),
      ],
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: spreads,
              onPageChanged: (int index) =>
                  setState(() => _page = twoPages ? index * 2 + 1 : index + 1),
              itemBuilder: (BuildContext context, int index) =>
                  InteractiveViewer(
                    maxScale: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(MfwSpace.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (final int page
                              in twoPages
                                  ? <int>[index * 2 + 1, index * 2 + 2]
                                  : <int>[index + 1])
                            if (page <= widget.issue.pages)
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(MfwSpace.xs),
                                  child: AspectRatio(
                                    aspectRatio: 300 / 424,
                                    child: _Page(page: page),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
          Material(
            color: MfwColours.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: MfwSpace.sm),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Previous page',
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _page > 1 ? () => _go(_page - 1) : null,
                    ),
                    Expanded(
                      child: Slider(
                        value: _page.toDouble(),
                        min: 1,
                        max: widget.issue.pages.toDouble(),
                        label: 'Page $_page',
                        semanticFormatterCallback: (double v) =>
                            'Page ${v.round()} of ${widget.issue.pages}',
                        onChanged: (double v) => _go(v.round()),
                      ),
                    ),
                    Text(
                      '$_page / ${widget.issue.pages}',
                      style: MfwType.small,
                    ),
                    IconButton(
                      tooltip: 'Next page',
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _page < widget.issue.pages
                          ? () => _go(_page + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Goes to [page] (1-based), on the spread that holds it.
  void _go(int page) {
    final bool twoPages =
        MediaQuery.of(context).orientation == Orientation.landscape;
    _pages.jumpToPage(twoPages ? (page - 1) ~/ 2 : page - 1);
    setState(() => _page = page);
  }
}

/// A page of the issue, drawn as the frames draw it: a white sheet with
/// grey lines, because the pages are MFW content (DEC-024).
class _Page extends StatelessWidget {
  const _Page({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MfwSpace.xl),
      decoration: BoxDecoration(
        color: MfwColours.surface,
        border: Border.all(color: MfwColours.divider),
      ),
      child: Semantics(
        label: 'Page $page',
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Page $page', style: MfwType.small),
                const SizedBox(height: MfwSpace.lg),
                _Line(width: box.maxWidth * 0.75, height: 18),
                const SizedBox(height: MfwSpace.sm),
                for (int i = 0; i < 9; i++)
                  _Line(width: box.maxWidth * (i.isEven ? 1 : 0.9), height: 8),
                const SizedBox(height: MfwSpace.md),
                const Expanded(
                  child: GreyBox(
                    label: '',
                    width: double.infinity,
                    icon: Icons.image_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    margin: const EdgeInsets.only(bottom: MfwSpace.sm),
    color: MfwColours.inputFill,
  );
}
