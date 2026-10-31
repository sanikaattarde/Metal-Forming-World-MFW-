import 'dart:async';
import 'dart:math';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/data/wordpress_json.dart';
import 'package:mfw_app/features/news/data/wordpress_site.dart';
import 'package:mfw_app/features/news/domain/news_ports.dart';

/// News from MFW's WordPress site (MOD-09) over the standard REST routes
/// (API_AND_MODULE_CONTRACTS section 9.1). Read only and public.
///
/// Only the categories MFW selects are read (RS INT-WP-003), in small
/// pages, newest first (INT-WP-004).
///
/// TODO(yg): the cache, fromCache and offline reading (T-08.3, OQ-16); the
/// news controls, hidden posts and breaking (T-08.4, OQ-17); the live read
/// of MFW's site (OQ-39).
final class WordPressNewsRepository implements NewsRepository {
  /// Creates the repository for `site` over `transport`.
  WordPressNewsRepository({required this._transport, required this._site});

  final HttpTransport _transport;
  final WordPressSite _site;

  static const AppFailure _unreadable = AppFailure(
    FailureCode.invalidResponse,
    detail: 'wordpress response not readable',
  );

  @override
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1}) async {
    if (page < 1) {
      return const Err<NewsPage>(
        AppFailure(FailureCode.invalidInput, detail: 'page below 1'),
      );
    }
    if (categoryId != null && !_site.categoryIds.contains(categoryId)) {
      return const Err<NewsPage>(
        AppFailure(FailureCode.notFound, detail: 'category not selected'),
      );
    }
    final Result<HttpResponse> got = await _get(
      _site.endpoint(
        <String>['posts'],
        <String, String>{
          'categories': categoryId ?? _site.categoryIds.join(','),
          'per_page': '${_site.perPage}',
          'page': '$page',
          'orderby': 'date',
          'order': 'desc',
          '_embed': '',
        },
      ),
    );
    switch (got) {
      case Err<HttpResponse>(:final AppFailure failure):
        return Err<NewsPage>(failure);
      case Ok<HttpResponse>(value: final HttpResponse response):
        // FX-WP-07. PROPOSED: a page past the end is an empty last page,
        // since posts can be removed between two page reads.
        if (response.statusCode == 400 &&
            WordPressJson.errorCode(response.body) ==
                'rest_post_invalid_page_number') {
          return const Ok<NewsPage>(
            NewsPage(posts: <NewsPost>[], hasMore: false, fromCache: false),
          );
        }
        if (response.statusCode != 200) {
          return Err<NewsPage>(WordPressJson.failureFor(response));
        }
        final List<NewsPost>? posts = WordPressJson.listOf(
          WordPressJson.decode(response.body),
          WordPressJson.post,
        );
        if (posts == null) {
          return const Err<NewsPage>(_unreadable);
        }
        // PROPOSED: without the X-WP-TotalPages header, a full page means
        // there may be more.
        final int? totalPages = int.tryParse(
          response.headers['x-wp-totalpages'] ?? '',
        );
        return Ok<NewsPage>(
          NewsPage(
            posts: List<NewsPost>.unmodifiable(posts),
            hasMore: totalPages == null
                ? posts.length >= _site.perPage
                : page < totalPages,
            fromCache: false,
          ),
        );
    }
  }

  @override
  Future<Result<NewsPost>> getPost(String postId) async {
    final Result<HttpResponse> got = await _get(
      _site.endpoint(<String>['posts', postId], <String, String>{'_embed': ''}),
    );
    switch (got) {
      case Err<HttpResponse>(:final AppFailure failure):
        return Err<NewsPost>(failure);
      case Ok<HttpResponse>(value: final HttpResponse response):
        if (response.statusCode != 200) {
          return Err<NewsPost>(WordPressJson.failureFor(response));
        }
        final NewsPost? post = WordPressJson.post(
          WordPressJson.decode(response.body),
        );
        if (post == null) {
          return const Err<NewsPost>(_unreadable);
        }
        if (!post.categoryIds.any(_site.categoryIds.contains)) {
          return const Err<NewsPost>(
            AppFailure(
              FailureCode.notFound,
              detail: 'post outside the selected categories',
            ),
          );
        }
        return Ok<NewsPost>(post);
    }
  }

  /// The selected categories that the site knows, in the configured order.
  @override
  Future<Result<List<NewsCategory>>> listCategories() async {
    final Result<HttpResponse> got = await _get(
      _site.endpoint(
        <String>['categories'],
        <String, String>{
          'include': _site.categoryIds.join(','),
          'per_page': '${min(_site.categoryIds.length, 100)}',
        },
      ),
    );
    switch (got) {
      case Err<HttpResponse>(:final AppFailure failure):
        return Err<List<NewsCategory>>(failure);
      case Ok<HttpResponse>(value: final HttpResponse response):
        if (response.statusCode != 200) {
          return Err<List<NewsCategory>>(WordPressJson.failureFor(response));
        }
        final List<NewsCategory>? read = WordPressJson.listOf(
          WordPressJson.decode(response.body),
          WordPressJson.category,
        );
        if (read == null) {
          return const Err<List<NewsCategory>>(_unreadable);
        }
        final Map<String, NewsCategory> byId = <String, NewsCategory>{
          for (final NewsCategory category in read)
            category.categoryId: category,
        };
        return Ok<List<NewsCategory>>(<NewsCategory>[
          for (final String id in _site.categoryIds)
            if (byId[id] case final NewsCategory category) category,
        ]);
    }
  }

  Future<Result<HttpResponse>> _get(Uri url) => _transport
      .get(url)
      .timeout(
        _site.timeout,
        onTimeout: () => const Err<HttpResponse>(
          AppFailure(
            FailureCode.timeout,
            retryable: true,
            detail: 'wordpress timeout',
          ),
        ),
      );
}
