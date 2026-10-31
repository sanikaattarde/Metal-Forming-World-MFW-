import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import 'fake_wordpress_site.dart';
import 'labelled_news_image_source.dart';
import 'news_test_support.dart';
import 'wp_fixtures.dart';

FakeWordPressSite siteWith(String fileName) =>
    FakeWordPressSite.fromFixtures()..posts.add(wpPostIn(fileName));

Widget articleScreen(HttpTransport transport, String postId) =>
    NewsArticleScreen(
      news: repositoryOver(transport),
      images: const LabelledNewsImageSource(),
      postId: postId,
    );

/// Every text shown on screen, joined.
String allText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text text) => text.data ?? text.textSpan?.toPlainText() ?? '')
    .join('\n');

void main() {
  group('NewsArticleScreen [FR-NEWS-002]', () {
    testWidgets('shows a loading indicator, then the image, title, date and '
        'content [AC-7.5]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        articleScreen(FakeWordPressSite.fromFixtures(), '125'),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('image:125'), findsOneWidget);
      expect(find.text('Test post 125'), findsOneWidget);
      expect(
        find.text(NewsText.date(DateTime.utc(2026, 3, 25, 9, 30).toLocal())),
        findsOneWidget,
      );
      expect(find.text('Synthetic body text for post 125.'), findsOneWidget);
      expect(find.text('Second synthetic paragraph.'), findsOneWidget);
    });

    testWidgets('scripts, styles and embeds are not shown and nothing runs '
        'them [FX-WP-05, SEC-CHK-15, AC-7.5]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        articleScreen(siteWith('fx_wp_05_post_with_script.json'), '201'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Synthetic text before the script.'), findsOneWidget);
      expect(
        find.text('Synthetic text after the script & the embed.'),
        findsOneWidget,
      );
      final String shown = allText(tester);
      for (final String code in <String>[
        'fx-wp-05-script-ran',
        'alert',
        'color: red',
        'fx-wp-05-iframe',
        'onerror',
        '<',
      ]) {
        expect(shown, isNot(contains(code)), reason: code);
      }
      expect(find.text('image:201'), findsOneWidget);
    });

    testWidgets('entities in the title and body are decoded [FX-WP-06]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        articleScreen(siteWith('fx_wp_06_entities.json'), '203'),
        size: const Size(320, 900),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text(
          'Test post 203 – ‘Quoted’ & ₹ prices, Café notes and Größe tables',
        ),
        findsOneWidget,
      );
      expect(find.text('Prices in ₹ & notes in Café style…'), findsOneWidget);
    });

    testWidgets('an unknown or removed article is no longer available, with '
        'no retry', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        articleScreen(FakeWordPressSite.fromFixtures(), '999'),
      );
      await tester.pumpAndSettle();

      expect(find.text(NewsText.notAvailable), findsOneWidget);
      expect(find.text(NewsText.retry), findsNothing);
    });

    testWidgets('no connection says so, and Retry loads [FR-STATE-003]', (
      WidgetTester tester,
    ) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures()
        ..offline = true;
      await pumpScreen(tester, articleScreen(site, '124'));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.offline), findsOneWidget);

      site.offline = false;
      await tester.tap(find.text(NewsText.retry));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Test post 124'), findsOneWidget);
    });

    testWidgets('the article stays clear of side insets', (
      WidgetTester tester,
    ) async {
      tester.view.padding = const FakeViewPadding(left: 40, right: 60);
      await pumpScreen(
        tester,
        articleScreen(FakeWordPressSite.fromFixtures(), '125'),
      );
      await tester.pumpAndSettle();

      final Finder title = find.text('Test post 125');
      expect(tester.getTopLeft(title).dx, greaterThanOrEqualTo(40));
      expect(tester.getTopRight(title).dx, lessThanOrEqualTo(800 - 60));
    });

    testWidgets('a failure that is not retryable offers no retry '
        '[FX-WP-09]', (WidgetTester tester) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures()
        ..fault = WpFixture.load('fx_wp_09_no_route.json');
      await pumpScreen(tester, articleScreen(site, '125'));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.unreachable), findsOneWidget);
      expect(find.text(NewsText.retry), findsNothing);
      expect(
        failureCodeOfScreen(FailureCode.serviceUnavailable),
        NewsText.unreachable,
      );
    });
  });
}

String failureCodeOfScreen(FailureCode code) =>
    NewsText.failure(AppFailure(code));
