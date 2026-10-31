import 'package:mfw_app/contracts/contracts.dart';

/// User-facing text of the catalogue, kept together (CODING_STANDARDS
/// section 9). PLACEHOLDER wording: the M2 designs set the real text, and
/// MOD-02 will own the failure messages.
abstract final class CatalogueText {
  /// Title of SCR-A-11.
  static const String title = 'Catalogue';

  /// Title of SCR-A-12.
  static const String details = 'Issue details';

  /// Label of the search box (RS FR-SRCH-001).
  static const String searchLabel = 'Search issues';

  /// Label of the control that clears the search.
  static const String clearSearch = 'Clear search';

  /// Heading above the latest issue (RS FR-MAG-004).
  static const String latest = 'Latest issue';

  /// Heading above the earlier issues (RS FR-MAG-004).
  static const String archive = 'Archive';

  /// Nothing is published (RS FR-STATE-002).
  static const String empty = 'No issues have been published yet.';

  /// The search or filters match nothing (RS FR-STATE-002).
  static const String noResults = 'No issues match your search.';

  /// An unpublished issue (`notFound`, OP-CAT-02).
  static const String notAvailable = 'This issue is no longer available.';

  /// No connection (`network`, RS FR-STATE-003).
  static const String offline =
      'You are offline. Check your connection and try again.';

  /// Any other failure.
  static const String failed = 'The issues could not be loaded.';

  /// The retry action.
  static const String retry = 'Retry';

  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// A publication date, for example "1 October 2026". PLACEHOLDER format
  /// until the M2 designs; no date package is approved.
  static String date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// The message for a failed read.
  static String failure(AppFailure failure) => switch (failure.code) {
    FailureCode.network => offline,
    FailureCode.notFound => notAvailable,
    _ => failed,
  };
}
