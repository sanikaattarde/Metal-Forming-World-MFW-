import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_profile_repository.dart';
import 'fake_server.dart';
import 'test_helpers.dart';
import 'test_users.dart';

void main() {
  group('Re-authentication before account deletion [OP-12, R-4 d]', () {
    test('a sign-in that is no longer recent cannot delete the account '
        '[FR-PRIV-003]', () async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr01);

      auth.expireRecentSignIn();

      expect(
        failureCodeOf(await auth.deleteAccount()),
        FailureCode.unauthenticated,
      );
      expect(server.accountById(fxUsr01.userId), isNotNull);
      expect(auth.currentUserId, fxUsr01.userId);
    });

    test('re-authenticating with the password lets the deletion run '
        '[FR-AUTH-009]', () async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr01);
      auth.expireRecentSignIn();

      expect(
        await auth.reauthenticateWithEmail(password: 'x'),
        isA<Ok<void>>(),
      );
      expect(await auth.deleteAccount(), isA<Ok<void>>());
      expect(server.accountById(fxUsr01.userId), isNull);
    });

    test('an empty password, a signed-out device and a Google session are '
        'refused for the email method', () async {
      final FakeAuthService email = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final FakeAuthService signedOut = FakeAuthService(FakeServer());
      final FakeAuthService google = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr04,
      );

      expect(
        failureCodeOf(await email.reauthenticateWithEmail(password: '')),
        FailureCode.unauthenticated,
      );
      expect(
        failureCodeOf(await signedOut.reauthenticateWithEmail(password: 'x')),
        FailureCode.unauthenticated,
      );
      expect(
        failureCodeOf(await google.reauthenticateWithEmail(password: 'x')),
        FailureCode.unauthenticated,
      );
    });

    test('Google re-authentication needs the same Google account '
        '[C-04]', () async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr04);
      auth.expireRecentSignIn();

      expect(
        failureCodeOf(await auth.reauthenticateWithGoogle()),
        FailureCode.cancelled,
      );

      auth.nextGoogleEmail = fxUsr05.email;
      expect(
        failureCodeOf(await auth.reauthenticateWithGoogle()),
        FailureCode.unauthenticated,
      );
      expect(
        failureCodeOf(await auth.deleteAccount()),
        FailureCode.unauthenticated,
      );

      auth.nextGoogleEmail = fxUsr04.email;
      expect(await auth.reauthenticateWithGoogle(), isA<Ok<void>>());
      expect(await auth.deleteAccount(), isA<Ok<void>>());
      expect(server.accountById(fxUsr04.userId), isNull);
    });

    test('an email session cannot use the Google method', () async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      )..nextGoogleEmail = fxUsr01.email;

      expect(
        failureCodeOf(await auth.reauthenticateWithGoogle()),
        FailureCode.unauthenticated,
      );
    });

    test('a fresh sign-in after an expired one is recent again', () async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      auth.expireRecentSignIn();

      await auth.signOut();
      auth.signInAs(fxUsr01);

      expect(await auth.deleteAccount(), isA<Ok<void>>());
    });
  });

  group('Saving the profile returns its status [OP-PRF-02, R-3]', () {
    test('a saved profile is complete, with no missing fields', () async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr03);
      final FakeProfileRepository profiles = FakeProfileRepository(
        server,
        auth,
      );

      final ProfileSaveResult saved = valueOf(
        await profiles.saveOwnProfile(
          const ReaderProfile(
            name: 'Test Reader 03',
            occupation: 'Test Engineer',
            domainOfWork: 'Test Domain',
          ),
        ),
      );

      expect(saved.status, ProfileStatus.complete);
      expect(saved.missingFields, isEmpty);
    });

    test('saving while signed out is unauthenticated [MOD-04]', () async {
      final FakeServer server = FakeServer();
      final FakeProfileRepository profiles = FakeProfileRepository(
        server,
        FakeAuthService(server),
      );

      expect(
        failureCodeOf(await profiles.saveOwnProfile(const ReaderProfile())),
        FailureCode.unauthenticated,
      );
    });

    test('an incomplete outcome names the missing fields', () {
      const ProfileSaveResult outcome = ProfileSaveResult(
        status: ProfileStatus.incomplete,
        missingFields: <String>['occupation'],
      );

      expect(outcome.status, ProfileStatus.incomplete);
      expect(outcome.missingFields, <String>['occupation']);
      expect(
        const ProfileSaveResult(status: ProfileStatus.complete).missingFields,
        isEmpty,
      );
    });
  });
}
