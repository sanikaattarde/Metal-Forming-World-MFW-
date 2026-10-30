import 'package:mfw_app/contracts/contracts.dart';

/// PLACEHOLDER until MOD-03 (WS-A) provides the AuthService.
///
/// Nobody can sign in, so the app runs as a logged-out visitor, and every
/// account action fails with `serviceUnavailable`.
final class UnavailableAuthService implements AuthService {
  /// Creates the placeholder.
  const UnavailableAuthService();

  static const Err<void> _unavailable = Err<void>(
    AppFailure(FailureCode.serviceUnavailable),
  );

  @override
  Stream<AuthSession?> watchSession() => Stream<AuthSession?>.value(null);

  @override
  Stream<AccessState> watchAccessState() =>
      Stream<AccessState>.value(AccessState.signedOut);

  @override
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
  }) async => _unavailable;

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) async => _unavailable;

  @override
  Future<Result<void>> signInWithGoogle() async => _unavailable;

  @override
  Future<Result<void>> resendVerificationEmail() async => _unavailable;

  @override
  Future<Result<void>> reloadVerificationStatus() async => _unavailable;

  @override
  Future<Result<void>> sendPasswordReset(String email) async => _unavailable;

  @override
  Future<void> signOut() async {}

  @override
  Future<Result<void>> deleteAccount() async => _unavailable;
}
