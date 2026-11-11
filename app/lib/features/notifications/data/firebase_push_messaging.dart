import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../contracts/notifications.dart';
import '../domain/push_messaging.dart';

/// The [PushMessaging] adapter for Firebase Cloud Messaging (TD-13, DEC-003).
///
/// Thin on purpose: it runs only on a device or simulator. Push is not set
/// up in MFW's accounts (MOD11-P2-T01): on iOS a topic subscription needs
/// the push credential (CFG-10) and the Push Notifications capability, so
/// until then it fails with `apns-token-not-set`, reported as [PushError].
final class FirebasePushMessaging implements PushMessaging {
  /// Creates the adapter over [messaging], by default the app's instance.
  FirebasePushMessaging([FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  static PermissionOutcome _outcomeOf(NotificationSettings settings) =>
      switch (settings.authorizationStatus) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional => PermissionOutcome.granted,
        AuthorizationStatus.denied ||
        AuthorizationStatus.deniedPermanently => PermissionOutcome.denied,
        AuthorizationStatus.notDetermined => PermissionOutcome.notDetermined,
      };

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseException catch (error) {
      throw PushError(error.code);
    }
  }

  @override
  Future<PermissionOutcome> permissionStatus() => _guard(
    () async => _outcomeOf(await _messaging.getNotificationSettings()),
  );

  @override
  Future<PermissionOutcome> requestPermission() =>
      _guard(() async => _outcomeOf(await _messaging.requestPermission()));

  @override
  Future<void> subscribe(String topic) =>
      _guard(() => _messaging.subscribeToTopic(topic));

  @override
  Future<void> unsubscribe(String topic) =>
      _guard(() => _messaging.unsubscribeFromTopic(topic));

  @override
  Future<void> unregister() => _guard(_messaging.unregister);

  @override
  Stream<Map<String, String>> openedMessages() {
    late final StreamController<Map<String, String>> out;
    StreamSubscription<RemoteMessage>? taps;
    Map<String, String> dataOf(RemoteMessage message) => <String, String>{
      for (final MapEntry<String, dynamic> entry in message.data.entries)
        if (entry.value is String) entry.key: entry.value as String,
    };
    out = StreamController<Map<String, String>>(
      onListen: () {
        // The notification that opened the app from closed, then later taps.
        unawaited(
          _messaging.getInitialMessage().then((RemoteMessage? first) {
            if (first != null && !out.isClosed) {
              out.add(dataOf(first));
            }
          }, onError: (Object _) {}),
        );
        taps = FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) => out.add(dataOf(message)),
        );
      },
      onCancel: () => taps?.cancel(),
    );
    return out.stream;
  }
}
