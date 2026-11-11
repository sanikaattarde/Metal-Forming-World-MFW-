/// The route table of `API_AND_MODULE_CONTRACTS.md` section 6.1 (PROPOSED),
/// with the screen of `SCREEN_INVENTORY_AND_NAVIGATION.md` section 5 that
/// each route shows.
abstract final class AppRoutes {
  /// SCR-A-10, home.
  static const String home = '/';

  /// SCR-A-11, the catalogue (MOD05-P2-T01). Open to everyone.
  static const String catalogue = '/catalogue';

  /// SCR-A-15, downloads.
  static const String downloads = '/downloads';

  /// SCR-A-16 and SCR-A-17, bookmarks and favourites.
  static const String library = '/library';

  /// SCR-A-18, the news list.
  static const String news = '/news';

  /// SCR-A-01, sign in.
  static const String signIn = '/sign-in';

  /// SCR-A-04, password reset (MOD03-P2-T02). Open in every access state.
  static const String passwordReset = '/reset-password';

  /// SCR-A-02, register.
  static const String register = '/register';

  /// SCR-A-03, verify email.
  static const String verifyEmail = '/verify-email';

  /// SCR-A-05, complete profile.
  static const String completeProfile = '/complete-profile';

  /// SCR-A-06, the reader's own profile (MOD04-P2-T03). Needs a session.
  static const String profile = '/profile';

  /// SCR-A-07, settings.
  static const String settings = '/settings';

  /// SCR-A-08, delete the account (MOD03-P4-T01). Needs a session.
  static const String deleteAccount = '/settings/delete-account';

  /// SCR-A-21 with SCR-A-20, the notification choices (MOD11-P2-T02). Open
  /// to visitors (GS-Q46).
  static const String notificationSettings = '/settings/notifications';

  /// SCR-A-12 for [issueId].
  static String issue(String issueId) =>
      '/issues/${Uri.encodeComponent(issueId)}';

  /// SCR-A-14 for [issueId], at [page] when given. The reader clamps the
  /// page to the document (section 4.3).
  static String reader(String issueId, {int? page}) => page == null
      ? '${issue(issueId)}/read'
      : '${issue(issueId)}/read?page=$page';

  /// SCR-A-19 for [postId].
  static String newsPost(String postId) =>
      '/news/${Uri.encodeComponent(postId)}';
}
