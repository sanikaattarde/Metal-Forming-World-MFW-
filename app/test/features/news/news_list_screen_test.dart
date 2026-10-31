import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import '../../fakes/test_helpers.dart';
import 'fake_wordpress_site.dart';
import 'labelled_news_image_source.dart';
import 'news_test_support.dart';
import 'wp_fixtures.dart';

Widget listScreen(
  HttpTransport transport, {
  void Function(String postId)? onOpenPost,
}) => NewsListScreen(
  news: repositoryOver(transport),
  images: const LabelledNewsImageSource(),
  onOpenPost: onOpenPost,
);

Finder tile(String postId) => find.byKey(ValueKey<String>(postId));

Finder inTile(String postId, String text) =>
    find.descendant(of: tile(postId), matching: find.text(text));

List<String> shownPostIds(WidgetTester tester) => tester
    .widgetList<NewsPostTile>(find.byType(NewsPostTile))
    .map((NewsPostTile tile) => tile.post.postId)
    .toList();

/// Pulls far enough to arm the indicator on the tall test surface.
Future<void> pullToRefresh(WidgetTester tester) async {
  await tester.fling(find.byType(ListView), const Offset(0, 1000), 1000);
  await tester.pumpAndSettle();
}

/// The news list's own scrollable, not the category chips'.
Finder get postList => find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

