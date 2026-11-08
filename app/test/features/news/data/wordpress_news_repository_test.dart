import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/news.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/config/wordpress_config.dart';
import 'package:mfw_app/core/network/https_client.dart';
import 'package:mfw_app/features/news/news.dart';

import '../../../fakes/fake_https_get_client.dart';

final WordPressSiteConfig _config = WordPressSiteConfig(
  siteUri: Uri.parse('https://news.example.test'),
  categoryIds: <String>['7', '11', '14'],
);

WordPressNewsRepository _repository(FakeHttpsGetClient client) =>
    WordPressNewsRepository(client: client, config: _config);

T _ok<T>(Result<T> result) => switch (result) {
  Ok<T>(:final T value) => value,
  Err<T>(:final AppFailure failure) => fail('expected Ok, got ${failure.code}'),
};

AppFailure _err<T>(Result<T> result) => switch (result) {
  Ok<T>() => fail('expected Err'),
  Err<T>(:final AppFailure failure) => failure,
};

void main() {
  group('news list [FR-NEWS-001, INT-WP-004, INT-WP-005]', () {
    test('reads the first page with its images (FX-WP-01)', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse(
          wordPressFixture('fx_wp_01_posts_page1.json'),
          headers: <String, String>{'x-wp-total': '25', 'x-wp-totalpages': '3'},
        ),
      );

      final NewsPage page = _ok(await _repository(client).listPosts());

      expect(page.posts, hasLength(10));
      expect(page.hasMore, isTrue);
      expect(page.fromCache, isFalse);
      final NewsPost first = page.posts.first;
      expect(first.postId, '9001');
      expect(first.title, 'Synthetic post 1');
      expect(first.publishedAt, DateTime.utc(2026, 3, 27, 9, 30));
      expect(first.categoryIds, <String>['11']);
      expect(
        first.link,
        Uri.parse('https://news.example.test/synthetic-post-1/'),
      );
      expect(
        first.imageUrl,
        Uri.parse(
          'https://news.example.test/wp-content/uploads/2026/03/synthetic-1.jpg',
        ),
      );
      expect(
        first.isBreaking,
        isFalse,
        reason: 'controls come in MOD09-P2-T03',
      );
    });

    test('asks for one small page of the selected categories only '
        '[INT-WP-003, INT-WP-004]', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse('[]'),
      );

      await _repository(client).listPosts(page: 2);

      final Uri request = client.requests.single;
      expect(request.path, '/wp-json/wp/v2/posts');
      expect(request.queryParameters, <String, String>{
        'categories': '7,11,14',
        'per_page': '10',
        'page': '2',
        '_embed': 'wp:featuredmedia',
      });
    });

    test('the last page has no more (FX-WP-02)', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse(
          wordPressFixture('fx_wp_02_posts_last_page.json'),
          headers: <String, String>{'x-wp-totalpages': '3'},
        ),
      );

      final NewsPage page = _ok(await _repository(client).listPosts(page: 3));

      expect(page.posts, hasLength(5));
      expect(page.hasMore, isFalse);
    });

    test('without the page count header, a full page means more', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) =>
            jsonResponse(wordPressFixture('fx_wp_01_posts_page1.json')),
      );

      final NewsPage page = _ok(await _repository(client).listPosts());

      expect(page.hasMore, isTrue);
    });

    test('a page past the end is an empty last page (FX-WP-07)', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse(
          wordPressFixture('fx_wp_07_page_out_of_range.json'),
          status: 400,
        ),
      );

      final NewsPage page = _ok(await _repository(client).listPosts(page: 4));

      expect(page.posts, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('a post without featured media has no image (FX-WP-04)', () async {
      final String post = wordPressFixture('fx_wp_04_post_without_media.json');
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse('[$post]'),
      );

      final NewsPage page = _ok(await _repository(client).listPosts());

      expect(page.posts.single.imageUrl, isNull);
    });

    test('titles have their entities decoded (FX-WP-06) '
        '[CODING_STANDARDS 7]', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse(
          wordPressFixture('fx_wp_06_titles_with_entities.json'),
        ),
      );

      final NewsPage page = _ok(await _repository(client).listPosts());

      expect(page.posts.map((NewsPost p) => p.title), <String>[
        'Synthetic press’s new line',
        'Price ₹ 1,200 & more',
        '“Umformtechnik” für Anfänger',
      ]);
    });
  });

  group('category filter [FR-NEWS-003, INT-WP-003]', () {
    test('asks for one selected category', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse('[]'),
      );

      final NewsPage page = _ok(
        await _repository(client).listPosts(categoryId: '11'),
      );

      expect(client.requests.single.queryParameters['categories'], '11');
      expect(page.posts, isEmpty, reason: 'an empty category (FX-WP-03)');
      expect(page.hasMore, isFalse);
    });

    test(
      'refuses a category that is not selected, without a request',
      () async {
        final FakeHttpsGetClient client = FakeHttpsGetClient(
          (Uri uri) => jsonResponse('[]'),
        );

        final AppFailure failure = _err(
          await _repository(client).listPosts(categoryId: '1'),
        );

        expect(failure.code, FailureCode.notFound);
        expect(client.requests, isEmpty);
      },
    );

    test(
      'lists the selected categories in their order, names decoded',
      () async {
        final FakeHttpsGetClient client = FakeHttpsGetClient(
          (Uri uri) =>
              jsonResponse(wordPressFixture('fx_wp_01_categories.json')),
        );

        final List<NewsCategory> categories = _ok(
          await _repository(client).listCategories(),
        );

        expect(client.requests.single.path, '/wp-json/wp/v2/categories');
        expect(client.requests.single.queryParameters, <String, String>{
          'include': '7,11,14',
          'per_page': '3',
          'orderby': 'include',
        });
        expect(categories.map((NewsCategory c) => c.categoryId), <String>[
          '7',
          '11',
          '14',
        ]);
        expect(categories.last.name, 'Fairs & Events');
      },
    );

    test(
      'drops a category the site returns but the app does not show',
      () async {
        final FakeHttpsGetClient client = FakeHttpsGetClient(
          (Uri uri) => jsonResponse(
            '[{"id": 1, "name": "Synthetic Blog"}, {"id": 7, "name": "News"}]',
          ),
        );

        final List<NewsCategory> categories = _ok(
          await _repository(client).listCategories(),
        );

        expect(categories.map((NewsCategory c) => c.categoryId), <String>['7']);
      },
    );
  });

  group('article [FR-NEWS-002, INT-WP-005]', () {
    test('reads one post', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) =>
            jsonResponse(wordPressFixture('fx_wp_04_post_without_media.json')),
      );

      final NewsPost post = _ok(await _repository(client).getPost('9031'));

      expect(client.requests.single.path, '/wp-json/wp/v2/posts/9031');
      expect(post.postId, '9031');
      expect(post.contentHtml, contains('Synthetic body of post 31.'));
    });

    test('keeps the body as sent; scripts are dropped by the renderer, '
        'not here (FX-WP-05, SEC-CHK-15 in MOD09-P2-T01)', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) =>
            jsonResponse(wordPressFixture('fx_wp_05_post_with_script.json')),
      );

      final NewsPost post = _ok(await _repository(client).getPost('9032'));

      expect(post.contentHtml, contains('<script>'));
      expect(post.contentHtml, contains('Text after the script.'));
    });

    test('an unknown post is notFound', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse(
          wordPressFixture('fx_wp_09_invalid_post_id.json'),
          status: 404,
        ),
      );

      final AppFailure failure = _err(await _repository(client).getPost('1'));

      expect(failure.code, FailureCode.notFound);
    });

    test(
      'a post outside the selected categories is notFound [INT-WP-003]',
      () async {
        final FakeHttpsGetClient client = FakeHttpsGetClient(
          (Uri uri) => jsonResponse(
            wordPressFixture(
              'fx_wp_04_post_without_media.json',
            ).replaceFirst('"categories": [\n    7\n  ]', '"categories": [1]'),
          ),
        );

        final AppFailure failure = _err(
          await _repository(client).getPost('9031'),
        );

        expect(failure.code, FailureCode.notFound);
      },
    );

    test('the post ID is sent as one path segment', () async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => jsonResponse('{}', status: 404),
      );

      await _repository(client).getPost('12/../users');

      expect(client.requests.single.pathSegments.last, '12/../users');
      expect(client.requests.single.pathSegments, hasLength(5));
    });
  });

  group('site unreachable or unusable [FR-STATE-005]', () {
    Future<AppFailure> listWith(Result<HttpsResponse> response) async {
      final FakeHttpsGetClient client = FakeHttpsGetClient(
        (Uri uri) => response,
      );
      return _err(await _repository(client).listPosts());
    }

    test('API blocked: serviceUnavailable, no retry (FX-WP-08)', () async {
      for (final int status in <int>[401, 403]) {
        final AppFailure failure = await listWith(
          jsonResponse(
            wordPressFixture('fx_wp_08_api_blocked.json'),
            status: status,
          ),
        );
        expect(failure.code, FailureCode.serviceUnavailable);
        expect(failure.retryable, isFalse);
      }
    });

    test(
      'wrong route or base address: serviceUnavailable (FX-WP-09)',
      () async {
        final AppFailure failure = await listWith(
          jsonResponse(wordPressFixture('fx_wp_09_no_route.json'), status: 404),
        );

        expect(failure.code, FailureCode.serviceUnavailable);
        expect(failure.detail, contains('rest_no_route'));
      },
    );

    test('server error: serviceUnavailable, retryable (FX-WP-10)', () async {
      for (final int status in <int>[500, 503, 429]) {
        final AppFailure failure = await listWith(
          htmlResponse('<p>Synthetic error</p>', status: status),
        );
        expect(failure.code, FailureCode.serviceUnavailable);
        expect(failure.retryable, isTrue);
      }
    });

    test('a redirect is not followed: serviceUnavailable', () async {
      final AppFailure failure = await listWith(htmlResponse('', status: 301));

      expect(failure.code, FailureCode.serviceUnavailable);
    });

    test('HTML with status 200 is invalidResponse (FX-WP-12)', () async {
      final AppFailure failure = await listWith(
        htmlResponse(wordPressFixture('fx_wp_12_html_page.html')),
      );

      expect(failure.code, FailureCode.invalidResponse);
    });

    test('JSON of the wrong shape is invalidResponse', () async {
      for (final String body in <String>[
        '{"posts": []}',
        '[{"id": "9001"}]',
        '[{"id": 9001, "title": {"rendered": "T"}}]',
        'not json',
      ]) {
        final AppFailure failure = await listWith(jsonResponse(body));
        expect(failure.code, FailureCode.invalidResponse, reason: body);
      }
    });

    test('network and timeout failures pass through (FX-WP-11)', () async {
      const AppFailure timeout = AppFailure(
        FailureCode.timeout,
        retryable: true,
      );
      final AppFailure failure = await listWith(
        const Err<HttpsResponse>(timeout),
      );

      expect(failure, same(timeout));
    });
  });
}
