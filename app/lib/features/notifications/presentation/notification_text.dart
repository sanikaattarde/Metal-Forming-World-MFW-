/// The notification screens' wording (SCR-A-20, SCR-A-21). PLACEHOLDER until
/// the M2 designs set it; the categories themselves wait for OQ-18.
abstract final class NotificationText {
  /// The settings entry and the page title.
  static const String title = 'Notifications';

  /// The settings entry's line.
  static const String settingsLine = 'Choose what MFW tells you about';

  // SCR-A-20.

  /// The explanation's heading.
  static const String explainHeading = 'Hear about new issues first';

  /// What the app sends, before the system asks (FR-NOTIF-001).
  static const String explainBody =
      'MFW can tell you when a new issue is out, about expo specials and '
      'about major news. You choose which, and you can change it here at '
      'any time. Your phone asks you to allow notifications next.';

  /// Allow, then the system prompt.
  static const String allow = 'Allow notifications';

  /// Not now.
  static const String notNow = 'Not now';

  // SCR-A-21.

  /// Above the category switches.
  static const String chooseHeading = 'Notify me about';

  /// Notifications blocked in the system settings.
  static const String blocked =
      'Notifications are turned off for MFW in your phone settings. Turn '
      'them on there to receive the categories you choose.';

  /// Notifications not allowed yet.
  static const String notAllowed =
      'Notifications are not allowed yet, so none will arrive.';

  /// Ask the system again.
  static const String askAgain = 'Allow notifications';

  /// A visitor's choices stay on the device (GS-Q46).
  static const String visitorNote =
      'You are not signed in, so these choices are kept on this device only.';

  /// No categories to choose.
  static const String noCategories =
      'No notification categories are available.';

  /// Loading.
  static const String loading = 'Loading notification choices';

  /// The choices could not be loaded.
  static const String loadFailed =
      'Your notification choices could not be loaded. Check the connection '
      'and try again.';

  /// A change could not be saved.
  static const String saveFailed =
      'The change could not be saved. Check the connection and try again.';

  /// Retry.
  static const String retry = 'Retry';
}
