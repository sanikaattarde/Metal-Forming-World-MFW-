import 'package:mfw_app/contracts/contracts.dart';

/// Search and filters on the device, over issue metadata only (RS
/// FR-SRCH-001 to FR-SRCH-007, DEC-030). With five to twelve issues at
/// launch (RS ASM-02) nothing is sent to the server
/// (`API_AND_MODULE_CONTRACTS.md` section 6.5, PROPOSED).

/// The issues of [issues] that match [query], in their order.
///
/// - Text: every word of [IssueQuery.text] must appear in the title, the
///   description or the category's name from [categoryNames], ignoring
///   case and accents ("cafe" finds "Café"). Blank text does not filter.
/// - Filters: an issue must match every filter that is set. The segment
///   filter matches an issue whose segments include it (section 6.5).
/// - Text inside the PDF is never searched (FR-SRCH-007).
List<IssueSummary> applyQuery(
  List<IssueSummary> issues,
  IssueQuery query, {
  Map<String, String> categoryNames = const <String, String>{},
}) {
  final List<String> words = searchWords(query.text ?? '');
  return <IssueSummary>[
    for (final IssueSummary issue in issues)
      if (_filtersMatch(issue, query) &&
          _textMatches(issue, words, categoryNames[issue.categoryId]))
        issue,
  ];
}

bool _filtersMatch(IssueSummary issue, IssueQuery query) =>
    (query.categoryId == null || issue.categoryId == query.categoryId) &&
    (query.industrySegmentId == null ||
        issue.industrySegmentIds.contains(query.industrySegmentId)) &&
    (query.year == null || issue.year == query.year) &&
    (query.edition == null || issue.edition == query.edition);

bool _textMatches(IssueSummary issue, List<String> words, String? category) {
  if (words.isEmpty) {
    return true;
  }
  final String haystack = foldForSearch(
    '${issue.title} ${issue.description} ${category ?? ''}',
  );
  return words.every(haystack.contains);
}

/// The words of [text], folded for search, without empty ones.
List<String> searchWords(String text) =>
    foldForSearch(text)
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList();

/// [text] in lower case with the accents of Latin letters removed, so a
/// search matches with or without them.
String foldForSearch(String text) {
  final StringBuffer out = StringBuffer();
  for (final int rune in text.toLowerCase().runes) {
    final String char = String.fromCharCode(rune);
    out.write(_unaccented[char] ?? char);
  }
  return out.toString();
}

const Map<String, String> _unaccented = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a', //
  'ç': 'c', 'č': 'c', 'ć': 'c', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ě': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', //
  'ñ': 'n', 'ń': 'n', 'ň': 'n', //
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', //
  'ý': 'y', 'ÿ': 'y', 'ž': 'z', 'ź': 'z', 'ż': 'z', //
  'š': 's', 'ś': 's', 'ř': 'r', 'ł': 'l', 'đ': 'd', //
  'ß': 'ss', 'æ': 'ae', 'œ': 'oe',
};

/// An industry segment, for the segment filter. Its meaning is OQ-13.
/// Feature-level and PROPOSED: section 6.5 does not yet define the model.
final class IndustrySegment {
  /// Creates the segment.
  const IndustrySegment({required this.segmentId, required this.name});

  /// Opaque segment ID.
  final String segmentId;

  /// Display name.
  final String name;
}

/// Gives the industry segments, by name (OP-01 returns them with the
/// catalogue, `API_AND_BACKEND_CONTRACT.md` section 3.1).
/// A catalogue that can answer from the device when offline (MOD05-P2-T05,
/// RS NFR-OFF-002; OQ-10 working position of 12 November 2026, PROVISIONAL).
abstract interface class OfflineCatalogue {
  /// Whether the last answer came from the device, so the screen says the
  /// app is offline.
  bool get fromDevice;
}

abstract interface class SegmentSource {
  /// Lists the segments.
  Future<Result<List<IndustrySegment>>> listSegments();
}

/// The values each filter can take, from the issues that are listed, so no
/// filter offers a value that finds nothing.
final class FilterChoices {
  /// The choices for [issues].
  factory FilterChoices.of(List<IssueSummary> issues) {
    final Set<String> categories = <String>{};
    final Set<String> segments = <String>{};
    final Set<int> years = <int>{};
    final Set<String> editions = <String>{};
    for (final IssueSummary issue in issues) {
      categories.add(issue.categoryId);
      segments.addAll(issue.industrySegmentIds);
      years.add(issue.year);
      if (issue.edition case final String edition) {
        editions.add(edition);
      }
    }
    return FilterChoices._(
      categoryIds: categories,
      segmentIds: segments,
      years: years.toList()..sort((int a, int b) => b.compareTo(a)),
      editions: editions.toList()..sort(),
    );
  }

  const FilterChoices._({
    required this.categoryIds,
    required this.segmentIds,
    required this.years,
    required this.editions,
  });

  /// The categories with an issue.
  final Set<String> categoryIds;

  /// The segments with an issue.
  final Set<String> segmentIds;

  /// The years with an issue, newest first.
  final List<int> years;

  /// The editions with an issue, in order.
  final List<String> editions;
}
