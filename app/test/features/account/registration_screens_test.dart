// MOD03-P2-T01: SCR-A-02 and SCR-A-03 over AccountAuthService and the fake
// provider. Synthetic values only (DEC-024).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/features/account/account.dart';

import 'fake_identity_provider.dart';

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: buildMfwTheme(), home: screen));
  await tester.pump();
}

Finder field(String label) => find.widgetWithText(TextField, label);

void main() {
  late FakeIdentityProvider identity;
  late AccountAuthService auth;

  setUp(() {
    identity = FakeIdentityProvider();
    auth = AccountAuthService(identity);
  });

  group('SCR-A-02 register', () {
    late int signInTaps;

    Future<void> pumpRegister(WidgetTester tester) {
      signInTaps = 0;
      return pumpScreen(
        tester,
        RegisterScreen(auth: auth, onSignIn: () => signInTaps++),
      );
    }

    Future<void> fillAndSubmit(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      await tester.enterText(field(AccountText.email), email);
      await tester.enterText(field(AccountText.password), password);
      await tester.tap(find.text(AccountText.consent));
      await tester.tap(find.text(AccountText.registerButton));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the email and password fields, the hint and the links', (
      WidgetTester tester,
    ) async {
      await pumpRegister(tester);
      expect(find.text(AccountText.registerTitle), findsOneWidget);
      expect(field(AccountText.email), findsOneWidget);
      expect(field(AccountText.password), findsOneWidget);
      expect(find.text(AccountText.passwordHint), findsOneWidget);
      final TextField password = tester.widget(field(AccountText.password));
      expect(password.obscureText, isTrue);
    });

    testWidgets('a bad address and a short password are named, and nothing is '
        'sent', (WidgetTester tester) async {
      await pumpRegister(tester);
      await fillAndSubmit(tester, 'not-an-address', 'short');
      expect(find.text(AccountText.emailInvalid), findsOneWidget);
      expect(find.text(AccountText.passwordTooShort), findsOneWidget);
      expect(identity.calls, isEmpty);
    });

    testWidgets('a good registration creates the account and shows no notice', (
      WidgetTester tester,
    ) async {
      await pumpRegister(tester);
      await fillAndSubmit(tester, 'reader@example.test', 'long-enough-1');
      expect(identity.accounts.containsKey('reader@example.test'), isTrue);
      expect(find.byType(AccountNotice), findsNothing);
    });

    testWidgets('an address in use says so, at the top and on the field', (
      WidgetTester tester,
    ) async {
      identity.addAccount('reader@example.test', 'other-password');
      await pumpRegister(tester);
      await fillAndSubmit(tester, 'reader@example.test', 'long-enough-1');
      expect(find.text(AccountText.addressInUse), findsOneWidget);
      expect(find.text(AccountText.addressInUseField), findsOneWidget);
    });

    testWidgets('no network shows the network message', (
      WidgetTester tester,
    ) async {
      identity.failNext = 'network-request-failed';
      await pumpRegister(tester);
      await fillAndSubmit(tester, 'reader@example.test', 'long-enough-1');
      expect(
        find.text('No connection. Check your connection.'),
        findsOneWidget,
      );
    });

    testWidgets('while it runs the button shows progress and cannot be pressed '
        'again', (WidgetTester tester) async {
      identity.hold = Completer<void>();
      await pumpRegister(tester);
      await tester.enterText(field(AccountText.email), 'reader@example.test');
      await tester.enterText(field(AccountText.password), 'long-enough-1');
      await tester.tap(find.text(AccountText.consent));
      await tester.tap(find.text(AccountText.registerButton));
      await tester.pump();

      expect(find.bySemanticsLabel('Working'), findsOneWidget);
      final FilledButton button = tester.widget(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      identity.hold!.complete();
      identity.hold = null;
      await tester.pumpAndSettle();
      expect(
        identity.calls.where((String c) => c == 'createAccount'),
        hasLength(1),
      );
    });

    testWidgets('"Already registered? Sign in" opens sign-in', (
      WidgetTester tester,
    ) async {
      await pumpRegister(tester);
      await tester.tap(find.text(AccountText.toSignIn));
      expect(signInTaps, 1);
    });
  });

  group('SCR-A-03 verify email', () {
    setUp(() async {
      await auth.registerWithEmail(
        email: 'reader@example.test',
        password: 'long-enough-1',
      );
    });

    testWidgets('before the link is opened, the check says not yet', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, VerifyEmailScreen(auth: auth));
      expect(find.text(AccountText.verifyBody), findsOneWidget);
      await tester.tap(find.text(AccountText.verifiedButton));
      await tester.pumpAndSettle();
      expect(find.text(AccountText.notVerifiedYet), findsOneWidget);
    });

    testWidgets('after the link is opened, the check verifies the session', (
      WidgetTester tester,
    ) async {
      identity.verifyByEmailLink('reader@example.test');
      await pumpScreen(tester, VerifyEmailScreen(auth: auth));
      await tester.tap(find.text(AccountText.verifiedButton));
      await tester.pumpAndSettle();
      expect(find.text(AccountText.notVerifiedYet), findsNothing);
      expect((await auth.watchSession().first)?.emailVerified, isTrue);
    });

    testWidgets('sending the email again confirms it', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, VerifyEmailScreen(auth: auth));
      await tester.tap(find.text(AccountText.resend));
      await tester.pumpAndSettle();
      expect(find.text(AccountText.resent), findsOneWidget);
      expect(identity.verificationEmails, hasLength(2));
    });

    testWidgets('a failed resend shows the failure', (
      WidgetTester tester,
    ) async {
      identity.failNext = 'network-request-failed';
      await pumpScreen(tester, VerifyEmailScreen(auth: auth));
      await tester.tap(find.text(AccountText.resend));
      await tester.pumpAndSettle();
      expect(
        find.text('No connection. Check your connection.'),
        findsOneWidget,
      );
    });

    testWidgets('signing out ends the session', (WidgetTester tester) async {
      await pumpScreen(tester, VerifyEmailScreen(auth: auth));
      await tester.tap(find.text(AccountText.signOut));
      await tester.pumpAndSettle();
      expect(await auth.watchSession().first, isNull);
    });
  });
}
