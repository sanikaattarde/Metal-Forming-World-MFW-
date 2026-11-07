import 'package:mfw_app/contracts/contracts.dart';

/// Fake OP-NWS-01 (IC-06). Each read returns a snapshot, so a change shows
/// only in the next read, as after a refresh.
final class FakeNewsControlsService implements NewsControlsService {
  final Set<String> _hidden = <String>{};
  final Set<String> _breaking = <String>{};

  /// When set, every read fails with it.
  AppFailure? failure;

  /// Hides [postId], as an admin would.
  void hidePost(String postId) => _hidden.add(postId);

  /// Shows [postId] again.
  void showPost(String postId) => _hidden.remove(postId);

  /// Marks or unmarks [postId] as breaking.
  void markBreaking(String postId, {bool breaking = true}) {
    if (breaking) {
      _breaking.add(postId);
    } else {
      _breaking.remove(postId);
    }
  }

  @override
  Future<Result<NewsControls>> getNewsControls() async {
    final AppFailure? set = failure;
    if (set != null) {
      return Err<NewsControls>(set);
    }
    return Ok<NewsControls>(
      NewsControls(
        hiddenPostIds: Set<String>.unmodifiable(_hidden),
        breakingPostIds: Set<String>.unmodifiable(_breaking),
      ),
    );
  }
}
