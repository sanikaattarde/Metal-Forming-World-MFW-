import 'access_state.dart';
import 'result.dart';

/// How a reader signs in.
enum SignInMethod {
  /// Email address and password.
  email,

  /// Google Sign-In (PROVISIONAL, C-04).
  google,
}

/// The signed-in reader's session (RS DATA-003).
final class AuthSession {
  /// Creates a session snapshot.
  const AuthSession({
    required this.userId,
    required this.method,
    required this.emailVerified,
  });

  /// Opaque reader account ID. Never logged (CODING_STANDARDS section 6.2).
  final String userId;

  /// How the reader signed in.
  final SignInMethod method;

  /// Whether the email address is verified.
  final bool emailVerified;
}

/// Registration, sign-in, verification, password reset, sign-out,
/// re-authentication and account deletion (MOD-03, owned by WS-A).
///
/// Failures: `invalidInput`, `conflict` (address already used),
/// `unauthenticated` (wrong credentials, without saying which part),
/// `cancelled` (Google flow cancelled), `network`, `serviceUnavailable`.
abstract interface class AuthService {
  /// Emits the session, or null when signed out.
  Stream<AuthSession?> watchSession();

  /// Emits the access state (API_AND_MODULE_CONTRACTS section 4.1).
  Stream<AccessState> watchAccessState();

  /// Registers an email account. Fails with `invalidInput` or `conflict`.
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
  });

  /// Signs in with email and password. Fails with `unauthenticated`.
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs in with Google (PROVISIONAL, C-04). Fails with `cancelled`.
  Future<Result<void>> signInWithGoogle();

  /// Sends the verification email again. Fails with `unauthenticated`.
  Future<Result<void>> resendVerificationEmail();

  /// Reloads whether the email address is verified.
  Future<Result<void>> reloadVerificationStatus();

  /// Sends a password reset. The outcome does not reveal whether an
  /// account exists for [email].
  Future<Result<void>> sendPasswordReset(String email);

  /// Signs out.
  Future<void> signOut();

  /// Confirms the password of the signed-in email account again, so that
  /// the sign-in is recent before [deleteAccount] (OP-12; PROPOSED, R-4 d).
  /// How recent is OQ-56. The password is never logged. Fails with
  /// `unauthenticated` when signed out, when the session is not an email
  /// session, or when the password is wrong.
  Future<Result<void>> reauthenticateWithEmail({required String password});

  /// Runs the Google flow again for the signed-in Google account, so that
  /// the sign-in is recent before [deleteAccount] (PROVISIONAL, C-04;
  /// PROPOSED, R-4 d). Fails with `cancelled`, or with `unauthenticated`
  /// when signed out, when the session is not a Google session, or when
  /// another Google account is chosen.
  Future<Result<void>> reauthenticateWithGoogle();

  /// Deletes the reader's account; calls OP-ACC-01. Fails with
  /// `unauthenticated` when signed out or when the sign-in is not recent
  /// (RECENT_SIGN_IN_REQUIRED), with `conflict` for the last admin
  /// (LAST_ADMIN) and with `forbidden` while a deletion is running
  /// (ALREADY_DELETING), as API_AND_MODULE_CONTRACTS section 4.2 maps them.
  Future<Result<void>> deleteAccount();
}
