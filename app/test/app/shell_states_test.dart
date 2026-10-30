import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// An AuthService whose access state the test controls. The shell uses only
/// [watchAccessState].
final class ControlledAuthService implements AuthService {
  final StreamController<AccessState> states =
      StreamController<AccessState>.broadcast();
  int listens = 0;

  @override
  Stream<AccessState> watchAccessState() {
    listens++;
    return states.stream;
  }

  @override
  Stream<AuthSession?> watchSession() => throw UnimplementedError();

  @override
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<Result<void>> resendVerificationEmail() => throw UnimplementedError();

  @override
  Future<Result<void>> reloadVerificationStatus() => throw UnimplementedError();

  @override
  Future<Result<void>> sendPasswordReset(String email) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<Result<void>> deleteAccount() => throw UnimplementedError();
}

Widget appWith(AuthService auth) => ProviderScope(
  overrides: [authServiceProvider.overrideWithValue(auth)],
  child: const MfwApp(),
);

void main() {
  group('Navigation shell states [MOD-01]', () {
    testWidgets('loading until the access state is known, then the home '
        'screen [FR-STATE-001]', (WidgetTester tester) async {
      final ControlledAuthService auth = ControlledAuthService();

      await tester.pumpWidget(appWith(auth));
      await tester.pump();
      expect(find.text(ShellText.loading), findsOneWidget);

      auth.states.add(AccessState.signedOut);
      await tester.pumpAndSettle();
      expect(find.text(ShellText.home), findsOneWidget);
    });

    testWidgets('an access-state failure shows an error with Retry, and '
        'Retry asks again [FR-STATE-003]', (WidgetTester tester) async {
      final ControlledAuthService auth = ControlledAuthService();

      await tester.pumpWidget(appWith(auth));
      await tester.pump();
      auth.states.addError(StateError('synthetic failure'));
      await tester.pump();
      expect(find.text(ShellText.shellError), findsOneWidget);

      await tester.tap(find.text(ShellText.retry));
      await tester.pump();
      auth.states.add(AccessState.signedOut);
      await tester.pumpAndSettle();

      expect(auth.listens, 2);
      expect(find.text(ShellText.home), findsOneWidget);
    });

    testWidgets('the Retry control is at least 48 by 48 [OQ-25]', (
      WidgetTester tester,
    ) async {
      final ControlledAuthService auth = ControlledAuthService();

      await tester.pumpWidget(appWith(auth));
      await tester.pump();
      auth.states.addError(StateError('synthetic failure'));
      await tester.pump();

      final Size size = tester.getSize(
        find.widgetWithText(FilledButton, ShellText.retry),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
