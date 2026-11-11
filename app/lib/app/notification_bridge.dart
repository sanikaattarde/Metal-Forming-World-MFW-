import 'dart:async';

import 'package:flutter/widgets.dart';

import '../contracts/contracts.dart';
import '../features/notifications/notifications.dart';

/// Connects MOD-11 to the rest of the app (MOD11-P2-T02): keeps the
/// device's topics in line with whoever is signed in, and opens the target
/// of a tapped notification through the [AppNavigator], so the access guard
/// applies (FR-NOTIF-005, BR-005).
class NotificationBridge extends StatefulWidget {
  /// Creates the bridge around [child].
  const NotificationBridge({
    required this.notifications,
    required this.sessions,
    required this.navigator,
    required this.child,
    super.key,
  });

  /// MOD-11, or null when it does not exist (no Firebase, in tests).
  final DeviceNotificationService? notifications;

  /// MOD-03's session, read only when [notifications] exists.
  final Stream<AuthSession?> Function() sessions;

  /// Where a tap goes, read when it happens.
  final AppNavigator Function() navigator;

  /// The app below.
  final Widget child;

  @override
  State<NotificationBridge> createState() => _NotificationBridgeState();
}

class _NotificationBridgeState extends State<NotificationBridge> {
  StreamSubscription<AuthSession?>? _sessions;
  StreamSubscription<NotificationTarget>? _taps;
  bool _seen = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final DeviceNotificationService? notifications = widget.notifications;
    if (notifications == null) {
      return;
    }
    _sessions = widget.sessions().listen((AuthSession? session) {
      final String? userId = session?.userId;
      if (_seen && userId == _userId) {
        return;
      }
      _seen = true;
      _userId = userId;
      // At start-up and at each sign-in, the choices of whoever is signed in
      // (DATA-007), or the visitor's on this device.
      unawaited(notifications.syncTo(userId));
    }, onError: (Object _) {});
    _taps = notifications.watchOpened().listen((NotificationTarget target) {
      final AppNavigator navigator = widget.navigator();
      switch (target.type) {
        case NotificationTargetType.issue:
          navigator.openIssue(target.targetId);
        case NotificationTargetType.article:
          navigator.openArticle(target.targetId);
      }
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    unawaited(_sessions?.cancel());
    unawaited(_taps?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
