import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';
import '../../fakes/test_helpers.dart';
import 'catalogue_test_support.dart';

void main() {
  late List<IssueSummary> published;
  late Map<String, String> names;

  setUp(() async {
    final FakeCatalogueRepository catalogue =
        FakeCatalogueRepository.fromFixtures();
    published = valueOf(await catalogue.listPublishedIssues());
    names = <String, String>{
      for (final IssueCategory category in valueOf(
        await catalogue.listCategories(),
      ))
        category.categoryId: category.name,
    };
  });

  List<String> run(IssueQuery query) =>
      idsOf(applyQuery(published, query, categoryNames: names));

  group('applyQuery search [AC-1.2, FR-SRCH-001]', () {
    test('an empty query returns every issue in the given order', () {
      expect(run(const IssueQuery()), <String>[
        'fx-iss-01',
        'fx-iss-02',
        'fx-iss-03',
        'fx-iss-04',
        'fx-iss-05',
        'fx-iss-06',
        'fx-iss-07',
        'fx-iss-09',
        'fx-iss-10',
      ]);
    });

    test('blank text does not filter', () {
      expect(run(const IssueQuery(text: '   ')), hasLength(9));
    });

    test('a title word finds only the matching issue [AC-1.2]', () {
      expect(run(const IssueQuery(text: 'Issue 05')), <String>['fx-iss-05']);
    });

    test('a description word finds only the matching issues [AC-1.2]', () {
      expect(run(const IssueQuery(text: 'segments')), <String>['fx-iss-03']);
      expect(run(const IssueQuery(text: 'near-limit')), <String>['fx-iss-10']);
    });

    test('a category name finds only the issues in that category '
        '[AC-1.2]', () {
      expect(run(const IssueQuery(text: 'Test Category B')), <String>[
        'fx-iss-02',
        'fx-iss-06',
      ]);
    });

    test('search ignores letter case', () {
      expect(run(const IssueQuery(text: 'TEST CATEGORY b')), <String>[
        'fx-iss-02',
        'fx-iss-06',
      ]);
      expect(run(const IssueQuery(text: 'latest SYNTHETIC')), <String>[
        'fx-iss-01',
      ]);
    });

    test('search ignores spaces around the text', () {
      expect(run(const IssueQuery(text: '  Issue 07 ')), <String>['fx-iss-07']);
    });

    test('special characters match as typed [FX-ISS-09]', () {
      for (final String text in <String>[
        '"Forming"',
        '&',
        '₹',
        'café',
        'CAFÉ',
        'größe',
      ]) {
        expect(run(IssueQuery(text: text)), <String>[
          'fx-iss-09',
        ], reason: text);
      }
    });

    test('search covers title, description and category name only '
        '[FR-SRCH-007]', () {
      for (final String text in <String>[
        'E2',
        'fx-seg-01',
        'fx-cat-01',
        'fx-iss-01',
        '2026',
        'storage.example',
      ]) {
        expect(run(IssueQuery(text: text)), isEmpty, reason: text);
      }
    });

    test('without the category names, a category name finds nothing', () {
      expect(
        applyQuery(published, const IssueQuery(text: 'Test Category B')),
        isEmpty,
      );
    });

    test('a text with no match returns nothing [FR-STATE-002]', () {
      expect(run(const IssueQuery(text: 'no such words')), isEmpty);
    });
  });

  group('applyQuery filters [AC-1.3]', () {
    test('category filter [FR-SRCH-002]', () {
      expect(run(const IssueQuery(categoryId: 'fx-cat-01')), <String>[
        'fx-iss-01',
        'fx-iss-05',
        'fx-iss-10',
      ]);
    });

    test('year filter [FR-SRCH-004]', () {
      expect(run(const IssueQuery(year: 2025)), <String>[
        'fx-iss-05',
        'fx-iss-06',
        'fx-iss-07',
        'fx-iss-09',
        'fx-iss-10',
      ]);
      expect(run(const IssueQuery(year: 2026)), <String>[
        'fx-iss-01',
        'fx-iss-02',
        'fx-iss-03',
        'fx-iss-04',
      ]);
    });

    test('edition filter [FR-SRCH-005]', () {
      expect(run(const IssueQuery(edition: 'E2')), <String>[
        'fx-iss-02',
        'fx-iss-05',
        'fx-iss-09',
      ]);
    });

    test('an issue without an edition never matches an edition filter', () {
      final List<IssueSummary> issues = <IssueSummary>[
        testIssue('a', edition: 'E1'),
        testIssue('b'),
      ];

      expect(
        idsOf(applyQuery(issues, const IssueQuery(edition: 'E1'))),
        <String>['a'],
      );
    });

    test('filters combine: every set field must match [AC-1.3]', () {
      expect(
        run(const IssueQuery(categoryId: 'fx-cat-01', year: 2025)),
        <String>['fx-iss-05', 'fx-iss-10'],
      );
      expect(
        run(
          const IssueQuery(categoryId: 'fx-cat-01', year: 2025, edition: 'E3'),
        ),
        <String>['fx-iss-10'],
      );
      expect(
        run(const IssueQuery(categoryId: 'fx-cat-04', year: 2026)),
        <String>['fx-iss-04'],
      );
    });

    test('text and filters combine [AC-1.2, AC-1.3]', () {
      expect(
        run(const IssueQuery(text: 'Test Category A', year: 2026)),
        <String>['fx-iss-01'],
      );
    });

    test('a filter with no match returns nothing [FR-STATE-002]', () {
      expect(run(const IssueQuery(year: 2024)), isEmpty);
    });

    test('the result keeps the input order and leaves the input as it was', () {
      final List<IssueSummary> reversed = published.reversed.toList();

      expect(
        idsOf(
          applyQuery(
            reversed,
            const IssueQuery(year: 2026),
            categoryNames: names,
          ),
        ),
        <String>['fx-iss-04', 'fx-iss-03', 'fx-iss-02', 'fx-iss-01'],
      );
      expect(reversed, hasLength(9));
    });
  });

  group('applyQuery industry segment [PAC-07, FR-SRCH-003]', () {
    test('matches the issues whose segments contain the one chosen', () {
      expect(run(const IssueQuery(industrySegmentId: 'fx-seg-02')), <String>[
        'fx-iss-02',
        'fx-iss-03',
        'fx-iss-05',
        'fx-iss-07',
        'fx-iss-09',
      ]);
    });

    test('an issue with two segments matches either one', () {
      expect(
        run(const IssueQuery(industrySegmentId: 'fx-seg-01')),
        contains('fx-iss-03'),
      );
      expect(
        run(const IssueQuery(industrySegmentId: 'fx-seg-02')),
        contains('fx-iss-03'),
      );
    });

    test('an issue without segments never matches a segment filter', () {
      final List<IssueSummary> issues = <IssueSummary>[
        testIssue('a', industrySegmentIds: <String>['fx-seg-01']),
        testIssue('b'),
      ];

      expect(
        idsOf(
          applyQuery(issues, const IssueQuery(industrySegmentId: 'fx-seg-01')),
        ),
        <String>['a'],
      );
    });

    test('segment and year combine [PAC-07, AC-1.3]', () {
      expect(
        run(const IssueQuery(industrySegmentId: 'fx-seg-01', year: 2025)),
        <String>['fx-iss-06', 'fx-iss-10'],
      );
    });
  });
}
