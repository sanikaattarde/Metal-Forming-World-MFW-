import 'package:go_router/go_router.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Opens notification targets through the router, so the access guard
/// applies to them as to any other navigation (RS FR-NOTIF-005, BR-005).
final class RouterAppNavigator implements AppNavigator {
  /// Creates the navigator over [_router].
  RouterAppNavigator(this._router);

  final GoRouter _router;

  /// Opens the issue's reader route. A reader without full access sees the
  /// missing step and comes back to the issue after it (BR-005, FX-NTF-07).
  @override
  void openIssue(String issueId) =>
      _router.go('/issues/${Uri.encodeComponent(issueId)}/read');

  /// Opens the article, which every access state may read.
  @override
  void openArticle(String postId) =>
      _router.go('/news/${Uri.encodeComponent(postId)}');
}

/// Opens a tapped notification [target]; MOD-11 forwards its taps here.
void openNotificationTarget(AppNavigator navigator, NotificationTarget target) {
  switch (target.type) {
    case NotificationTargetType.issue:
      navigator.openIssue(target.targetId);
    case NotificationTargetType.article:
      navigator.openArticle(target.targetId);
  }
}
