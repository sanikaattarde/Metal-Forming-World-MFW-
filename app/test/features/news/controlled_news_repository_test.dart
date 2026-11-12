import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import '../../fakes/fake_news_controls_service.dart';
import '../../fakes/fake_news_repository.dart';

/// Posts 9012 (newest, day 12) down to 9001 (day 1); 10 per page.
FakeNewsRepository _news() => FakeNewsRepository(
  posts: <NewsPost>[
    for (int i = 12; i >= 1; i--)
      syntheticPost('${9000 + i}', day: i, category: i <= 3 ? '11' : '7'),
  ],
  categories: const <NewsCategory>[
    NewsCategory(categoryId: '7', name: 'Industry News'),
    NewsCategory(categoryId: '11', name: 'Events'),
  ],
);

List<String> _ids(Result<NewsPage> result) => switch (result) {
  Ok<NewsPage>(:final NewsPage value) => <String>[
    for (final NewsPost post in value.posts) post.postId,
  ],
  Err<NewsPage>(:final AppFailure failure) => fail('failed: ${failure.code}'),
};

void main() {
  group('hidden posts [FR-NEWS-008, IC-06]', () {
    test('a hidden post is not listed and cannot be opened', () async {
      final FakeNewsControlsService controls = FakeNewsControlsService()
        ..hidePost('9011');
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: _news(),
        controls: controls,
      );

      expect(_ids(await news.listPosts()), isNot(contains('9011')));
      final Result<NewsPost> opened = await news.getPost('9011');
      expect((opened as Err<NewsPost>).failure.code, FailureCode.notFound);
    });

    test(
      'hiding shows after the next first page, as after a refresh',
      () async {
        final FakeNewsControlsService controls = FakeNewsControlsService();
        final ControlledNewsRepository news = ControlledNewsRepository(
          news: _news(),
          controls: controls,
        );
        expect(_ids(await news.listPosts()), contains('9012'));

        controls.hidePost('9012');
        expect(_ids(await news.listPosts()), isNot(contains('9012')));

        controls.showPost('9012');
        expect(_ids(await news.listPosts()), contains('9012'));
      },
    );

    test('when the controls cannot be read, the news fails too', () async {
      final FakeNewsControlsService controls = FakeNewsControlsService()
        ..failure = const AppFailure(
          FailureCode.serviceUnavailable,
          retryable: true,
        );
      final FakeNewsRepository site = _news();
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: site,
        controls: controls,
      );

      final Result<NewsPage> listed = await news.listPosts();
      expect(
        (listed as Err<NewsPage>).failure.code,
        FailureCode.serviceUnavailable,
      );
      expect(site.listed, isEmpty);
      expect(await news.getPost('9012'), isA<Err<NewsPost>>());
    });
  });

  group('breaking posts [FR-NEWS-009, OQ-17 working position]', () {
    test('are marked and come first, newest first', () async {
      final FakeNewsControlsService controls = FakeNewsControlsService()
        ..markBreaking('9005')
        ..markBreaking('9008');
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: _news(),
        controls: controls,
      );

      final NewsPage page = (await news.listPosts() as Ok<NewsPage>).value;
      expect(page.posts.take(3).map((NewsPost p) => p.postId), <String>[
        '9008',
        '9005',
        '9012',
      ]);
      expect(page.posts[0].isBreaking, isTrue);
      expect(page.posts[2].isBreaking, isFalse);
      expect(page.posts, hasLength(10));
    });

    test('one beyond the first page is read and pinned, and left out of '
        'the next page', () async {
      final FakeNewsControlsService controls = FakeNewsControlsService()
        ..markBreaking('9001');
      final FakeNewsRepository site = _news();
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: site,
        controls: controls,
      );

      final List<String> first = _ids(await news.listPosts());
      expect(first.first, '9001');
      expect(first, hasLength(11));
      expect(site.read, <String>['9001']);

      final List<String> second = _ids(await news.listPosts(page: 2));
      expect(second, <String>['9002']);
    });

    test('a pinned post outside the chosen category is not added', () async {
      final FakeNewsControlsService controls = FakeNewsControlsService()
        ..markBreaking('9001');
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: _news(),
        controls: controls,
      );

      expect(
        _ids(await news.listPosts(categoryId: '7')),
        isNot(contains('9001')),
      );
      expect(_ids(await news.listPosts(categoryId: '11')).first, '9001');
    });

    test('an opened post is marked', () async {
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: _news(),
        controls: FakeNewsControlsService()..markBreaking('9003'),
      );

      final NewsPost post = (await news.getPost('9003') as Ok<NewsPost>).value;
      expect(post.isBreaking, isTrue);
    });

    test('no more than the limit are pinned', () async {
      final FakeNewsControlsService controls = FakeNewsControlsService();
      for (int i = 1; i <= 12; i++) {
        controls.markBreaking('${9000 + i}');
      }
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: _news(),
        controls: controls,
        pinnedLimit: 2,
      );

      final NewsPage page = (await news.listPosts() as Ok<NewsPage>).value;
      expect(page.posts.take(2).map((NewsPost p) => p.postId), <String>[
        '9012',
        '9011',
      ]);
      expect(page.posts, hasLength(10));
    });
  });

  group('the OP-04 records', () {
    test('only a flag set to true counts, and hidden wins over breaking', () {
      final NewsControls controls = newsControlsFrom(
        <String, Map<String, Object?>>{
          '1': <String, Object?>{'is_hidden': true, 'is_breaking': true},
          '2': <String, Object?>{'is_hidden': false, 'is_breaking': true},
          '3': <String, Object?>{'is_hidden': 'yes', 'is_breaking': 1},
          '4': <String, Object?>{},
        },
      );

      expect(controls.hiddenPostIds, <String>{'1'});
      expect(controls.breakingPostIds, <String>{'2'});
    });
  });

  group('IC-06 consumer check on SCR-A-18', () {
    testWidgets('a post hidden in the panel is gone after a refresh, and a '
        'breaking one is labelled first [AC-8.8]', (WidgetTester tester) async {
      final FakeNewsControlsService controls = FakeNewsControlsService();
      final ControlledNewsRepository news = ControlledNewsRepository(
        news: _news(),
        controls: controls,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: NewsScreen(news: news, onOpenPost: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Synthetic post 9012'), findsOneWidget);
      expect(find.text(NewsText.breaking.toUpperCase()), findsNothing);

      controls
        ..hidePost('9012')
        ..markBreaking('9009');
      await tester.fling(
        find.text('Synthetic post 9011'),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Synthetic post 9012'), findsNothing);
      expect(find.text(NewsText.breaking.toUpperCase()), findsOneWidget);
      final double breaking = tester
          .getTopLeft(find.text('Synthetic post 9009'))
          .dy;
      final double next = tester
          .getTopLeft(find.text('Synthetic post 9011'))
          .dy;
      expect(breaking, lessThan(next));
    });
  });
}
