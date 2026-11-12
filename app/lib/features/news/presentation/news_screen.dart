import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/news.dart';
import '../../../contracts/result.dart';
import '../../../core/errors/failure_messages.dart';
import '../../../core/format/display_format.dart';
import '../../../core/ui/content_widgets.dart';
import 'news_text.dart';

/// SCR-A-18, the news list (MOD09-P2-T01, RS FR-NEWS-001 to FR-NEWS-004,
/// FR-NEWS-007, FR-STATE-005). Open to visitors.
///
/// The posts of the categories MFW selects, newest first, with a filter
/// for one category, pull to refresh and a Show more button for the next
/// page. When the site cannot be reached, the screen says so with Retry,
/// and keeps the posts it already shows.
class NewsScreen extends StatefulWidget {
  /// Creates the screen.
  const NewsScreen({required this.news, required this.onOpenPost, super.key});

  /// MOD-09's news.
  final NewsRepository news;

  /// Opens an article.
  final ValueChanged<String> onOpenPost;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsCategory> _categories = const <NewsCategory>[];
  String? _category;

  /// The posts shown, in order, or null before the first page.
  List<NewsPost>? _posts;
  AppFailure? _failure;
  bool _fromCache = false;
  bool _hasMore = false;
  bool _loadingMore = false;
  int _page = 1;

