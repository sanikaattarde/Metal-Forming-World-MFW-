import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';
import 'catalogue_test_support.dart';
import 'labelled_cover_source.dart';

Widget detailsScreen(
  CatalogueRepository catalogue,
  String issueId, {
  IssueActionBuilder? actionBuilder,
}) => IssueDetailsScreen(
  catalogue: catalogue,
  covers: const LabelledCoverSource(),
  issueId: issueId,
  actionBuilder: actionBuilder,
);

void main() {
  group('IssueDetailsScreen [FR-MAG-005]', () {
    testWidgets('shows a loading indicator, then the cover, title, date, '
        'category and description [FR-STATE-001, FR-MAG-002]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        detailsScreen(FakeCatalogueRepository.fromFixtures(), 'fx-iss-01'),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text(coverMarker('fx-iss-01')), findsOneWidget);
      expect(find.text('Test Issue 01'), findsOneWidget);
      expect(find.text('1 October 2026'), findsOneWidget);
      expect(find.text('Test Category A'), findsOneWidget);
      expect(
        find.text('Latest synthetic issue, linked to FX-PDF-01.'),
        findsOneWidget,
      );
    });

    testWidgets('edition, industry segment and file size are not shown '
        'until OQ-13 is answered', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        detailsScreen(FakeCatalogueRepository.fromFixtures(), 'fx-iss-01'),
      );
      await tester.pumpAndSettle();

      for (final String text in <String>[
        'E1',
        'fx-seg',
        '800000',
        '800 KB',
        '0.8 MB',
        'Edition',
        'Segment',
      ]) {
        expect(find.textContaining(text), findsNothing, reason: text);
      }
    });

    testWidgets('the read or download action is built for the issue', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        detailsScreen(
          FakeCatalogueRepository.fromFixtures(),
          'fx-iss-02',
          actionBuilder: (BuildContext context, IssueSummary issue) =>
              Text('action:${issue.issueId}'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('action:fx-iss-02'), findsOneWidget);
    });

    testWidgets('an unpublished issue is no longer available, with no '
        'retry [IC-07, OP-CAT-02]', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        detailsScreen(FakeCatalogueRepository.fromFixtures(), 'fx-iss-08'),
      );
      await tester.pumpAndSettle();

      expect(find.text(CatalogueText.notAvailable), findsOneWidget);
      expect(find.text(CatalogueText.retry), findsNothing);
      expect(find.text('Test Issue 08'), findsNothing);
    });

    testWidgets('no connection says so and the retry loads the issue '
        '[FR-STATE-003]', (WidgetTester tester) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.network, retryable: true);
      await pumpScreen(tester, detailsScreen(catalogue, 'fx-iss-04'));
      await tester.pumpAndSettle();

      expect(find.text(CatalogueText.offline), findsOneWidget);

      catalogue.failure = null;
      await tester.tap(find.text(CatalogueText.retry));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Test Issue 04'), findsOneWidget);
    });

    testWidgets('the details stay clear of side insets (safe area)', (
      WidgetTester tester,
    ) async {
      tester.view.padding = const FakeViewPadding(left: 40, right: 60);
      await pumpScreen(
        tester,
        detailsScreen(FakeCatalogueRepository.fromFixtures(), 'fx-iss-09'),
      );
      await tester.pumpAndSettle();

      final Finder title = find.textContaining('Größe');
      expect(tester.getTopLeft(title).dx, greaterThanOrEqualTo(40));
      expect(tester.getTopRight(title).dx, lessThanOrEqualTo(800 - 60));
    });

    testWidgets('the long FX-ISS-09 title fits a narrow phone [FX-ISS-09]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        detailsScreen(FakeCatalogueRepository.fromFixtures(), 'fx-iss-09'),
        size: const Size(320, 640),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Größe'), findsOneWidget);
    });
  });
}
