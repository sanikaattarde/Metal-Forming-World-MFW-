import 'package:go_router/go_router.dart';

import '../contracts/platform.dart';
import 'routes.dart';

/// Opens notification targets through the router, so the access guard
/// applies to them as to any other navigation (RS FR-NOTIF-005, BR-005).
final class RouterAppNavigator implements AppNavigator {
  /// Creates the navigator over [_router].
  RouterAppNavigator(this._router);

  final GoRouter _router;

  /// Opens the issue's reader route. A reader without full access sees the
  /// missing step and comes back to the issue after it (BR-005, FX-NTF-07).
  @override
  void openIssue(String issueId) => _router.go(AppRoutes.reader(issueId));

  /// Opens the article, which every access state may read.
  @override
  void openArticle(String postId) => _router.go(AppRoutes.newsPost(postId));
}
