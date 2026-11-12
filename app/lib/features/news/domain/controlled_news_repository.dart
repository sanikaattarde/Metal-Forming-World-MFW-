import '../../../contracts/news.dart';
import '../../../contracts/result.dart';

/// MOD-09's news with the admin's controls applied (MOD09-P2-T03, RS
/// FR-NEWS-008, FR-NEWS-009, IC-06).
///
/// - A hidden post is never listed, and opening it reads as not found.
/// - A breaking post is marked, and the first page shows the breaking
///   posts first, newest first, then the rest in date order (OQ-17
///   working position of 12 November 2026, PROVISIONAL). A breaking post
///   that is not on the first page is read on its own and pinned there,
///   and is then left out of the later pages.
///
/// The controls are read again with each first page, so a change shows
/// after a refresh. The later pages use the controls of their first page.
/// When the controls cannot be read, the news fails too, so a hidden post
/// is never shown by mistake.
final class ControlledNewsRepository implements NewsRepository {
  /// Creates the repository over the news and its controls.
  ControlledNewsRepository({
    required this._news,
    required this._controls,
    this.pinnedLimit = 5,
  });

  final NewsRepository _news;
  final NewsControlsService _controls;

  /// The most breaking posts pinned on a first page.
  final int pinnedLimit;

  NewsControls? _current;

  /// The breaking posts pinned on the last first page, left out of the
  /// pages after it.
  Set<String> _pinned = const <String>{};

  Future<Result<NewsControls>> _read({required bool fresh}) async {
    final NewsControls? kept = _current;
    if (!fresh && kept != null) {
      return Ok<NewsControls>(kept);
    }
    final Result<NewsControls> result = await _controls.getNewsControls();
    if (result case Ok<NewsControls>(:final NewsControls value)) {
      _current = value;
    }
    return result;
  }

  @override
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1}) async {
    final Result<NewsControls> controls = await _read(fresh: page == 1);
    final NewsControls rules;
    switch (controls) {
      case Err<NewsControls>(:final AppFailure failure):
        return Err<NewsPage>(failure);
      case Ok<NewsControls>(:final NewsControls value):
        rules = value;
    }
    final Result<NewsPage> listed = await _news.listPosts(
      categoryId: categoryId,
      page: page,
    );
    final NewsPage found;
    switch (listed) {
      case Err<NewsPage>(:final AppFailure failure):
        return Err<NewsPage>(failure);
      case Ok<NewsPage>(:final NewsPage value):
        found = value;
    }
    final List<NewsPost> shown = <NewsPost>[
      for (final NewsPost post in found.posts)
        if (!rules.hiddenPostIds.contains(post.postId)) _marked(post, rules),
    ];
    if (page > 1) {
      return Ok<NewsPage>(
        NewsPage(
          posts: List<NewsPost>.unmodifiable(
            shown.where((NewsPost p) => !_pinned.contains(p.postId)),
          ),
          hasMore: found.hasMore,
          fromCache: found.fromCache,
        ),
      );
    }

    final Set<String> onPage = <String>{
      for (final NewsPost post in shown) post.postId,
    };
    final List<NewsPost> extra = <NewsPost>[];
    // Only when the page came from the site: a cached page shows what was
    // kept, with no further reads.
    if (!found.fromCache) {
      for (final String id in rules.breakingPostIds.difference(onPage)) {
        if (extra.length >= pinnedLimit) {
          break;
        }
        final Result<NewsPost> read = await _news.getPost(id);
        if (read case Ok<NewsPost>(:final NewsPost value)) {
          if (categoryId == null || value.categoryIds.contains(categoryId)) {
            extra.add(_marked(value, rules));
          }
        }
      }
    }
    final List<NewsPost> breaking = <NewsPost>[
      ...shown.where((NewsPost p) => p.isBreaking),
      ...extra,
    ]..sort((NewsPost a, NewsPost b) => b.publishedAt.compareTo(a.publishedAt));
    final List<NewsPost> pinned = breaking.take(pinnedLimit).toList();
    final Set<String> pinnedIds = <String>{
      for (final NewsPost post in pinned) post.postId,
    };
    _pinned = Set<String>.unmodifiable(
      pinnedIds.where((String id) => !onPage.contains(id)),
    );
    return Ok<NewsPage>(
      NewsPage(
        posts: List<NewsPost>.unmodifiable(<NewsPost>[
          ...pinned,
          ...shown.where((NewsPost p) => !pinnedIds.contains(p.postId)),
        ]),
        hasMore: found.hasMore,
        fromCache: found.fromCache,
      ),
    );
  }

  @override
  Future<Result<NewsPost>> getPost(String postId) async {
    final Result<NewsControls> controls = await _read(fresh: true);
    final NewsControls rules;
    switch (controls) {
      case Err<NewsControls>(:final AppFailure failure):
        return Err<NewsPost>(failure);
      case Ok<NewsControls>(:final NewsControls value):
        rules = value;
    }
    if (rules.hiddenPostIds.contains(postId)) {
      return const Err<NewsPost>(
        AppFailure(FailureCode.notFound, detail: 'post hidden'),
      );
    }
    final Result<NewsPost> read = await _news.getPost(postId);
    return switch (read) {
      Ok<NewsPost>(:final NewsPost value) => Ok<NewsPost>(
        _marked(value, rules),
      ),
      Err<NewsPost>() => read,
    };
  }

  /// [posts] with the latest controls applied: hidden ones left out and
  /// breaking ones marked, in the same order. For posts kept on the device,
  /// such as the saved articles (MOD09-P2-T02).
  Future<Result<List<NewsPost>>> applyTo(List<NewsPost> posts) async {
    final Result<NewsControls> controls = await _read(fresh: true);
    return switch (controls) {
      Err<NewsControls>(:final AppFailure failure) => Err<List<NewsPost>>(
        failure,
      ),
      Ok<NewsControls>(:final NewsControls value) => Ok<List<NewsPost>>(
        List<NewsPost>.unmodifiable(<NewsPost>[
          for (final NewsPost post in posts)
            if (!value.hiddenPostIds.contains(post.postId))
              _marked(post, value),
        ]),
      ),
    };
  }

  @override
  Future<Result<List<NewsCategory>>> listCategories() => _news.listCategories();

  static NewsPost _marked(NewsPost post, NewsControls rules) {
    final bool breaking = rules.breakingPostIds.contains(post.postId);
    if (breaking == post.isBreaking) {
      return post;
    }
    return NewsPost(
      postId: post.postId,
      title: post.title,
      contentHtml: post.contentHtml,
      publishedAt: post.publishedAt,
      categoryIds: post.categoryIds,
      link: post.link,
      isBreaking: breaking,
      imageUrl: post.imageUrl,
    );
  }
}