  /// Counts reads, so a late answer for an earlier filter is ignored.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCategories());
    unawaited(_loadFirst());
  }

  Future<void> _loadCategories() async {
    final Result<List<NewsCategory>> result = await widget.news
        .listCategories();
    if (!mounted) {
      return;
    }
    if (result case Ok<List<NewsCategory>>(:final List<NewsCategory> value)) {
      setState(() {
        _categories = value;
      });
    }
  }

  Future<void> _loadFirst({bool keep = false}) async {
    final int generation = ++_generation;
    if (!keep) {
      setState(() {
        _posts = null;
        _failure = null;
      });
    }
    final Result<NewsPage> result = await widget.news.listPosts(
      categoryId: _category,
    );
    if (!mounted || generation != _generation) {
      return;
    }
    setState(() {
      switch (result) {
        case Ok<NewsPage>(:final NewsPage value):
          _posts = value.posts;
          _hasMore = value.hasMore;
          _fromCache = value.fromCache;
          _failure = null;
          _page = 1;
        case Err<NewsPage>(:final AppFailure failure):
          // A refresh that fails keeps what is shown, with the notice.
          _failure = failure;
          if (!keep) {
            _posts = null;
          }
      }
    });
    if (_categories.isEmpty) {
      unawaited(_loadCategories());
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) {
      return;
    }
    final int generation = _generation;
    setState(() {
      _loadingMore = true;
    });
    final Result<NewsPage> result = await widget.news.listPosts(
      categoryId: _category,
      page: _page + 1,
    );
    if (!mounted || generation != _generation) {
      return;
    }
    setState(() {
      _loadingMore = false;
      switch (result) {
        case Ok<NewsPage>(:final NewsPage value):
          final Set<String> shown = <String>{
            for (final NewsPost post in _posts ?? const <NewsPost>[])
              post.postId,
          };
          _posts = <NewsPost>[
            ...?_posts,
            ...value.posts.where((NewsPost p) => !shown.contains(p.postId)),
          ];
          _hasMore = value.hasMore;
          _page += 1;
        case Err<NewsPage>(:final AppFailure failure):
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(SnackBar(content: Text(messageFor(failure))));
      }
    });
  }

  void _choose(String? categoryId) {
    if (categoryId == _category) {
      return;
    }
    setState(() {
      _category = categoryId;
    });
    unawaited(_loadFirst());
  }

  String? _categoryName(NewsPost post) {
    for (final NewsCategory category in _categories) {
      if (post.categoryIds.contains(category.categoryId)) {
        return category.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<NewsPost>? posts = _posts;
    final AppFailure? failure = _failure;
    final Widget body;
    if (posts == null && failure == null) {
      body = const LoadingContent(label: NewsText.loading);
    } else {
      body = RefreshIndicator(
        onRefresh: () => _loadFirst(keep: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: <Widget>[
            if (failure != null)
              ContentNotice(
                _isUnreachable(failure)
                    ? (posts == null || posts.isEmpty
                          ? NewsText.unreachable
                          : NewsText.unreachableKept)
                    : messageFor(failure),
                kind: _isUnreachable(failure)
                    ? NoticeKind.offline
                    : NoticeKind.error,
                action: TextButton(
                  onPressed: () => unawaited(_loadFirst(keep: posts != null)),
                  child: const Text(NewsText.retry),
                ),
              )
            else if (_fromCache)
              const ContentNotice(
                NewsText.unreachableKept,
                kind: NoticeKind.offline,
              ),
            if (_categories.length > 1) _chips(),
            const SizedBox(height: MfwSpace.sm),
            if (posts != null && posts.isEmpty)
              EmptyState(
                icon: Icons.article_outlined,
                heading: _category == null
                    ? NewsText.noneHeading
                    : NewsText.emptyHeading,
                text: _category == null
                    ? NewsText.noneText
                    : NewsText.emptyText,
              ),
            for (final NewsPost post in posts ?? const <NewsPost>[])
              NewsRow(
                key: ValueKey<String>(post.postId),
                post: post,
                categoryName: _categoryName(post),
                onOpen: () => widget.onOpenPost(post.postId),
              ),
            if (_hasMore && posts != null && posts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: MfwSpace.md),
                child: Center(
                  child: _loadingMore
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: () => unawaited(_loadMore()),
                          child: const Text(NewsText.more),
                        ),
                ),
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text(NewsText.title)),
      body: body,
    );
  }

  Widget _chips() {
    final List<(String? id, String name)> options = <(String?, String)>[
      (null, NewsText.all),
      for (final NewsCategory c in _categories) (c.categoryId, c.name),
    ];
    return Wrap(
      spacing: MfwSpace.sm,
      runSpacing: MfwSpace.sm,
      children: <Widget>[
        for (final (String? id, String name) in options)
          FilterChip(
            label: Text(name),
            tooltip: NewsText.filterTooltip(name, selected: id == _category),
            selected: id == _category,
            onSelected: (_) => _choose(id),
          ),
      ],
    );
  }
}

/// Whether [failure] means the site cannot be reached now (FR-STATE-005).
bool _isUnreachable(AppFailure failure) => switch (failure.code) {
  FailureCode.network ||
  FailureCode.timeout ||
  FailureCode.serviceUnavailable => true,
  _ => false,
};

/// One post in the list: its picture, a Breaking label when it is marked
/// (OQ-17, PROVISIONAL), the title, the date and the category.
class NewsRow extends StatelessWidget {
  /// Creates the row.
  const NewsRow({
    required this.post,
    required this.onOpen,
    this.categoryName,
    super.key,
  });

  /// The post.
  final NewsPost post;

  /// The name of its first selected category, if known.
  final String? categoryName;

  /// Opens the article.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final Uri? image = post.imageUrl;
    const Widget placeholder = Icon(
      Icons.image_outlined,
      color: MfwColours.body,
    );
    final String date = DisplayFormat.date(post.publishedAt);
    final String meta = categoryName == null ? date : '$date · $categoryName';
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MfwSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Container(
                  width: 96,
                  height: 72,
                  color: MfwColours.inputFill,
                  alignment: Alignment.center,
                  child: image == null
                      ? placeholder
                      : Image.network(
                          image.toString(),
                          width: 96,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? _,
                          ) => placeholder,
                        ),
                ),
              ),
              const SizedBox(width: MfwSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (post.isBreaking)
                      Padding(
                        padding: const EdgeInsets.only(bottom: MfwSpace.xs),
                        child: Text(
                          NewsText.breaking.toUpperCase(),
                          style: MfwType.label,
                        ),
                      ),
                    Text(post.title, style: MfwType.h5),
                    const SizedBox(height: MfwSpace.xs),
                    Text(meta, style: MfwType.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
