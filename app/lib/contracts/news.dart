import 'result.dart';

/// A WordPress news post with app-level controls applied (RS INT-WP-005,
/// DATA-015).
final class NewsPost {
  /// Creates a post.
  const NewsPost({
    required this.postId,
    required this.title,
    required this.contentHtml,
    required this.publishedAt,
    required this.categoryIds,
    required this.link,
    required this.isBreaking,
    this.imageUrl,
  });

  /// Opaque post ID (WordPress `id`).
  final String postId;

  /// Title with HTML entities decoded.
  final String title;

  /// Body HTML, rendered without scripts (CODING_STANDARDS section 7).
  final String contentHtml;

  /// Featured image, if the post has one.
  final Uri? imageUrl;

  /// Publication time, in UTC.
  final DateTime publishedAt;

  /// WordPress category IDs.
  final List<String> categoryIds;

  /// Address on the WordPress site, used for sharing (RS FR-SHR-004).
  final Uri link;

  /// Marked breaking in the admin panel; presentation: OQ-17.
  final bool isBreaking;
}

/// A news category shown in the app (RS INT-WP-003).
///
/// PROPOSED Dart shape: the contract names the type without fields.
final class NewsCategory {
  /// Creates a category.
  const NewsCategory({required this.categoryId, required this.name});

  /// Opaque category ID (WordPress category `id`).
  final String categoryId;

  /// Display name.
  final String name;
}

/// One page of news.
final class NewsPage {
  /// Creates a page.
  const NewsPage({
    required this.posts,
    required this.hasMore,
    required this.fromCache,
  });

  /// The posts on this page.
  final List<NewsPost> posts;

  /// Whether another page exists.
  final bool hasMore;

  /// Drives the offline notice (RS FR-NEWS-005).
  final bool fromCache;
}

/// News from WordPress (MOD-09). Public.
///
/// Failures: `network`, `timeout`, `serviceUnavailable`, `invalidResponse`,
/// `notFound`.
abstract interface class NewsRepository {
  /// Lists posts, optionally in one category; [page] is 1-based.
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1});

  /// Reads one post.
  Future<Result<NewsPost>> getPost(String postId);

  /// Lists the categories MFW selects.
  Future<Result<List<NewsCategory>>> listCategories();
}

/// The app-level news controls (RS DATA-009).
///
/// PROPOSED Dart shape for the output of OP-NWS-01, "hidden and breaking
/// post IDs".
final class NewsControls {
  /// Creates the controls.
  const NewsControls({
    required this.hiddenPostIds,
    required this.breakingPostIds,
  });

  /// Posts removed from the app (RS FR-NEWS-008).
  final Set<String> hiddenPostIds;

  /// Posts marked breaking (RS FR-NEWS-009).
  final Set<String> breakingPostIds;
}

/// Reads the news controls (OP-NWS-01). Public.
///
/// PROPOSED Dart shape: the operation is in API_AND_MODULE_CONTRACTS
/// section 8, with no Dart interface.
abstract interface class NewsControlsService {
  /// Reads the current controls. Fails with `serviceUnavailable`.
  Future<Result<NewsControls>> getNewsControls();
}
