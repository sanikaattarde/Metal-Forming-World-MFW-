import 'package:flutter/foundation.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Where the news list stands.
enum NewsFeedStatus {
  /// The first page of the chosen category is loading.
  loading,

  /// Posts (possibly none) are shown.
  ready,

  /// The first page could not be loaded; [NewsFeed.failure] says why.
  failed,
}

/// The state of the news list (SCR-A-18): categories, the chosen category,
/// and the posts loaded so far, page by page (RS FR-NEWS-001,
/// FR-NEWS-003, FR-NEWS-004, INT-WP-004).
///
/// A refresh or a next page that fails keeps the posts already shown and
/// sets [notice] (FR-STATE-005). An answer for a category no longer chosen
/// is dropped.
class NewsFeed extends ChangeNotifier {
  /// Creates the feed over [news]; call [start].
  NewsFeed(this._news);

  final NewsRepository _news;

  NewsFeedStatus _status = NewsFeedStatus.loading;
  AppFailure? _failure;
  AppFailure? _notice;
  Map<String, String> _categoryNames = const <String, String>{};
  String? _selected;
  List<NewsPost> _posts = const <NewsPost>[];
  int _page = 0;
  bool _hasMore = false;
  bool _loadingMore = false;
  int _generation = 0;
  bool _disposed = false;

  /// Where the list stands.
  NewsFeedStatus get status => _status;

  /// Why the first page failed, when [status] is failed.
  AppFailure? get failure => _failure;

  /// Why the last refresh or next page failed, while older posts show.
  AppFailure? get notice => _notice;

  /// Category names by ID, in the configured order (RS INT-WP-003).
  Map<String, String> get categoryNames => _categoryNames;

  /// The chosen category, or null for all.
  String? get selectedCategoryId => _selected;

  /// The posts loaded so far, newest first.
  List<NewsPost> get posts => _posts;

  /// Whether another page exists.
  bool get hasMore => _hasMore;

  /// Whether the next page is loading.
  bool get loadingMore => _loadingMore;

  /// Loads the categories and the first page.
  Future<void> start() async {
    final int generation = ++_generation;
    _status = NewsFeedStatus.loading;
    _failure = null;
    _notice = null;
    _notify();
    final (
      Result<List<NewsCategory>> categories,
      Result<NewsPage> page,
    ) = await (
      _news.listCategories(),
      _news.listPosts(categoryId: _selected),
    ).wait;
    if (_isStale(generation)) {
      return;
    }
    switch ((categories, page)) {
      case (
        Ok<List<NewsCategory>>(value: final List<NewsCategory> read),
        Ok<NewsPage>(value: final NewsPage first),
      ):
        _categoryNames = Map<String, String>.unmodifiable(<String, String>{
          for (final NewsCategory category in read)
            category.categoryId: category.name,
        });
        _showFirst(first);
      case (Err<List<NewsCategory>>(:final AppFailure failure), _) ||
          (_, Err<NewsPage>(:final AppFailure failure)):
        _fail(failure);
    }
    _notify();
  }

  /// Loads again after a failed start.
  Future<void> retry() => start();

  /// Shows the first page of [categoryId], or of all categories for null.
  Future<void> select(String? categoryId) async {
    if (categoryId == _selected && _status == NewsFeedStatus.ready) {
      return;
    }
    _selected = categoryId;
    final int generation = ++_generation;
    _status = NewsFeedStatus.loading;
    _posts = const <NewsPost>[];
    _notice = null;
    _loadingMore = false;
    _notify();
    final Result<NewsPage> page = await _news.listPosts(categoryId: categoryId);
    if (_isStale(generation)) {
      return;
    }
    switch (page) {
      case Ok<NewsPage>(value: final NewsPage first):
        _showFirst(first);
      case Err<NewsPage>(:final AppFailure failure):
        _fail(failure);
    }
    _notify();
  }

  /// Reads the first page again (RS FR-NEWS-004).
  Future<void> refresh() async {
    if (_status != NewsFeedStatus.ready) {
      return start();
    }
    final int generation = ++_generation;
    final Result<NewsPage> page = await _news.listPosts(categoryId: _selected);
    if (_isStale(generation)) {
      return;
    }
    switch (page) {
      case Ok<NewsPage>(value: final NewsPage first):
        _showFirst(first);
      case Err<NewsPage>(:final AppFailure failure):
        _notice = failure;
    }
    _notify();
  }

  /// Appends the next page, leaving out posts already shown (a post
  /// published between two reads shifts the pages).
  Future<void> loadMore() async {
    if (_status != NewsFeedStatus.ready || !_hasMore || _loadingMore) {
      return;
    }
    final int generation = _generation;
    _loadingMore = true;
    _notify();
    final Result<NewsPage> next = await _news.listPosts(
      categoryId: _selected,
      page: _page + 1,
    );
    if (_isStale(generation)) {
      return;
    }
    _loadingMore = false;
    switch (next) {
      case Ok<NewsPage>(value: final NewsPage page):
        final Set<String> shown = <String>{
          for (final NewsPost post in _posts) post.postId,
        };
        _posts = List<NewsPost>.unmodifiable(<NewsPost>[
          ..._posts,
          ...page.posts.where((NewsPost post) => !shown.contains(post.postId)),
        ]);
        _page++;
        _hasMore = page.hasMore;
        _notice = null;
      case Err<NewsPage>(:final AppFailure failure):
        _notice = failure;
    }
    _notify();
  }

  void _showFirst(NewsPage page) {
    _posts = List<NewsPost>.unmodifiable(page.posts);
    _page = 1;
    _hasMore = page.hasMore;
    _loadingMore = false;
    _notice = null;
    _status = NewsFeedStatus.ready;
  }

  void _fail(AppFailure failure) {
    _failure = failure;
    _posts = const <NewsPost>[];
    _status = NewsFeedStatus.failed;
  }

  bool _isStale(int generation) => _disposed || generation != _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
