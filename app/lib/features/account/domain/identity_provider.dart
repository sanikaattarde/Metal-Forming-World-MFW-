import '../../../contracts/auth.dart';

/// The signed-in account, as the identity provider reports it.
final class IdentityUser {
  /// Creates a snapshot of the provider's account.
  const IdentityUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.method,
  });

  /// The provider's account ID. Never logged (CODING_STANDARDS section 6.2).
  final String uid;

  /// The address the account uses, shown only to its owner.
  final String? email;

  /// Whether the provider reports the address as verified.
  final bool emailVerified;

  /// How the account signs in.
  final SignInMethod method;
}

/// A refusal or failure from the identity provider, by its code only.
///
/// The codes are the provider's own (for Firebase Authentication, for
/// example `email-already-in-use` or `network-request-failed`). The
/// provider's message is never kept, because it may hold the address.
final class IdentityError implements Exception {
  /// Creates the error for [code].
  const IdentityError(this.code);

  /// The provider's code.
  final String code;

  @override
  String toString() => 'IdentityError($code)';
}

/// The identity provider MOD-03 signs readers in with (DEC-003: Firebase
/// Authentication). A port, so that the account logic is tested with a fake
/// and the platform plugin stays in one thin adapter.
///
/// Every method throws [IdentityError] on a refusal or failure.
abstract interface class IdentityProvider {
  /// Emits the account on every sign-in, sign-out and [reloadUser], and
  /// the current one first.
  Stream<IdentityUser?> userChanges();

  /// The signed-in account now, or null.
  IdentityUser? get currentUser;

  /// Creates an email account and signs it in.
  Future<void> createAccount({required String email, required String password});

  /// Signs in with an email address and password.
  Future<void> signIn({required String email, required String password});

  /// Sends the signed-in account a verification email.
  Future<void> sendVerificationEmail();

  /// Reads the signed-in account again, so a verification made in the
  /// email shows here.
  Future<void> reloadUser();

  /// Sends a password reset email to [email].
  Future<void> sendPasswordReset(String email);

  /// Confirms the signed-in email account's password again.
  Future<void> reauthenticate(String password);

  /// Signs out on this device.
  Future<void> signOut();
}
