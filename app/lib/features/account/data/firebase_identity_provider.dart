import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../contracts/auth.dart';
import '../domain/identity_provider.dart';

/// The [IdentityProvider] adapter for Firebase Authentication (DEC-003).
///
/// Thin on purpose: it maps calls and errors and holds no logic, because it
/// runs only on a device or simulator. The account logic is tested through
/// the port with a fake.
final class FirebaseIdentityProvider implements IdentityProvider {
  /// Creates the adapter over [auth].
  FirebaseIdentityProvider(this._auth);

  final FirebaseAuth _auth;

  // A reload changes the user in place, so it is announced here as well as
  // through the plugin's own stream.
  final StreamController<IdentityUser?> _reloads =
      StreamController<IdentityUser?>.broadcast();

  static IdentityUser? _map(User? user) {
    if (user == null) {
      return null;
    }
    final bool google = user.providerData.any(
      (UserInfo info) => info.providerId == 'google.com',
    );
    return IdentityUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      method: google ? SignInMethod.google : SignInMethod.email,
    );
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw IdentityError(error.code);
    }
  }

  User _user() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const IdentityError('no-current-user');
    }
    return user;
  }

  @override
  Stream<IdentityUser?> userChanges() {
    StreamSubscription<User?>? plugin;
    StreamSubscription<IdentityUser?>? reloads;
    late final StreamController<IdentityUser?> out;
    out = StreamController<IdentityUser?>(
      onListen: () {
        plugin = _auth.userChanges().listen(
          (User? user) => out.add(_map(user)),
          onError: out.addError,
        );
        reloads = _reloads.stream.listen(out.add);
      },
      onCancel: () async {
        await plugin?.cancel();
        await reloads?.cancel();
      },
    );
    return out.stream;
  }

  @override
  IdentityUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) => _guard(
    () =>
        _auth.createUserWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> sendVerificationEmail() =>
      _guard(() => _user().sendEmailVerification());

  @override
  Future<void> reloadUser() => _guard(() async {
    await _user().reload();
    _reloads.add(currentUser);
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> reauthenticate(String password) => _guard(() async {
    final User user = _user();
    final String? email = user.email;
    if (email == null) {
      throw const IdentityError('user-mismatch');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  });

  @override
  Future<void> signOut() => _guard(_auth.signOut);
}
