import '../../../contracts/catalogue.dart';
import '../../../contracts/news.dart';
import 'share_sheet.dart';

/// The words shared for an issue or an article (MOD10-P1-T01). PLACEHOLDER
/// wording until M2.
///
/// - An issue: its title and both store links that are known, because the
///   recipient's phone may be either (FR-SHR-001, FR-SHR-002, OQ-15
///   working position of 12 November 2026, PROVISIONAL).
/// - An article: its title and its address on MFW's website (FR-SHR-003,
///   FR-SHR-004).
///
/// Neither ever holds a link into the app (FR-SHR-005) or a file
/// (FR-SHR-006).
abstract final class ShareTexts {
  /// The text for [issue], or null when no store link is known.
  static String? issue(IssueSummary issue, StoreLinks links) {
    if (!links.any) {
      return null;
    }
    return <String>[
      issue.title,
      'Read it in the MFW app.',
      if (links.android != null) 'Android: ${links.android}',
      if (links.ios != null) 'iPhone and iPad: ${links.ios}',
    ].join('\n');
  }

  /// The text for [post].
  static String article(NewsPost post) => '${post.title}\n${post.link}';
}
