import 'package:mfw_app/contracts/contracts.dart';

/// Metadata-only search and filtering (RS FR-SRCH-001 to FR-SRCH-007),
/// done on the device (API_AND_MODULE_CONTRACTS section 6.5).
///
/// Every field set in [query] must match; a null field does not filter.
/// The text is trimmed and matched, ignoring letter case, as a part of the
/// title, the description or the category name. Nothing else is searched,
/// and never the text inside a PDF (FR-SRCH-007). [categoryNames] maps a
/// category ID to its name; without it, category names are not searched.
/// The result keeps the order of [issues].
///
/// PROPOSED: [categoryNames] is not in the contract signature, which has
/// no way to reach category names (AC-1.2 searches by one).
List<IssueSummary> applyQuery(
  List<IssueSummary> issues,
  IssueQuery query, {
  Map<String, String> categoryNames = const <String, String>{},
}) {
  final String text = query.text?.trim().toLowerCase() ?? '';
  return <IssueSummary>[
    for (final IssueSummary issue in issues)
      if (_matchesFilters(issue, query) &&
          (text.isEmpty || _matchesText(issue, text, categoryNames)))
        issue,
  ];
}

bool _matchesFilters(IssueSummary issue, IssueQuery query) {
  final String? categoryId = query.categoryId;
  final String? segmentId = query.industrySegmentId;
  final int? year = query.year;
  final String? edition = query.edition;
  return (categoryId == null || issue.categoryId == categoryId) &&
      (segmentId == null || issue.industrySegmentIds.contains(segmentId)) &&
      (year == null || issue.year == year) &&
      (edition == null || issue.edition == edition);
}

bool _matchesText(
  IssueSummary issue,
  String lowerText,
  Map<String, String> categoryNames,
) => <String?>[issue.title, issue.description, categoryNames[issue.categoryId]]
    .any(
      (String? field) =>
          field != null && field.toLowerCase().contains(lowerText),
    );
