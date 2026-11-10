// MOD04-P2-T01: AccountProfileRepository over OP-10 and the profile record,
// and SCR-A-05 (FR-PROF-001 to FR-PROF-005, BR-003, INV-10, PAC-02).
// PROVISIONAL: the five working-position fields (OQ-01 to OQ-03).
// Synthetic values only (DEC-024).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../app/app_harness.dart';
import 'fake_identity_provider.dart';
import 'fake_profile_backend.dart';

const ReaderProfile fullProfile = ReaderProfile(
  name: 'Test Reader',
  age: 30,
  gender: 'Prefer not to say',
  occupation: 'Tester',
  domainOfWork: 's1',
);

void main() {
  late FakeIdentityProvider identity;
  late FakeProfileBackend backend;
  late AccountProfileRepository profiles;
  late String uid;

  setUp(() async {
    identity = FakeIdentityProvider();
    backend = FakeProfileBackend(identity);
    profiles = AccountProfileRepository(
      identity,
      backend,
      backend,
      requestIds: () => 'request-1',
    );
    uid = identity
        .addAccount('reader@example.test', 'right-password', verified: true)
        .uid;
    await identity.signIn(
      email: 'reader@example.test',
      password: 'right-password',
    );
  });

  Future<List<ProfileStatus>> statuses(Future<void> Function() during) async {
    final List<ProfileStatus> seen = <ProfileStatus>[];
    final List<Object> errors = <Object>[];
    final StreamSubscription<ProfileStatus> sub = profiles.watchStatus().listen(
      seen.add,
      onError: errors.add,
    );
    await Future<void>.delayed(Duration.zero);
    await during();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    if (errors.isNotEmpty) {
      throw errors.first;
    }
    return seen;
  }

  group('watchStatus [INV-10, BR-003]', () {
    test(
      'no profile is incomplete, and a full one makes it complete',
      () async {
        final List<ProfileStatus> seen = await statuses(() async {
          backend.putProfile(uid, AccountProfileRepository.wireOf(fullProfile));
        });
        expect(seen, <ProfileStatus>[
          ProfileStatus.unknown,
          ProfileStatus.incomplete,
          ProfileStatus.complete,
        ]);
      },
    );

    test('a profile missing a configured field is incomplete', () async {
      backend.putProfile(uid, <String, Object?>{
        'full_name': 'Test Reader',
        'age_value': 30,
      });
      expect((await statuses(() async {})).last, ProfileStatus.incomplete);
    });

    test(
      'the configured set decides: with two fields, two values complete it',
      () async {
        backend.publicConfig!['profile_required_fields'] = <String>[
          'full_name',
          'age_value',
        ];
        backend.putProfile(uid, <String, Object?>{
          'full_name': 'Test Reader',
          'age_value': 30,
        });
        expect((await statuses(() async {})).last, ProfileStatus.complete);
      },
    );

    test('signed out is unknown', () async {
      await identity.signOut();
      expect(await statuses(() async {}), <ProfileStatus>[
        ProfileStatus.unknown,
      ]);
    });

    for (final (String name, Map<String, Object?>? config)
        in <(String, Map<String, Object?>?)>[
          ('missing', null),
          (
            'without the field list',
            <String, Object?>{'policy_versions': <String, Object?>{}},
          ),
          (
            'naming an unknown field',
            <String, Object?>{
              'profile_required_fields': <String>['shoe_size'],
            },
          ),
        ]) {
      test('a configuration $name fails closed, as an error [SC-03]', () async {
        backend.publicConfig = config;
        await expectLater(statuses(() async {}), throwsA(isA<StateError>()));
      });
    }
  });

  group('saveOwnProfile [OP-10]', () {
    test(
      'sends the given fields by their OP-10 names, with a request identifier',
      () async {
        await profiles.recordConsent(
          ConsentRecord(agreedTo: 'both', agreedAt: DateTime.utc(2026)),
        );
        final Result<ProfileSaveResult> result = await profiles.saveOwnProfile(
          fullProfile,
        );
        expect(
          (result as Ok<ProfileSaveResult>).value.status,
          ProfileStatus.complete,
        );
        final (String operation, Map<String, Object?> data) =
            backend.calls.single;
        expect(operation, 'saveProfile');
        expect(data['request_id'], 'request-1');
        expect(data['profile'], <String, Object?>{
          'full_name': 'Test Reader',
          'age_value': 30,
          'gender': 'Prefer not to say',
          'job_title': 'Tester',
          'industry_segment_id': 's1',
        });
      },
    );

    test('consent given in the session goes with the next save, with the current versions, once', () async {
      await profiles.recordConsent(
        ConsentRecord(agreedTo: 'both', agreedAt: DateTime.utc(2026)),
      );
      await profiles.saveOwnProfile(fullProfile);
      await profiles.saveOwnProfile(fullProfile);
      expect(backend.calls[0].$2['accepted_versions'], <String, Object?>{
        'privacy_policy': 'pp-test-1',
        'terms_of_use': 'tou-test-1',
      });
      expect(backend.calls[1].$2.containsKey('accepted_versions'), isFalse);
      expect(backend.consents[uid], isNotNull);
    });

    test('an incomplete reply names the missing fields', () async {
      await profiles.recordConsent(
        ConsentRecord(agreedTo: 'both', agreedAt: DateTime.utc(2026)),
      );
      final Result<ProfileSaveResult> result = await profiles.saveOwnProfile(
        const ReaderProfile(name: 'Test Reader'),
      );
      final ProfileSaveResult saved = (result as Ok<ProfileSaveResult>).value;
      expect(saved.status, ProfileStatus.incomplete);
      expect(saved.missingFields, contains('age_value'));
    });

    for (final (BackendCallError error, FailureCode code)
        in <(BackendCallError, FailureCode)>[
          (
            const BackendCallError(
              'INVALID_ARGUMENT',
              fields: <String>['age_value'],
            ),
            FailureCode.invalidInput,
          ),
          (
            const BackendCallError(
              'FAILED_PRECONDITION',
              reason: 'ACCOUNT_CLOSED',
            ),
            FailureCode.forbidden,
          ),
          (
            const BackendCallError('UNAVAILABLE'),
            FailureCode.serviceUnavailable,
          ),
        ]) {
      test(
        '${error.category}/${error.reason ?? '-'} is ${code.name}',
        () async {
          backend.failNext = error;
          final Result<ProfileSaveResult> result = await profiles
              .saveOwnProfile(fullProfile);
          expect((result as Err<ProfileSaveResult>).failure.code, code);
        },
      );
    }

    test('signed out, nothing is sent', () async {
      await identity.signOut();
      final Result<ProfileSaveResult> result = await profiles.saveOwnProfile(
        fullProfile,
      );
      expect(
        (result as Err<ProfileSaveResult>).failure.code,
        FailureCode.unauthenticated,
      );
      expect(backend.calls, isEmpty);
    });
  });

  group('loadForm and getOwnProfile', () {
    test('the form has the configured fields in a fixed order, the segments, and asks for consent first', () async {
      backend.publicConfig!['profile_required_fields'] = <String>[
        'job_title',
        'full_name',
      ];
      final ProfileFormSpec spec =
          (await profiles.loadForm() as Ok<ProfileFormSpec>).value;
      expect(spec.fields, <ProfileField>[
        ProfileField.fullName,
        ProfileField.jobTitle,
      ]);
      expect(
        spec.segments,
        isEmpty,
        reason: 'segments are read only when asked for',
      );
      expect(spec.current, isNull);
      expect(spec.needsConsent, isTrue);
    });

    test(
      'consent given in the session, or a saved profile, means no second ask',
      () async {
        await profiles.recordConsent(
          ConsentRecord(agreedTo: 'both', agreedAt: DateTime.utc(2026)),
        );
        expect(
          (await profiles.loadForm() as Ok<ProfileFormSpec>).value.needsConsent,
          isFalse,
        );

        final AccountProfileRepository fresh = AccountProfileRepository(
          identity,
          backend,
          backend,
        );
        backend.putProfile(uid, AccountProfileRepository.wireOf(fullProfile));
        final ProfileFormSpec spec =
            (await fresh.loadForm() as Ok<ProfileFormSpec>).value;
        expect(spec.needsConsent, isFalse);
        expect(spec.current?.name, 'Test Reader');
        expect(spec.current?.age, 30);
        expect(spec.segments, hasLength(2));
      },
    );

    test('a read that fails is a retryable failure', () async {
      backend.readError = StateError('offline');
      final Result<ProfileFormSpec> result = await profiles.loadForm();
      expect((result as Err<ProfileFormSpec>).failure.retryable, isTrue);
      expect(
        (await profiles.getOwnProfile() as Err<ReaderProfile?>).failure.code,
        FailureCode.serviceUnavailable,
      );
    });
  });

  group('SCR-A-05 complete profile [PAC-02]', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: CompleteProfileScreen(forms: profiles, profiles: profiles),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder field(String label) => find.widgetWithText(TextField, label);

    Future<void> choose(
      WidgetTester tester,
      String label,
      String option,
    ) async {
      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, label),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    Future<void> fillAll(WidgetTester tester, {String age = '30'}) async {
      await tester.enterText(field(AccountText.fullName), 'Test Reader');
      await tester.enterText(field(AccountText.age), age);
      await choose(tester, AccountText.gender, 'Prefer not to say');
      await tester.enterText(field(AccountText.occupation), 'Tester');
      await choose(tester, AccountText.domainOfWork, 'Segment one');
    }

    Future<void> save(WidgetTester tester) async {
      await tester.ensureVisible(find.text(AccountText.saveAndContinue));
      await tester.tap(find.text(AccountText.saveAndContinue));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the five configured fields and the consent action', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      for (final String label in <String>[
        AccountText.fullName,
        AccountText.age,
        AccountText.occupation,
      ]) {
        expect(field(label), findsOneWidget);
      }
      expect(find.text(AccountText.gender), findsOneWidget);
      expect(find.text(AccountText.domainOfWork), findsOneWidget);
      expect(find.text(AccountText.consent), findsOneWidget);
    });

    testWidgets('shows only the configured fields', (
      WidgetTester tester,
    ) async {
      backend.publicConfig!['profile_required_fields'] = <String>['full_name'];
      await pumpScreen(tester);
      expect(field(AccountText.fullName), findsOneWidget);
      expect(field(AccountText.age), findsNothing);
      expect(find.text(AccountText.domainOfWork), findsNothing);
    });

    testWidgets(
      'empty fields, a missing choice and no consent are each named, and nothing is sent',
      (WidgetTester tester) async {
        await pumpScreen(tester);
        await save(tester);
        for (final String error in <String>[
          AccountText.nameInvalid,
          AccountText.ageInvalid,
          AccountText.occupationInvalid,
          AccountText.consentMissing,
        ]) {
          expect(find.text(error), findsOneWidget, reason: error);
        }
        expect(find.text(AccountText.chooseOption), findsNWidgets(2));
        expect(backend.calls, isEmpty);
      },
    );

    for (final String age in <String>['0', '121', '30.5', 'thirty', '-4']) {
      testWidgets('an age of "$age" is refused', (WidgetTester tester) async {
        await pumpScreen(tester);
        await fillAll(tester, age: age);
        await save(tester);
        expect(find.text(AccountText.ageInvalid), findsOneWidget);
      });
    }

    testWidgets('an age of 1 is accepted: there is no age gate [FR-PROF-005]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      await fillAll(tester, age: '1');
      await tester.tap(find.text(AccountText.consent));
      await save(tester);
      expect(find.text(AccountText.ageInvalid), findsNothing);
      expect(
        (backend.calls.single.$2['profile']!
            as Map<String, Object?>)['age_value'],
        1,
      );
    });

    testWidgets(
      'a full form with consent saves once, with the consent versions',
      (WidgetTester tester) async {
        await pumpScreen(tester);
        await fillAll(tester);
        await tester.tap(find.text(AccountText.consent));
        await save(tester);
        expect(backend.calls, hasLength(1));
        expect(backend.calls.single.$2['accepted_versions'], isNotNull);
        expect(find.byType(AccountNotice), findsNothing);
        expect(backend.profiles[uid]?['full_name'], 'Test Reader');
      },
    );

    testWidgets('no segments yet says so on the field [OQ-13]', (
      WidgetTester tester,
    ) async {
      backend.segments = const <SegmentOption>[];
      await pumpScreen(tester);
      await save(tester);
      expect(find.text(AccountText.noSegments), findsOneWidget);
    });

    testWidgets('a form that cannot load offers Retry, which loads it', (
      WidgetTester tester,
    ) async {
      backend.readError = StateError('offline');
      await pumpScreen(tester);
      expect(find.text('Retry'), findsOneWidget);
      backend.readError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(field(AccountText.fullName), findsOneWidget);
    });
  });

  group('through the app [BR-003]', () {
    testWidgets(
      'a verified reader completes the profile and then opens the full issue',
      (WidgetTester tester) async {
        // One configured field, for brevity; the form follows the configuration.
        backend.publicConfig!['profile_required_fields'] = <String>[
          'full_name',
        ];
        final AccountAuthService auth = AccountAuthService(
          identity,
          profileStatus: profiles.watchStatus,
        );
        final GoRouter router = await pumpAppWithProfiles(
          tester,
          auth,
          profiles,
        );
        router.go('/issues/fx-iss-01/read');
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/complete-profile');

        await tester.enterText(
          find.widgetWithText(TextField, AccountText.fullName),
          'Test Reader',
        );
        await tester.tap(find.text(AccountText.consent));
        await tester.tap(find.text(AccountText.saveAndContinue));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/issues/fx-iss-01/read');
      },
    );
  });
}
