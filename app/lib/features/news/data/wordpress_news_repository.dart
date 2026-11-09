import 'dart:convert';

import '../../../contracts/news.dart';
import '../../../contracts/result.dart';
import '../../../core/config/wordpress_config.dart';
import '../../../core/network/https_client.dart';
import 'wordpress_dto.dart';

/// [NewsRepository] on MFW's WordPress REST API (MOD09-P1-T01, RS INT-WP-001
/// to INT-WP-005; `API_AND_MODULE_CONTRACTS.md` section 9.1, PROVISIONAL
/// until OQ-39).
///
/// The app only reads, and never signs in to WordPress. Only the categories
/// of [WordPressSiteConfig.categoryIds] are shown (INT-WP-003). There is no
/// cache yet, so [NewsPage.fromCache] is false (MOD09-P2-T02).
///
/// Status codes map to failures as follows (fixtures of
/// `TEST_DATA_AND_FIXTURES.md` section 10): 401 and 403 (the API blocked, FX-WP-08) to `serviceUnavailable`; 404
/// with `rest_no_route` (FX-WP-09) to `serviceUnavailable`; 5xx and 429
/// (FX-WP-10) to `serviceUnavailable`, retryable; a 200 that is not JSON
/// (FX-WP-12) to `invalidResponse`; a page past the end (FX-WP-07) to an
/// empty last page.
final class WordPressNewsRepository implements NewsRepository {
  /// Creates the repository.
  WordPressNewsRepository({required this._client, required this._config});

  final HttpsGetClient _client;
  final WordPressSiteConfig _config;

  static final RegExp _digits = RegExp(r'^[0-9]{1,18}$');

