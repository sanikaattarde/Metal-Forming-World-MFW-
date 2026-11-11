/// What this device keeps about notifications: whether the reader has seen
/// the explanation (SCR-A-20), a visitor's chosen categories, which the
/// backend never stores (GS-Q46, OQ-09), and the topics this device is
/// subscribed to, so that a change ends the old ones (FR-NOTIF-003).
final class DeviceChoicesRecord {
  /// Creates the record.
  const DeviceChoicesRecord({
    this.explained = false,
    this.visitorCategories = const <String>{},
    this.subscribedTopics = const <String>{},
  });

  /// Whether the explanation was shown and answered.
  final bool explained;

  /// A visitor's chosen categories.
  final Set<String> visitorCategories;

  /// The topics this device is subscribed to.
  final Set<String> subscribedTopics;

  /// A copy with the given parts changed.
  DeviceChoicesRecord copyWith({
    bool? explained,
    Set<String>? visitorCategories,
    Set<String>? subscribedTopics,
  }) => DeviceChoicesRecord(
    explained: explained ?? this.explained,
    visitorCategories: visitorCategories ?? this.visitorCategories,
    subscribedTopics: subscribedTopics ?? this.subscribedTopics,
  );
}

/// The device's [DeviceChoicesRecord]. A JSON file in the app, a fake in
/// tests. A record that cannot be read counts as empty.
abstract interface class DeviceChoices {
  /// The record now.
  Future<DeviceChoicesRecord> load();

  /// Replaces the record.
  Future<void> save(DeviceChoicesRecord record);
}