void main() {
  group('NewsListScreen [MOD-09]', () {
    testWidgets('shows a loading indicator, then posts with image, title, '
        'date and category, newest first [AC-7.1, FR-NEWS-001]', (
      WidgetTester tester,
    ) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures();
      final List<NewsPost> expected = valueOf(
        await repositoryOver(site).listPosts(),
      ).posts;

      await pumpScreen(tester, listScreen(site));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(shownPostIds(tester), <String>[
        for (int id = 125; id > 115; id--) '$id',
      ]);
      for (final NewsPost post in expected) {
        final String id = post.postId;
        expect(inTile(id, imageMarker(post)), findsOneWidget, reason: id);
        expect(inTile(id, post.title), findsOneWidget, reason: id);
        expect(
          inTile(id, NewsText.date(post.publishedAt.toLocal())),
          findsOneWidget,
          reason: id,
        );
      }
      expect(inTile('125', 'Test News A'), findsOneWidget);
      expect(inTile('124', 'Test News B & Events'), findsOneWidget);
      expect(
        inTile('120', 'Test News A, Test News B & Events'),
        findsOneWidget,
      );
      double previous = -1;
      for (final String id in shownPostIds(tester)) {
        final double top = tester.getTopLeft(tile(id)).dy;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('each category chip lists only that category\'s posts '
        '[AC-7.3, FR-NEWS-003]', (WidgetTester tester) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures();
      await pumpScreen(tester, listScreen(site));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, NewsText.all), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Test News A'));
      await tester.pumpAndSettle();
      final List<String> categoryA = shownPostIds(tester);
      expect(categoryA, isNotEmpty);
      expect(
        categoryA.every((String id) => int.parse(id).isOdd || id == '120'),
        isTrue,
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Test News B & Events'));
      await tester.pumpAndSettle();
      final List<String> categoryB = shownPostIds(tester);
      expect(categoryB, isNotEmpty);
      expect(categoryB.every((String id) => int.parse(id).isEven), isTrue);

      await tester.tap(find.widgetWithText(ChoiceChip, NewsText.all));
      await tester.pumpAndSettle();
      expect(shownPostIds(tester).first, '125');
    });

    testWidgets('a category with no posts says so [FX-WP-03, FR-STATE-002]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, listScreen(FakeWordPressSite.fromFixtures()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Test News C'));
      await tester.pumpAndSettle();

      expect(find.byType(NewsPostTile), findsNothing);
      expect(find.text(NewsText.emptyCategory), findsOneWidget);
    });

    testWidgets('pulling to refresh lists a newly published post '
        '[AC-7.2, FR-NEWS-004]', (WidgetTester tester) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures();
      await pumpScreen(tester, listScreen(site));
      await tester.pumpAndSettle();
      site.posts.add(
        syntheticWpPost(126, dateGmt: DateTime.utc(2026, 3, 26, 9, 30)),
      );

      await pullToRefresh(tester);

      expect(shownPostIds(tester).first, '126');
    });

    testWidgets('More news loads the next page; the last page has no '
        'button [INT-WP-004]', (WidgetTester tester) async {
      await pumpScreen(tester, listScreen(FakeWordPressSite.fromFixtures()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text(NewsText.more),
        200,
        scrollable: postList,
      );
      await tester.tap(find.text(NewsText.more));
      await tester.pumpAndSettle();
      expect(shownPostIds(tester), hasLength(20));

      await tester.scrollUntilVisible(
        find.text(NewsText.more),
        200,
        scrollable: postList,
      );
      await tester.tap(find.text(NewsText.more));
      await tester.pumpAndSettle();

      expect(shownPostIds(tester), hasLength(25));
      expect(find.text(NewsText.more), findsNothing);
    });

    testWidgets('no connection says so, and Retry loads [FR-STATE-003]', (
      WidgetTester tester,
    ) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures()
        ..offline = true;
      await pumpScreen(tester, listScreen(site));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.offline), findsOneWidget);
      expect(find.byType(NewsPostTile), findsNothing);

      site
        ..offline = false
        ..gate = Completer<void>();
      await tester.tap(find.text(NewsText.retry));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      site.gate!.complete();
      await tester.pumpAndSettle();

      expect(find.byType(NewsPostTile), findsNWidgets(10));
    });

    testWidgets('a blocked site says news cannot be loaded, with no retry '
        '[FX-WP-08, FR-STATE-005]', (WidgetTester tester) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures()
        ..fault = WpFixture.load('fx_wp_08_blocked.json');
      await pumpScreen(tester, listScreen(site));
      await tester.pumpAndSettle();

      expect(find.text(NewsText.unreachable), findsOneWidget);
      expect(find.text(NewsText.retry), findsNothing);
    });

    testWidgets('a failed refresh keeps the posts loaded earlier, with a '
        'message [FR-STATE-005]', (WidgetTester tester) async {
      final FakeWordPressSite site = FakeWordPressSite.fromFixtures();
      await pumpScreen(tester, listScreen(site));
      await tester.pumpAndSettle();
      site.fault = WpFixture.load('fx_wp_12_html_page.json');

      await pullToRefresh(tester);

      expect(find.byType(NewsPostTile), findsNWidgets(10));
      expect(find.text(NewsText.staleNotice), findsOneWidget);
    });

    testWidgets('tapping a post opens it by its ID [FR-NEWS-002]', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await pumpScreen(
        tester,
        listScreen(FakeWordPressSite.fromFixtures(), onOpenPost: opened.add),
      );
      await tester.pumpAndSettle();

      await tester.tap(tile('123'));

      expect(opened, <String>['123']);
    });

    testWidgets('a post without featured media shows the placeholder '
        '[FX-WP-04]', (WidgetTester tester) async {
      final FakeWordPressSite site = FakeWordPressSite(
        posts: <Map<String, Object?>>[
          wpPostIn('fx_wp_04_post_without_media.json'),
        ],
        categories: wpPostsIn('fx_wp_01_categories.json'),
      );
      await pumpScreen(tester, listScreen(site));
      await tester.pumpAndSettle();

      expect(find.text('no-image:202'), findsOneWidget);
    });

    testWidgets('the chips and posts stay clear of side insets, and tap '
        'targets are 48 by 48 and labelled', (WidgetTester tester) async {
      tester.view.padding = const FakeViewPadding(left: 40, right: 60);
      await pumpScreen(tester, listScreen(FakeWordPressSite.fromFixtures()));
      await tester.pumpAndSettle();

      for (final Finder part in <Finder>[
        find.widgetWithText(ChoiceChip, NewsText.all),
        tile('125'),
      ]) {
        expect(tester.getTopLeft(part).dx, greaterThanOrEqualTo(40));
        expect(tester.getTopRight(part).dx, lessThanOrEqualTo(800 - 60));
      }
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
