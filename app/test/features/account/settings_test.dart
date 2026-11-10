// MOD04-P2-T04: SCR-A-07, settings, for a signed-in reader and a visitor,
// and its entries. Synthetic values only (DEC-024).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/access_guard.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../app/app_harness.dart';
import 'fake_identity_provider.dart';
import 'fake_link_opener.dart';

void main() {
  late FakeIdentityProvider identity;
  late AccountAuthService auth;
  late FakeLinkOpener links;
  late List<String> opened;

  setUp(() {
    identity = FakeIdentityProvider();
    auth = AccountAuthService(identity);
    links = FakeLinkOpener();
    opened = <String>[];
    identity.addAccount(
      'reader@example.test',
      'right-password',
      verified: true,
    );
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    Widget? notifications,
    Widget? readerMode,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: SettingsScreen(
          auth: auth,
          links: links,
          privacyPolicy: Uri.parse('https://example.test/privacy'),
          termsOfUse: Uri.parse('https://example.test/terms'),
          onOpenProfile: () => opened.add('profile'),
          onSignIn: () => opened.add('sign-in'),
          onDeleteAccount: () => opened.add('delete'),
          notifications: notifications,
          readerMode: readerMode,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a signed-in reader has the profile, sign-out and deletion', (
    WidgetTester tester,
  ) async {
    await identity.signIn(
      email: 'reader@example.test',
      password: 'right-password',
    );
    await pumpSettings(tester);
    expect(find.text(AccountText.signInOrRegister), findsNothing);
    await tester.tap(find.text(AccountText.yourProfile));
    await tester.tap(find.text(AccountText.deleteAccount));
    expect(opened, <String>['profile', 'delete']);
  });

  testWidgets(
    'sign-out signs out, and the screen turns to the visitor view [FR-AUTH-008]',
    (WidgetTester tester) async {
      await identity.signIn(
        email: 'reader@example.test',
        password: 'right-password',
      );
      await pumpSettings(tester);
      await tester.tap(find.text(AccountText.signOut));
      await tester.pumpAndSettle();
      expect(identity.currentUser, isNull);
      expect(find.text(AccountText.signInOrRegister), findsOneWidget);
      expect(find.text(AccountText.deleteAccount), findsNothing);
    },
  );

  testWidgets('a visitor is offered sign-in, and no account entries', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester);
    expect(find.text(AccountText.yourProfile), findsNothing);
    expect(find.text(AccountText.signOut), findsNothing);
    await tester.tap(find.text(AccountText.signInOrRegister));
    expect(opened, <String>['sign-in']);
  });

  testWidgets('the policy and terms open the CFG-07 addresses [FR-PRIV-002]', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester);
    await tester.tap(find.text(AccountText.privacyPolicy));
    await tester.tap(find.text(AccountText.termsOfUse));
    await tester.pumpAndSettle();
    expect(links.opened.map((Uri u) => u.path), <String>['/privacy', '/terms']);
  });

  testWidgets('a page that cannot open says so', (WidgetTester tester) async {
    links.works = false;
    await pumpSettings(tester);
    await tester.tap(find.text(AccountText.privacyPolicy));
    await tester.pumpAndSettle();
    expect(find.text(AccountText.linkFailed), findsOneWidget);
  });

  testWidgets('the licences open the licence page', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester);
    await tester.tap(find.text(AccountText.licences));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets(
    'the notification and reader-mode slots show what the shell gives',
    (WidgetTester tester) async {
      await pumpSettings(
        tester,
        notifications: const Text('Notification choices'),
        readerMode: const Text('Reader mode'),
      );
      expect(find.text('Notification choices'), findsOneWidget);
      expect(find.text('Reader mode'), findsOneWidget);
    },
  );

  test('the deletion page needs a session, and sends a visitor home', () {
    expect(
      redirectFor(AccessState.signedOut, Uri.parse('/settings/delete-account')),
      '/',
    );
    expect(
      redirectFor(
        AccessState.profileIncomplete,
        Uri.parse('/settings/delete-account'),
      ),
      isNull,
    );
  });

  testWidgets(
    'through the app, settings opens the profile and the deletion page',
    (WidgetTester tester) async {
      await identity.signIn(
        email: 'reader@example.test',
        password: 'right-password',
      );
      final GoRouter router = await pumpApp(tester, auth);
      router.go('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountText.deleteAccount));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/settings/delete-account');
    },
  );
}
