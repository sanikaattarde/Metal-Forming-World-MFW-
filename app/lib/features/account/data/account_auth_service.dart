import 'dart:async';

import '../../../contracts/contracts.dart';
import '../domain/account_rules.dart';
import '../domain/identity_provider.dart';

/// MOD-03's `AuthService` over an [IdentityProvider] (IC-01): registration
/// and email verification (MOD03-P2-T01).
///
/// Failures follow the contract: `invalidInput`, `conflict` for an address
/// already in use, `unauthenticated`, `network` and `serviceUnavailable`.
/// No provider message, address or password is kept in a failure.
final class AccountAuthService implements AuthService {
  /// Creates the service over [identity].
  AccountAuthService(this._identity);

  final IdentityProvider _identity;

  static const Err<void> _notYet = Err<void>(
    AppFailure(FailureCode.serviceUnavailable),
  );

  @override
  Stream<AuthSession?> watchSession() =>
      _identity.userChanges().map(sessionOf).distinct(_sameSession);

  /// The session for [user], or null when signed out.
  static AuthSession? sessionOf(IdentityUser? user) => user == null
      ? null
      : AuthSession(
          userId: user.uid,
          method: user.method,
          emailVerified: user.emailVerified,
        );

  static bool _sameSession(AuthSession? a, AuthSession? b) =>
      a?.userId == b?.userId &&
      a?.emailVerified == b?.emailVerified &&
      a?.method == b?.method;

  @override
  Stream<AccessState> watchAccessState() => watchSession().map(
    (AuthSession? session) => switch (session) {
      null => AccessState.signedOut,
      AuthSession(emailVerified: false) => AccessState.emailUnverified,
      _ => AccessState.profileIncomplete,
    },
  );

  @override
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (!AccountRules.isEmail(email) ||
        !AccountRules.isPasswordLongEnough(password)) {
      return const Err<void>(AppFailure(FailureCode.invalidInput));
    }
    try {
      await _identity.createAccount(email: email.trim(), password: password);
    } on IdentityError catch (error) {
      return Err<void>(identityFailure(error));
    }
    // The account exists now. A verification email that fails to send can
    // be sent again from SCR-A-03, so registration still succeeds.
    try {
      await _identity.sendVerificationEmail();
    } on IdentityError {
      // Left to "Send the email again".
    }
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> resendVerificationEmail() =>
      _signedIn(_identity.sendVerificationEmail);

  @override
  Future<Result<void>> reloadVerificationStatus() =>
      _signedIn(_identity.reloadUser);

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) async => _notYet;

  /// Google Sign-In waits for DEC-006 (PROVISIONAL, C-04; MOD03-P3-T02).
  @override
  Future<Result<void>> signInWithGoogle() async => _notYet;

  @override
  Future<Result<void>> sendPasswordReset(String email) async => _notYet;

  @override
  Future<void> signOut() async {
    try {
      await _identity.signOut();
    } on IdentityError {
      // The plugin clears the local session even when it reports an error.
    }
  }

  @override
  Future<Result<void>> reauthenticateWithEmail({
    required String password,
  }) async => _notYet;

  /// Google Sign-In waits for DEC-006 (PROVISIONAL, C-04).
  @override
  Future<Result<void>> reauthenticateWithGoogle() async => _notYet;

  @override
  Future<Result<void>> deleteAccount() async => _notYet;

  Future<Result<void>> _signedIn(Future<void> Function() action) async {
    if (_identity.currentUser == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    try {
      await action();
      return const Ok<void>(null);
    } on IdentityError catch (error) {
      return Err<void>(identityFailure(error));
    }
  }

  /// The failure for a provider [error]. The codes are Firebase
  /// Authentication's; any other is `unknown`. Wrong credentials of any
  /// kind are one `unauthenticated`, so the reader cannot tell which part
  /// was wrong or whether the address has an account (SEC-CHK-17).
  static AppFailure identityFailure(IdentityError error) =>
      switch (error.code) {
        'email-already-in-use' => AppFailure(
          FailureCode.conflict,
          detail: 'identity ${error.code}',
        ),
        'invalid-email' || 'weak-password' || 'missing-password' => AppFailure(
          FailureCode.invalidInput,
          detail: 'identity ${error.code}',
        ),
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'user-disabled' ||
        'user-mismatch' ||
        'user-token-expired' ||
        'requires-recent-login' ||
        'no-current-user' => AppFailure(
          FailureCode.unauthenticated,
          detail: 'identity ${error.code}',
        ),
        'network-request-failed' => AppFailure(
          FailureCode.network,
          retryable: true,
          detail: 'identity ${error.code}',
        ),
        'too-many-requests' ||
        'quota-exceeded' ||
        'internal-error' => AppFailure(
          FailureCode.serviceUnavailable,
          retryable: true,
          detail: 'identity ${error.code}',
        ),
        _ => const AppFailure(FailureCode.unknown, detail: 'identity other'),
      };
}
