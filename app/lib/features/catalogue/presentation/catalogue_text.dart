import 'package:mfw_app/contracts/contracts.dart';

import '../../../core/errors/failure_messages.dart';
import '../../../core/format/display_format.dart';
import '../../downloads/presentation/downloads_text.dart';

/// User-facing text of the catalogue screens, kept together
/// (`CODING_STANDARDS.md` section 9). PLACEHOLDER wording from the reader
/// frames (`READER_SCREEN_DESIGNS.md`) until M2.
abstract final class CatalogueText {
  /// Title of SCR-A-11.
  static const String title = 'Catalogue';

  /// Spoken while the catalogue loads.
  static const String loading = 'Loading the catalogue';

  /// Spoken while an issue loads.
  static const String loadingIssue = 'Loading the issue';

  /// The back action.
  static const String back = 'Back';

  /// The retry action.
  static const String retry = 'Retry';

  /// Heading when nothing is published.
  static const String emptyHeading = 'No issues yet';

  /// Line when nothing is published.
  static const String emptyText = 'Published issues will appear here.';

  /// The search field's hint.
  static const String searchHint = 'Search issues';

  /// Clears the search text.
  static const String clearSearch = 'Clear the search';

  /// Clears the search and every filter.
  static const String clearFilters = 'Clear the filters';

  /// Heading when nothing matches.
  static const String noMatchHeading = 'No issues match';

  /// Line when nothing matches.
  static const String noMatchText = 'Try other words, or clear the filters.';

  /// The category filter (FR-SRCH-002).
  static const String filterCategory = 'Category';

  /// The industry segment filter (FR-SRCH-003; meaning: OQ-13).
  static const String filterSegment = 'Industry segment';

  /// The year filter (FR-SRCH-004).
  static const String filterYear = 'Year';

  /// The edition filter (FR-SRCH-005; meaning: OQ-13).
  static const String filterEdition = 'Edition';

  /// The category filter's "no filter" choice.
  static const String anyCategory = 'Any category';

  /// The segment filter's "no filter" choice.
  static const String anySegment = 'Any industry segment';

  /// The year filter's "no filter" choice.
  static const String anyYear = 'Any year';

  /// The edition filter's "no filter" choice.
  static const String anyEdition = 'Any edition';

  /// What a filter chip says it does, with its value when one is set.
  static String filterTooltip(String filter, String? value) =>
      value == null ? 'Filter by $filter' : '$filter: $value';

  /// Heading for an issue that is no longer published (FR-MAG-008).
  static const String goneHeading = 'This issue is no longer available';

  /// Line for an issue that is no longer published.
  static const String goneText =
      'It was withdrawn from the catalogue. Other issues are still there.';

  /// Reads a full issue (SCR-A-14).
  static const String read = 'Read';

  /// Downloads a full issue (SCR-A-13).
  static const String download = DownloadsText.download;

  /// Shown to a visitor on SCR-A-12.
  static const String visitorNotice =
      'Sign in to read and download full issues.';

  /// Sign in.
  static const String signIn = 'Sign in';

  /// Register.
  static const String register = 'Create an account';

  /// Shown on SCR-A-12 to a reader whose email is not verified.
  static const String verifyNotice =
      'Verify your email address to read and download full issues.';

  /// Goes to SCR-A-03.
  static const String verifyAction = 'Verify email';

  /// Shown on SCR-A-12 to a reader whose profile is incomplete.
  static const String profileNotice =
      'Complete your profile to read and download full issues.';

  /// Goes to SCR-A-05.
  static const String profileAction = 'Complete profile';

  /// How many issues are listed.
  static String issueCount(int count) =>
      count == 1 ? '1 issue' : '$count issues';

  /// The spoken name of an issue's cover.
  static String coverOf(String title) => 'Cover of $title';

  /// The line under an issue's title in a list: its category and date.
  static String listMeta(String category, DateTime date) =>
      '$category · ${DisplayFormat.date(date)}';

  /// The line under the title on SCR-A-12: category, date and, when the
  /// working position of OQ-13 shows it, the file size.
  static String detailMeta(String category, DateTime date, int? sizeBytes) =>
      sizeBytes == null
      ? listMeta(category, date)
      : '${listMeta(category, date)} · ${DownloadsText.sizeLabel(sizeBytes)}';

  /// The text for [failure].
  static String failure(AppFailure failure) => messageFor(failure);

  /// Shown over the catalogue read from the device (MOD05-P2-T05).
  static const String offlineCopy =
      'You are offline. This is the catalogue from your last visit.';
}
