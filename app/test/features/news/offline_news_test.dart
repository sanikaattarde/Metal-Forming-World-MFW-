import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import '../../fakes/fake_news_controls_service.dart';
import '../../fakes/fake_news_repository.dart';

/// The cache in memory; [failWrites] makes every write fail.
final class MemoryNewsCache implements NewsCacheStore {
  NewsCacheRecord record = const NewsCacheRecord();
  bool failWrites = false;

  @override
  Future<NewsCacheRecord> load() async => record;

  @override
  Future<void> save(NewsCacheRecord next) async {
    if (failWrites) {
      throw const FileSystemException('full');
    }
    record = next;
  }
}

const AppFailure _offline = AppFailure(FailureCode.network, retryable: true);

FakeNewsRepository _site() => FakeNewsRepository(
  posts: <NewsPost>[
    for (int i = 6; i >= 1; i--)
      syntheticPost('${9000 + i}', day: i, category: i.isEven ? '7' : '11'),
  ],
  categories: const <NewsCategory>[
    NewsCategory(categoryId: '7', name: 'Industry News'),
    NewsCategory(categoryId: '11', name: 'Events'),
  ],
  pageSize: 4,
);

NewsPost _post(Result<NewsPost> result) => switch (result) {
  Ok<NewsPost>(:final NewsPost value) => value,
  Err<NewsPost>(:final AppFailure failure) => fail('failed ${failure.code}'),
};

