import '../../../contracts/notifications.dart';

/// The device's push client (TD-13, PROPOSED: one topic per notification
/// category). Firebase Cloud Messaging in the app, a fake in tests.
///
/// Push is not set up in MFW's accounts yet (MOD11-P2-T01), so the adapter
/// has not reached a real device.
abstract interface class PushMessaging {
  /// The system's notification permission now, without asking.
  Future<PermissionOutcome> permissionStatus();

  /// Shows the system's permission prompt, or returns the earlier answer.
  Future<PermissionOutcome> requestPermission();

  /// Subscribes this device to [topic]. Throws [PushError] when the push
  /// service cannot be reached.
  Future<void> subscribe(String topic);

  /// Ends this device's subscription to [topic]. Throws [PushError].
  Future<void> unsubscribe(String topic);

  /// Ends this app's registration with the push service, so its token no
  /// longer receives anything. Whether that also ends its topic
  /// subscriptions is OQ-55, so a caller ends each subscription first.
  Future<void> unregister();

  /// The data of each notification the reader taps, including the one that
  /// opened the app.
  Stream<Map<String, String>> openedMessages();
}

/// A push call that failed. [kind] is the plugin's code only, never a token.
final class PushError implements Exception {
  /// Creates the error.
  const PushError(this.kind);

  /// The plugin's code, such as `apns-token-not-set`.
  final String kind;

  @override
  String toString() => 'PushError($kind)';
}

/// The push topic of a notification category: its identifier, as the
/// backend derives it (`pushSender.ts`, PROPOSED). Null for a name the push
/// service would refuse.
String? topicFor(String categoryId) =>
    RegExp(r'^[A-Za-z0-9\-_.~%]{1,900}$').hasMatch(categoryId)
    ? categoryId
    : null;
