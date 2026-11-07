import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'fake_catalogue_repository.dart';
import 'test_helpers.dart';

List<String> idsOf(List<IssueSummary> issues) =>
    issues.map((IssueSummary issue) => issue.issueId).toList();

void main() {
  group('FakeCatalogueRepository [IC-07]', () {
    test('implements CatalogueRepository', () {
      expect(
        FakeCatalogueRepository.fromFixtures(),
        isA<CatalogueRepository>(),
      );
    });

    test(
      'holds FX-CAT-01 to FX-CAT-04 and the published FX-ISS issues',
      () async {
        final FakeCatalogueRepository catalogue =
            FakeCatalogueRepository.fromFixtures();

        final List<IssueCategory> categories = valueOf(
          await catalogue.listCategories(),
        );
        final List<IssueSummary> issues = valueOf(
          await catalogue.listPublishedIssues(),
        );

        expect(
          categories.map((IssueCategory category) => category.name),
          <String>[
            'Test Category A',
            'Test Category B',
            'Test Category C',
            'Test Category D',
          ],
        );
        expect(issues, hasLength(9));
        expect(idsOf(issues), isNot(contains('fx-iss-08')));
      },
    );

    test('FX-ISS-01 is the latest published issue [FR-MAG-001]', () async {
      final List<IssueSummary> issues = valueOf(
        await FakeCatalogueRepository.fromFixtures().listPublishedIssues(),
      );

      final IssueSummary latest = issues.reduce(
        (IssueSummary a, IssueSummary b) =>
            a.publicationDate.isAfter(b.publicationDate) ? a : b,
      );

      expect(latest.issueId, 'fx-iss-01');
      expect(latest.coverImageUrl, isNotNull);
    });

    test('publishing FX-ISS-08 shows it after a refresh, unpublishing hides it [AC-1.4]', () async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();

      catalogue.publish('fx-iss-08');
      expect(
        idsOf(valueOf(await catalogue.listPublishedIssues())),
        contains('fx-iss-08'),
      );

      catalogue.unpublish('fx-iss-08');
      expect(
        idsOf(valueOf(await catalogue.listPublishedIssues())),
        isNot(contains('fx-iss-08')),
      );
    });

    test('details of an unpublished issue are notFound [OP-CAT-02]', () async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();

      expect(
        failureCodeOf(await catalogue.getIssue('fx-iss-08')),
        FailureCode.notFound,
      );
      expect(
        valueOf(await catalogue.getIssue('fx-iss-02')).issueId,
        'fx-iss-02',
      );
    });

    test('FX-ISS-09 keeps its special characters', () async {
      final IssueSummary issue = valueOf(
        await FakeCatalogueRepository.fromFixtures().getIssue('fx-iss-09'),
      );

      for (final String character in <String>['&', '"', '₹', 'é']) {
        expect(issue.title, contains(character));
      }
    });

    test('a set failure is returned', () async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.network, retryable: true);

      expect(
        failureCodeOf(await catalogue.listPublishedIssues()),
        FailureCode.network,
      );
    });
  });
}
