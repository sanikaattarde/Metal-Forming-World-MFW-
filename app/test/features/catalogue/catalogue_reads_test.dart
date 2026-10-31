import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';
import '../../fakes/test_helpers.dart';
import 'catalogue_test_support.dart';

void main() {
  group('loadCatalogue [FR-MAG-001, FR-MAG-004]', () {
    test('issues come newest first: FX-ISS-01 is the latest issue and the '
        'archive follows [FR-MAG-004]', () async {
      final CatalogueSnapshot snapshot = valueOf(
        await loadCatalogue(FakeCatalogueRepository.fromFixtures()),
      );

      expect(snapshot.latest?.issueId, 'fx-iss-01');
      expect(idsOf(snapshot.archive), <String>[
        'fx-iss-02',
        'fx-iss-03',
        'fx-iss-04',
        'fx-iss-05',
        'fx-iss-06',
        'fx-iss-07',
        'fx-iss-10',
        'fx-iss-09',
      ]);
      expect(idsOf(snapshot.issues), hasLength(9));
    });

    test('category names come from the repository [FR-MAG-003]', () async {
      final CatalogueSnapshot snapshot = valueOf(
        await loadCatalogue(renamedCategoryCatalogue()),
      );

      expect(snapshot.categoryNames['fx-cat-01'], 'Renamed A');
      expect(snapshot.categoryNames, hasLength(4));
    });

    test('issues with the same date keep the repository order', () async {
      final DateTime same = DateTime.utc(2026, 5, 1);
      final CatalogueSnapshot snapshot = valueOf(
        await loadCatalogue(
          FakeCatalogueRepository(
            issues: <IssueSummary>[
              testIssue('b', publicationDate: same),
              testIssue('old', publicationDate: DateTime.utc(2025, 5, 1)),
              testIssue('a', publicationDate: same),
              testIssue('c', publicationDate: same),
            ],
            categories: const <IssueCategory>[],
          ),
        ),
      );

      expect(idsOf(snapshot.issues), <String>['b', 'a', 'c', 'old']);
    });

    test('an empty catalogue has no latest issue and no archive', () async {
      final CatalogueSnapshot snapshot = valueOf(
        await loadCatalogue(
          FakeCatalogueRepository(
            issues: const <IssueSummary>[],
            categories: const <IssueCategory>[],
          ),
        ),
      );

      expect(snapshot.latest, isNull);
      expect(snapshot.archive, isEmpty);
    });

    test('a failed issue list is returned as it came [FR-STATE-003]', () async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.network, retryable: true);

      final AppFailure? failure = failureOf(await loadCatalogue(catalogue));

      expect(failure?.code, FailureCode.network);
      expect(failure?.retryable, isTrue);
    });

    test('a failed category list fails the load', () async {
      final AppFailure? failure = failureOf(
        await loadCatalogue(
          CategoriesFailCatalogue(
            FakeCatalogueRepository.fromFixtures(),
            const AppFailure(FailureCode.invalidResponse),
          ),
        ),
      );

      expect(failure?.code, FailureCode.invalidResponse);
    });
  });

  group('publication changes on the next load [IC-07]', () {
    test('an issue published in the admin panel shows on the next load '
        '[FR-MAG-007]', () async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();
      expect(
        idsOf(valueOf(await loadCatalogue(catalogue)).issues),
        isNot(contains('fx-iss-08')),
      );

      catalogue.publish('fx-iss-08');

      final CatalogueSnapshot next = valueOf(await loadCatalogue(catalogue));
      expect(next.latest?.issueId, 'fx-iss-08');
      expect(next.archive.first.issueId, 'fx-iss-01');
    });

    test(
      'an unpublished issue is gone on the next load [FR-MAG-008]',
      () async {
        final FakeCatalogueRepository catalogue =
            FakeCatalogueRepository.fromFixtures();

        catalogue.unpublish('fx-iss-02');

        expect(
          idsOf(valueOf(await loadCatalogue(catalogue)).issues),
          isNot(contains('fx-iss-02')),
        );
      },
    );

    test(
      'the details of an unpublished issue are notFound [OP-CAT-02]',
      () async {
        final FakeCatalogueRepository catalogue =
            FakeCatalogueRepository.fromFixtures();

        expect(
          failureCodeOf(await loadIssueDetails(catalogue, 'fx-iss-08')),
          FailureCode.notFound,
        );

        catalogue.unpublish('fx-iss-03');
        expect(
          failureCodeOf(await loadIssueDetails(catalogue, 'fx-iss-03')),
          FailureCode.notFound,
        );
      },
    );
  });

  group('loadIssueDetails [FR-MAG-005]', () {
    test('gives the issue and its category name', () async {
      final IssueDetails details = valueOf(
        await loadIssueDetails(
          FakeCatalogueRepository.fromFixtures(),
          'fx-iss-03',
        ),
      );

      expect(details.issue.issueId, 'fx-iss-03');
      expect(details.categoryName, 'Test Category C');
    });

    test('a category missing from the list gives no name', () async {
      final IssueDetails details = valueOf(
        await loadIssueDetails(
          FakeCatalogueRepository(
            issues: <IssueSummary>[testIssue('a', categoryId: 'gone')],
            categories: const <IssueCategory>[],
          ),
          'a',
        ),
      );

      expect(details.categoryName, isNull);
    });

    test('a failure is returned as it came', () async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(
              FailureCode.serviceUnavailable,
              retryable: true,
            );

      expect(
        failureCodeOf(await loadIssueDetails(catalogue, 'fx-iss-01')),
        FailureCode.serviceUnavailable,
      );
    });
  });
}
