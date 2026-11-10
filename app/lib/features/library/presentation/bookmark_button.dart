import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'library_text.dart';

/// The reader's bookmark action (RS FR-BKM-001, FR-BKM-007): filled when
/// the page shown is bookmarked; a tap adds the bookmark, or removes it.
/// The bookmark keeps the file revision being read (section 6.8 rule 3).
class BookmarkButton extends StatefulWidget {
  /// Creates the action for [issueId] at [fileRevision], following
  /// [reader]'s page.
  const BookmarkButton({
    required this.library,
    required this.issueId,
    required this.fileRevision,
    required this.reader,
    super.key,
  });

  /// MOD-08.
  final LibraryRepository library;

  /// The issue being read.
  final String issueId;

  /// The revision of the file being read.
  final int fileRevision;

  /// MOD-07's state for the issue.
  final ReaderController reader;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late final StreamSubscription<int> _pages;
  late final StreamSubscription<List<Bookmark>> _bookmarks;
  int _page = 1;
  Map<int, Bookmark> _marked = <int, Bookmark>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pages = widget.reader.watchCurrentPage().listen((int page) {
      setState(() {
        _page = page;
      });
    });
    // A failed watch, as at sign-out, keeps the last state shown.
    _bookmarks = widget.library.watchBookmarks().listen((List<Bookmark> all) {
      setState(() {
        _marked = <int, Bookmark>{
          for (final Bookmark bookmark in all)
            if (bookmark.issueId == widget.issueId) bookmark.page: bookmark,
        };
      });
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    unawaited(_pages.cancel());
    unawaited(_bookmarks.cancel());
    super.dispose();
  }

  Future<void> _toggle() async {
    setState(() {
      _busy = true;
    });
    final Bookmark? existing = _marked[_page];
    final Result<Object?> result = existing == null
        ? await widget.library.addBookmark(
            widget.issueId,
            _page,
            widget.fileRevision,
          )
        : await widget.library.removeBookmark(existing.bookmarkId);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
    });
    final String message = switch (result) {
      Err<Object?>(:final AppFailure failure) => LibraryText.failure(failure),
      Ok<Object?>() =>
        existing == null
            ? LibraryText.bookmarkAdded
            : LibraryText.bookmarkRemoved,
    };
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool marked = _marked.containsKey(_page);
    return IconButton(
      tooltip: marked ? LibraryText.pageBookmarked : LibraryText.addBookmark,
      isSelected: marked,
      icon: const Icon(Icons.bookmark_border),
      selectedIcon: const Icon(Icons.bookmark),
      onPressed: _busy ? null : () => unawaited(_toggle()),
    );
  }
}
