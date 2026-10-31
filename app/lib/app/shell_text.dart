/// User-facing text of the shell, kept together (CODING_STANDARDS section 9).
///
/// PLACEHOLDER wording: the M2 designs set the real text.
abstract final class ShellText {
  /// Title of SCR-A-16 and SCR-A-17.
  static const String library = 'Library';

  /// The issue action for a reader without full access (SCR-A-12).
  static const String readOrDownload = 'Read or download';

  /// Opens a kept copy in the reader (SCR-A-12).
  static const String read = 'Read';

  /// Title of SCR-A-01.
  static const String signIn = 'Sign in';

  /// Title of SCR-A-02.
  static const String register = 'Register';

  /// Title of SCR-A-03.
  static const String verifyEmail = 'Verify email';

  /// Title of SCR-A-05.
  static const String completeProfile = 'Complete profile';

  /// Title of SCR-A-07.
  static const String settings = 'Settings';

  /// Title of SCR-A-22.
  static const String notFound = 'Not found';

  /// Body of SCR-A-22.
  static const String notFoundBody = 'This page does not exist.';

  /// Body of a screen whose design waits for M2.
  static const String placeholderBody = 'Placeholder screen';

  /// Shown until the access state is known.
  static const String loading = 'Loading';

  /// Shown when the access state cannot be read.
  static const String shellError = 'The app could not check your sign-in.';

  /// The retry action.
  static const String retry = 'Retry';
}
