import '../../fakes/fake_auth_service.dart';
import '../../fakes/fake_download_manager.dart';
import '../../fakes/fake_issue_file_service.dart';
import '../../fakes/fake_server.dart';
import '../../fakes/test_users.dart';
import '../../fixtures/fx_issue_files.dart';

/// A device signed in as FX-USR-01 holding complete copies of [issueIds].
/// Copies of [damagedCopies] fail their check when opened.
FakeDownloadManager downloadsHolding(
  List<String> issueIds, {
  Set<String> damagedCopies = const <String>{},
}) {
  final FakeAuthService auth = FakeAuthService(
    FakeServer(),
    signedInAs: fxUsr01,
  );
  final FakeDownloadManager downloads = FakeDownloadManager(
    auth,
    FakeIssueFileService(auth, files: fxIssueFiles),
    damagedIssueIds: damagedCopies,
  );
  for (final String issueId in issueIds) {
    downloads.seedCopy(ownerUserId: fxUsr01.userId, issueId: issueId);
  }
  return downloads;
}
