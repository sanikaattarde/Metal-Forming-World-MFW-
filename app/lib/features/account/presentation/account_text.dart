/// The account screens' wording, from the MOD16-P1-T03 frames. PLACEHOLDER
/// until the M2 designs set it (`ACCOUNT_SCREEN_DESIGNS.md` section 7).
abstract final class AccountText {
  // Fields.

  /// The email field.
  static const String email = 'Email';

  /// The password field.
  static const String password = 'Password';

  /// The hint under a new password.
  static const String passwordHint = 'At least 8 characters';

  /// An address that does not look like one.
  static const String emailInvalid = 'Enter a valid email address.';

  /// A password that is too short.
  static const String passwordTooShort = 'Use at least 8 characters.';

  /// A password left empty.
  static const String passwordMissing = 'Enter your password.';

  // SCR-A-02.

  /// The register title.
  static const String registerTitle = 'Create an account';

  /// The register button.
  static const String registerButton = 'Create account';

  /// The link to sign in instead.
  static const String toSignIn = 'Already registered? Sign in';

  /// An address already in use.
  static const String addressInUse =
      'An account with this email address exists. Sign in instead.';

  /// The field error for an address already in use.
  static const String addressInUseField = 'This address is in use.';

  // SCR-A-03.

  /// The verify title.
  static const String verifyTitle = 'Verify your email';

  /// What to do next.
  static const String verifyBody =
      'We sent a link to your email address. Open it to verify your '
      'address, then come back here.';

  /// The button after verifying.
  static const String verifiedButton = 'I have verified my email';

  /// The address is not verified yet.
  static const String notVerifiedYet =
      'Your address is not verified yet. Open the link in the email, then '
      'try again.';

  /// Resend the email.
  static const String resend = 'Send the email again';

  /// The email was sent again.
  static const String resent = 'We sent the email again.';

  /// Sign out.
  static const String signOut = 'Sign out';
}
