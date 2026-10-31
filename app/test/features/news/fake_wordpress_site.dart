import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import 'wp_fixtures.dart';

/// Serves one fixture for every request, after its delay.
final class FixtureTransport implements HttpTransport {
  /// Creates the transport for [fixture].
  FixtureTransport(this.fixture);

  /// The response sent.
  WpFixture fixture;

  /// Every requested address, in order.
  final List<Uri> requests = <Uri>[];

  @override
  Future<Result<HttpResponse>> get(Uri url) async {
    requests.add(url);
    if (fixture.delay > Duration.zero) {
      await Future<void>.delayed(fixture.delay);
    }
    return Ok<HttpResponse>(fixture.response);
  }
}

/// A fake WordPress site that answers the three routes of
/// API_AND_MODULE_CONTRACTS section 9.1 from its posts, as WordPress does:
/// newest first, filtered by category, paged with X-WP-Total and
/// X-WP-TotalPages, and FX-WP-07 past the last page.
final class FakeWordPressSite implements HttpTransport {
  /// Creates the site with [posts] and [categories] in the FX-WP shape.
  FakeWordPressSite({
    required List<Map<String, Object?>> posts,
    required List<Map<String, Object?>> categories,
  }) : posts = List<Map<String, Object?>>.of(posts),
       categories = List<Map<String, Object?>>.of(categories);

  /// FX-WP-01 page 1, a synthetic page 2 and FX-WP-02 (25 posts), with the
  /// FX-WP-01 categories.
  factory FakeWordPressSite.fromFixtures() => FakeWordPressSite(
    posts: <Map<String, Object?>>[
      ...wpPostsIn('fx_wp_01_posts_page1.json'),
      for (int id = 115; id > 105; id--)
        syntheticWpPost(id, categories: <int>[if (id.isOdd) 11 else 12]),
      ...wpPostsIn('fx_wp_02_posts_last_page.json'),
    ],
    categories: wpPostsIn('fx_wp_01_categories.json'),
  );

  /// The site's posts; tests add one to publish it.
  final List<Map<String, Object?>> posts;

  /// The site's categories.
  final List<Map<String, Object?>> categories;

  /// Every requested address, in order.
  final List<Uri> requests = <Uri>[];

  /// When set, every request gets this fixture instead (FX-WP-07 to 12).
  WpFixture? fault;

  /// When true, every request fails with `network`.
  bool offline = false;

  /// When set, each request waits for it.
  Completer<void>? gate;

  @override
  Future<Result<HttpResponse>> get(Uri url) async {
    requests.add(url);
    await gate?.future;
    if (offline) {
      return const Err<HttpResponse>(
        AppFailure(FailureCode.network, retryable: true),
      );
    }
    final WpFixture? set = fault;
    if (set != null) {
      if (set.delay > Duration.zero) {
        await Future<void>.delayed(set.delay);
      }
      return Ok<HttpResponse>(set.response);
    }
    final List<String> route = url.pathSegments
        .skipWhile((String segment) => segment != 'v2')
        .skip(1)
        .toList();
    return Ok<HttpResponse>(switch (route) {
      <String>['posts'] => _list(url.queryParameters),
      <String>['posts', final String id] => _one(id),
      <String>['categories'] => _categories(url.queryParameters),
      _ => _json(404, <String, Object?>{'code': 'rest_no_route'}),
    });
  }

  HttpResponse _list(Map<String, String> query) {
    final Set<int> wanted = _ids(query['categories']);
    final List<Map<String, Object?>> matching =
        posts
            .where(
              (Map<String, Object?> post) =>
                  wanted.isEmpty ||
                  (post['categories']! as List<Object?>).any(wanted.contains),
            )
            .toList()
          ..sort(
            (Map<String, Object?> a, Map<String, Object?> b) =>
                (b['date_gmt']! as String).compareTo(a['date_gmt']! as String),
          );
    final int perPage = int.parse(query['per_page'] ?? '10');
    final int page = int.parse(query['page'] ?? '1');
    final int totalPages = (matching.length / perPage).ceil();
    if (page > max(totalPages, 1)) {
      return WpFixture.load('fx_wp_07_page_out_of_range.json').response;
    }
    final int start = (page - 1) * perPage;
    return _json(
      200,
      matching.sublist(start, min(start + perPage, matching.length)),
      headers: <String, String>{
        'X-WP-Total': '${matching.length}',
        'X-WP-TotalPages': '$totalPages',
      },
    );
  }

  HttpResponse _one(String id) {
    for (final Map<String, Object?> post in posts) {
      if ('${post['id']}' == id) {
        return _json(200, post);
      }
    }
    return _json(404, <String, Object?>{'code': 'rest_post_invalid_id'});
  }

  HttpResponse _categories(Map<String, String> query) {
    final Set<int> wanted = _ids(query['include']);
    return _json(200, <Map<String, Object?>>[
      for (final Map<String, Object?> category in categories)
        if (wanted.isEmpty || wanted.contains(category['id'])) category,
    ]);
  }

  static Set<int> _ids(String? list) => <int>{
    for (final String part in (list ?? '').split(','))
      if (int.tryParse(part) case final int id) id,
  };

  static HttpResponse _json(
    int status,
    Object? body, {
    Map<String, String> headers = const <String, String>{},
  }) => HttpResponse(
    statusCode: status,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      ...headers,
    },
    body: jsonEncode(body),
  );
}
