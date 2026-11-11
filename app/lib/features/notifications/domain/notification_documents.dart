/// A notification category (DATA-007, OP-05). The three fixed categories of
/// the working position (GS-Q47); OQ-18 is OPEN.
final class NotificationCategory {
  /// Creates a category.
  const NotificationCategory({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.isActive,
  });

  /// The identifier, which is also the push topic.
  final String id;

  /// The name the reader sees.
  final String name;

  /// The order in the list.
  final int displayOrder;

  /// Whether the category is offered. A preference for an inactive one is
  /// kept (INV-13).
  final bool isActive;
}

/// The records behind MOD-11: OP-05, the public category list, and OP-09,
/// the reader's own preferences (`users/{uid}/notification_preferences`).
/// Cloud Firestore in the app, a fake in tests. Each call throws
/// [NotificationDocumentsError] when the records cannot be read or written.
abstract interface class NotificationDocuments {
  /// Every category, active or not.
  Future<List<NotificationCategory>> categories();

  /// The categories [userId] chose.
  Future<Set<String>> preferences(String userId);

  /// Records that [userId] chose [categoryId] (OP-09 add).
  Future<void> addPreference(String userId, String categoryId);

  /// Removes [userId]'s choice of [categoryId] (OP-09 remove).
  Future<void> removePreference(String userId, String categoryId);
}

/// A read or write of the records that failed. [offline] when the device
/// has no connection.
final class NotificationDocumentsError implements Exception {
  /// Creates the error.
  const NotificationDocumentsError({this.offline = false});

  /// Whether the failure was the connection.
  final bool offline;
}
