import 'package:mfw_app/contracts/contracts.dart';

import 'fixture_loader.dart';

/// The catalogue fixture: FX-CAT-01 to FX-CAT-04 and FX-ISS-01 to FX-ISS-10.
typedef CatalogueFixture = ({
  List<IssueCategory> categories,
  List<IssueSummary> issues,
  Set<String> unpublishedIssueIds,
});

/// Reads test/fixtures/catalogue/fx_catalogue.json.
CatalogueFixture loadCatalogueFixture() {
  final Map<String, Object?> root =
      readJsonFixture('catalogue/fx_catalogue.json') as Map<String, Object?>;
  final List<Map<String, Object?>> issues = (root['issues'] as List<Object?>)
      .cast<Map<String, Object?>>();
  return (
    categories: (root['categories'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(
          (Map<String, Object?> json) => IssueCategory(
            categoryId: json['categoryId'] as String,
            name: json['name'] as String,
          ),
        )
        .toList(),
    issues: issues.map(_issueFrom).toList(),
    unpublishedIssueIds: issues
        .where((Map<String, Object?> json) => json['published'] != true)
        .map((Map<String, Object?> json) => json['issueId'] as String)
        .toSet(),
  );
}

IssueSummary _issueFrom(Map<String, Object?> json) => IssueSummary(
  issueId: json['issueId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  categoryId: json['categoryId'] as String,
  publicationDate: DateTime.parse(
    '${json['publicationDate'] as String}T00:00:00Z',
  ),
  year: json['year'] as int,
  industrySegmentIds: (json['industrySegmentIds'] as List<Object?>)
      .cast<String>()
      .toList(),
  edition: json['edition'] as String?,
  coverImageUrl: switch (json['coverImageUrl']) {
    final String url => Uri.parse(url),
    _ => null,
  },
  fileSizeBytes: json['fileSizeBytes'] as int?,
);

/// Fake MOD-12 catalogue as MOD-05 reads it (IC-07).
///
/// [publish] and [unpublish] stand in for the admin panel; the next read
/// shows the change, as after a refresh. The order is the fixture order.
final class FakeCatalogueRepository implements CatalogueRepository {
  /// Creates the catalogue.
  FakeCatalogueRepository({
    required List<IssueSummary> issues,
    required List<IssueCategory> categories,
    Set<String> unpublishedIssueIds = const <String>{},
  }) : _issues = List<IssueSummary>.unmodifiable(issues),
       _categories = List<IssueCategory>.unmodifiable(categories),
       _unpublished = Set<String>.of(unpublishedIssueIds);

  /// Creates the catalogue from the FX-CAT and FX-ISS fixtures.
  factory FakeCatalogueRepository.fromFixtures() {
    final CatalogueFixture fixture = loadCatalogueFixture();
    return FakeCatalogueRepository(
      issues: fixture.issues,
      categories: fixture.categories,
      unpublishedIssueIds: fixture.unpublishedIssueIds,
    );
  }

  final List<IssueSummary> _issues;
  final List<IssueCategory> _categories;
  final Set<String> _unpublished;

  /// When set, every read fails with it.
  AppFailure? failure;

  /// Publishes [issueId], as an admin would.
  void publish(String issueId) => _unpublished.remove(issueId);

  /// Unpublishes [issueId], as an admin would.
  void unpublish(String issueId) => _unpublished.add(issueId);

  /// Whether [issueId] exists and is published.
  bool isPublished(String issueId) =>
      !_unpublished.contains(issueId) &&
      _issues.any((IssueSummary issue) => issue.issueId == issueId);

  @override
  Future<Result<List<IssueSummary>>> listPublishedIssues() async {
    final AppFailure? set = failure;
    if (set != null) {
      return Err<List<IssueSummary>>(set);
    }
    return Ok<List<IssueSummary>>(
      _issues
          .where((IssueSummary issue) => isPublished(issue.issueId))
          .toList(),
    );
  }

  @override
  Future<Result<IssueSummary>> getIssue(String issueId) async {
    final AppFailure? set = failure;
    if (set != null) {
      return Err<IssueSummary>(set);
    }
    for (final IssueSummary issue in _issues) {
      if (issue.issueId == issueId && isPublished(issueId)) {
        return Ok<IssueSummary>(issue);
      }
    }
    return const Err<IssueSummary>(AppFailure(FailureCode.notFound));
  }

  @override
  Future<Result<List<IssueCategory>>> listCategories() async {
    final AppFailure? set = failure;
    if (set != null) {
      return Err<List<IssueCategory>>(set);
    }
    return Ok<List<IssueCategory>>(_categories);
  }
}
