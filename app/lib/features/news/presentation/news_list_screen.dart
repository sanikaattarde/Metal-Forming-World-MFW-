import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/presentation/news_failure_view.dart';
import 'package:mfw_app/features/news/presentation/news_feed.dart';
import 'package:mfw_app/features/news/presentation/news_image_source.dart';
import 'package:mfw_app/features/news/presentation/news_post_tile.dart';
import 'package:mfw_app/features/news/presentation/news_text.dart';

/// The news list (SCR-A-18). Public: no sign-in needed (RS FR-NEWS-007).
///
/// Posts with image, title, date and category, newest first
/// (FR-NEWS-001); a chip per category MFW selects (FR-NEWS-003);
/// pull-to-refresh (FR-NEWS-004); more pages on request (INT-WP-004).
/// Loading, empty and error states; a failed refresh keeps the posts shown
/// with a message (FR-STATE-001 to FR-STATE-003, FR-STATE-005).
///
/// TODO(yg): the offline notice and cache (T-08.3, OQ-16); breaking posts
/// (T-08.4, OQ-17).
class NewsListScreen extends StatefulWidget {
  /// Creates the screen.
  const NewsListScreen({
    required this.news,
    required this.images,
    this.onOpenPost,
    super.key,
  });

  /// MOD-09's source of posts.
  final NewsRepository news;

  /// Draws the images.
  final NewsImageSource images;

  /// Opens an article (SCR-A-19) by its post ID.
  final void Function(String postId)? onOpenPost;

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late final NewsFeed _feed = NewsFeed(widget.news);

  @override
  void initState() {
    super.initState();
    unawaited(_feed.start());
  }

  @override
  void dispose() {
    _feed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(NewsText.title)),
      // Keeps clear of side insets; the list pads the bottom itself.
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListenableBuilder(
          listenable: _feed,
          builder: (BuildContext context, Widget? child) => _body(),
        ),
      ),
    );
  }

  Widget _body() {
    final AppFailure? failure = _feed.failure;
    if (_feed.status == NewsFeedStatus.failed && failure != null) {
      return NewsFailureView(failure: failure, onRetry: _feed.retry);
    }
    if (_feed.categoryNames.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: <Widget>[
        _chips(),
        Expanded(
          child: _feed.status == NewsFeedStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : _list(),
        ),
      ],
    );
  }

  Widget _chips() {
    final String? selected = _feed.selectedCategoryId;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          for (final (String? id, String name) in <(String?, String)>[
            (null, NewsText.all),
            for (final MapEntry<String, String> category
                in _feed.categoryNames.entries)
              (category.key, category.value),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(name),
                selected: id == selected,
                onSelected: (bool _) => unawaited(_feed.select(id)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _list() {
    final List<NewsPost> posts = _feed.posts;
    return RefreshIndicator(
      onRefresh: _feed.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          if (_feed.notice != null)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(NewsText.staleNotice),
            ),
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Text(
                  _feed.selectedCategoryId == null
                      ? NewsText.emptyAll
                      : NewsText.emptyCategory,
                ),
              ),
            ),
          for (final NewsPost post in posts) _tile(post),
          if (_feed.hasMore)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _feed.loadingMore
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: () => unawaited(_feed.loadMore()),
                        child: const Text(NewsText.more),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tile(NewsPost post) {
    final List<String> names = <String>[
      for (final String id in post.categoryIds)
        if (_feed.categoryNames[id] case final String name) name,
    ];
    final void Function(String postId)? open = widget.onOpenPost;
    return NewsPostTile(
      post: post,
      categoryLabel: names.isEmpty ? null : names.join(', '),
      images: widget.images,
      onTap: open == null ? null : () => open(post.postId),
    );
  }
}
