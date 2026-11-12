import 'package:mfw_app/contracts/contracts.dart';

/// News held in memory, synthetic, newest first as WordPress lists them.
///
/// [failure] makes every read fail, as when the site cannot be reached.
/// [pageSize] splits the list into pages.
final class FakeNewsRepository implements NewsRepository {
  /// Creates the fake.
  FakeNewsRepository({
    List<NewsPost>? posts,
    List<NewsCategory>? categories,
    this.pageSize = 10,
  }) : posts = posts ?? <NewsPost>[],
       categories = categories ?? <NewsCategory>[];

  /// The posts, newest first.
  final List<NewsPost> posts;

  /// The selected categories.
  final List<NewsCategory> categories;

  /// Posts per page.
  final int pageSize;

  /// When set, every read fails with it.
  AppFailure? failure;

  /// Every list read, as (category, page).
  final List<(String?, int)> listed = <(String?, int)>[];

  /// Every post read.
  final List<String> read = <String>[];

  @override
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1}) async {
    listed.add((categoryId, page));
    final AppFailure? set = failure;
    if (set != null) {
      return Err<NewsPage>(set);
    }
    final List<NewsPost> matching = posts
        .where(
          (NewsPost p) =>
              categoryId == null || p.categoryIds.contains(categoryId),
        )
        .toList();
    final int start = (page - 1) * pageSize;
    final List<NewsPost> slice = start >= matching.length
        ? const <NewsPost>[]
        : matching.sublist(start, (start + pageSize).clamp(0, matching.length));
    return Ok<NewsPage>(
      NewsPage(
        posts: slice,
        hasMore: start + pageSize < matching.length,
        fromCache: false,
      ),
    );
  }

  @override
  Future<Result<NewsPost>> getPost(String postId) async {
    read.add(postId);
    final AppFailure? set = failure;
    if (set != null) {
      return Err<NewsPost>(set);
    }
    for (final NewsPost post in posts) {
      if (post.postId == postId) {
        return Ok<NewsPost>(post);
      }
    }
    return const Err<NewsPost>(AppFailure(FailureCode.notFound));
  }

  @override
  Future<Result<List<NewsCategory>>> listCategories() async {
    final AppFailure? set = failure;
    if (set != null) {
      return Err<List<NewsCategory>>(set);
    }
    return Ok<List<NewsCategory>>(List<NewsCategory>.of(categories));
  }
}

/// A synthetic post [id] in [category], published on day [day] of March
/// 2026.
NewsPost syntheticPost(
  String id, {
  String category = '7',
  int day = 1,
  String body = '<p>Synthetic body.</p>',
  bool breaking = false,
}) => NewsPost(
  postId: id,
  title: 'Synthetic post $id',
  contentHtml: body,
  publishedAt: DateTime.utc(2026, 3, day),
  categoryIds: <String>[category],
  link: Uri.parse('https://news.example.test/synthetic-post-$id/'),
  isBreaking: breaking,
);
