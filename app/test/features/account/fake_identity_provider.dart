import 'dart:async';

import 'package:mfw_app/contracts/auth.dart';
import 'package:mfw_app/features/account/account.dart';

/// One account at the fake provider. Synthetic values only (DEC-024).
final class FakeIdentityAccount {
  FakeIdentityAccount({
    required this.uid,
    required this.email,
    required this.password,
  });

  final String uid;
  final String email;
  String password;
  bool verified = false;
  bool disabled = false;
}

/// A fake [IdentityProvider] that behaves like Firebase Authentication
/// without email-enumeration protection: an unknown address on a password
/// reset is reported, so the tests show that the service hides it.
final class FakeIdentityProvider implements IdentityProvider {
  final Map<String, FakeIdentityAccount> accounts =
      <String, FakeIdentityAccount>{};
  final StreamController<IdentityUser?> _changes =
      StreamController<IdentityUser?>.broadcast(sync: true);
  FakeIdentityAccount? _signedIn;
  bool _sessionVerified = false;
  int _nextUid = 1;

  /// The provider code the next call fails with, once.
  String? failNext;

  /// While set, every call waits for it, to show a screen while busy.
  Completer<void>? hold;

  /// The calls made, by name, in order.
  final List<String> calls = <String>[];

  /// The addresses verification emails were sent to.
  final List<String> verificationEmails = <String>[];

  /// The addresses password resets were sent to.
  final List<String> passwordResets = <String>[];

  /// Adds an account, as if registered earlier.
  FakeIdentityAccount addAccount(
    String email,
    String password, {
    bool verified = false,
  }) {
    final FakeIdentityAccount account = FakeIdentityAccount(
      uid: 'uid-${_nextUid++}',
      email: email,
      password: password,
    )..verified = verified;
    accounts[email] = account;
    return account;
  }

  /// Opens the verification link, as the reader would in the email. The
  /// session sees it only after [reloadUser].
  void verifyByEmailLink(String email) => accounts[email]!.verified = true;

  IdentityUser? _user() {
    final FakeIdentityAccount? account = _signedIn;
    return account == null
        ? null
        : IdentityUser(
            uid: account.uid,
            email: account.email,
            emailVerified: _sessionVerified,
            method: SignInMethod.email,
          );
  }

  Future<void> _step(String name) async {
    calls.add(name);
    final Completer<void>? waiting = hold;
    if (waiting != null) {
      await waiting.future;
    }
    final String? code = failNext;
    if (code != null) {
      failNext = null;
      throw IdentityError(code);
    }
  }

  void _setSignedIn(FakeIdentityAccount? account) {
    _signedIn = account;
    _sessionVerified = account?.verified ?? false;
    _changes.add(_user());
  }

  @override
  Stream<IdentityUser?> userChanges() async* {
    yield _user();
    yield* _changes.stream;
  }

  @override
  IdentityUser? get currentUser => _user();

  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await _step('createAccount');
    if (accounts.containsKey(email)) {
      throw const IdentityError('email-already-in-use');
    }
    if (password.length < 6) {
      throw const IdentityError('weak-password');
    }
    _setSignedIn(addAccount(email, password));
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _step('signIn');
    final FakeIdentityAccount? account = accounts[email];
    if (account == null || account.password != password) {
      throw const IdentityError('invalid-credential');
    }
    if (account.disabled) {
      throw const IdentityError('user-disabled');
    }
    _setSignedIn(account);
  }

  @override
  Future<void> sendVerificationEmail() async {
    await _step('sendVerificationEmail');
    final FakeIdentityAccount? account = _signedIn;
    if (account == null) {
      throw const IdentityError('no-current-user');
    }
    verificationEmails.add(account.email);
  }

  @override
  Future<void> reloadUser() async {
    await _step('reloadUser');
    final FakeIdentityAccount? account = _signedIn;
    if (account == null) {
      throw const IdentityError('no-current-user');
    }
    _sessionVerified = account.verified;
    _changes.add(_user());
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _step('sendPasswordReset');
    if (!accounts.containsKey(email)) {
      throw const IdentityError('user-not-found');
    }
    passwordResets.add(email);
  }

  @override
  Future<void> reauthenticate(String password) async {
    await _step('reauthenticate');
    final FakeIdentityAccount? account = _signedIn;
    if (account == null) {
      throw const IdentityError('no-current-user');
    }
    if (account.password != password) {
      throw const IdentityError('invalid-credential');
    }
  }

  @override
  Future<void> signOut() async {
    await _step('signOut');
    _setSignedIn(null);
  }
}