void main() {
  group('articles already loaded read offline [FR-NEWS-005]', () {
    test(
      'an opened article is answered from the device, and says so',
      () async {
        final FakeNewsRepository site = _site();
        final OfflineNewsRepository news = OfflineNewsRepository(
          news: site,
          store: MemoryNewsCache(),
        );
        _post(await news.getPost('9003'));
        expect(news.fromDevice('9003'), isFalse);

        site.failure = _offline;
        expect(_post(await news.getPost('9003')).title, 'Synthetic post 9003');
        expect(news.fromDevice('9003'), isTrue);

        site.failure = null;
        _post(await news.getPost('9003'));
        expect(news.fromDevice('9003'), isFalse);
      },
    );

    test(
      'the oldest opened article rotates out [OQ-16, PLACEHOLDER]',
      () async {
        final FakeNewsRepository site = _site();
        final OfflineNewsRepository news = OfflineNewsRepository(
          news: site,
          store: MemoryNewsCache(),
          recentLimit: 2,
        );
        for (final String id in <String>['9001', '9002', '9003']) {
          _post(await news.getPost(id));
        }
        site.failure = _offline;

        // 9001 is past the limit, and is not on a kept list either.
        expect(await news.getPost('9001'), isA<Err<NewsPost>>());
        expect(await news.getPost('9002'), isA<Ok<NewsPost>>());
        expect(await news.getPost('9003'), isA<Ok<NewsPost>>());
      },
    );

    test('the first page of each list is kept, with its articles', () async {
      final FakeNewsRepository site = _site();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: site,
        store: MemoryNewsCache(),
      );
      await news.listPosts();
      await news.listPosts(categoryId: '11');
      site.failure = _offline;

      final NewsPage all = (await news.listPosts() as Ok<NewsPage>).value;
      expect(all.fromCache, isTrue);
      expect(all.hasMore, isFalse);
      expect(all.posts.map((NewsPost p) => p.postId), <String>[
        '9006',
        '9005',
        '9004',
        '9003',
      ]);
      final NewsPage events =
          (await news.listPosts(categoryId: '11') as Ok<NewsPage>).value;
      expect(events.posts.map((NewsPost p) => p.postId), <String>[
        '9005',
        '9003',
        '9001',
      ]);
      expect(await news.listPosts(categoryId: '7'), isA<Err<NewsPage>>());
      expect(await news.listPosts(page: 2), isA<Err<NewsPage>>());
      // An article on a kept list opens offline.
      expect(_post(await news.getPost('9004')).postId, '9004');
      expect(news.fromDevice('9004'), isTrue);
    });

    test('a failure that is not about the connection is not hidden', () async {
      final FakeNewsRepository site = _site();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: site,
        store: MemoryNewsCache(),
      );
      await news.listPosts();
      site.failure = const AppFailure(FailureCode.invalidResponse);

      expect(await news.listPosts(), isA<Err<NewsPage>>());
    });

    test('an article gone from the site leaves the recent copies', () async {
      final FakeNewsRepository site = _site();
      final MemoryNewsCache cache = MemoryNewsCache();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: site,
        store: cache,
      );
      _post(await news.getPost('9002'));
      site.posts.removeWhere((NewsPost p) => p.postId == '9002');

      final Result<NewsPost> gone = await news.getPost('9002');
      expect((gone as Err<NewsPost>).failure.code, FailureCode.notFound);
      expect(cache.record.recent, isEmpty);
    });

    test('a copy that cannot be written does not stop the news', () async {
      final MemoryNewsCache cache = MemoryNewsCache()..failWrites = true;
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: _site(),
        store: cache,
      );

      expect(await news.listPosts(), isA<Ok<NewsPage>>());
      expect(await news.getPost('9001'), isA<Ok<NewsPost>>());
    });
  });

  group('Save [FR-NEWS-006, OQ-16 working position]', () {
    test('a saved article stays until removed, past the rotation', () async {
      final FakeNewsRepository site = _site();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: site,
        store: MemoryNewsCache(),
        recentLimit: 1,
      );
      final NewsPost first = _post(await news.getPost('9001'));
      await news.save(first);
      _post(await news.getPost('9002'));
      expect(await news.isSaved('9001'), isTrue);

      site.failure = _offline;
      expect(_post(await news.getPost('9001')).postId, '9001');

      await news.remove('9001');
      expect(await news.isSaved('9001'), isFalse);
      expect(await news.saved(), isEmpty);
      expect(await news.getPost('9001'), isA<Err<NewsPost>>());
    });

    test(
      'the newest saved comes first, and saving again moves it up',
      () async {
        final OfflineNewsRepository news = OfflineNewsRepository(
          news: _site(),
          store: MemoryNewsCache(),
        );
        await news.save(syntheticPost('1'));
        await news.save(syntheticPost('2'));
        await news.save(syntheticPost('1'));

        expect((await news.saved()).map((NewsPost p) => p.postId), <String>[
          '1',
          '2',
        ]);
      },
    );

    test(
      'a saved article hidden later leaves the saved list [FR-NEWS-008]',
      () async {
        final OfflineNewsRepository offline = OfflineNewsRepository(
          news: _site(),
          store: MemoryNewsCache(),
        );
        final FakeNewsControlsService controls = FakeNewsControlsService();
        final ControlledNewsRepository news = ControlledNewsRepository(
          news: offline,
          controls: controls,
        );
        await offline.save(syntheticPost('9001'));
        await offline.save(syntheticPost('9002'));
        controls.hidePost('9001');

        final List<NewsPost> shown = (await news.applyTo(
          await offline.saved(),
        ) as Ok<List<NewsPost>>).value;
        expect(shown.map((NewsPost p) => p.postId), <String>['9002']);
        expect(await news.getPost('9001'), isA<Err<NewsPost>>());
      },
    );
  });

  group('JsonNewsCache', () {
    late Directory folder;

    setUp(() async {
      folder = await Directory.systemTemp.createTemp('news_cache');
    });

    tearDown(() async {
      await folder.delete(recursive: true);
    });

    test('keeps every part across a restart', () async {
      final NewsPost post = NewsPost(
        postId: '9001',
        title: 'Synthetic & title',
        contentHtml: '<p>Body</p>',
        publishedAt: DateTime.utc(2026, 3, 21, 9, 30),
        categoryIds: const <String>['7'],
        link: Uri.parse('https://news.example.test/synthetic-post-9001/'),
        isBreaking: true,
        imageUrl: Uri.parse('https://news.example.test/i.jpg'),
      );
      await JsonNewsCache(() async => folder).save(
        NewsCacheRecord(
          recent: <NewsPost>[post],
          saved: <NewsPost>[post],
          lists: <String, List<NewsPost>>{
            NewsCacheRecord.allKey: <NewsPost>[post],
          },
        ),
      );

      final NewsCacheRecord again = await JsonNewsCache(() async => folder)
          .load();
      for (final NewsPost read in <NewsPost>[
        again.recent.single,
        again.saved.single,
        again.lists[NewsCacheRecord.allKey]!.single,
      ]) {
        expect(read.postId, '9001');
        expect(read.title, 'Synthetic & title');
        expect(read.contentHtml, '<p>Body</p>');
        expect(read.publishedAt, DateTime.utc(2026, 3, 21, 9, 30));
        expect(read.categoryIds, <String>['7']);
        expect(read.link.path, '/synthetic-post-9001/');
        expect(read.isBreaking, isTrue);
        expect(read.imageUrl?.path, '/i.jpg');
      }
    });

    test(
      'an unreadable file counts as empty, and a broken post is skipped',
      () async {
        await File('${folder.path}/news_cache.json').writeAsString('{not json');
        expect(
          (await JsonNewsCache(() async => folder).load()).recent,
          isEmpty,
        );

        await File('${folder.path}/news_cache.json').writeAsString(
          '{"recent":[{"id":"1"},{"id":"2","title":"T","content":"<p>x</p>",'
          '"published_at":"2026-03-01T00:00:00.000Z","categories":["7"],'
          '"link":"https://news.example.test/2/"}]}',
        );
        final NewsCacheRecord record = await JsonNewsCache(() async => folder)
            .load();
        expect(record.recent.map((NewsPost p) => p.postId), <String>['2']);
        expect(record.saved, isEmpty);
      },
    );
  });

  group('SCR-A-19 and SCR-A-18 offline', () {
    Widget app(Widget child) =>
        MaterialApp(theme: buildMfwTheme(), home: child);

    testWidgets('an article from the device says the app is offline', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository site = _site();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: site,
        store: MemoryNewsCache(),
      );
      _post(await news.getPost('9001'));
      site.failure = _offline;

      await tester.pumpWidget(
        app(
          ArticleScreen(
            news: news,
            postId: '9001',
            onOpenLink: (Uri uri) async => true,
            fromDevice: news.fromDevice,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(NewsText.offlineArticle), findsOneWidget);
      expect(find.text('Synthetic body.'), findsOneWidget);
    });

    testWidgets('Save keeps the article, and the Saved filter lists it', (
      WidgetTester tester,
    ) async {
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: _site(),
        store: MemoryNewsCache(),
      );
      await tester.pumpWidget(
        app(
          ArticleScreen(
            news: news,
            postId: '9002',
            onOpenLink: (Uri uri) async => true,
            actions: (NewsPost post) => <Widget>[
              SaveArticleButton(saved: news, post: post),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(NewsText.save));
      await tester.pumpAndSettle();
      expect(find.text(NewsText.saved), findsOneWidget);
      expect(find.byTooltip(NewsText.unsave), findsOneWidget);
      expect(await news.isSaved('9002'), isTrue);

      await tester.pumpWidget(
        app(
          NewsScreen(
            news: news,
            onOpenPost: (_) {},
            loadSaved: () async => Ok<List<NewsPost>>(await news.saved()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, NewsText.savedFilter));
      await tester.pumpAndSettle();

      expect(find.text('Synthetic post 9002'), findsOneWidget);
      expect(find.text('Synthetic post 9006'), findsNothing);
    });

    testWidgets('Remove takes it off the saved list', (
      WidgetTester tester,
    ) async {
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: _site(),
        store: MemoryNewsCache(),
      );
      await news.save(syntheticPost('9003', category: '11', day: 3));
      await tester.pumpWidget(
        app(
          ArticleScreen(
            news: news,
            postId: '9003',
            onOpenLink: (Uri uri) async => true,
            actions: (NewsPost post) => <Widget>[
              SaveArticleButton(saved: news, post: post),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(NewsText.unsave));
      await tester.pumpAndSettle();
      expect(find.text(NewsText.removed), findsOneWidget);
      expect(await news.saved(), isEmpty);
    });

    testWidgets('a Save that cannot be written says so', (
      WidgetTester tester,
    ) async {
      final MemoryNewsCache cache = MemoryNewsCache();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: _site(),
        store: cache,
      );
      await tester.pumpWidget(
        app(
          ArticleScreen(
            news: news,
            postId: '9002',
            onOpenLink: (Uri uri) async => true,
            actions: (NewsPost post) => <Widget>[
              SaveArticleButton(saved: news, post: post),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      cache.failWrites = true;

      await tester.tap(find.byTooltip(NewsText.save));
      await tester.pumpAndSettle();
      expect(find.text(NewsText.saveFailed), findsOneWidget);
      expect(find.byTooltip(NewsText.save), findsOneWidget);
    });

    testWidgets('an empty Saved filter says how to save', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app(
          NewsScreen(
            news: _site(),
            onOpenPost: (_) {},
            loadSaved: () async => const Ok<List<NewsPost>>(<NewsPost>[]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, NewsText.savedFilter));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.savedEmptyHeading), findsOneWidget);
    });

    testWidgets('the list from the device carries the offline notice', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository site = _site();
      final OfflineNewsRepository news = OfflineNewsRepository(
        news: site,
        store: MemoryNewsCache(),
      );
      await news.listPosts();
      site.failure = _offline;

      await tester.pumpWidget(app(NewsScreen(news: news, onOpenPost: (_) {})));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.unreachableKept), findsOneWidget);
      expect(find.text('Synthetic post 9006'), findsOneWidget);
    });
  });
}
