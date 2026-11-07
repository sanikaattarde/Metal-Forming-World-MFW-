import 'catalogue.dart';
import 'news.dart';
import 'result.dart';

/// Shares an issue or an article through the share sheet (MOD-10).
///
/// Never shares a file (RS FR-SHR-006). Failures: `cancelled`, `unknown`.
abstract interface class ShareService {
  /// Shares the issue title and store-listing link (which link: OQ-15).
  Future<Result<void>> shareIssue(IssueSummary issue);

  /// Shares the article title and WordPress address.
  Future<Result<void>> shareArticle(NewsPost post);
}
