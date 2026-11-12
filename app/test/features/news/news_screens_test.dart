import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import '../../fakes/fake_news_repository.dart';

const List<NewsCategory> _categories = <NewsCategory>[
  NewsCategory(categoryId: '7', name: 'Industry News'),
  NewsCategory(categoryId: '11', name: 'Events'),
];

Widget _app(Widget child) => MaterialApp(theme: buildMfwTheme(), home: child);

FakeNewsRepository _news({int count = 4, int pageSize = 10}) =>
    FakeNewsRepository(
      posts: <NewsPost>[
        for (int i = count; i >= 1; i--)
          syntheticPost('${9000 + i}', day: i, category: i.isEven ? '7' : '11'),
      ],
      categories: List<NewsCategory>.of(_categories),
      pageSize: pageSize,
    );

void main() {
  group('SCR-A-18 the news list [FR-NEWS-001, FR-NEWS-002, FR-NEWS-004]', () {
    testWidgets('lists the posts newest first with date and category', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await tester.pumpWidget(
        _app(NewsScreen(news: _news(), onOpenPost: opened.add)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Synthetic post 9004'), findsOneWidget);
      expect(find.text('4 March 2026 · Industry News'), findsOneWidget);
      expect(find.text('3 March 2026 · Events'), findsOneWidget);
      final double first = tester
          .getTopLeft(find.text('Synthetic post 9004'))
          .dy;
      final double last = tester
          .getTopLeft(find.text('Synthetic post 9001'))
          .dy;
      expect(first, lessThan(last));

      await tester.tap(find.text('Synthetic post 9003'));
      expect(opened, <String>['9003']);
    });

    testWidgets('the filter shows one category [FR-NEWS-004]', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news();
      await tester.pumpWidget(_app(NewsScreen(news: news, onOpenPost: (_) {})));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilterChip, NewsText.all), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Events'));
      await tester.pumpAndSettle();

      expect(news.listed.last, ('11', 1));
      expect(find.text('Synthetic post 9003'), findsOneWidget);
      expect(find.text('Synthetic post 9004'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, NewsText.all));
      await tester.pumpAndSettle();
      expect(news.listed.last, (null, 1));
      expect(find.text('Synthetic post 9004'), findsOneWidget);
    });

    testWidgets('an empty category says so', (WidgetTester tester) async {
      final FakeNewsRepository news = _news(count: 2)
        ..categories.add(
          const NewsCategory(categoryId: '14', name: 'Interviews'),
        );
      await tester.pumpWidget(_app(NewsScreen(news: news, onOpenPost: (_) {})));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Interviews'));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.emptyHeading), findsOneWidget);
    });

    testWidgets('Show more reads the next page', (WidgetTester tester) async {
      final FakeNewsRepository news = _news(count: 12, pageSize: 10);
      await tester.pumpWidget(_app(NewsScreen(news: news, onOpenPost: (_) {})));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic post 9002'), findsNothing);

      await tester.scrollUntilVisible(find.text(NewsText.more), 200);
      await tester.tap(find.text(NewsText.more));
      await tester.pumpAndSettle();

      expect(news.listed.last, (null, 2));
      await tester.scrollUntilVisible(find.text('Synthetic post 9001'), 200);
      expect(find.text(NewsText.more), findsNothing);
    });
  });

  group('the site cannot be reached [FR-STATE-005]', () {
    testWidgets('says so with Retry, and Retry reads again', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news()
        ..failure = const AppFailure(
          FailureCode.serviceUnavailable,
          retryable: true,
        );
      await tester.pumpWidget(_app(NewsScreen(news: news, onOpenPost: (_) {})));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.unreachable), findsOneWidget);
      expect(find.text('Synthetic post 9004'), findsNothing);

      news.failure = null;
      await tester.tap(find.text(NewsText.retry));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.unreachable), findsNothing);
      expect(find.text('Synthetic post 9004'), findsOneWidget);
    });

    testWidgets('a refresh that fails keeps the posts shown', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news();
      await tester.pumpWidget(_app(NewsScreen(news: news, onOpenPost: (_) {})));
      await tester.pumpAndSettle();

      news.failure = const AppFailure(FailureCode.network, retryable: true);
      await tester.fling(
        find.text('Synthetic post 9004'),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text(NewsText.unreachableKept), findsOneWidget);
      expect(find.text('Synthetic post 9004'), findsOneWidget);
    });
  });

  group('SCR-A-19 the article [FR-NEWS-003, SEC-CHK-15]', () {
    testWidgets('shows the category, title, date and body, with no script', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news()
        ..posts.add(
          syntheticPost(
            '9100',
            day: 21,
            body:
                '<p>Synthetic paragraph.</p>'
                '<script>document.title = "synthetic script";</script>'
                '<p>See <a href="https://example.test/more">more</a>.</p>',
          ),
        );
      final List<Uri> links = <Uri>[];
      await tester.pumpWidget(
        _app(
          ArticleScreen(
            news: news,
            postId: '9100',
            onOpenLink: (Uri uri) async {
              links.add(uri);
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('INDUSTRY NEWS'), findsOneWidget);
      expect(find.text('Synthetic post 9100'), findsOneWidget);
      expect(find.text('21 March 2026'), findsOneWidget);
      expect(find.text('Synthetic paragraph.'), findsOneWidget);
      expect(find.textContaining('synthetic script'), findsNothing);

      final Finder link = find.textContaining('See more.', findRichText: true);
      expect(link, findsOneWidget);
      final RichText text = tester.widget<RichText>(link);
      final TextSpan more = (text.text as TextSpan).children!
          .whereType<TextSpan>()
          .expand(
            (TextSpan s) => <TextSpan>[
              s,
              ...?s.children?.whereType<TextSpan>(),
            ],
          )
          .firstWhere((TextSpan s) => s.text == 'more');
      (more.recognizer! as TapGestureRecognizer).onTap!();
      expect(links, <Uri>[Uri.parse('https://example.test/more')]);
    });

    testWidgets('a link that cannot be opened says so', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news()
        ..posts.add(
          syntheticPost(
            '9101',
            body: '<p><a href="https://example.test/x">x</a></p>',
          ),
        );
      await tester.pumpWidget(
        _app(
          ArticleScreen(
            news: news,
            postId: '9101',
            onOpenLink: (Uri uri) async => false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final RichText text = tester.widget<RichText>(
        find.textContaining('x', findRichText: true).last,
      );
      final TextSpan root = text.text as TextSpan;
      final TextSpan x =
          <TextSpan>[root, ...?root.children?.whereType<TextSpan>()]
              .expand(
                (TextSpan s) => <TextSpan>[
                  s,
                  ...?s.children?.whereType<TextSpan>(),
                ],
              )
              .firstWhere((TextSpan s) => s.recognizer != null);
      (x.recognizer! as TapGestureRecognizer).onTap!();
      await tester.pumpAndSettle();

      expect(find.text(NewsText.linkFailed), findsOneWidget);
    });

    testWidgets('a removed article says it is not available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          ArticleScreen(
            news: _news(),
            postId: '1',
            onOpenLink: (Uri uri) async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(NewsText.goneHeading), findsOneWidget);
    });

    testWidgets('an unreachable site offers Retry', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news()
        ..failure = const AppFailure(FailureCode.timeout, retryable: true);
      await tester.pumpWidget(
        _app(
          ArticleScreen(
            news: news,
            postId: '9001',
            onOpenLink: (Uri uri) async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(NewsText.unreachable), findsOneWidget);

      news.failure = null;
      await tester.tap(find.text(NewsText.retry));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic post 9001'), findsOneWidget);
    });

    testWidgets('an embedded player is a link opened outside the app', (
      WidgetTester tester,
    ) async {
      final FakeNewsRepository news = _news()
        ..posts.add(
          syntheticPost(
            '9102',
            body: '<iframe src="https://video.example.test/embed/1"></iframe>',
          ),
        );
      final List<Uri> links = <Uri>[];
      await tester.pumpWidget(
        _app(
          ArticleScreen(
            news: news,
            postId: '9102',
            onOpenLink: (Uri uri) async {
              links.add(uri);
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(NewsText.openMedia));
      expect(links, <Uri>[Uri.parse('https://video.example.test/embed/1')]);
    });
  });
}