  @override
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1}) async {
    if (page < 1) {
      throw RangeError.range(page, 1, null, 'page');
    }
    if (categoryId != null && !_config.categoryIds.contains(categoryId)) {
      return const Err<NewsPage>(
        AppFailure(FailureCode.notFound, detail: 'category not selected'),
      );
    }
    final Uri uri = _route('posts', <String, String>{
      'categories': categoryId ?? _config.categoryIds.join(','),
      'per_page': '${_config.pageSize}',
      'page': '$page',
      '_embed': 'wp:featuredmedia',
    });
    final Result<HttpsResponse> result = await _client.get(uri);
    switch (result) {
      case Err<HttpsResponse>(:final AppFailure failure):
        return Err<NewsPage>(failure);
      case Ok<HttpsResponse>(value: final HttpsResponse response):
        if (response.statusCode == 400 &&
            _errorCode(response) == 'rest_post_invalid_page_number') {
          return const Ok<NewsPage>(
            NewsPage(posts: <NewsPost>[], hasMore: false, fromCache: false),
          );
        }
        final AppFailure? failure = _statusFailure(response);
        if (failure != null) {
          return Err<NewsPage>(failure);
        }
        return _parse(response, (Object? json) {
          if (json is! List<Object?>) {
            throw const WordPressShapeError('post list');
          }
          final List<NewsPost> posts = json.map(newsPostFromJson).toList();
          final int? totalPages = int.tryParse(
            response.headers['x-wp-totalpages'] ?? '',
          );
          return NewsPage(
            posts: List<NewsPost>.unmodifiable(posts),
            hasMore: totalPages != null
                ? page < totalPages
                : posts.length == _config.pageSize,
            fromCache: false,
          );
        });
    }
  }

  @override
  Future<Result<NewsPost>> getPost(String postId) async {
    // WordPress post IDs are whole numbers. Any other ID, for example from a
    // deep link, would reach WordPress as an unknown route (`rest_no_route`)
    // and read as the site being unusable, so it is refused here.
    if (!_digits.hasMatch(postId)) {
      return const Err<NewsPost>(
        AppFailure(FailureCode.notFound, detail: 'post ID not numeric'),
      );
    }
    final Uri uri = _route(
      'posts/${Uri.encodeComponent(postId)}',
      <String, String>{'_embed': 'wp:featuredmedia'},
    );
    final Result<HttpsResponse> result = await _client.get(uri);
    switch (result) {
      case Err<HttpsResponse>(:final AppFailure failure):
        return Err<NewsPost>(failure);
      case Ok<HttpsResponse>(value: final HttpsResponse response):
        if (response.statusCode == 404 &&
            _errorCode(response) == 'rest_post_invalid_id') {
          return const Err<NewsPost>(
            AppFailure(FailureCode.notFound, detail: 'no such post'),
          );
        }
        final AppFailure? failure = _statusFailure(response);
        if (failure != null) {
          return Err<NewsPost>(failure);
        }
        final Result<NewsPost> parsed = _parse(response, newsPostFromJson);
        if (parsed case Ok<NewsPost>(value: final NewsPost post)) {
          // A post outside the selected categories is not shown (INT-WP-003).
          if (!post.categoryIds.any(_config.categoryIds.contains)) {
            return const Err<NewsPost>(
              AppFailure(FailureCode.notFound, detail: 'category not selected'),
            );
          }
        }
        return parsed;
    }
  }

  @override
  Future<Result<List<NewsCategory>>> listCategories() async {
    final Uri uri = _route('categories', <String, String>{
      'include': _config.categoryIds.join(','),
      'per_page': '${_config.categoryIds.length.clamp(1, 100)}',
      'orderby': 'include',
    });
    final Result<HttpsResponse> result = await _client.get(uri);
    switch (result) {
      case Err<HttpsResponse>(:final AppFailure failure):
        return Err<List<NewsCategory>>(failure);
      case Ok<HttpsResponse>(value: final HttpsResponse response):
        final AppFailure? failure = _statusFailure(response);
        if (failure != null) {
          return Err<List<NewsCategory>>(failure);
        }
        return _parse(response, (Object? json) {
          if (json is! List<Object?>) {
            throw const WordPressShapeError('category list');
          }
          final List<NewsCategory> categories = json
              .map(newsCategoryFromJson)
              .where(
                (NewsCategory c) => _config.categoryIds.contains(c.categoryId),
              )
              .toList();
          return List<NewsCategory>.unmodifiable(categories);
        });
    }
  }

  Uri _route(String path, Map<String, String> query) {
    final Uri site = _config.siteUri;
    final String base = site.path.endsWith('/')
        ? site.path.substring(0, site.path.length - 1)
        : site.path;
    return site.replace(
      path: '$base/wp-json/wp/v2/$path',
      queryParameters: query,
    );
  }

  /// The failure a non-2xx status stands for, or null for 2xx.
  AppFailure? _statusFailure(HttpsResponse response) {
    final int status = response.statusCode;
    if (status >= 200 && status < 300) {
      return null;
    }
    if (status == 429 || status >= 500) {
      return AppFailure(
        FailureCode.serviceUnavailable,
        retryable: true,
        detail: 'status $status',
      );
    }
    // 3xx (redirects are not followed), 401 and 403 (the API is blocked),
    // 404 (a wrong route or base address) and any other 4xx: the site cannot
    // serve the app as configured, and trying again will not help.
    return AppFailure(
      FailureCode.serviceUnavailable,
      detail: 'status $status ${_errorCode(response) ?? ''}'.trim(),
    );
  }

  String? _errorCode(HttpsResponse response) {
    try {
      return wordPressErrorCode(jsonDecode(response.body));
    } on FormatException {
      return null;
    }
  }

  Result<T> _parse<T>(HttpsResponse response, T Function(Object? json) read) {
    final String type = response.headers['content-type'] ?? '';
    if (!type.contains('json')) {
      return Err<T>(
        AppFailure(FailureCode.invalidResponse, detail: 'content type $type'),
      );
    }
    try {
      return Ok<T>(read(jsonDecode(response.body)));
    } on FormatException {
      return Err<T>(
        const AppFailure(FailureCode.invalidResponse, detail: 'not JSON'),
      );
    } on WordPressShapeError catch (error) {
      return Err<T>(
        AppFailure(FailureCode.invalidResponse, detail: error.field),
      );
    }
  }
}
