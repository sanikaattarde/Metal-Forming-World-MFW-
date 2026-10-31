import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import '../../fakes/fixture_loader.dart';
import '../../fakes/test_helpers.dart';
import 'fake_wordpress_site.dart';
import 'news_test_support.dart';
import 'wp_fixtures.dart';

FixtureTransport serving(String fileName) =>
    FixtureTransport(WpFixture.load(fileName));

HttpResponse jsonResponse(Object? body, {int status = 200}) => HttpResponse(
  statusCode: status,
  headers: const <String, String>{'Content-Type': 'application/json'},
  body: jsonEncode(body),
);

/// A transport that answers every request with [response].
final class OneResponse implements HttpTransport {
  OneResponse(this.response);

  final Result<HttpResponse> response;

  final List<Uri> requests = <Uri>[];

  @override
  Future<Result<HttpResponse>> get(Uri url) async {
    requests.add(url);
    return response;
  }
}

List<String> idsOf(Iterable<NewsPost> posts) =>
    posts.map((NewsPost post) => post.postId).toList();

void main() {
  group('listPosts [INT-WP-001, INT-WP-004, IC-06]', () {
    test(
      'FX-WP-01: maps ten posts and finds more pages [FR-NEWS-001]',
      () async {
        final FixtureTransport transport = serving('fx_wp_01_posts_page1.json');

        final NewsPage page = valueOf(
          await repositoryOver(transport).listPosts(),
        );

        expect(idsOf(page.posts), <String>[
          for (int id = 125; id > 115; id--) '$id',
        ]);
        expect(page.hasMore, isTrue);
        expect(page.fromCache, isFalse);
        final NewsPost first = page.posts.first;
        expect(first.title, 'Test post 125');
        expect(
          first.contentHtml,
          contains('Synthetic body text for post 125.'),
        );
        expect(first.publishedAt, DateTime.utc(2026, 3, 25, 9, 30));
        expect(first.publishedAt.isUtc, isTrue);
        expect(
          first.link,
          Uri.parse('https://wordpress.example/news/test-post-125/'),
        );
        expect(first.categoryIds, <String>['11']);
        expect(
          first.imageUrl,
          Uri.parse('https://wordpress.example/img/125.jpg'),
        );
        expect(page.posts[5].categoryIds, <String>['11', '12']);
      },
    );

    test('asks for small pages of the selected categories, newest first, '
        'with embedded media [INT-WP-003, INT-WP-004]', () async {
      final FixtureTransport transport = serving('fx_wp_01_posts_page1.json');

      await repositoryOver(transport).listPosts(page: 2);
      await repositoryOver(transport).listPosts(categoryId: '12');

      final Uri all = transport.requests.first;
      expect(all.scheme, 'https');
      expect(all.host, 'wordpress.example');
      expect(all.path, '/wp-json/wp/v2/posts');
      expect(all.queryParameters, <String, String>{
        'categories': '11,12,13',
        'per_page': '10',
        'page': '2',
        'orderby': 'date',
        'order': 'desc',
        '_embed': '',
      });
      expect(transport.requests.last.queryParameters['categories'], '12');
      expect(transport.requests.last.queryParameters['page'], '1');
    });

    test('a site in a sub-folder keeps its path', () async {
      final FixtureTransport transport = serving('fx_wp_01_posts_page1.json');
      final WordPressNewsRepository news = WordPressNewsRepository(
        transport: transport,
        site: WordPressSite(
          baseUrl: Uri.parse('https://wordpress.example/blog'),
          categoryIds: const <String>['11'],
        ),
      );

      await news.listPosts();

      expect(transport.requests.single.path, '/blog/wp-json/wp/v2/posts');
    });

    test('FX-WP-02: the last page has no more [FR-NEWS-001]', () async {
      final NewsPage page = valueOf(
        await repositoryOver(serving('fx_wp_02_posts_last_page.json'))
            .listPosts(page: 3),
      );

      expect(idsOf(page.posts), <String>['105', '104', '103', '102', '101']);
      expect(page.hasMore, isFalse);
    });

    test(
      'FX-WP-03: an empty category is an empty page [FR-STATE-002]',
      () async {
        final NewsPage page = valueOf(
          await repositoryOver(serving('fx_wp_03_empty_category.json'))
              .listPosts(categoryId: '13'),
        );

        expect(page.posts, isEmpty);
        expect(page.hasMore, isFalse);
      },
    );

    test(
      'without the page headers, a full page means there may be more',
      () async {
        final List<Map<String, Object?>> ten = wpPostsIn(
          'fx_wp_01_posts_page1.json',
        );

        final NewsPage full = valueOf(
          await repositoryOver(OneResponse(Ok(jsonResponse(ten)))).listPosts(),
        );
        final NewsPage short = valueOf(
          await repositoryOver(
            OneResponse(Ok(jsonResponse(ten.take(4).toList()))),
          ).listPosts(),
        );

        expect(full.hasMore, isTrue);
        expect(short.hasMore, isFalse);
      },
    );

    test('FX-WP-07: a page past the end is an empty last page', () async {
      final NewsPage page = valueOf(
        await repositoryOver(serving('fx_wp_07_page_out_of_range.json'))
            .listPosts(page: 4),
      );

      expect(page.posts, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('a category MFW did not select is notFound, with no request '
        '[INT-WP-003]', () async {
      final FixtureTransport transport = serving('fx_wp_01_posts_page1.json');

      expect(
        failureCodeOf(
          await repositoryOver(transport).listPosts(categoryId: '99'),
        ),
        FailureCode.notFound,
      );
      expect(transport.requests, isEmpty);
    });

    test('a page below 1 is invalidInput, with no request', () async {
      final FixtureTransport transport = serving('fx_wp_01_posts_page1.json');

      expect(
        failureCodeOf(await repositoryOver(transport).listPosts(page: 0)),
        FailureCode.invalidInput,
      );
      expect(transport.requests, isEmpty);
    });
  });

  group('getPost [FR-NEWS-002]', () {
    test('FX-WP-04: a post without featured media has no image', () async {
      final NewsPost post = valueOf(
        await repositoryOver(serving('fx_wp_04_post_without_media.json'))
            .getPost('202'),
      );

      expect(post.postId, '202');
      expect(post.imageUrl, isNull);
    });

    test('FX-WP-05: keeps the embedded image; the body text has no script '
        '[SEC-CHK-15]', () async {
      final NewsPost post = valueOf(
        await repositoryOver(serving('fx_wp_05_post_with_script.json'))
            .getPost('201'),
      );

      expect(post.imageUrl, Uri.parse('https://wordpress.example/img/201.jpg'));
      final String text = htmlToPlainText(post.contentHtml);
      expect(text, contains('Synthetic text before the script.'));
      expect(text, contains('Synthetic text after the script & the embed.'));
      for (final String code in <String>[
        'fx-wp-05-script-ran',
        'alert',
        'color: red',
        'fx-wp-05-iframe',
        'onerror',
        '<',
      ]) {
        expect(text, isNot(contains(code)), reason: code);
      }
    });

    test('FX-WP-06: entities in the title are decoded and non-ASCII text '
        'kept', () async {
      final NewsPost post = valueOf(
        await repositoryOver(serving('fx_wp_06_entities.json')).getPost('203'),
      );

      expect(
        post.title,
        'Test post 203 – ‘Quoted’ & ₹ prices, Café notes and Größe tables',
      );
    });

    test('asks for the post by its ID with embedded media', () async {
      final FixtureTransport transport = serving(
        'fx_wp_04_post_without_media.json',
      );

      await repositoryOver(transport).getPost('202');

      expect(transport.requests.single.path, '/wp-json/wp/v2/posts/202');
      expect(transport.requests.single.queryParameters, <String, String>{
        '_embed': '',
      });
    });

    test('an ID with a slash stays one path segment', () async {
      final FixtureTransport transport = serving(
        'fx_wp_04_post_without_media.json',
      );

      await repositoryOver(transport).getPost('202/../../users');

      expect(transport.requests.single.pathSegments, <String>[
        'wp-json',
        'wp',
        'v2',
        'posts',
        '202/../../users',
      ]);
    });

    test('a post outside the selected categories is notFound '
        '[INT-WP-003]', () async {
      final Map<String, Object?> post = wpPostIn(
        'fx_wp_04_post_without_media.json',
      )..['categories'] = <int>[99];

      expect(
        failureCodeOf(
          await repositoryOver(OneResponse(Ok(jsonResponse(post))))
              .getPost('202'),
        ),
        FailureCode.notFound,
      );
    });

    test('an unknown post is notFound', () async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures();

      expect(
        failureCodeOf(await repositoryOver(site).getPost('999')),
        FailureCode.notFound,
      );
    });
  });

  group('listCategories [FR-NEWS-003, INT-WP-003]', () {
    test('FX-WP-01: three categories, names decoded, in the configured '
        'order', () async {
      final FixtureTransport transport = serving('fx_wp_01_categories.json');

      final List<NewsCategory> categories = valueOf(
        await repositoryOver(transport).listCategories(),
      );

      expect(
        categories.map((NewsCategory category) => category.categoryId),
        <String>['11', '12', '13'],
      );
      expect(categories[1].name, 'Test News B & Events');
      expect(transport.requests.single.path, '/wp-json/wp/v2/categories');
      expect(transport.requests.single.queryParameters, <String, String>{
        'include': '11,12,13',
        'per_page': '3',
      });
    });

    test('a category MFW did not select is dropped', () async {
      final List<Object?> body = <Object?>[
        ...WpFixture.load('fx_wp_01_categories.json').json! as List<Object?>,
        <String, Object?>{'id': 99, 'name': 'Not selected'},
      ];

      final List<NewsCategory> categories = valueOf(
        await repositoryOver(OneResponse(Ok(jsonResponse(body))))
            .listCategories(),
      );

      expect(categories, hasLength(3));
    });
  });

  group('failures [FR-STATE-005]', () {
    test('FX-WP-08: a blocked API (403 or 401) is serviceUnavailable, not '
        'retryable', () async {
      final WpFixture blocked = WpFixture.load('fx_wp_08_blocked.json');
      for (final int status in <int>[403, 401]) {
        final AppFailure? failure = failureOf(
          await repositoryOver(
            OneResponse(
              Ok(
                HttpResponse(
                  statusCode: status,
                  headers: blocked.headers,
                  body: blocked.body,
                ),
              ),
            ),
          ).listPosts(),
        );

        expect(
          failure?.code,
          FailureCode.serviceUnavailable,
          reason: '$status',
        );
        expect(failure?.retryable, isFalse, reason: '$status');
      }
    });

    test(
      'FX-WP-09: a wrong route is serviceUnavailable, not retryable',
      () async {
        final AppFailure? failure = failureOf(
          await repositoryOver(serving('fx_wp_09_no_route.json')).listPosts(),
        );

        expect(failure?.code, FailureCode.serviceUnavailable);
        expect(failure?.retryable, isFalse);
        expect(failure?.detail, contains('rest_no_route'));
      },
    );

    test('FX-WP-10: a server error (503 or 500) is serviceUnavailable and '
        'retryable', () async {
      final WpFixture down = WpFixture.load('fx_wp_10_server_error.json');
      for (final int status in <int>[503, 500]) {
        final AppFailure? failure = failureOf(
          await repositoryOver(
            OneResponse(
              Ok(
                HttpResponse(
                  statusCode: status,
                  headers: down.headers,
                  body: down.body,
                ),
              ),
            ),
          ).getPost('101'),
        );

        expect(
          failure?.code,
          FailureCode.serviceUnavailable,
          reason: '$status',
        );
        expect(failure?.retryable, isTrue, reason: '$status');
      }
    });

    test('FX-WP-11: a response slower than the client timeout is a '
        'retryable timeout', () async {
      final AppFailure? failure = failureOf(
        await repositoryOver(serving('fx_wp_11_slow.json')).listPosts(),
      );

      expect(failure?.code, FailureCode.timeout);
      expect(failure?.retryable, isTrue);
    });

    test('FX-WP-12: an HTML page with status 200 is invalidResponse', () async {
      expect(
        failureCodeOf(
          await repositoryOver(serving('fx_wp_12_html_page.json')).listPosts(),
        ),
        FailureCode.invalidResponse,
      );
      expect(
        failureCodeOf(
          await repositoryOver(serving('fx_wp_12_html_page.json'))
              .listCategories(),
        ),
        FailureCode.invalidResponse,
      );
    });

    test('no connection is a retryable network failure', () async {
      final AppFailure? failure = failureOf(
        await repositoryOver(
          OneResponse(
            const Err<HttpResponse>(
              AppFailure(FailureCode.network, retryable: true),
            ),
          ),
        ).listPosts(),
      );

      expect(failure?.code, FailureCode.network);
      expect(failure?.retryable, isTrue);
    });

    test('another 400 is invalidResponse', () async {
      expect(
        failureCodeOf(
          await repositoryOver(
            OneResponse(
              Ok(
                jsonResponse(<String, Object?>{
                  'code': 'rest_invalid_param',
                }, status: 400),
              ),
            ),
          ).listPosts(),
        ),
        FailureCode.invalidResponse,
      );
    });

    test('a post missing a required field fails the page as '
        'invalidResponse [CODING_STANDARDS section 7]', () async {
      final List<Map<String, Object?>> posts = wpPostsIn(
        'fx_wp_01_posts_page1.json',
      );
      posts[3].remove('title');

      expect(
        failureCodeOf(
          await repositoryOver(OneResponse(Ok(jsonResponse(posts))))
              .listPosts(),
        ),
        FailureCode.invalidResponse,
      );
    });

    test('an object where a list is expected is invalidResponse', () async {
      expect(
        failureCodeOf(
          await repositoryOver(
            OneResponse(Ok(jsonResponse(<String, Object?>{'posts': 1}))),
          ).listPosts(),
        ),
        FailureCode.invalidResponse,
      );
    });

    test(
      'unknown fields are ignored and a non-https image is dropped',
      () async {
        final Map<String, Object?> post =
            wpPostIn('fx_wp_04_post_without_media.json')
              ..['unknown_field'] = <String, Object?>{'x': 1}
              ..['_embedded'] = <String, Object?>{
                'wp:featuredmedia': <Object?>[
                  <String, Object?>{
                    'source_url': 'http://wordpress.example/a.jpg',
                  },
                ],
              };

        final NewsPost read = valueOf(
          await repositoryOver(OneResponse(Ok(jsonResponse(post))))
              .getPost('202'),
        );

        expect(read.imageUrl, isNull);
      },
    );
  });

  group('WordPressSite [INT-WP-001]', () {
    test('refuses an address that is not https', () {
      expect(
        () => WordPressSite(
          baseUrl: Uri.parse('http://wordpress.example/'),
          categoryIds: const <String>['11'],
        ),
        throwsArgumentError,
      );
    });

    test('refuses an empty category list', () {
      expect(
        () => WordPressSite(
          baseUrl: Uri.parse('https://wordpress.example/'),
          categoryIds: const <String>[],
        ),
        throwsArgumentError,
      );
    });
  });

  group('news controls [FX-WP-13]', () {
    test('the fixture hides one FX-WP-01 post and marks another breaking', () {
      final Map<String, Object?> controls = readJsonFixture(
        'wordpress/fx_wp_13_news_controls.json',
      ) as Map<String, Object?>;
      final Set<String> page1 = <String>{
        for (final Map<String, Object?> post in wpPostsIn(
          'fx_wp_01_posts_page1.json',
        ))
          '${post['id']}',
      };

      final List<Object?> hidden = controls['hiddenPostIds']! as List<Object?>;
      final List<Object?> breaking =
          controls['breakingPostIds']! as List<Object?>;
      expect(hidden, hasLength(1));
      expect(breaking, hasLength(1));
      expect(page1, containsAll(<Object?>[...hidden, ...breaking]));
      expect(hidden.first, isNot(breaking.first));
    });

    test(
      'controls are not applied yet: no post is breaking (T-08.4)',
      () async {
        final NewsPage page = valueOf(
          await repositoryOver(serving('fx_wp_01_posts_page1.json'))
              .listPosts(),
        );

        expect(page.posts.any((NewsPost post) => post.isBreaking), isFalse);
      },
    );
  });
}
