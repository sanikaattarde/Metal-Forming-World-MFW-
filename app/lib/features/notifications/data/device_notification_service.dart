import 'dart:async';

import '../../../contracts/contracts.dart';
import '../domain/device_choices.dart';
import '../domain/notification_documents.dart';
import '../domain/push_messaging.dart';

/// MOD-11's [NotificationService] on this device (MOD11-P2-T02, FR-NOTIF-001
/// to FR-NOTIF-003, FR-NOTIF-006, FR-NOTIF-007, DATA-007).
///
/// A signed-in reader's choices are records under the account (OP-09), so
/// they follow the reader to another device. A visitor's stay on the device
/// only and the backend stores nothing (GS-Q46; OQ-09 is OPEN). Either way
/// the device is subscribed to the topic of each chosen category and to
/// nothing else, so after a change only the new choice arrives
/// (FR-NOTIF-003).
///
/// When a reader signs in, the account's choices replace the device's and a
/// visitor's earlier choices are forgotten (PROPOSED). At sign-out and at
/// account deletion, [clearDevice] ends everything (OQ-55 working position,
/// MOD11-P2-T04).
///
/// Failures: `network` when the records or the push service cannot be
/// reached, `unknown` otherwise.
final class DeviceNotificationService implements NotificationService {
  /// Creates the service. [currentUserId] is the signed-in reader, or null
  /// for a visitor.
  DeviceNotificationService({
    required this._push,
    required this._documents,
    required this._device,
    required this._currentUserId,
  });

  final PushMessaging _push;
  final NotificationDocuments _documents;
  final DeviceChoices _device;
  final String? Function() _currentUserId;

  // One change at a time, so two quick changes cannot interleave their
  // subscribe and unsubscribe calls. Each call makes its own futures, in the
  // zone it is called from.
  Future<void>? _last;

  static const AppFailure _network = AppFailure(
    FailureCode.network,
    retryable: true,
    detail: 'notifications network',
  );
  static const AppFailure _unknown = AppFailure(
    FailureCode.unknown,
    detail: 'notifications other',
  );

  Future<T> _serial<T>(Future<T> Function() action) async {
    final Future<void>? previous = _last;
    final Completer<void> mine = Completer<void>();
    _last = mine.future;
    try {
      if (previous != null) {
        await previous;
      }
      return await action();
    } finally {
      mine.complete();
    }
  }

  static AppFailure _failureOf(Object error) => switch (error) {
    NotificationDocumentsError(offline: true) => _network,
    PushError() => _network,
    _ => _unknown,
  };

  /// Whether a reader is signed in, so the choices are the account's.
  bool get signedIn => _currentUserId() != null;

  /// The categories offered (OP-05): the active ones, in their order.
  Future<Result<List<NotificationCategory>>> categories() async {
    try {
      final List<NotificationCategory> all = await _documents.categories();
      final List<NotificationCategory> active =
          all.where((NotificationCategory c) => c.isActive).toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return Ok<List<NotificationCategory>>(active);
    } on Object catch (error) {
      return Err<List<NotificationCategory>>(_failureOf(error));
    }
  }

  /// The system permission now, without asking. An answer that cannot be
  /// read counts as not decided.
  Future<PermissionOutcome> permission() async {
    try {
      return await _push.permissionStatus();
    } on Object {
      return PermissionOutcome.notDetermined;
    }
  }

  /// Whether the explanation (SCR-A-20) was answered on this device.
  Future<bool> explained() async => (await _device.load()).explained;

  /// Records that the reader chose not now on the explanation, so it is not
  /// shown first again.
  Future<void> declineExplanation() async {
    final DeviceChoicesRecord record = await _device.load();
    await _device.save(record.copyWith(explained: true));
  }

  /// Asks the system for permission. The screen has explained first
  /// (SCR-A-20, FR-NOTIF-001). A denial is an outcome, not a failure.
  @override
  Future<Result<PermissionOutcome>> explainAndRequestPermission() async {
    try {
      final PermissionOutcome outcome = await _push.requestPermission();
      final DeviceChoicesRecord record = await _device.load();
      await _device.save(record.copyWith(explained: true));
      return Ok<PermissionOutcome>(outcome);
    } on Object catch (error) {
      return Err<PermissionOutcome>(_failureOf(error));
    }
  }

  @override
  Future<Result<NotificationPreferences>> getPreferences() async {
    try {
      final Set<String> chosen = await _chosen(_currentUserId());
      return Ok<NotificationPreferences>(_preferencesOf(chosen));
    } on Object catch (error) {
      return Err<NotificationPreferences>(_failureOf(error));
    }
  }

