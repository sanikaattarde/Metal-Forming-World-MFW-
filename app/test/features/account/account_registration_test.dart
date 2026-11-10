// MOD03-P2-T01: registration and verification in AccountAuthService, and
// the provider and backend error mappings (FR-AUTH-001, FR-AUTH-002,
// SEC-CHK-17). Synthetic values only (DEC-024).
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import 'fake_identity_provider.dart';

void main() {
  late FakeIdentityProvider identity;
  late AccountAuthService auth;

  setUp(() {
    identity = FakeIdentityProvider();
    auth = AccountAuthService(identity);
  });

  FailureCode? codeOf(Result<void> result) =>
      result is Err<void> ? result.failure.code : null;

  group('registerWithEmail [FR-AUTH-001]', () {
    test(
      'creates the account, signs it in unverified and sends the email',
      () async {
        final Result<void> result = await auth.registerWithEmail(
          email: '  reader@example.test ',
          password: 'long-enough-1',
        );

        expect(result, isA<Ok<void>>());
        expect(identity.accounts.keys, <String>['reader@example.test']);
        expect(identity.verificationEmails, <String>['reader@example.test']);
        final AuthSession? session = await auth.watchSession().first;
        expect(session?.emailVerified, isFalse);
        expect(session?.method, SignInMethod.email);
        expect(
          await auth.watchAccessState().first,
          AccessState.emailUnverified,
        );
      },
    );

    test('an address already in use is a conflict', () async {
      identity.addAccount('reader@example.test', 'other-password');
      final Result<void> result = await auth.registerWithEmail(
        email: 'reader@example.test',
        password: 'long-enough-1',
      );
      expect(codeOf(result), FailureCode.conflict);
    });

    for (final (String email, String password) in <(String, String)>[
      ('not-an-address', 'long-enough-1'),
      ('reader@example', 'long-enough-1'),
      ('reader@example.test', 'short'),
      ('reader@example.test', '1234567'),
    ]) {
      test('"$email" with a ${password.length}-character password is refused '
          'before the provider is called', () async {
        final Result<void> result = await auth.registerWithEmail(
          email: email,
          password: password,
        );
        expect(codeOf(result), FailureCode.invalidInput);
        expect(identity.calls, isEmpty);
      });
    }

    test('no network is a retryable network failure', () async {
      identity.failNext = 'network-request-failed';
      final Result<void> result = await auth.registerWithEmail(
        email: 'reader@example.test',
        password: 'long-enough-1',
      );
      final AppFailure failure = (result as Err<void>).failure;
      expect(failure.code, FailureCode.network);
      expect(failure.retryable, isTrue);
    });

    test('a verification email that fails to send still registers, and can be '
        'sent again', () async {
      identity.hold = null;
      final Result<void> first = await auth.registerWithEmail(
        email: 'reader@example.test',
        password: 'long-enough-1',
      );
      expect(first, isA<Ok<void>>());
      // The next call, the resend, fails once and then works.
      identity.failNext = 'too-many-requests';
      expect(
        codeOf(await auth.resendVerificationEmail()),
        FailureCode.serviceUnavailable,
      );
      expect(await auth.resendVerificationEmail(), isA<Ok<void>>());
      expect(identity.verificationEmails, hasLength(2));
    });
  });

  group('verification [FR-AUTH-002, BR-002]', () {
    test('resending needs a signed-in account', () async {
      expect(
        codeOf(await auth.resendVerificationEmail()),
        FailureCode.unauthenticated,
      );
      expect(
        codeOf(await auth.reloadVerificationStatus()),
        FailureCode.unauthenticated,
      );
    });

    test('the session sees a verification only after reloading', () async {
      await auth.registerWithEmail(
        email: 'reader@example.test',
        password: 'long-enough-1',
      );
      identity.verifyByEmailLink('reader@example.test');
      expect((await auth.watchSession().first)?.emailVerified, isFalse);

      expect(await auth.reloadVerificationStatus(), isA<Ok<void>>());

      expect((await auth.watchSession().first)?.emailVerified, isTrue);
      expect(
        await auth.watchAccessState().first,
        isNot(AccessState.emailUnverified),
      );
    });

    test('signing out ends the session', () async {
      await auth.registerWithEmail(
        email: 'reader@example.test',
        password: 'long-enough-1',
      );
      await auth.signOut();
      expect(await auth.watchSession().first, isNull);
      expect(await auth.watchAccessState().first, AccessState.signedOut);
    });
  });

  group('identityFailure: provider codes', () {
    for (final (String code, FailureCode expected) in <(String, FailureCode)>[
      ('email-already-in-use', FailureCode.conflict),
      ('invalid-email', FailureCode.invalidInput),
      ('weak-password', FailureCode.invalidInput),
      ('invalid-credential', FailureCode.unauthenticated),
      ('wrong-password', FailureCode.unauthenticated),
      ('user-not-found', FailureCode.unauthenticated),
      ('user-disabled', FailureCode.unauthenticated),
      ('requires-recent-login', FailureCode.unauthenticated),
      ('network-request-failed', FailureCode.network),
      ('too-many-requests', FailureCode.serviceUnavailable),
      ('something-new', FailureCode.unknown),
    ]) {
      test('$code is ${expected.name}', () {
        final AppFailure failure = AccountAuthService.identityFailure(
          IdentityError(code),
        );
        expect(failure.code, expected);
        expect(failure.detail, isNot(contains('@')));
      });
    }

    test('an unknown code is not copied into the detail', () {
      expect(
        AccountAuthService.identityFailure(
          const IdentityError('reader@example.test'),
        ).detail,
        'identity other',
      );
    });
  });

  group('FirebaseBackendCalls.backendErrorOf: callable errors', () {
    for (final (String code, Object? details, String category, String? reason)
        in <(String, Object?, String, String?)>[
          ('unauthenticated', null, 'UNAUTHENTICATED', null),
          ('permission-denied', null, 'FORBIDDEN', null),
          (
            'failed-precondition',
            <String, Object?>{'reason': 'EMAIL_NOT_VERIFIED'},
            'FAILED_PRECONDITION',
            'EMAIL_NOT_VERIFIED',
          ),
          ('not-found', <String, Object?>{'reason': 'GONE'}, 'GONE', 'GONE'),
          ('not-found', null, 'NOT_FOUND', null),
          (
            'aborted',
            <String, Object?>{'reason': 'STALE_RECORD'},
            'CONFLICT',
            'STALE_RECORD',
          ),
          ('resource-exhausted', null, 'RATE_LIMITED', null),
          ('unavailable', null, 'UNAVAILABLE', null),
          ('deadline-exceeded', null, 'UNAVAILABLE', 'DEADLINE_EXCEEDED'),
          ('internal', 'some text', 'INTERNAL', null),
          ('cancelled', null, 'UNKNOWN', null),
        ]) {
      test('$code ${details ?? ''} is $category/${reason ?? '-'}', () {
        final BackendCallError error = FirebaseBackendCalls.backendErrorOf(
          code,
          details,
        );
        expect(error.category, category);
        expect(error.reason, reason);
      });
    }

    test('the named fields are kept, and nothing else from the details', () {
      final BackendCallError error = FirebaseBackendCalls.backendErrorOf(
        'invalid-argument',
        <String, Object?>{
          'fields': <Object?>['age_value', 3, 'full_name'],
          'value': 'Private Name',
        },
      );
      expect(error.category, 'INVALID_ARGUMENT');
      expect(error.fields, <String>['age_value', 'full_name']);
      expect(error.toString(), isNot(contains('Private')));
    });
  });

  test('request identifiers are 32 hexadecimal characters and differ', () {
    final String one = newRequestId();
    expect(one, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(newRequestId(), isNot(one));
  });
}
