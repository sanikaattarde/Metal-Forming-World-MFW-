import 'package:mfw_app/contracts/contracts.dart';

/// User-facing text of the news feature, kept together (CODING_STANDARDS
/// section 9). PLACEHOLDER wording: the M2 designs set the real text, and
/// MOD-02 will own the failure messages.
abstract final class NewsText {
  /// Title of the news list (SCR-A-18).
  static const String title = 'News';

  /// Title of the article page (SCR-A-19).
  static const String article = 'Article';

  /// The chip for every selected category.
  static const String all = 'All';

  /// Loads the next page.
  static const String more = 'More news';

  /// No posts at all (RS FR-STATE-002).
  static const String emptyAll = 'No news yet.';

  /// No posts in the chosen category (RS FR-STATE-002).
  static const String emptyCategory = 'No news in this category.';

  /// A post that is gone, or outside MFW's categories (`notFound`).
  static const String notAvailable = 'This article is no longer available.';

  /// No connection (`network`, RS FR-STATE-003).
  static const String offline =
      'You are offline. Check your connection and try again.';

  /// The site cannot be reached or read (RS FR-STATE-005).
  static const String unreachable = "News can't be loaded right now.";

  /// A refresh or next page failed while older posts show (FR-STATE-005).
  static const String staleNotice =
      "News can't be refreshed right now. Showing the news loaded earlier.";

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

  /// A date already in local time (CODING_STANDARDS section 7, item 5),
  /// for example "25 March 2026". PLACEHOLDER format; no date package is
  /// approved.
  static String date(DateTime local) =>
      '${local.day} ${_months[local.month - 1]} ${local.year}';

  /// The message for a failed read.
  static String failure(AppFailure failure) => switch (failure.code) {
    FailureCode.network => offline,
    FailureCode.notFound => notAvailable,
    _ => unreachable,
  };
}
