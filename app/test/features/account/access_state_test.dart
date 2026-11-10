// MOD03-P2-T03: AccountAuthService.watchAccessState from the session and
// MOD-04's profile status, in the order of API_AND_MODULE_CONTRACTS section
// 4.1 (FR-AUTH-010, BR-002, BR-003, IC-01), and the guard on it.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../app/app_harness.dart';
import '../../fakes/test_users.dart';
import 'fake_identity_provider.dart';

/// A profile status source per session, as MOD-04's watchStatus is.
final class FakeProfileStatus {
  final Map<String, ProfileStatus> byEmail = <String, ProfileStatus>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int listeners = 0;
  int active = 0;
  Object? error;

  late FakeIdentityProvider identity;

  void set(String email, ProfileStatus status) {
    byEmail[email] = status;
    _changes.add(null);
  }

  Stream<ProfileStatus> watch() {
    late final StreamController<ProfileStatus> out;
    StreamSubscription<void>? sub;
    void emit() {
      if (error != null) {
        out.addError(error!);
        return;
      }
      final String? email = identity.currentUser?.email;
      out.add(byEmail[email] ?? ProfileStatus.unknown);
    }

    out = StreamController<ProfileStatus>(
      onListen: () {
        listeners++;
        active++;
        emit();
        sub = _changes.stream.listen((_) => emit());
      },
      onCancel: () async {
        active--;
        await sub?.cancel();
      },
    );
    return out.stream;
  }
}

void main() {
  late FakeIdentityProvider identity;
  late FakeProfileStatus profile;
  late AccountAuthService auth;
  late List<AccessState> seen;
  late StreamSubscription<AccessState> listening;
  late List<Object> errors;

  setUp(() {
    identity = FakeIdentityProvider();
    profile = FakeProfileStatus()..identity = identity;
    auth = AccountAuthService(identity, profileStatus: profile.watch);
    seen = <AccessState>[];
    errors = <Object>[];
    listening = auth.watchAccessState().listen(seen.add, onError: errors.add);
  });

  tearDown(() => listening.cancel());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('signed out is signedOut, and the profile is not read', () async {
    await settle();
    expect(seen, <AccessState>[AccessState.signedOut]);
    expect(profile.listeners, 0);
  });

  test(
    'an unverified session is emailUnverified, and the profile is not read',
    () async {
      identity.addAccount('reader@example.test', 'right-password');
      await auth.signInWithEmail(
        email: 'reader@example.test',
        password: 'right-password',
      );
      await settle();
      expect(seen.last, AccessState.emailUnverified);
      expect(profile.listeners, 0);
    },
  );

  test('a verified session waits for the profile, then follows it', () async {
    identity.addAccount(
      'reader@example.test',
      'right-password',
      verified: true,
    );
    await auth.signInWithEmail(
      email: 'reader@example.test',
      password: 'right-password',
    );
    await settle();
    expect(seen, <AccessState>[
      AccessState.signedOut,
    ], reason: 'unknown emits nothing');

    profile.set('reader@example.test', ProfileStatus.incomplete);
    await settle();
    expect(seen.last, AccessState.profileIncomplete);

    profile.set('reader@example.test', ProfileStatus.complete);
    await settle();
    expect(seen.last, AccessState.fullAccess);
  });

  test('signing out stops reading the profile', () async {
    identity.addAccount(
      'reader@example.test',
      'right-password',
      verified: true,
    );
    profile.set('reader@example.test', ProfileStatus.complete);
    await auth.signInWithEmail(
      email: 'reader@example.test',
      password: 'right-password',
    );
    await settle();
    expect(profile.active, 1);

    await auth.signOut();
    await settle();
    expect(seen.last, AccessState.signedOut);
    expect(profile.active, 0);
  });

  test('verifying the address moves on to the profile', () async {
    await auth.registerWithEmail(
      email: 'new@example.test',
      password: 'long-enough-1',
    );
    await settle();
    expect(seen.last, AccessState.emailUnverified);
    profile.set('new@example.test', ProfileStatus.incomplete);
    identity.verifyByEmailLink('new@example.test');
    await auth.reloadVerificationStatus();
    await settle();
    expect(seen.last, AccessState.profileIncomplete);
  });

  test('a profile that cannot be read is an error, which the shell shows with Retry', () async {
    identity.addAccount(
      'reader@example.test',
      'right-password',
      verified: true,
    );
    profile.error = StateError('offline');
    await auth.signInWithEmail(
      email: 'reader@example.test',
      password: 'right-password',
    );
    await settle();
    expect(errors, hasLength(1));
  });

  test(
    'without MOD-04 a verified reader counts as profileIncomplete',
    () async {
      final AccountAuthService alone = AccountAuthService(identity);
      identity.addAccount(
        'reader@example.test',
        'right-password',
        verified: true,
      );
      await alone.signInWithEmail(
        email: 'reader@example.test',
        password: 'right-password',
      );
      expect(
        await alone.watchAccessState().first,
        AccessState.profileIncomplete,
      );
    },
  );

  group('IC-01: the fixture readers get their documented state', () {
    for (final TestUser user in <TestUser>[
      fxUsr01,
      fxUsr02,
      fxUsr03,
      fxUsr04,
      fxUsr05,
    ]) {
      test('${user.fixtureId} is ${user.documentedAccessState.name}', () async {
        identity.addAccount(
          user.email,
          'right-password',
          verified: user.emailVerified,
        );
        profile.set(
          user.email,
          user.profileComplete
              ? ProfileStatus.complete
              : ProfileStatus.incomplete,
        );
        await auth.signInWithEmail(
          email: user.email,
          password: 'right-password',
        );
        await settle();
        expect(seen.last, user.documentedAccessState);
      });
    }
  });

  group('through the app', () {
    Finder titled(String title) =>
        find.descendant(of: find.byType(AppBar), matching: find.text(title));

    testWidgets('a reader with a complete profile opens the full issue', (
      WidgetTester tester,
    ) async {
      identity.addAccount(
        'reader@example.test',
        'right-password',
        verified: true,
      );
      profile.set('reader@example.test', ProfileStatus.complete);
      await auth.signInWithEmail(
        email: 'reader@example.test',
        password: 'right-password',
      );
      final GoRouter router = await pumpApp(tester, auth);
      router.go('/issues/fx-iss-01/read');
      await tester.pumpAndSettle();
      expect(titled(ShellText.reader), findsOneWidget);
    });

    testWidgets('a reader with an incomplete profile is sent to complete it', (
      WidgetTester tester,
    ) async {
      identity.addAccount(
        'reader@example.test',
        'right-password',
        verified: true,
      );
      profile.set('reader@example.test', ProfileStatus.incomplete);
      await auth.signInWithEmail(
        email: 'reader@example.test',
        password: 'right-password',
      );
      final GoRouter router = await pumpApp(tester, auth);
      router.go('/issues/fx-iss-01/read');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/complete-profile');
    });
  });
}
