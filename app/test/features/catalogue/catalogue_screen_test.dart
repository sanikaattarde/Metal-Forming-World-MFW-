import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';
import '../../fakes/test_helpers.dart';
import 'catalogue_test_support.dart';
import 'labelled_cover_source.dart';

const List<String> newestFirst = <String>[
  'fx-iss-01',
  'fx-iss-02',
  'fx-iss-03',
  'fx-iss-04',
  'fx-iss-05',
  'fx-iss-06',
  'fx-iss-07',
  'fx-iss-10',
  'fx-iss-09',
];

Widget catalogueScreen(
  CatalogueRepository catalogue, {
  void Function(String issueId)? onOpenIssue,
}) => CatalogueScreen(
  catalogue: catalogue,
  covers: const LabelledCoverSource(),
  onOpenIssue: onOpenIssue,
);

Finder tile(String issueId) => find.byKey(ValueKey<String>(issueId));

Finder inTile(String issueId, String text) =>
    find.descendant(of: tile(issueId), matching: find.text(text));

List<String> shownIssueIds(WidgetTester tester) => tester
    .widgetList<IssueTile>(find.byType(IssueTile))
    .map((IssueTile tile) => tile.issue.issueId)
    .toList();

void main() {
  group('CatalogueScreen [MOD-05]', () {
    testWidgets('shows a loading indicator, then the issues '
        '[FR-STATE-001]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(IssueTile), findsNWidgets(9));
    });

    testWidgets('every issue shows its cover, title, date, category and '
        'description [AC-1.1, FR-MAG-002, FR-MAG-003]', (
      WidgetTester tester,
    ) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();
      final List<IssueSummary> issues = valueOf(
        await catalogue.listPublishedIssues(),
      );
      final Map<String, String> names = <String, String>{
        for (final IssueCategory category in valueOf(
          await catalogue.listCategories(),
        ))
          category.categoryId: category.name,
      };

      await pumpScreen(tester, catalogueScreen(catalogue));
      await tester.pumpAndSettle();

      for (final IssueSummary issue in issues) {
        final String id = issue.issueId;
        expect(inTile(id, coverMarker(id)), findsOneWidget, reason: id);
        expect(inTile(id, issue.title), findsOneWidget, reason: id);
        expect(
          inTile(id, CatalogueText.date(issue.publicationDate)),
          findsOneWidget,
          reason: id,
        );
        expect(inTile(id, names[issue.categoryId]!), findsOneWidget);
        expect(inTile(id, issue.description), findsOneWidget, reason: id);
      }
    });

    testWidgets('the latest issue comes first, then the archive, newest '
        'first [AC-1.1, FR-MAG-004]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );
      await tester.pumpAndSettle();

      expect(shownIssueIds(tester), newestFirst);
      final double latestHeading = tester
          .getTopLeft(find.text(CatalogueText.latest))
          .dy;
      final double archiveHeading = tester
          .getTopLeft(find.text(CatalogueText.archive))
          .dy;
      expect(latestHeading, lessThan(tester.getTopLeft(tile('fx-iss-01')).dy));
      expect(tester.getTopLeft(tile('fx-iss-01')).dy, lessThan(archiveHeading));
      expect(archiveHeading, lessThan(tester.getTopLeft(tile('fx-iss-02')).dy));
      double previous = archiveHeading;
      for (final String id in newestFirst.skip(1)) {
        final double top = tester.getTopLeft(tile(id)).dy;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('category names come from the repository [FR-MAG-003]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, catalogueScreen(renamedCategoryCatalogue()));
      await tester.pumpAndSettle();

      expect(inTile('fx-iss-01', 'Renamed A'), findsOneWidget);
      expect(find.text('Test Category A'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Renamed A');
      await tester.pump();

      expect(shownIssueIds(tester), <String>[
        'fx-iss-01',
        'fx-iss-05',
        'fx-iss-10',
      ]);
    });

    testWidgets('search lists only the matching issues, without the '
        'latest and archive headings [AC-1.2, FR-SRCH-001]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test Category B');
      await tester.pump();

      expect(shownIssueIds(tester), <String>['fx-iss-02', 'fx-iss-06']);
      expect(find.text(CatalogueText.latest), findsNothing);
      expect(find.text(CatalogueText.archive), findsNothing);

      await tester.enterText(find.byType(TextField), 'segments');
      await tester.pump();
      expect(shownIssueIds(tester), <String>['fx-iss-03']);

      await tester.enterText(find.byType(TextField), 'Issue 05');
      await tester.pump();
      expect(shownIssueIds(tester), <String>['fx-iss-05']);
    });

    testWidgets('clearing the search shows the whole catalogue again', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip(CatalogueText.clearSearch), findsNothing);

      await tester.enterText(find.byType(TextField), 'Issue 05');
      await tester.pump();
      await tester.tap(find.byTooltip(CatalogueText.clearSearch));
      await tester.pump();

      expect(shownIssueIds(tester), newestFirst);
      expect(find.text(CatalogueText.latest), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });

    testWidgets('a search with no match shows the empty state '
        '[FR-STATE-002]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'no such words');
      await tester.pump();

      expect(find.byType(IssueTile), findsNothing);
      expect(find.text(CatalogueText.noResults), findsOneWidget);
    });

    testWidgets('an empty catalogue says so [FR-STATE-002]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        catalogueScreen(
          FakeCatalogueRepository(
            issues: const <IssueSummary>[],
            categories: const <IssueCategory>[],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(CatalogueText.empty), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('no connection says so and offers a retry that loads the '
        'catalogue [FR-STATE-003]', (WidgetTester tester) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.network, retryable: true);
      await pumpScreen(tester, catalogueScreen(catalogue));
      await tester.pumpAndSettle();

      expect(find.text(CatalogueText.offline), findsOneWidget);
      expect(find.byType(IssueTile), findsNothing);

      catalogue.failure = null;
      await tester.tap(find.text(CatalogueText.retry));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(CatalogueText.offline), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(IssueTile), findsNWidgets(9));
    });

    testWidgets('a failure that is not retryable offers no retry', (
      WidgetTester tester,
    ) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.invalidResponse);
      await pumpScreen(tester, catalogueScreen(catalogue));
      await tester.pumpAndSettle();

      expect(find.text(CatalogueText.failed), findsOneWidget);
      expect(find.text(CatalogueText.retry), findsNothing);
    });

    testWidgets('tapping an issue opens it by its ID [FR-MAG-005]', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await pumpScreen(
        tester,
        catalogueScreen(
          FakeCatalogueRepository.fromFixtures(),
          onOpenIssue: opened.add,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(tile('fx-iss-03'));

      expect(opened, <String>['fx-iss-03']);
    });

    testWidgets('the long FX-ISS-09 title fits a narrow phone and is found '
        'by search [FX-ISS-09]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
        size: const Size(320, 2000),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField), 'café');
      await tester.pump();

      expect(shownIssueIds(tester), <String>['fx-iss-09']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the search box and the issues stay clear of side insets '
        '(safe area)', (WidgetTester tester) async {
      tester.view.padding = const FakeViewPadding(left: 40, right: 60);
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );
      await tester.pumpAndSettle();

      for (final Finder part in <Finder>[
        find.byType(TextField),
        tile('fx-iss-01'),
        tile('fx-iss-09'),
      ]) {
        expect(tester.getTopLeft(part).dx, greaterThanOrEqualTo(40));
        expect(tester.getTopRight(part).dx, lessThanOrEqualTo(800 - 60));
      }
    });

    testWidgets('tap targets are at least 48 by 48 and labelled', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        catalogueScreen(FakeCatalogueRepository.fromFixtures()),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Issue');
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
