import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';

/// News posts held in memory, synthetic.
final class ListedNews implements NewsRepository {
  ListedNews(this.posts, {this.failure});

  final List<NewsPost> posts;
  final AppFailure? failure;

  @override
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1}) async {
    final AppFailure? set = failure;
    if (set != null) {
      return Err<NewsPage>(set);
    }
    return Ok<NewsPage>(
      NewsPage(posts: posts, hasMore: false, fromCache: false),
    );
  }

  @override
  Future<Result<NewsPost>> getPost(String postId) async =>
      Ok<NewsPost>(posts.firstWhere((NewsPost p) => p.postId == postId));

  @override
  Future<Result<List<NewsCategory>>> listCategories() async =>
      const Ok<List<NewsCategory>>(<NewsCategory>[]);
}

NewsPost post(String id, {bool breaking = false}) => NewsPost(
  postId: id,
  title: 'Synthetic post $id',
  contentHtml: '<p>Synthetic.</p>',
  publishedAt: DateTime.utc(2026, 3, 21),
  categoryIds: const <String>['1'],
  link: Uri.parse('https://wp.example/$id'),
  isBreaking: breaking,
);

final class Calls {
  final List<String> log = <String>[];

  HomeActions get actions => HomeActions(
    onOpenIssue: (String id) => log.add('issue $id'),
    onOpenCatalogue: () => log.add('catalogue'),
    onOpenPost: (String id) => log.add('post $id'),
    onOpenNews: () => log.add('news'),
    onOpenDownloads: () => log.add('downloads'),
  );
}

Future<void> pumpHome(
  WidgetTester tester,
  CatalogueRepository catalogue,
  HomeActions actions, {
  NewsRepository? news,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMfwTheme(),
      home: HomeScreen(catalogue: catalogue, news: news, actions: actions),
    ),
  );
}

void main() {
  group('HomeScreen, SCR-A-10 [MOD05-P2-T03]', () {
    testWidgets('shows the latest issue, the archive and the way to the '
        'catalogue [FR-MAG-001, FR-MAG-006]', (WidgetTester tester) async {
      final Calls calls = Calls();
      await pumpHome(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        calls.actions,
      );
      expect(find.bySemanticsLabel('Loading the latest issues'), findsOne);
      await tester.pumpAndSettle();

      expect(find.text('LATEST ISSUE'), findsOneWidget);
      expect(find.text('Test Issue 01'), findsOneWidget);
      expect(find.text('Test Category A · 1 October 2026'), findsOneWidget);
      expect(find.text('ARCHIVE'), findsOneWidget);
      expect(find.text('Test Issue 02'), findsOneWidget);

      await tester.tap(find.text('View issue'));
      await tester.tap(find.text('Test Issue 02'));
      await tester.tap(find.text('See the catalogue'));
      expect(calls.log, <String>[
        'issue fx-iss-01',
        'issue fx-iss-02',
        'catalogue',
      ]);
    });

    testWidgets('the archive shows at most six issues after the latest', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        Calls().actions,
      );
      await tester.pumpAndSettle();
      // Nine published issues: the latest and six in the archive.
      expect(find.text('Test Issue 10'), findsNothing);
      expect(find.textContaining('a deliberately long title'), findsNothing);
    });

    testWidgets('with no connection it says so and offers Downloads '
        '[FR-STATE-002, NFR-OFF-001]', (WidgetTester tester) async {
      final Calls calls = Calls();
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.network, retryable: true);
      await pumpHome(tester, catalogue, calls.actions);
      await tester.pumpAndSettle();
      expect(find.text('The latest issues need a connection'), findsOneWidget);
      await tester.tap(find.text('Open Downloads'));
      expect(calls.log, <String>['downloads']);

      catalogue.failure = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('LATEST ISSUE'), findsOneWidget);
    });

    testWidgets('an empty catalogue shows the empty state and no archive', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        FakeCatalogueRepository(
          issues: const <IssueSummary>[],
          categories: const <IssueCategory>[],
        ),
        Calls().actions,
      );
      await tester.pumpAndSettle();
      expect(find.text('No issues yet'), findsOneWidget);
      expect(find.text('ARCHIVE'), findsNothing);
      expect(find.text('See the catalogue'), findsNothing);
    });

    testWidgets('shows up to three posts with the breaking label, each '
        'opening its article', (WidgetTester tester) async {
      final Calls calls = Calls();
      await pumpHome(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        calls.actions,
        news: ListedNews(<NewsPost>[
          post('1', breaking: true),
          post('2'),
          post('3'),
          post('4'),
        ]),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('See all news'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('BREAKING'), findsOneWidget);
      expect(find.text('Synthetic post 3'), findsOneWidget);
      expect(find.text('Synthetic post 4'), findsNothing);
      await tester.tap(find.text('Synthetic post 2'));
      await tester.ensureVisible(find.text('See all news'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See all news'));
      expect(calls.log, <String>['post 2', 'news']);
    });

    testWidgets('a news failure leaves the issues in place', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        Calls().actions,
        news: ListedNews(
          const <NewsPost>[],
          failure: const AppFailure(FailureCode.serviceUnavailable),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test Issue 01'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('The news cannot be loaded right now.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });

    testWidgets('without a news site there is no news section', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        Calls().actions,
      );
      await tester.pumpAndSettle();
      expect(find.text('LATEST NEWS'), findsNothing);
    });

    testWidgets('meets the tap-target and label guidelines', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        Calls().actions,
        news: ListedNews(<NewsPost>[post('1')]),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
