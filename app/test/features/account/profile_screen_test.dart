// MOD04-P2-T03: SCR-A-06, the reader's own profile and editing it
// (FR-PROF-006, FR-PROF-007), and the guard on /profile. PROVISIONAL: the
// working-position fields (OQ-01). Synthetic values only (DEC-024).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/access_guard.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../app/app_harness.dart';
import 'fake_identity_provider.dart';
import 'fake_profile_backend.dart';

void main() {
  late FakeIdentityProvider identity;
  late FakeProfileBackend backend;
  late AccountProfileRepository profiles;
  late String uid;

  setUp(() async {
    identity = FakeIdentityProvider();
    backend = FakeProfileBackend(identity);
    profiles = AccountProfileRepository(identity, backend, backend);
    uid = identity
        .addAccount('reader@example.test', 'right-password', verified: true)
        .uid;
    await identity.signIn(
      email: 'reader@example.test',
      password: 'right-password',
    );
    backend
      ..consents[uid] = <String, Object?>{'privacy_policy': 'pp-test-1'}
      ..putProfile(uid, <String, Object?>{
        'full_name': 'Test Reader',
        'age_value': 30,
        'gender': 'Prefer not to say',
        'job_title': 'Tester',
        'industry_segment_id': 's2',
      });
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: ProfileScreen(
          forms: profiles,
          profiles: profiles,
          email: 'reader@example.test',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets(
    'shows the address and each saved value, with the segment by name',
    (WidgetTester tester) async {
      await pumpProfile(tester);
      for (final String text in <String>[
        'reader@example.test',
        'Test Reader',
        '30',
        'Prefer not to say',
        'Tester',
        'Segment two',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.text('s2'), findsNothing);
    },
  );

  testWidgets('a value not given shows as such', (WidgetTester tester) async {
    backend.putProfile(uid, <String, Object?>{'full_name': 'Test Reader'});
    await pumpProfile(tester);
    expect(find.text(AccountText.notGiven), findsNWidgets(4));
  });

  testWidgets(
    'editing starts from the saved values, saves through OP-10 and shows the change [FR-PROF-006]',
    (WidgetTester tester) async {
      await pumpProfile(tester);
      await tester.tap(find.text(AccountText.editProfile));
      await tester.pumpAndSettle();
      final TextField name = tester.widget(field(AccountText.fullName));
      expect(name.controller!.text, 'Test Reader');

      await tester.enterText(field(AccountText.age), '31');
      await tester.ensureVisible(find.text(AccountText.saveChanges));
      await tester.tap(find.text(AccountText.saveChanges));
      await tester.pumpAndSettle();

      final Map<String, Object?> sent =
          backend.calls.single.$2['profile']! as Map<String, Object?>;
      expect(sent['age_value'], 31);
      expect(sent['industry_segment_id'], 's2');
      expect(backend.calls.single.$2.containsKey('accepted_versions'), isFalse);
      expect(find.text(AccountText.profileSaved), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
      expect(find.text(AccountText.editProfile), findsOneWidget);
    },
  );

  testWidgets('editing checks the values as SCR-A-05 does', (
    WidgetTester tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.text(AccountText.editProfile));
    await tester.pumpAndSettle();
    await tester.enterText(field(AccountText.age), '200');
    await tester.ensureVisible(find.text(AccountText.saveChanges));
    await tester.tap(find.text(AccountText.saveChanges));
    await tester.pumpAndSettle();
    expect(find.text(AccountText.ageInvalid), findsOneWidget);
    expect(backend.calls, isEmpty);
  });

  testWidgets('cancel leaves editing without saving', (
    WidgetTester tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.text(AccountText.editProfile));
    await tester.pumpAndSettle();
    await tester.enterText(field(AccountText.fullName), 'Changed Name');
    await tester.ensureVisible(find.text(AccountText.cancel));
    await tester.tap(find.text(AccountText.cancel));
    await tester.pumpAndSettle();
    expect(find.text('Test Reader'), findsOneWidget);
    expect(backend.calls, isEmpty);
  });

  testWidgets('a failed save shows the failure and keeps the form', (
    WidgetTester tester,
  ) async {
    backend.failNext = const BackendCallError('UNAVAILABLE');
    await pumpProfile(tester);
    await tester.tap(find.text(AccountText.editProfile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(AccountText.saveChanges));
    await tester.tap(find.text(AccountText.saveChanges));
    await tester.pumpAndSettle();
    expect(find.text('The service is unavailable. Try again.'), findsOneWidget);
    expect(find.text(AccountText.saveChanges), findsOneWidget);
  });

  testWidgets('a profile that cannot load offers Retry', (
    WidgetTester tester,
  ) async {
    backend.readError = StateError('offline');
    await pumpProfile(tester);
    expect(find.text('Retry'), findsOneWidget);
    backend.readError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Test Reader'), findsOneWidget);
  });

  test(
    'a change made on one device is what another device reads [FR-PROF-007]',
    () async {
      final AccountProfileRepository otherDevice = AccountProfileRepository(
        identity,
        backend,
        backend,
      );
      await profiles.saveOwnProfile(
        const ReaderProfile(
          name: 'New Name',
          age: 30,
          gender: 'Female',
          occupation: 'Tester',
          domainOfWork: 's1',
        ),
      );
      final ReaderProfile? read =
          (await otherDevice.getOwnProfile() as Ok<ReaderProfile?>).value;
      expect(read?.name, 'New Name');
      expect(read?.gender, 'Female');
    },
  );

  group('the guard on /profile', () {
    test('a visitor is sent to sign in and comes back', () {
      expect(
        redirectFor(AccessState.signedOut, Uri.parse('/profile')),
        '/sign-in?from=%2Fprofile',
      );
      expect(
        redirectFor(AccessState.signedOut, Uri.parse('/profile/')),
        isNotNull,
      );
    });

    for (final AccessState state in <AccessState>[
      AccessState.emailUnverified,
      AccessState.profileIncomplete,
      AccessState.fullAccess,
    ]) {
      test('${state.name} opens it', () {
        expect(redirectFor(state, Uri.parse('/profile')), isNull);
      });
    }

    testWidgets('through the app, a signed-in reader sees their profile', (
      WidgetTester tester,
    ) async {
      final AccountAuthService auth = AccountAuthService(
        identity,
        profileStatus: profiles.watchStatus,
      );
      final GoRouter router = await pumpAppWithProfiles(tester, auth, profiles);
      router.go('/profile');
      await tester.pumpAndSettle();
      expect(find.text(AccountText.profileTitle), findsOneWidget);
      expect(find.text('Test Reader'), findsOneWidget);
    });
  });
}
