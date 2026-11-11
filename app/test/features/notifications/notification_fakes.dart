import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

/// A fake push client: it records the topics this device is subscribed to,
/// and can refuse a call. No real device or push service is reached.
final class FakePushMessaging implements PushMessaging {
  PermissionOutcome status = PermissionOutcome.notDetermined;

  /// What the system prompt answers.
  PermissionOutcome answer = PermissionOutcome.granted;

  final Set<String> topics = <String>{};
  final List<String> calls = <String>[];

  /// The topic whose next subscribe or unsubscribe fails, once.
  String? failTopic;

  bool registered = true;
  final StreamController<Map<String, String>> opened =
      StreamController<Map<String, String>>.broadcast();

  @override
  Future<PermissionOutcome> permissionStatus() async => status;

  @override
  Future<PermissionOutcome> requestPermission() async {
    calls.add('requestPermission');
    if (status == PermissionOutcome.notDetermined) {
      status = answer;
    }
    return status;
  }

  void _maybeFail(String topic) {
    if (failTopic == topic) {
      failTopic = null;
      throw const PushError('unavailable');
    }
  }

  @override
  Future<void> subscribe(String topic) async {
    calls.add('subscribe $topic');
    _maybeFail(topic);
    topics.add(topic);
  }

  @override
  Future<void> unsubscribe(String topic) async {
    calls.add('unsubscribe $topic');
    _maybeFail(topic);
    topics.remove(topic);
  }

  @override
  Future<void> unregister() async {
    calls.add('unregister');
    registered = false;
  }

  @override
  Stream<Map<String, String>> openedMessages() => opened.stream;
}

/// The records of OP-05 and OP-09 in memory, as the rules allow them.
final class FakeNotificationDocuments implements NotificationDocuments {
  FakeNotificationDocuments({List<NotificationCategory>? categories})
    : all = categories ?? seedCategories();

  List<NotificationCategory> all;
  final Map<String, Set<String>> stored = <String, Set<String>>{};
  final List<String> calls = <String>[];

  /// Whether the next call fails, offline.
  bool failNext = false;

  void _maybeFail() {
    if (failNext) {
      failNext = false;
      throw const NotificationDocumentsError(offline: true);
    }
  }

  @override
  Future<List<NotificationCategory>> categories() async {
    _maybeFail();
    return List<NotificationCategory>.of(all);
  }

  @override
  Future<Set<String>> preferences(String userId) async {
    _maybeFail();
    return Set<String>.of(stored[userId] ?? <String>{});
  }

  @override
  Future<void> addPreference(String userId, String categoryId) async {
    calls.add('add $userId $categoryId');
    _maybeFail();
    (stored[userId] ??= <String>{}).add(categoryId);
  }

  @override
  Future<void> removePreference(String userId, String categoryId) async {
    calls.add('remove $userId $categoryId');
    _maybeFail();
    stored[userId]?.remove(categoryId);
  }
}

/// The three categories of the seed (GS-Q47), and an inactive one.
List<NotificationCategory> seedCategories() => const <NotificationCategory>[
  NotificationCategory(
    id: 'notif-major-news',
    name: 'Major news',
    displayOrder: 3,
    isActive: true,
  ),
  NotificationCategory(
    id: 'notif-new-issues',
    name: 'New issues',
    displayOrder: 1,
    isActive: true,
  ),
  NotificationCategory(
    id: 'notif-expo-specials',
    name: 'Expo specials',
    displayOrder: 2,
    isActive: true,
  ),
  NotificationCategory(
    id: 'notif-old',
    name: 'Old category',
    displayOrder: 4,
    isActive: false,
  ),
];

/// The device's record in memory.
final class MemoryDeviceChoices implements DeviceChoices {
  DeviceChoicesRecord record = const DeviceChoicesRecord();

  @override
  Future<DeviceChoicesRecord> load() async => record;

  @override
  Future<void> save(DeviceChoicesRecord record) async => this.record = record;
}

/// A navigator that records where taps go.
final class RecordingNavigator implements AppNavigator {
  final List<String> opened = <String>[];

  @override
  void openIssue(String issueId) => opened.add('issue $issueId');

  @override
  void openArticle(String postId) => opened.add('article $postId');
}

/// The service over the fakes, for the reader [userId] of the closure.
DeviceNotificationService serviceOver({
  required FakePushMessaging push,
  required FakeNotificationDocuments documents,
  required MemoryDeviceChoices device,
  required String? Function() userId,
}) => DeviceNotificationService(
  push: push,
  documents: documents,
  device: device,
  currentUserId: userId,
);
