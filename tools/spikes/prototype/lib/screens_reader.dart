import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/widgets.dart';

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
        body: Message(
          icon: Icons.broken_image_outlined,
          text: 'This issue file is damaged and cannot be opened.',
          action: 'Download it again',
          onAction: () {
            model.damagedFile = false;
            setState(() => _damaged = false);
          },
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
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: <Widget>[
                          for (final int page
                              in twoPages
                                  ? <int>[index * 2 + 1, index * 2 + 2]
                                  : <int>[index + 1])
                            if (page <= widget.issue.pages)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: GreyBox(
                                    label: 'Page $page',
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Page $_page of ${widget.issue.pages} · '
              '${model.swipeMode ? 'Swipe mode' : 'Page-turn mode'} · '
              'pinch to zoom up to 300%',
            ),
          ),
        ],
      ),
    );
  }
}
