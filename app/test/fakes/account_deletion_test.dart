import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fixtures/fx_issue_files.dart';
import 'fake_auth_service.dart';
import 'fake_download_manager.dart';
import 'fake_issue_file_service.dart';
import 'fake_library_repository.dart';
import 'fake_notification_service.dart';
import 'fake_profile_repository.dart';
import 'fake_server.dart';
import 'test_helpers.dart';
import 'test_users.dart';

void main() {
  group('Fake account deletion [IC-08]', () {
    for (final DownloadsAfterAccountDeletion policy
        in DownloadsAfterAccountDeletion.values) {
      test(
        'FX-USR-07 deletion clears server data; downloads: ${policy.name} [OQ-11]',
        () async {
          final FakeServer server = FakeServer();
          final FakeAuthService auth = FakeAuthService(
            server,
            signedInAs: fxUsr07,
          );
          final FakeLibraryRepository library = FakeLibraryRepository(
            server,
            auth,
          );
          final FakeDownloadManager downloads = FakeDownloadManager(
            auth,
            FakeIssueFileService(auth, files: fxIssueFiles),
            afterAccountDeletion: policy,
          )..seedCopy(ownerUserId: fxUsr07.userId, issueId: 'fx-iss-01');
          valueOf(await library.addBookmark('fx-iss-01', 5));
          expect(
            await library.setFavourite('fx-iss-02', true),
            isA<Ok<void>>(),
          );
          expect(
            await FakeNotificationService(server, auth).savePreferences(
              const NotificationPreferences(
                optedIn: true,
                categoryIds: <String>['fx-cat-01'],
              ),
            ),
            isA<Ok<void>>(),
          );
          expect(
            await FakeProfileRepository(server, auth).recordConsent(
              ConsentRecord(
                agreedTo: 'fx-policy-and-terms-1',
                agreedAt: DateTime.utc(2026),
              ),
            ),
            isA<Ok<void>>(),
          );
          expect(server.holdsDataFor(fxUsr07.userId), isTrue);

          expect(await auth.deleteAccount(), isA<Ok<void>>());

          expect(server.holdsDataFor(fxUsr07.userId), isFalse);
          expect(await auth.watchAccessState().first, AccessState.signedOut);
          expect(
            downloads.holdsCopy(
              ownerUserId: fxUsr07.userId,
              issueId: 'fx-iss-01',
            ),
            policy == DownloadsAfterAccountDeletion.keepCopies,
          );
          auth.signInAs(fxUsr01);
          expect(await downloads.listDownloaded(), isEmpty);
        },
      );
    }

    test('deleteAccount while signed out is unauthenticated', () async {
      expect(
        failureCodeOf(await FakeAuthService(FakeServer()).deleteAccount()),
        FailureCode.unauthenticated,
      );
    });
  });
}
