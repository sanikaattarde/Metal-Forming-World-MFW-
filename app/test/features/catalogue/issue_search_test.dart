import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';

void main() {
  final CatalogueFixture fixture = loadCatalogueFixture();
  final List<IssueSummary> published = fixture.issues
      .where(
        (IssueSummary issue) =>
            !fixture.unpublishedIssueIds.contains(issue.issueId),
      )
      .toList();
  final Map<String, String> names = <String, String>{
    for (final IssueCategory category in fixture.categories)
      category.categoryId: category.name,
  };

  List<String> ids(IssueQuery query) => applyQuery(
    published,
    query,
    categoryNames: names,
  ).map((IssueSummary issue) => issue.issueId).toList();

  group('applyQuery: search [FR-SRCH-001, AC-1.2]', () {
    test('a title word finds its issue', () {
      expect(ids(const IssueQuery(text: 'Forming')), <String>['fx-iss-09']);
    });

    test('a description word finds its issue', () {
      expect(ids(const IssueQuery(text: 'latest')), <String>['fx-iss-01']);
    });

    test('a category name finds every issue in it', () {
      final List<IssueSummary> found = applyQuery(
        published,
        const IssueQuery(text: 'hydroforming'),
        categoryNames: <String, String>{...names, 'fx-cat-03': 'Hydroforming'},
      );
      expect(found.map((IssueSummary issue) => issue.issueId), <String>[
        'fx-iss-03',
        'fx-iss-07',
      ]);
    });

    test('case and accents are ignored', () {
      expect(ids(const IssueQuery(text: 'CAFE')), <String>['fx-iss-09']);
      expect(ids(const IssueQuery(text: 'grosse')), <String>['fx-iss-09']);
      expect(ids(const IssueQuery(text: 'Größe')), <String>['fx-iss-09']);
    });

    test('every word must match', () {
      expect(ids(const IssueQuery(text: 'synthetic segments')), <String>[
        'fx-iss-03',
      ]);
      expect(ids(const IssueQuery(text: 'issue nothing')), isEmpty);
    });

    test('blank text does not filter', () {
      expect(ids(const IssueQuery(text: '   ')), hasLength(9));
    });

    test('the same search gives the same result each time', () {
      final List<String> first = ids(const IssueQuery(text: 'archive'));
      expect(ids(const IssueQuery(text: 'archive')), first);
    });
  });

  group('applyQuery: filters [FR-SRCH-002 to FR-SRCH-005, AC-1.3, PAC-07]', () {
    test('category alone', () {
      expect(ids(const IssueQuery(categoryId: 'fx-cat-01')), <String>[
        'fx-iss-01',
        'fx-iss-05',
        'fx-iss-10',
      ]);
    });

    test('year alone', () {
      expect(ids(const IssueQuery(year: 2026)), <String>[
        'fx-iss-01',
        'fx-iss-02',
        'fx-iss-03',
        'fx-iss-04',
      ]);
    });

    test('edition alone', () {
      expect(ids(const IssueQuery(edition: 'E3')), <String>[
        'fx-iss-03',
        'fx-iss-06',
        'fx-iss-10',
      ]);
    });

    test('a segment matches an issue that lists it among others [PAC-07]', () {
      expect(ids(const IssueQuery(industrySegmentId: 'fx-seg-02')), <String>[
        'fx-iss-02',
        'fx-iss-03',
        'fx-iss-05',
        'fx-iss-07',
        'fx-iss-09',
      ]);
    });

    test('filters combine, with search too', () {
      expect(
        ids(const IssueQuery(categoryId: 'fx-cat-01', year: 2025)),
        <String>['fx-iss-05', 'fx-iss-10'],
      );
      expect(
        ids(
          const IssueQuery(categoryId: 'fx-cat-01', year: 2025, edition: 'E3'),
        ),
        <String>['fx-iss-10'],
      );
      expect(
        ids(const IssueQuery(text: '10', categoryId: 'fx-cat-01')),
        <String>['fx-iss-10'],
      );
    });

    test('an unpublished issue is never found [FR-MAG-008]', () {
      expect(ids(const IssueQuery(text: 'Test Issue 08')), isEmpty);
    });
  });

  group('FilterChoices', () {
    test('offers only values that some issue has', () {
      final FilterChoices choices = FilterChoices.of(published);
      expect(choices.years, <int>[2026, 2025]);
      expect(choices.editions, <String>['E1', 'E2', 'E3']);
      expect(choices.segmentIds, <String>{'fx-seg-01', 'fx-seg-02'});
      expect(choices.categoryIds, hasLength(4));
    });
  });
}
