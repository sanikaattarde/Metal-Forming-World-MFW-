import 'result.dart';

/// The outcome of the notification permission request. A denial is an
/// outcome, not a failure.
enum PermissionOutcome {
  /// Notifications allowed.
  granted,

  /// Notifications refused.
  denied,

  /// The reader has not decided.
  notDetermined,
}

/// Notification preferences (RS DATA-007). Categories: OQ-18.
final class NotificationPreferences {
  /// Creates preferences.
  const NotificationPreferences({
    required this.optedIn,
    required this.categoryIds,
  });

  /// Whether the reader receives notifications.
  final bool optedIn;

  /// Categories the reader receives.
  final List<String> categoryIds;
}

/// What a notification opens.
///
/// PROPOSED name: the contract gives the values, `issue` or `article`.
enum NotificationTargetType {
  /// An issue.
  issue,

  /// A news article.
  article,
}

/// The target of a tapped notification (RS FR-NOTIF-005).
final class NotificationTarget {
  /// Creates a target.
  const NotificationTarget({required this.type, required this.targetId});

  /// Issue or article.
  final NotificationTargetType type;

  /// Opaque issue ID or post ID.
  final String targetId;
}

/// Notification permission, preferences and taps (MOD-11, owned by WS-A).
///
/// Failures: `network`, `unknown`.
abstract interface class NotificationService {
  /// Explains notifications, then asks the system for permission.
  Future<Result<PermissionOutcome>> explainAndRequestPermission();

  /// Reads the reader's preferences (OP-NTF-03).
  Future<Result<NotificationPreferences>> getPreferences();

  /// Saves the reader's preferences (OP-NTF-04).
  Future<Result<void>> savePreferences(NotificationPreferences p);

  /// Emits tapped targets; forwarded to AppNavigator.
  Stream<NotificationTarget> watchOpened();
}
