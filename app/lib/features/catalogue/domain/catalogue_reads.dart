import 'package:mfw_app/contracts/contracts.dart';

/// The published issues and category names, as one read of the catalogue.
final class CatalogueSnapshot {
  /// Creates the snapshot; [issues] are put newest first.
  CatalogueSnapshot({
    required List<IssueSummary> issues,
    required List<IssueCategory> categories,
  }) : issues = List<IssueSummary>.unmodifiable(newestFirst(issues)),
       categoryNames = Map<String, String>.unmodifiable(<String, String>{
         for (final IssueCategory category in categories)
           category.categoryId: category.name,
       });

  /// Published issues, newest publication date first.
  final List<IssueSummary> issues;

  /// Category names by category ID, from the repository (FR-MAG-003).
  final Map<String, String> categoryNames;

  /// The latest issue (FR-MAG-004), or null when nothing is published.
  ///
  /// PROPOSED: "latest" means the newest publication date.
  IssueSummary? get latest => issues.isEmpty ? null : issues.first;

  /// The archive: every issue but the latest, newest first (FR-MAG-004).
  List<IssueSummary> get archive => issues.skip(1).toList();
}

/// [issues] sorted by publication date, newest first. Issues with the same
/// date keep their order.
List<IssueSummary> newestFirst(List<IssueSummary> issues) {
  final List<(int, IssueSummary)> indexed = <(int, IssueSummary)>[
    for (final (int index, IssueSummary issue) in issues.indexed)
      (index, issue),
  ];
  indexed.sort(((int, IssueSummary) a, (int, IssueSummary) b) {
    final int byDate = b.$2.publicationDate.compareTo(a.$2.publicationDate);
    return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
  });
  return <IssueSummary>[
    for (final (int _, IssueSummary issue) in indexed) issue,
  ];
}

/// Reads the published issues and the categories (OP-CAT-01, OP-CAT-03).
/// Either failure fails the read, as it came.
Future<Result<CatalogueSnapshot>> loadCatalogue(
  CatalogueRepository catalogue,
) async {
  final (
    Result<List<IssueSummary>> issues,
    Result<List<IssueCategory>> categories,
  ) = await (
    catalogue.listPublishedIssues(),
    catalogue.listCategories(),
  ).wait;
  return switch ((issues, categories)) {
    (
      Ok<List<IssueSummary>>(value: final List<IssueSummary> issueList),
      Ok<List<IssueCategory>>(value: final List<IssueCategory> categoryList),
    ) =>
      Ok<CatalogueSnapshot>(
        CatalogueSnapshot(issues: issueList, categories: categoryList),
      ),
    (Err<List<IssueSummary>>(:final AppFailure failure), _) ||
    (
      _,
      Err<List<IssueCategory>>(:final AppFailure failure),
    ) => Err<CatalogueSnapshot>(failure),
  };
}

/// One published issue and the name of its category, or null when the
/// category is not in the list.
typedef IssueDetails = ({IssueSummary issue, String? categoryName});

/// Reads one published issue and the categories (OP-CAT-02, OP-CAT-03).
/// An unpublished issue is `notFound`. Either failure fails the read.
Future<Result<IssueDetails>> loadIssueDetails(
  CatalogueRepository catalogue,
  String issueId,
) async {
  final (Result<IssueSummary> issue, Result<List<IssueCategory>> categories) =
      await (catalogue.getIssue(issueId), catalogue.listCategories()).wait;
  return switch ((issue, categories)) {
    (
      Ok<IssueSummary>(value: final IssueSummary found),
      Ok<List<IssueCategory>>(value: final List<IssueCategory> categoryList),
    ) =>
      Ok<IssueDetails>((
        issue: found,
        categoryName: categoryList
            .where(
              (IssueCategory category) =>
                  category.categoryId == found.categoryId,
            )
            .map((IssueCategory category) => category.name)
            .firstOrNull,
      )),
    (Err<IssueSummary>(:final AppFailure failure), _) ||
    (
      _,
      Err<List<IssueCategory>>(:final AppFailure failure),
    ) => Err<IssueDetails>(failure),
  };
}
