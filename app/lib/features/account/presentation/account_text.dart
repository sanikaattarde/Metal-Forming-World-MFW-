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

  // SCR-A-01.

  /// The sign-in title.
  static const String signInTitle = 'Sign in';

  /// Why to sign in.
  static const String signInBody = 'Sign in to read and download full issues.';

  /// The sign-in button.
  static const String signInButton = 'Sign in';

  /// One message for any wrong address or password (SEC-CHK-17).
  static const String wrongCredentials = 'The email or password is not right.';

  /// The link to the password reset.
  static const String forgotPassword = 'Forgot your password?';

  /// The link to register.
  static const String toRegister = 'New here? Create an account';

  // SCR-A-04.

  /// The password reset title.
  static const String resetTitle = 'Reset your password';

  /// What the reset does.
  static const String resetBody =
      'Enter your email address, and we will send a link.';

  /// The reset button.
  static const String resetButton = 'Send link';

  /// The reset button once a link was sent.
  static const String resetAgainButton = 'Send again';

  /// The same message for a known and an unknown address (SC-21).
  static const String resetSent =
      'If an account uses this address, we have sent it a link to set a new '
      'password.';

  /// Back to sign-in.
  static const String backToSignIn = 'Back to sign in';

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
