import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

import 'fake_server.dart';
import 'fake_streams.dart';
import 'test_users.dart';

/// Fake MOD-03 for one device, over a [FakeServer] (IC-01, IC-08).
///
/// Passwords are never checked. The access state follows the order in
/// API_AND_MODULE_CONTRACTS section 4.1. As with a real provider, the
/// session sees a verified address only after [reloadVerificationStatus].
final class FakeAuthService implements AuthService {
  /// Creates a device, signed in as [signedInAs] when given.
  FakeAuthService(this._server, {TestUser? signedInAs}) {
    if (signedInAs != null) {
      signInAs(signedInAs);
    }
  }

  final FakeServer _server;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  final List<void Function(String userId)> _deletionHooks =
      <void Function(String userId)>[];
  String? _userId;
  bool _sessionEmailVerified = false;

  /// The Google account the next [signInWithGoogle] uses; null means the
  /// reader cancels the flow.
  String? nextGoogleEmail;

  /// How many verification emails were requested.
  int verificationEmailsSent = 0;

  /// Fires after every session change on this device.
  Stream<void> get changes => _changes.stream;

  /// The signed-in reader's ID, or null.
  String? get currentUserId => currentSession?.userId;

  /// The session now, or null when signed out or the account is gone.
  AuthSession? get currentSession {
    final String? userId = _userId;
    final FakeAccount? account = userId == null
        ? null
        : _server.accountById(userId);
    if (account == null) {
      return null;
    }
    return AuthSession(
      userId: account.userId,
      method: account.method,
      emailVerified: _sessionEmailVerified,
    );
  }

  /// The access state now (API_AND_MODULE_CONTRACTS section 4.1).
  AccessState get currentAccessState {
    final AuthSession? session = currentSession;
    if (session == null) {
      return AccessState.signedOut;
    }
    if (!session.emailVerified) {
      return AccessState.emailUnverified;
    }
    if (_server.profileOf(session.userId) == null) {
      return AccessState.profileIncomplete;
    }
    return AccessState.fullAccess;
  }

  /// Signs this device in as [user], whose account must exist.
  void signInAs(TestUser user) {
    final FakeAccount? account = _server.accountById(user.userId);
    if (account == null) {
      throw StateError('${user.fixtureId} has no account on this server');
    }
    _signIn(account);
  }

  /// Runs [hook] with the reader's ID after an account deletion, for
  /// device-side clean-up.
  void addDeletionHook(void Function(String userId) hook) =>
      _deletionHooks.add(hook);

  @override
  Stream<AuthSession?> watchSession() => watchDerived(
    () => currentSession,
    <Stream<void>>[changes, _server.changes],
  );

  @override
  Stream<AccessState> watchAccessState() => watchDerived(
    () => currentAccessState,
    <Stream<void>>[changes, _server.changes],
  ).distinct();

  @override
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return const Err<void>(AppFailure(FailureCode.invalidInput));
    }
    if (_server.accountByEmail(email) != null) {
      return const Err<void>(AppFailure(FailureCode.conflict));
    }
    _signIn(
      _server.createAccount(
        email: email,
        method: SignInMethod.email,
        emailVerified: false,
      ),
    );
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final FakeAccount? account = _server.accountByEmail(email);
    if (account == null ||
        account.method != SignInMethod.email ||
        password.isEmpty) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _signIn(account);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    final String? email = nextGoogleEmail;
    if (email == null) {
      return const Err<void>(AppFailure(FailureCode.cancelled));
    }
    final FakeAccount? existing = _server.accountByEmail(email);
    if (existing != null && existing.method != SignInMethod.google) {
      // Linking an address used with another method is OQ-05.
      return const Err<void>(AppFailure(FailureCode.conflict));
    }
    // ASSUMPTION until OQ-04: a Google account counts as verified.
    _signIn(
      existing ??
          _server.createAccount(
            email: email,
            method: SignInMethod.google,
            emailVerified: true,
          ),
    );
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> resendVerificationEmail() async {
    if (currentSession == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    verificationEmailsSent++;
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> reloadVerificationStatus() async {
    final String? userId = currentUserId;
    final FakeAccount? account = userId == null
        ? null
        : _server.accountById(userId);
    if (account == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _sessionEmailVerified = account.emailVerified;
    _notify();
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async =>
      const Ok<void>(null);

  @override
  Future<void> signOut() async {
    _userId = null;
    _sessionEmailVerified = false;
    _notify();
  }

  @override
  Future<Result<void>> deleteAccount() async {
    final String? userId = currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _server.deleteUser(userId);
    await signOut();
    for (final void Function(String userId) hook in _deletionHooks) {
      hook(userId);
    }
    return const Ok<void>(null);
  }

  void _signIn(FakeAccount account) {
    _userId = account.userId;
    _sessionEmailVerified = account.emailVerified;
    _notify();
  }

  void _notify() => _changes.add(null);
}
