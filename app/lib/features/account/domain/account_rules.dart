/// The account input checks the app makes before calling the provider
/// (MOD-03). The provider and the backend check again; these only save the
/// reader a round trip and give a clear message.
abstract final class AccountRules {
  /// PROPOSED: the design's "At least 8 characters" (SCR-A-02,
  /// `ACCOUNT_SCREEN_DESIGNS.md`). The reader password rules are not set in
  /// any document; the provider's own minimum is lower.
  static const int minPasswordLength = 8;

  // One @, something before it, and a dot in the part after it. The
  // provider decides whether the address is really usable.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Whether [email] looks like an email address.
  static bool isEmail(String email) => _email.hasMatch(email.trim());

  /// Whether [password] is long enough.
  static bool isPasswordLongEnough(String password) =>
      password.length >= minPasswordLength;
}
