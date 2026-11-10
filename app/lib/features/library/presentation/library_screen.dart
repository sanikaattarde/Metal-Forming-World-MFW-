import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/ui/content_widgets.dart';
import 'library_text.dart';

/// The library (SCR-A-16 and SCR-A-17 as one screen with two views,
/// SN-05): the reader's bookmarks by issue (RS FR-BKM-002), each opening
/// the reader at its page (FR-BKM-006) or removed (FR-BKM-007), and the
/// favourite issues (FR-BKM-003). Stored with the account, so another
/// device shows the same (FR-BKM-004).
class LibraryScreen extends StatelessWidget {
  /// Creates the screen.
  const LibraryScreen({
    required this.library,
    required this.titleOf,
    required this.onOpenBookmark,
    this.onOpenIssue,
    super.key,
  });

  /// MOD-08.
  final LibraryRepository library;

  /// An issue's title.
  final Future<String> Function(String issueId) titleOf;

  /// Opens the reader at a bookmark's page.
  final ValueChanged<Bookmark> onOpenBookmark;

  /// Opens a favourite issue (SCR-A-12). Without it there is no
  /// favourites view.
  final ValueChanged<String>? onOpenIssue;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<String>? openIssue = onOpenIssue;
    final Widget bookmarks = _Bookmarks(
      library: library,
      titleOf: titleOf,
      onOpen: onOpenBookmark,
    );
    if (openIssue == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(LibraryText.bookmarks),
        ),
        body: bookmarks,
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(LibraryText.title),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: LibraryText.bookmarks),
              Tab(text: LibraryText.favourites),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            bookmarks,
            _Favourites(library: library, titleOf: titleOf, onOpen: openIssue),
          ],
        ),
      ),
    );
  }
}

/// Titles fetched once per issue and kept for the screen's life.
mixin _Titles<T extends StatefulWidget> on State<T> {
  final Map<String, String> titles = <String, String>{};

  Future<String> Function(String issueId) get titleSource;

  void want(Iterable<String> issueIds) {
    for (final String issueId in issueIds) {
      if (titles.containsKey(issueId)) {
        continue;
      }
      titles[issueId] = issueId;
      unawaited(
        titleSource(issueId).then((String title) {
          if (mounted) {
            setState(() {
              titles[issueId] = title;
            });
          }
        }, onError: (Object _) {}),
      );
    }
  }
}

class _Bookmarks extends StatefulWidget {
  const _Bookmarks({
    required this.library,
    required this.titleOf,
    required this.onOpen,
  });

  final LibraryRepository library;
  final Future<String> Function(String issueId) titleOf;
  final ValueChanged<Bookmark> onOpen;

  @override
  State<_Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<_Bookmarks> with _Titles<_Bookmarks> {
  late final Stream<List<Bookmark>> _bookmarks = widget.library
      .watchBookmarks();

  @override
  Future<String> Function(String issueId) get titleSource => widget.titleOf;

  Future<void> _remove(Bookmark bookmark) async {
    final Result<void> result = await widget.library.removeBookmark(
      bookmark.bookmarkId,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          Err<void>(:final AppFailure failure) => LibraryText.failure(failure),
          Ok<void>() => LibraryText.bookmarkRemoved,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Bookmark>>(
      stream: _bookmarks,
      builder: (BuildContext context, AsyncSnapshot<List<Bookmark>> snapshot) {
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(MfwSpace.lg),
            children: <Widget>[
              ContentNotice(
                snapshot.error is AppFailure
                    ? LibraryText.failure(snapshot.error! as AppFailure)
                    : LibraryText.failure(
                        const AppFailure(FailureCode.unknown),
                      ),
              ),
            ],
          );
        }
        final List<Bookmark>? bookmarks = snapshot.data;
        if (bookmarks == null) {
          return const LoadingContent(label: LibraryText.loading);
        }
        if (bookmarks.isEmpty) {
          return ListView(
            children: const <Widget>[
              EmptyState(
                icon: Icons.bookmark_border,
                heading: LibraryText.noBookmarksHeading,
                text: LibraryText.noBookmarksText,
              ),
            ],
          );
        }
        // By issue in the order each first appears, pages in order.
        final Map<String, List<Bookmark>> byIssue = <String, List<Bookmark>>{};
        for (final Bookmark bookmark in bookmarks) {
          byIssue
              .putIfAbsent(bookmark.issueId, () => <Bookmark>[])
              .add(bookmark);
        }
        for (final List<Bookmark> pages in byIssue.values) {
          pages.sort((Bookmark a, Bookmark b) => a.page.compareTo(b.page));
        }
        final List<String> issues = byIssue.keys.toList();
        want(issues);
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
          children: <Widget>[
            for (final String issueId in issues) ...<Widget>[
              SectionHeading(titles[issueId] ?? issueId),
              for (final Bookmark bookmark in byIssue[issueId]!)
                ListTile(
                  key: ValueKey<String>(bookmark.bookmarkId),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark),
                  title: Text(LibraryText.page(bookmark.page)),
                  onTap: () => widget.onOpen(bookmark),
                  trailing: IconButton(
                    tooltip: LibraryText.removeBookmark,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => unawaited(_remove(bookmark)),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _Favourites extends StatefulWidget {
  const _Favourites({
    required this.library,
    required this.titleOf,
    required this.onOpen,
  });

  final LibraryRepository library;
  final Future<String> Function(String issueId) titleOf;
  final ValueChanged<String> onOpen;

  @override
  State<_Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<_Favourites> with _Titles<_Favourites> {
  late final Stream<Set<String>> _favourites = widget.library
      .watchFavouriteIssueIds();

  @override
  Future<String> Function(String issueId) get titleSource => widget.titleOf;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<String>>(
      stream: _favourites,
      builder: (BuildContext context, AsyncSnapshot<Set<String>> snapshot) {
        final Set<String>? favourites = snapshot.data;
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(MfwSpace.lg),
            children: <Widget>[
              ContentNotice(
                LibraryText.failure(const AppFailure(FailureCode.unknown)),
              ),
            ],
          );
        }
        if (favourites == null) {
          return const LoadingContent(label: LibraryText.loading);
        }
        if (favourites.isEmpty) {
          return ListView(
            children: const <Widget>[
              EmptyState(
                icon: Icons.star_border,
                heading: LibraryText.noFavouritesHeading,
                text: LibraryText.noFavouritesText,
              ),
            ],
          );
        }
        final List<String> ids = favourites.toList()..sort();
        want(ids);
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
          children: <Widget>[
            for (final String issueId in ids)
              ListTile(
                key: ValueKey<String>(issueId),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star),
                title: Text(titles[issueId] ?? issueId),
                onTap: () => widget.onOpen(issueId),
                trailing: IconButton(
                  tooltip: LibraryText.removeFavourite,
                  icon: const Icon(Icons.star),
                  onPressed: () =>
                      unawaited(widget.library.setFavourite(issueId, false)),
                ),
              ),
          ],
        );
      },
    );
  }
}
