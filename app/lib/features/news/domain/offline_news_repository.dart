import '../../../contracts/news.dart';
import '../../../contracts/result.dart';
import 'news_cache.dart';

/// MOD-09's news readable without a connection (MOD09-P2-T02, RS
/// FR-NEWS-005, FR-NEWS-006; OQ-16 working position of 27 October 2026,
/// GS-Q48).
///
/// - Each article opened is kept on the device, and the oldest rotate out
///   past [recentLimit] (PLACEHOLDER: the number kept is OQ-16).
/// - The first page of each list is kept too, with the articles in it.
/// - The reader's Save keeps an article until the reader removes it.
///
/// When the site cannot be reached, a first page and an article are
/// answered from what is kept, and [fromDevice] tells the screen to say
/// so. A later page, and an article never loaded, fail as before.
///
/// The admin's controls apply on top (MOD09-P2-T03), so a post hidden
/// later is not shown from the device either.
final class OfflineNewsRepository implements NewsRepository, SavedArticles {
  /// Creates the repository over the site's news, keeping its copies in
  /// the store.
  OfflineNewsRepository({
    required this._news,
    required this._store,
    this.recentLimit = 20,
  });

  final NewsRepository _news;
  final NewsCacheStore _store;

  /// The most recently opened articles kept (PLACEHOLDER, OQ-16).
  final int recentLimit;

  final Set<String> _fromDevice = <String>{};

  /// Whether the last answer for [postId] came from the device.
  bool fromDevice(String postId) => _fromDevice.contains(postId);

  static bool _unreachable(AppFailure failure) => switch (failure.code) {
    FailureCode.network ||
    FailureCode.timeout ||
    FailureCode.serviceUnavailable => true,
    _ => false,
  };

  @override
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1}) async {
    final Result<NewsPage> result = await _news.listPosts(
      categoryId: categoryId,
      page: page,
    );
    if (page != 1) {
      return result;
    }
    final String key = categoryId ?? NewsCacheRecord.allKey;
    switch (result) {
      case Ok<NewsPage>(:final NewsPage value):
        await _keep((NewsCacheRecord record) {
          return record.copyWith(
            lists: <String, List<NewsPost>>{
              ...record.lists,
              key: List<NewsPost>.unmodifiable(value.posts),
            },
          );
        });
        return result;
      case Err<NewsPage>(:final AppFailure failure):
        if (!_unreachable(failure)) {
          return result;
        }
        final List<NewsPost>? kept = (await _store.load()).lists[key];
        if (kept == null) {
          return result;
        }
        return Ok<NewsPage>(
          NewsPage(posts: kept, hasMore: false, fromCache: true),
        );
    }
  }

  @override
  Future<Result<NewsPost>> getPost(String postId) async {
    final Result<NewsPost> result = await _news.getPost(postId);
    switch (result) {
      case Ok<NewsPost>(:final NewsPost value):
        _fromDevice.remove(postId);
        await _keep((NewsCacheRecord record) {
          return record.copyWith(
            recent: <NewsPost>[
              value,
              ...record.recent.where((NewsPost p) => p.postId != postId),
            ].take(recentLimit).toList(),
            // A saved article takes the site's latest text.
            saved: <NewsPost>[
              for (final NewsPost p in record.saved)
                p.postId == postId ? value : p,
            ],
          );
        });
        return result;
      case Err<NewsPost>(:final AppFailure failure):
        if (failure.code == FailureCode.notFound) {
          // Gone from the site, or out of the selected categories: the
          // copies opened lately go too. A saved one stays until removed.
          await _keep(
            (NewsCacheRecord record) => record.copyWith(
              recent: record.recent
                  .where((NewsPost p) => p.postId != postId)
                  .toList(),
            ),
          );
          return result;
        }
        if (!_unreachable(failure)) {
          return result;
        }
        final NewsPost? kept = _find(await _store.load(), postId);
        if (kept == null) {
          return result;
        }
        _fromDevice.add(postId);
        return Ok<NewsPost>(kept);
    }
  }

  static NewsPost? _find(NewsCacheRecord record, String postId) {
    for (final List<NewsPost> posts in <List<NewsPost>>[
      record.saved,
      record.recent,
      ...record.lists.values,
    ]) {
      for (final NewsPost post in posts) {
        if (post.postId == postId && post.contentHtml.isNotEmpty) {
          return post;
        }
      }
    }
    return null;
  }

  @override
  Future<Result<List<NewsCategory>>> listCategories() => _news.listCategories();

  @override
  Future<bool> isSaved(String postId) async =>
      (await _store.load()).saved.any((NewsPost p) => p.postId == postId);

  @override
  Future<void> save(NewsPost post) async {
    final NewsCacheRecord record = await _store.load();
    await _store.save(
      record.copyWith(
        saved: <NewsPost>[
          post,
          ...record.saved.where((NewsPost p) => p.postId != post.postId),
        ],
      ),
    );
  }

  @override
  Future<void> remove(String postId) async {
    final NewsCacheRecord record = await _store.load();
    await _store.save(
      record.copyWith(
        saved: record.saved.where((NewsPost p) => p.postId != postId).toList(),
      ),
    );
  }

  @override
  Future<List<NewsPost>> saved() async =>
      List<NewsPost>.unmodifiable((await _store.load()).saved);

  /// Changes the record. A copy that cannot be written is not kept; the
  /// news still shows.
  Future<void> _keep(NewsCacheRecord Function(NewsCacheRecord) change) async {
    try {
      await _store.save(change(await _store.load()));
    } on Object {
      // Keeping a copy is a convenience; the reader is not interrupted.
    }
  }
}
