// MOD03-P2-T02: sign-in, password reset and sign-out, in AccountAuthService,
// on SCR-A-01 and SCR-A-04, and through the router's guard (FR-AUTH-003,
// FR-AUTH-004, FR-AUTH-008, SEC-CHK-17, SC-21). Synthetic values only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../app/app_harness.dart';
import 'fake_identity_provider.dart';

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: buildMfwTheme(), home: screen));
  await tester.pump();
}

Finder field(String label) => find.widgetWithText(TextField, label);

Finder titled(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));

void main() {
  late FakeIdentityProvider identity;
  late AccountAuthService auth;

  setUp(() {
    identity = FakeIdentityProvider();
    auth = AccountAuthService(identity);
    identity.addAccount(
      'reader@example.test',
      'right-password',
      verified: true,
    );
  });

  FailureCode? codeOf(Result<void> result) =>
      result is Err<void> ? result.failure.code : null;

  group('signInWithEmail [FR-AUTH-003, SEC-CHK-17]', () {
    test('the right password signs in', () async {
      expect(
        await auth.signInWithEmail(
          email: ' reader@example.test ',
          password: 'right-password',
        ),
        isA<Ok<void>>(),
      );
      expect((await auth.watchSession().first)?.emailVerified, isTrue);
    });

    test('a wrong password, an unknown address and a disabled account all give '
        'the same failure', () async {
      identity.addAccount('closed@example.test', 'right-password').disabled =
          true;
      final List<Result<void>> results = <Result<void>>[
        await auth.signInWithEmail(
          email: 'reader@example.test',
          password: 'wrong-password',
        ),
        await auth.signInWithEmail(
          email: 'nobody@example.test',
          password: 'right-password',
        ),
        await auth.signInWithEmail(
          email: 'closed@example.test',
          password: 'right-password',
        ),
      ];
      expect(results.map(codeOf).toSet(), <FailureCode>{
        FailureCode.unauthenticated,
      });
      expect(await auth.watchSession().first, isNull);
    });

    test(
      'an empty password or a bad address is refused before the provider',
      () async {
        expect(
          codeOf(
            await auth.signInWithEmail(
              email: 'reader@example.test',
              password: '',
            ),
          ),
          FailureCode.invalidInput,
        );
        expect(
          codeOf(await auth.signInWithEmail(email: 'reader', password: 'x')),
          FailureCode.invalidInput,
        );
        expect(identity.calls, isEmpty);
      },
    );
  });

  group('sendPasswordReset [FR-AUTH-004, SC-21]', () {
    test('a known and an unknown address get the same outcome', () async {
      expect(
        await auth.sendPasswordReset('reader@example.test'),
        isA<Ok<void>>(),
      );
      expect(
        await auth.sendPasswordReset('nobody@example.test'),
        isA<Ok<void>>(),
      );
      expect(identity.passwordResets, <String>['reader@example.test']);
    });

    test(
      'no network is still reported, because it is not about the account',
      () async {
        identity.failNext = 'network-request-failed';
        expect(
          codeOf(await auth.sendPasswordReset('reader@example.test')),
          FailureCode.network,
        );
      },
    );
  });

  group('SCR-A-01 sign in', () {
    late int registerTaps;
    late int resetTaps;

    Future<void> pumpSignIn(WidgetTester tester) {
      registerTaps = 0;
      resetTaps = 0;
      return pumpScreen(
        tester,
        SignInScreen(
          auth: auth,
          onRegister: () => registerTaps++,
          onForgotPassword: () => resetTaps++,
        ),
      );
    }

    Future<void> signIn(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      await tester.enterText(field(AccountText.email), email);
      await tester.enterText(field(AccountText.password), password);
      await tester.tap(
        find.widgetWithText(FilledButton, AccountText.signInButton),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a wrong password shows one message and clears the password', (
      WidgetTester tester,
    ) async {
      await pumpSignIn(tester);
      await signIn(tester, 'reader@example.test', 'wrong-password');
      expect(find.text(AccountText.wrongCredentials), findsOneWidget);
      final TextField password = tester.widget(field(AccountText.password));
      expect(password.controller!.text, isEmpty);
    });

    testWidgets('an unknown address shows the very same message', (
      WidgetTester tester,
    ) async {
      await pumpSignIn(tester);
      await signIn(tester, 'nobody@example.test', 'right-password');
      expect(find.text(AccountText.wrongCredentials), findsOneWidget);
    });

    testWidgets('no network offers Retry', (WidgetTester tester) async {
      identity.failNext = 'network-request-failed';
      await pumpSignIn(tester);
      await signIn(tester, 'reader@example.test', 'right-password');
      expect(
        find.text('No connection. Check your connection.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('empty fields are named and nothing is sent', (
      WidgetTester tester,
    ) async {
      await pumpSignIn(tester);
      await tester.tap(
        find.widgetWithText(FilledButton, AccountText.signInButton),
      );
      await tester.pumpAndSettle();
      expect(find.text(AccountText.emailInvalid), findsOneWidget);
      expect(find.text(AccountText.passwordMissing), findsOneWidget);
      expect(identity.calls, isEmpty);
    });

    testWidgets('the right password signs in', (WidgetTester tester) async {
      await pumpSignIn(tester);
      await signIn(tester, 'reader@example.test', 'right-password');
      expect(find.byType(AccountNotice), findsNothing);
      expect(await auth.watchSession().first, isNotNull);
    });

    testWidgets('the links open the reset and registration', (
      WidgetTester tester,
    ) async {
      await pumpSignIn(tester);
      await tester.tap(find.text(AccountText.forgotPassword));
      await tester.tap(find.text(AccountText.toRegister));
      expect((resetTaps, registerTaps), (1, 1));
      expect(find.textContaining('Google'), findsNothing);
    });
  });

  group('SCR-A-04 password reset', () {
    for (final String email in <String>[
      'reader@example.test',
      'nobody@example.test',
    ]) {
      testWidgets('$email gets the same confirmation', (
        WidgetTester tester,
      ) async {
        await pumpScreen(
          tester,
          PasswordResetScreen(auth: auth, onBackToSignIn: () {}),
        );
        await tester.enterText(field(AccountText.email), email);
        await tester.tap(find.text(AccountText.resetButton));
        await tester.pumpAndSettle();
        expect(find.text(AccountText.resetSent), findsOneWidget);
        expect(find.text(AccountText.resetAgainButton), findsOneWidget);
      });
    }

    testWidgets('a bad address is named and nothing is sent', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PasswordResetScreen(auth: auth, onBackToSignIn: () {}),
      );
      await tester.enterText(field(AccountText.email), 'reader');
      await tester.tap(find.text(AccountText.resetButton));
      await tester.pumpAndSettle();
      expect(find.text(AccountText.emailInvalid), findsOneWidget);
      expect(identity.calls, isEmpty);
    });
  });

  group('through the app', () {
    testWidgets(
      'a visitor opening a full issue signs in on SCR-A-01, and after '
      'sign-out is asked again [FR-AUTH-008]',
      (WidgetTester tester) async {
        final GoRouter router = await pumpApp(tester, auth);
        router.go('/issues/fx-iss-01/read');
        await tester.pumpAndSettle();
        expect(titled(AccountText.signInTitle), findsOneWidget);

        await tester.enterText(field(AccountText.email), 'reader@example.test');
        await tester.enterText(field(AccountText.password), 'right-password');
        await tester.tap(
          find.widgetWithText(FilledButton, AccountText.signInButton),
        );
        await tester.pumpAndSettle();
        expect(titled(AccountText.signInTitle), findsNothing);

        await auth.signOut();
        await tester.pumpAndSettle();
        router.go('/issues/fx-iss-01/read');
        await tester.pumpAndSettle();
        expect(titled(AccountText.signInTitle), findsOneWidget);
      },
    );

    testWidgets('sign-in, reset and registration link to each other and keep '
        'where the reader was going', (WidgetTester tester) async {
      final GoRouter router = await pumpApp(tester, auth);
      router.go('/sign-in?from=/library');
      await tester.pumpAndSettle();

      await tester.tap(find.text(AccountText.forgotPassword));
      await tester.pumpAndSettle();
      expect(titled(AccountText.resetTitle), findsOneWidget);
      expect(router.state.uri.toString(), '/reset-password?from=%2Flibrary');

      await tester.tap(find.text(AccountText.backToSignIn));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountText.toRegister));
      await tester.pumpAndSettle();
      expect(titled(AccountText.registerTitle), findsOneWidget);
      expect(router.state.uri.queryParameters['from'], '/library');
      expect(find.text(ShellText.placeholderBody), findsNothing);
    });
  });
}
