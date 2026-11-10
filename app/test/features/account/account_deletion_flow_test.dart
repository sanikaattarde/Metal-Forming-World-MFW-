// MOD03-P4-T01: in-app account deletion through OP-12, the local clean-up
// and sign-out, and SCR-A-08 (FR-AUTH-009, FR-PRIV-003, FR-PRIV-004, IC-08,
// AC-3.7, PAC-06). PROVISIONAL (DEC-029, OQ-24). Synthetic values only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../app/app_harness.dart';
import 'fake_identity_provider.dart';

/// OP-12 as the backend answers it, scripted one call at a time.
final class FakeDeletionBackend implements BackendCalls {
  final List<(String, Map<String, Object?>)> calls =
      <(String, Map<String, Object?>)>[];
  final List<BackendCallError?> script = <BackendCallError?>[];

  @override
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  ) async {
    calls.add((operation, data));
    final BackendCallError? error = script.isEmpty ? null : script.removeAt(0);
    if (error != null) {
      throw error;
    }
    return <String, Object?>{'state': 'deleted'};
  }
}

const BackendCallError recentSignIn = BackendCallError(
  'FAILED_PRECONDITION',
  reason: 'RECENT_SIGN_IN_REQUIRED',
);

void main() {
  late FakeIdentityProvider identity;
  late FakeDeletionBackend backend;
  late AccountAuthService auth;
  late List<String> cleared;
  late String uid;

  setUp(() async {
    identity = FakeIdentityProvider();
    backend = FakeDeletionBackend();
    auth = AccountAuthService(
      identity,
      backend: backend,
      requestIds: () => 'request-1',
    );
    cleared = <String>[];
    auth.addDeletionHook((String userId) async => cleared.add(userId));
    uid = identity
        .addAccount('reader@example.test', 'right-password', verified: true)
        .uid;
    await identity.signIn(
      email: 'reader@example.test',
      password: 'right-password',
    );
  });

  FailureCode? codeOf(Result<void> result) =>
      result is Err<void> ? result.failure.code : null;

  group('deleteAccount [OP-12]', () {
    test('asks OP-12 with the confirmation, clears the local data, then signs out [IC-08]', () async {
      expect(await auth.deleteAccount(), isA<Ok<void>>());
      expect(backend.calls.single.$1, 'requestAccountDeletion');
      expect(backend.calls.single.$2, <String, Object?>{
        'request_id': 'request-1',
        'confirm': true,
      });
      expect(cleared, <String>[uid]);
      expect(identity.currentUser, isNull);
      expect(identity.calls.last, 'signOut');
    });

    test('a clean-up that fails still signs the reader out', () async {
      auth.addDeletionHook((String userId) async => throw StateError('disk'));
      expect(await auth.deleteAccount(), isA<Ok<void>>());
      expect(identity.currentUser, isNull);
    });

    for (final (BackendCallError error, FailureCode code)
        in <(BackendCallError, FailureCode)>[
          (recentSignIn, FailureCode.unauthenticated),
          (
            const BackendCallError('FAILED_PRECONDITION', reason: 'LAST_ADMIN'),
            FailureCode.conflict,
          ),
          (
            const BackendCallError(
              'FAILED_PRECONDITION',
              reason: 'ALREADY_DELETING',
            ),
            FailureCode.forbidden,
          ),
          (
            const BackendCallError('UNAVAILABLE'),
            FailureCode.serviceUnavailable,
          ),
        ]) {
      test(
        '${error.reason ?? error.category} is ${code.name}, and nothing local changes',
        () async {
          backend.script.add(error);
          expect(codeOf(await auth.deleteAccount()), code);
          expect(cleared, isEmpty);
          expect(identity.currentUser, isNotNull);
        },
      );
    }

    test('signed out, nothing is sent', () async {
      await auth.signOut();
      expect(codeOf(await auth.deleteAccount()), FailureCode.unauthenticated);
      expect(backend.calls, isEmpty);
    });

    test('without the backend, deletion is unavailable', () async {
      final AccountAuthService alone = AccountAuthService(identity);
      expect(
        codeOf(await alone.deleteAccount()),
        FailureCode.serviceUnavailable,
      );
    });
  });

  group('reauthenticateWithEmail [R-4 d]', () {
    test(
      'the right password confirms; a wrong or empty one does not',
      () async {
        expect(
          await auth.reauthenticateWithEmail(password: 'right-password'),
          isA<Ok<void>>(),
        );
        expect(
          codeOf(
            await auth.reauthenticateWithEmail(password: 'wrong-password'),
          ),
          FailureCode.unauthenticated,
        );
        expect(
          codeOf(await auth.reauthenticateWithEmail(password: '')),
          FailureCode.invalidInput,
        );
      },
    );

    test('signed out, it is refused', () async {
      await auth.signOut();
      expect(
        codeOf(await auth.reauthenticateWithEmail(password: 'right-password')),
        FailureCode.unauthenticated,
      );
    });
  });

  group('SCR-A-08 delete account', () {
    late int keeps;

    Future<void> pumpScreen(WidgetTester tester) async {
      keeps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: DeleteAccountScreen(auth: auth, onKeep: () => keeps++),
        ),
      );
      await tester.pump();
    }

    Future<void> tapDelete(WidgetTester tester, String label) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'says what goes, keeps the account by default, and deletes only on the outlined button',
      (WidgetTester tester) async {
        await pumpScreen(tester);
        expect(find.text(AccountText.deleteBody), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, AccountText.keepAccount),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(OutlinedButton, AccountText.deleteMyAccount),
          findsOneWidget,
        );
        await tester.tap(find.text(AccountText.keepAccount));
        expect(keeps, 1);
        expect(backend.calls, isEmpty);
      },
    );

    testWidgets('deleting deletes and signs out [AC-3.7]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      await tapDelete(tester, AccountText.deleteMyAccount);
      expect(backend.calls, hasLength(1));
      expect(identity.currentUser, isNull);
    });

    testWidgets(
      'when a recent sign-in is needed, the password is asked, and a wrong one is refused',
      (WidgetTester tester) async {
        backend.script.add(recentSignIn);
        await pumpScreen(tester);
        await tapDelete(tester, AccountText.deleteMyAccount);
        expect(find.text(AccountText.reauthNeeded), findsOneWidget);
        expect(
          find.widgetWithText(TextField, AccountText.password),
          findsOneWidget,
        );

        await tester.enterText(
          find.widgetWithText(TextField, AccountText.password),
          'wrong-password',
        );
        await tapDelete(tester, AccountText.confirmAndDelete);
        expect(find.text(AccountText.wrongCredentials), findsOneWidget);
        expect(backend.calls, hasLength(1));

        await tester.enterText(
          find.widgetWithText(TextField, AccountText.password),
          'right-password',
        );
        await tapDelete(tester, AccountText.confirmAndDelete);
        expect(backend.calls, hasLength(2));
        expect(identity.currentUser, isNull);
      },
    );

    testWidgets('the last admin is told why, and the account stays', (
      WidgetTester tester,
    ) async {
      backend.script.add(
        const BackendCallError('FAILED_PRECONDITION', reason: 'LAST_ADMIN'),
      );
      await pumpScreen(tester);
      await tapDelete(tester, AccountText.deleteMyAccount);
      expect(find.text(AccountText.lastAdmin), findsOneWidget);
      expect(identity.currentUser, isNotNull);
    });

    testWidgets('a deletion already running says so', (
      WidgetTester tester,
    ) async {
      backend.script.add(
        const BackendCallError(
          'FAILED_PRECONDITION',
          reason: 'ALREADY_DELETING',
        ),
      );
      await pumpScreen(tester);
      await tapDelete(tester, AccountText.deleteMyAccount);
      expect(find.text(AccountText.alreadyDeleting), findsOneWidget);
    });
  });

  testWidgets(
    'through the app: settings, delete, and the reader is a visitor at home [PAC-06]',
    (WidgetTester tester) async {
      final GoRouter router = await pumpApp(tester, auth);
      router.go('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountText.deleteAccount));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountText.deleteMyAccount));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/');
      expect(cleared, <String>[uid]);
      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.text(AccountText.signInOrRegister), findsOneWidget);
    },
  );
}