  static NotificationPreferences _preferencesOf(Set<String> chosen) =>
      NotificationPreferences(
        optedIn: chosen.isNotEmpty,
        categoryIds: (chosen.toList()..sort()),
      );

  Future<Set<String>> _chosen(String? userId) async => userId == null
      ? (await _device.load()).visitorCategories
      : await _documents.preferences(userId);

  /// Saves [p]: the account's records for a reader, the device's for a
  /// visitor; then the device's topics follow. Opting out keeps no category.
  @override
  Future<Result<void>> savePreferences(NotificationPreferences p) => _serial(
    () async {
      final Set<String> wanted = p.optedIn ? p.categoryIds.toSet() : <String>{};
      final String? userId = _currentUserId();
      try {
        if (userId == null) {
          final DeviceChoicesRecord record = await _device.load();
          await _device.save(record.copyWith(visitorCategories: wanted));
        } else {
          final Set<String> stored = await _documents.preferences(userId);
          for (final String id in wanted.difference(stored)) {
            await _documents.addPreference(userId, id);
          }
          for (final String id in stored.difference(wanted)) {
            await _documents.removePreference(userId, id);
          }
        }
        await _subscribeTo(wanted);
        return const Ok<void>(null);
      } on Object catch (error) {
        return Err<void>(_failureOf(error));
      }
    },
  );

  /// Brings the device's topics in line with the choices of [userId], or a
  /// visitor's when null: at start-up and when a reader signs in (DATA-007).
  Future<Result<void>> syncTo(String? userId) => _serial(() async {
    try {
      if (userId != null) {
        final DeviceChoicesRecord record = await _device.load();
        await _device.save(
          record.copyWith(visitorCategories: const <String>{}),
        );
      }
      await _subscribeTo(await _chosen(userId));
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err<void>(_failureOf(error));
    }
  });

  /// Ends every subscription of this device, then its registration with the
  /// push service, and forgets a visitor's choices, so the device receives
  /// nothing until someone chooses again (OQ-55 working position,
  /// MOD11-P2-T04). Each subscription is ended first, because whether
  /// unregistering ends them is what OQ-55 asks. The account's records are
  /// not touched: they come back at the next sign-in, or go with the account
  /// (OP-12). A failure part-way leaves the rest to the next start, whose
  /// visitor sync ends what is left.
  Future<Result<void>> clearDevice() => _serial(() async {
    try {
      final DeviceChoicesRecord record = await _device.load();
      await _device.save(record.copyWith(visitorCategories: const <String>{}));
      await _subscribeTo(const <String>{});
      await _push.unregister();
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err<void>(_failureOf(error));
    }
  });

  // Subscribes to each wanted topic and ends each other one this device
  // holds, saving after each step, so a failure part-way is resumed by the
  // next change and nothing is left that the reader did not choose.
  Future<void> _subscribeTo(Set<String> categoryIds) async {
    final Set<String> wanted = <String>{
      for (final String id in categoryIds) ?topicFor(id),
    };
    DeviceChoicesRecord record = await _device.load();
    for (final String topic in record.subscribedTopics.difference(wanted)) {
      await _push.unsubscribe(topic);
      record = record.copyWith(
        subscribedTopics: record.subscribedTopics.difference(<String>{topic}),
      );
      await _device.save(record);
    }
    for (final String topic in wanted.difference(record.subscribedTopics)) {
      await _push.subscribe(topic);
      record = record.copyWith(
        subscribedTopics: <String>{...record.subscribedTopics, topic},
      );
      await _device.save(record);
    }
  }

  /// The target of each tapped notification (FR-NOTIF-005). A notification
  /// that opens nothing, or names an unknown target, opens the app only.
  @override
  Stream<NotificationTarget> watchOpened() => _push
      .openedMessages()
      .map(targetOf)
      .where((NotificationTarget? t) => t != null)
      .cast<NotificationTarget>();

  /// The target in a notification's [data], as OP-25 sends it.
  static NotificationTarget? targetOf(Map<String, String> data) {
    final String? ref = data['target_ref'];
    if (ref == null || ref.isEmpty) {
      return null;
    }
    return switch (data['target_type']) {
      'issue' => NotificationTarget(
        type: NotificationTargetType.issue,
        targetId: ref,
      ),
      'news_post' => NotificationTarget(
        type: NotificationTargetType.article,
        targetId: ref,
      ),
      _ => null,
    };
  }
}
