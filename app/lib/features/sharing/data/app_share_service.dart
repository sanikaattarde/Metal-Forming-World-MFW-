import 'dart:ui';

import '../../../contracts/catalogue.dart';
import '../../../contracts/news.dart';
import '../../../contracts/result.dart';
import '../../../contracts/sharing.dart';
import '../domain/share_sheet.dart';
import '../domain/share_texts.dart';

/// MOD-10's [ShareService] (MOD10-P1-T01, RS FR-SHR-001 to FR-SHR-006) over
/// the share sheet. [origin] is where the sheet points from on a tablet.
///
/// Failures: `cancelled` when the reader closes the sheet, `unknown` when
/// the sheet cannot open or an issue has no store link to share.
final class AppShareService implements ShareService {
  /// Creates the service.
  const AppShareService({
    required this._sheet,
    required this._links,
    this.origin,
  });

  final ShareSheet _sheet;
  final StoreLinks _links;

  /// Where the sheet points from on a tablet.
  final Rect? origin;

  @override
  Future<Result<void>> shareIssue(IssueSummary issue) async {
    final String? text = ShareTexts.issue(issue, _links);
    if (text == null) {
      return const Err<void>(
        AppFailure(FailureCode.unknown, detail: 'no store link'),
      );
    }
    return _share(text, issue.title);
  }

  @override
  Future<Result<void>> shareArticle(NewsPost post) =>
      _share(ShareTexts.article(post), post.title);

  Future<Result<void>> _share(String text, String subject) async {
    try {
      final ShareSheetOutcome outcome = await _sheet.share(
        text: text,
        subject: subject,
        origin: origin,
      );
      return switch (outcome) {
        ShareSheetOutcome.dismissed => const Err<void>(
          AppFailure(FailureCode.cancelled),
        ),
        ShareSheetOutcome.shared ||
        ShareSheetOutcome.unknown => const Ok<void>(null),
      };
    } on Object {
      return const Err<void>(
        AppFailure(FailureCode.unknown, detail: 'share sheet'),
      );
    }
  }
}
