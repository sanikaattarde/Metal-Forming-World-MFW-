import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import 'fake_wordpress_site.dart';
import 'news_test_support.dart';
import 'wp_fixtures.dart';

List<String> idsOf(Iterable<NewsPost> posts) =>
    posts.map((NewsPost post) => post.postId).toList();

/// Holds each request until the test releases it, in any order.
final class HeldTransport implements HttpTransport {
  HeldTransport(this.inner);

  final HttpTransport inner;

  final List<Completer<void>> held = <Completer<void>>[];

  @override
  Future<Result<HttpResponse>> get(Uri url) async {
    final Completer<void> release = Completer<void>();
    held.add(release);
    await release.future;
    return inner.get(url);
  }
}

void main() {
  late FakeWordPressSite site;
  late NewsFeed feed;

  setUp(() {
    site = FakeWordPressSite.fromFixtures();
    feed = NewsFeed(repositoryOver(site));
  });

  tearDown(() => feed.dispose());

  group('NewsFeed [MOD-09]', () {
    test('start loads the categories and the first page, newest first '
        '[FR-NEWS-001]', () async {
      expect(feed.status, NewsFeedStatus.loading);

      await feed.start();

      expect(feed.status, NewsFeedStatus.ready);
      expect(idsOf(feed.posts), <String>[
        for (int id = 125; id > 115; id--) '$id',
      ]);
      expect(feed.hasMore, isTrue);
      expect(feed.categoryNames, <String, String>{
        '11': 'Test News A',
        '12': 'Test News B & Events',
        '13': 'Test News C',
      });
      expect(feed.selectedCategoryId, isNull);
    });

    test(
      'selecting a category lists only its posts [AC-7.3, FR-NEWS-003]',
      () async {
        await feed.start();

        for (final String category in <String>['11', '12']) {
          await feed.select(category);

          expect(feed.selectedCategoryId, category);
          expect(feed.posts, isNotEmpty, reason: category);
          expect(
            feed.posts.every(
              (NewsPost post) => post.categoryIds.contains(category),
            ),
            isTrue,
            reason: category,
          );
        }
        expect(idsOf(feed.posts), contains('120'));

        await feed.select(null);

        expect(idsOf(feed.posts).first, '125');
        expect(feed.posts, hasLength(10));
      },
    );

    test('the empty category has no posts and no more [FX-WP-03]', () async {
      await feed.start();

      await feed.select('13');

      expect(feed.status, NewsFeedStatus.ready);
      expect(feed.posts, isEmpty);
      expect(feed.hasMore, isFalse);
    });

    test(
      'loadMore appends the next pages until the last [INT-WP-004]',
      () async {
        await feed.start();

        await feed.loadMore();
        expect(feed.posts, hasLength(20));
        expect(feed.hasMore, isTrue);

        await feed.loadMore();
        expect(feed.posts, hasLength(25));
        expect(feed.hasMore, isFalse);
        expect(idsOf(feed.posts).toSet(), hasLength(25));
        expect(idsOf(feed.posts).last, '101');
      },
    );

    test('a post published between pages is not listed twice', () async {
      await feed.start();
      site.posts.add(
        syntheticWpPost(126, dateGmt: DateTime.utc(2026, 3, 26, 9, 30)),
      );

      await feed.loadMore();

      expect(idsOf(feed.posts).toSet(), hasLength(feed.posts.length));
      expect(feed.posts, hasLength(19));
    });

    test(
      'refresh lists a newly published post [AC-7.2, FR-NEWS-004]',
      () async {
        await feed.start();
        site.posts.add(
          syntheticWpPost(126, dateGmt: DateTime.utc(2026, 3, 26, 9, 30)),
        );

        await feed.refresh();

        expect(idsOf(feed.posts).first, '126');
        expect(feed.posts, hasLength(10));
      },
    );

    test('a failed refresh keeps the loaded posts with a notice '
        '[FR-STATE-005]', () async {
      await feed.start();
      site.offline = true;

      await feed.refresh();

      expect(feed.status, NewsFeedStatus.ready);
      expect(feed.posts, hasLength(10));
      expect(feed.notice?.code, FailureCode.network);

      site.offline = false;
      await feed.refresh();

      expect(feed.notice, isNull);
    });

    test('a failed next page keeps the loaded posts with a notice', () async {
      await feed.start();
      site.fault = WpFixture.load('fx_wp_10_server_error.json');

      await feed.loadMore();

      expect(feed.posts, hasLength(10));
      expect(feed.hasMore, isTrue);
      expect(feed.notice?.code, FailureCode.serviceUnavailable);
      expect(feed.loadingMore, isFalse);
    });

    test('a failed start is failed, and retry loads [FR-STATE-003]', () async {
      site.fault = WpFixture.load('fx_wp_10_server_error.json');

      await feed.start();

      expect(feed.status, NewsFeedStatus.failed);
      expect(feed.failure?.code, FailureCode.serviceUnavailable);

      site.fault = null;
      await feed.retry();

      expect(feed.status, NewsFeedStatus.ready);
      expect(feed.posts, hasLength(10));
    });

    test('an answer for a category no longer selected is dropped', () async {
      await feed.start();
      final HeldTransport held = HeldTransport(site);
      final NewsFeed slow = NewsFeed(
        WordPressNewsRepository(
          transport: held,
          site: WordPressSite(
            baseUrl: testSite.baseUrl,
            categoryIds: testSite.categoryIds,
          ),
        ),
      );
      addTearDown(slow.dispose);
      final Future<void> starting = slow.start();
      await pumpEventQueue();
      for (final Completer<void> release in held.held) {
        release.complete();
      }
      await starting;
      held.held.clear();

      final Future<void> first = slow.select('11');
      final Future<void> second = slow.select('12');
      await pumpEventQueue();
      held.held[1].complete();
      await second;
      held.held[0].complete();
      await first;

      expect(slow.selectedCategoryId, '12');
      expect(
        slow.posts.every((NewsPost post) => post.categoryIds.contains('12')),
        isTrue,
      );
    });

    test('listeners hear each change', () async {
      int changes = 0;
      feed.addListener(() => changes++);

      await feed.start();

      expect(changes, greaterThan(0));
    });
  });
}
