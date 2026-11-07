import 'package:mfw_app/contracts/contracts.dart';

/// An [AppNavigator] that records each call, in order (IC-05).
final class RecordingAppNavigator implements AppNavigator {
  /// Calls as `issue:<issueId>` or `article:<postId>`.
  final List<String> calls = <String>[];

  @override
  void openIssue(String issueId) => calls.add('issue:$issueId');

  @override
  void openArticle(String postId) => calls.add('article:$postId');
}
