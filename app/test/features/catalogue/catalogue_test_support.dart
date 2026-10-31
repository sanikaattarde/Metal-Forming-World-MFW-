import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../fakes/fake_catalogue_repository.dart';

/// The issue IDs of [issues], in order.
List<String> idsOf(Iterable<IssueSummary> issues) =>
    issues.map((IssueSummary issue) => issue.issueId).toList();

/// A synthetic issue for cases the FX-ISS set does not cover.
IssueSummary testIssue(
  String issueId, {
  DateTime? publicationDate,
  String categoryId = 'fx-cat-01',
  List<String> industrySegmentIds = const <String>[],
  String? edition,
}) {
  final DateTime date = publicationDate ?? DateTime.utc(2026, 3, 1);
  return IssueSummary(
    issueId: issueId,
    title: 'Title $issueId',
    description: 'Description $issueId',
    categoryId: categoryId,
    publicationDate: date,
    year: date.year,
    industrySegmentIds: industrySegmentIds,
    edition: edition,
  );
}

/// The FX catalogue with category names replaced, to show the names come
/// from the repository.
FakeCatalogueRepository renamedCategoryCatalogue() {
  final CatalogueFixture fixture = loadCatalogueFixture();
  return FakeCatalogueRepository(
    issues: fixture.issues,
    categories: <IssueCategory>[
      for (final IssueCategory category in fixture.categories)
        IssueCategory(
          categoryId: category.categoryId,
          name: 'Renamed ${category.name.split(' ').last}',
        ),
    ],
    unpublishedIssueIds: fixture.unpublishedIssueIds,
  );
}

/// A catalogue whose category list fails while its issues load.
final class CategoriesFailCatalogue implements CatalogueRepository {
  /// Wraps [inner]; [listCategories] fails with [failure].
  CategoriesFailCatalogue(this.inner, this.failure);

  /// The catalogue that answers the other reads.
  final CatalogueRepository inner;

  /// The failure of [listCategories].
  final AppFailure failure;

  @override
  Future<Result<List<IssueSummary>>> listPublishedIssues() =>
      inner.listPublishedIssues();

  @override
  Future<Result<IssueSummary>> getIssue(String issueId) =>
      inner.getIssue(issueId);

  @override
  Future<Result<List<IssueCategory>>> listCategories() async =>
      Err<List<IssueCategory>>(failure);
}

/// Pumps [screen] in the placeholder theme on a surface of [size].
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(800, 2000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: placeholderTheme, home: screen));
}
