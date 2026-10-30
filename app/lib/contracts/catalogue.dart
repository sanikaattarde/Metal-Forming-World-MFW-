import 'result.dart';

/// Public issue metadata. Never contains a file location.
///
/// Fields are CONFIRMED (RS DATA-001, FR-MAG-002). Which fields are public
/// is OQ-13.
final class IssueSummary {
  /// Creates issue metadata.
  const IssueSummary({
    required this.issueId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.publicationDate,
    required this.year,
    this.industrySegmentIds = const [],
    this.edition,
    this.coverImageUrl,
    this.fileSizeBytes,
  });

  /// Opaque issue ID.
  final String issueId;

  /// Issue title.
  final String title;

  /// Issue description.
  final String description;

  /// The issue's category.
  final String categoryId;

  /// Publication date (a calendar date).
  final DateTime publicationDate;

  /// Publication year.
  final int year;

  /// Several per issue; meaning of "industry segment": OQ-13.
  final List<String> industrySegmentIds;

  /// Edition; meaning: OQ-13.
  final String? edition;

  /// Cover image address.
  final Uri? coverImageUrl;

  /// File size in whole bytes; shown before sign-in? OQ-13.
  final int? fileSizeBytes;
}

/// An issue category (RS DATA-002).
final class IssueCategory {
  /// Creates a category.
  const IssueCategory({required this.categoryId, required this.name});

  /// Opaque category ID.
  final String categoryId;

  /// Display name.
  final String name;
}

/// Metadata-only search and filters (RS FR-SRCH-001 to 007).
final class IssueQuery {
  /// Creates a query; a null field does not filter.
  const IssueQuery({
    this.text,
    this.categoryId,
    this.industrySegmentId,
    this.year,
    this.edition,
  });

  /// Text searched in title, description and category.
  final String? text;

  /// Category filter.
  final String? categoryId;

  /// Matches an issue whose industrySegmentIds contains it.
  final String? industrySegmentId;

  /// Year filter.
  final int? year;

  /// Edition filter.
  final String? edition;
}

/// Published issues and categories (MOD-05). Public; no sign-in needed.
///
/// Failures: `network`, `serviceUnavailable`, `notFound` (unpublished
/// issue), `invalidResponse`.
abstract interface class CatalogueRepository {
  /// Lists published issues (OP-CAT-01).
  Future<Result<List<IssueSummary>>> listPublishedIssues();

  /// Reads one published issue; `notFound` if unpublished (OP-CAT-02).
  Future<Result<IssueSummary>> getIssue(String issueId);

  /// Lists categories (OP-CAT-03).
  Future<Result<List<IssueCategory>>> listCategories();
}
