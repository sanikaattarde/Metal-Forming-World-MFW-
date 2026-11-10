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
}
