import 'dart:async';

import '../../../contracts/contracts.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/backend_calls.dart';
import '../domain/account_rules.dart';
import '../domain/identity_provider.dart';

/// MOD-03's `AuthService` over an [IdentityProvider] (IC-01): registration
/// and email verification (MOD03-P2-T01); sign-in, password reset and
/// sign-out (MOD03-P2-T02); the access state (MOD03-P2-T03); account
/// deletion and re-authentication (MOD03-P4-T01).
///
/// Failures follow the contract: `invalidInput`, `conflict` for an address
/// already in use, `unauthenticated`, `network` and `serviceUnavailable`.
/// No provider message, address or password is kept in a failure.
final class AccountAuthService implements AuthService {
  /// Creates the service over [identity]. [profileStatus] is MOD-04's
  /// `ProfileRepository.watchStatus`; without it a verified reader counts
  /// as `profileIncomplete`, so nothing opens that should not.
  ///
  /// [backend] carries OP-12; without it deletion is unavailable.
  AccountAuthService(
    this._identity, {
    this._profileStatus,
    this._backend,
    String Function()? requestIds,
  }) : _requestIds = requestIds ?? newRequestId;

  final IdentityProvider _identity;
  final Stream<ProfileStatus> Function()? _profileStatus;
  final BackendCalls? _backend;
  final String Function() _requestIds;
  final List<Future<void> Function(String userId)> _deletionHooks =
      <Future<void> Function(String userId)>[];

  /// Registers [hook] to clear a module's local data for a deleted account,
  /// such as MOD-06's kept copies (IC-08, FR-AUTH-009). Hooks run after
  /// the server has accepted the deletion and before the local sign-out.
  void addDeletionHook(Future<void> Function(String userId) hook) =>
      _deletionHooks.add(hook);

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

  /// The access state of `API_AND_MODULE_CONTRACTS.md` section 4.1, in its
  /// order: signed out, then an unverified address, then the profile
  /// (FR-AUTH-010, BR-002, BR-003). The profile is read only for a verified
  /// session, and again for each new session. While its status is still
  /// unknown nothing is emitted, so the guard never sends a reader with a
  /// complete profile to SCR-A-05 for a moment. Whether a Google account
  /// can be unverified is OQ-04: the provider's flag is used as it is.
  @override
  Stream<AccessState> watchAccessState() {
    StreamSubscription<AuthSession?>? sessions;
    StreamSubscription<ProfileStatus>? profile;
    late final StreamController<AccessState> out;

    void stopProfile() {
      final StreamSubscription<ProfileStatus>? old = profile;
      profile = null;
      if (old != null) {
        unawaited(old.cancel());
      }
    }

    void onSession(AuthSession? session) {
      stopProfile();
      if (session == null) {
        out.add(AccessState.signedOut);
        return;
      }
      if (!session.emailVerified) {
        out.add(AccessState.emailUnverified);
        return;
      }
      final Stream<ProfileStatus> Function()? source = _profileStatus;
      if (source == null) {
        out.add(AccessState.profileIncomplete);
        return;
      }
      profile = source().listen((ProfileStatus status) {
        switch (status) {
          case ProfileStatus.complete:
            out.add(AccessState.fullAccess);
          case ProfileStatus.incomplete:
            out.add(AccessState.profileIncomplete);
          case ProfileStatus.unknown:
            break;
        }
      }, onError: out.addError);
    }

    out = StreamController<AccessState>(
      onListen: () {
        sessions = watchSession().listen(onSession, onError: out.addError);
      },
      onCancel: () async {
        stopProfile();
        await sessions?.cancel();
      },
    );
    return out.stream.distinct();
  }

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

  /// One `unauthenticated` for a wrong address, a wrong password, an
  /// unknown account and a disabled one, so the reader cannot tell them
  /// apart (SEC-CHK-17).
  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!AccountRules.isEmail(email) || password.isEmpty) {
      return const Err<void>(AppFailure(FailureCode.invalidInput));
    }
    try {
      await _identity.signIn(email: email.trim(), password: password);
      return const Ok<void>(null);
    } on IdentityError catch (error) {
      return Err<void>(identityFailure(error));
    }
  }

  /// Google Sign-In waits for DEC-006 (PROVISIONAL, C-04; MOD03-P3-T02).
  @override
  Future<Result<void>> signInWithGoogle() async => _notYet;

  /// The same outcome whether or not an account uses [email] (FR-AUTH-004,
  /// SC-21): an unknown address is not reported.
  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    if (!AccountRules.isEmail(email)) {
      return const Err<void>(AppFailure(FailureCode.invalidInput));
    }
    try {
      await _identity.sendPasswordReset(email.trim());
    } on IdentityError catch (error) {
      if (error.code != 'user-not-found' && error.code != 'user-disabled') {
        return Err<void>(identityFailure(error));
      }
    }
    return const Ok<void>(null);
  }

  @override
  Future<void> signOut() async {
    try {
      await _identity.signOut();
    } on IdentityError {
      // The plugin clears the local session even when it reports an error.
    }
  }

  /// Confirms the password of the signed-in email account, so that the
  /// sign-in is recent before [deleteAccount] (R-4 d; how recent is OQ-56).
  @override
  Future<Result<void>> reauthenticateWithEmail({
    required String password,
  }) async {
    final IdentityUser? user = _identity.currentUser;
    if (user == null || user.method != SignInMethod.email) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    if (password.isEmpty) {
      return const Err<void>(AppFailure(FailureCode.invalidInput));
    }
    try {
      await _identity.reauthenticate(password);
      return const Ok<void>(null);
    } on IdentityError catch (error) {
      return Err<void>(identityFailure(error));
    }
  }

  /// Google Sign-In waits for DEC-006 (PROVISIONAL, C-04).
  @override
  Future<Result<void>> reauthenticateWithGoogle() async => _notYet;

  /// Deletes the reader's account through OP-12 at once (DEC-029,
  /// immediate deletion; PROVISIONAL, OQ-24), then clears this device's data
  /// for it and signs out (FR-AUTH-009, FR-PRIV-004). The confirmation is
  /// the screen's (SCR-A-08), so the call carries `confirm: true`.
  @override
  Future<Result<void>> deleteAccount() async {
    final IdentityUser? user = _identity.currentUser;
    if (user == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    final BackendCalls? backend = _backend;
    if (backend == null) {
      return _notYet;
    }
    try {
      await backend.call('requestAccountDeletion', <String, Object?>{
        'request_id': _requestIds(),
        'confirm': true,
      });
    } on BackendCallError catch (error) {
      return Err<void>(
        failureFromBackend(error.category, reason: error.reason),
      );
    }
    // The account is gone, or its deletion is finishing on the server
    // (OP-41). A clean-up that fails must not keep the reader signed in.
    for (final Future<void> Function(String userId) hook in _deletionHooks) {
      try {
        await hook(user.uid);
      } on Object {
        // Left for the module's own clean-up at the next start.
      }
    }
    await signOut();
    return const Ok<void>(null);
  }

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
