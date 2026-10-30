import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_profile_repository.dart';
import 'fake_server.dart';
import 'test_helpers.dart';
import 'test_users.dart';

void main() {
  group('FakeAuthService and FakeProfileRepository [IC-01]', () {
    test('implement AuthService and ProfileRepository', () {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server);

      expect(auth, isA<AuthService>());
      expect(FakeProfileRepository(server, auth), isA<ProfileRepository>());
    });

    test(
      'a logged-out visitor has no session and is signedOut [FX-USR-09]',
      () async {
        final FakeAuthService auth = FakeAuthService(FakeServer());

        expect(await auth.watchSession().first, isNull);
        expect(await auth.watchAccessState().first, AccessState.signedOut);
      },
    );

    for (final TestUser user in <TestUser>[
      fxUsr01,
      fxUsr02,
      fxUsr03,
      fxUsr04,
      fxUsr05,
    ]) {
      test('${user.fixtureId} gets its documented access state', () async {
        final FakeAuthService auth = FakeAuthService(
          FakeServer(),
          signedInAs: user,
        );

        expect(await auth.watchAccessState().first, user.documentedAccessState);
      });
    }

    test('register, verify, reload and complete the profile reach fullAccess [AC-3.1]', () async {
      final FakeServer server = FakeServer(accounts: const <TestUser>[]);
      final FakeAuthService auth = FakeAuthService(server);
      final FakeProfileRepository profiles = FakeProfileRepository(
        server,
        auth,
      );
      final List<AccessState> seen = recordEvents(auth.watchAccessState());
      const String address = 'fx-new-01@example.com';

      expect(
        await auth.registerWithEmail(email: address, password: 'x'),
        isA<Ok<void>>(),
      );
      server.markEmailVerified(address);
      expect(await auth.reloadVerificationStatus(), isA<Ok<void>>());
      expect(
        await profiles.saveOwnProfile(
          const ReaderProfile(
            name: 'Test Reader 99',
            occupation: 'Test Engineer',
            domainOfWork: 'Test Domain',
          ),
        ),
        isA<Ok<void>>(),
      );
      await settle();

      expect(seen, <AccessState>[
        AccessState.signedOut,
        AccessState.emailUnverified,
        AccessState.profileIncomplete,
        AccessState.fullAccess,
      ]);
    });

    test('sign-out returns the device to signedOut', () async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final List<AccessState> seen = recordEvents(auth.watchAccessState());

      await auth.signOut();
      await settle();

      expect(seen, <AccessState>[
        AccessState.fullAccess,
        AccessState.signedOut,
      ]);
    });

    test(
      'sign-in with an unknown address is unauthenticated [MOD-03]',
      () async {
        final FakeAuthService auth = FakeAuthService(FakeServer());

        expect(
          failureCodeOf(
            await auth.signInWithEmail(
              email: 'fx-unknown@example.com',
              password: 'x',
            ),
          ),
          FailureCode.unauthenticated,
        );
      },
    );

    test(
      'registering an address already in use is a conflict [MOD-03]',
      () async {
        final FakeAuthService auth = FakeAuthService(FakeServer());

        expect(
          failureCodeOf(
            await auth.registerWithEmail(email: fxUsr01.email, password: 'x'),
          ),
          FailureCode.conflict,
        );
      },
    );

    test('a cancelled Google flow is cancelled [MOD-03]', () async {
      final FakeAuthService auth = FakeAuthService(FakeServer());

      expect(
        failureCodeOf(await auth.signInWithGoogle()),
        FailureCode.cancelled,
      );
    });

    test('profile status follows the signed-in reader [FR-PROF-004]', () async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server);
      final FakeProfileRepository profiles = FakeProfileRepository(
        server,
        auth,
      );
      final List<ProfileStatus> seen = recordEvents(profiles.watchStatus());

      auth.signInAs(fxUsr03);
      auth.signInAs(fxUsr01);
      await auth.signOut();
      await settle();

      expect(seen, <ProfileStatus>[
        ProfileStatus.unknown,
        ProfileStatus.incomplete,
        ProfileStatus.complete,
        ProfileStatus.unknown,
      ]);
    });

    test(
      'profile calls while signed out are unauthenticated [MOD-04]',
      () async {
        final FakeServer server = FakeServer();
        final FakeProfileRepository profiles = FakeProfileRepository(
          server,
          FakeAuthService(server),
        );

        expect(
          failureCodeOf(await profiles.getOwnProfile()),
          FailureCode.unauthenticated,
        );
      },
    );
  });
}
