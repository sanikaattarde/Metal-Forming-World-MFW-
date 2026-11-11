import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/notification_documents.dart';

/// The [NotificationDocuments] adapter for Cloud Firestore (DEC-003), over
/// the paths of `DATABASE_AND_DATA_MODEL.md` section 12: the public
/// `notification_categories` (OP-05) and the reader's own
/// `users/{uid}/notification_preferences/{category_id}` (OP-09), whose rule
/// takes exactly `user_id`, `category_id` and `created_at`.
///
/// Thin on purpose: it runs only on a device or simulator.
final class FirestoreNotificationDocuments implements NotificationDocuments {
  /// Creates the adapter over [firestore].
  FirestoreNotificationDocuments(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _preferences(String userId) =>
      _firestore.collection('users/$userId/notification_preferences');

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseException catch (error) {
      throw NotificationDocumentsError(offline: error.code == 'unavailable');
    }
  }

  @override
  Future<List<NotificationCategory>> categories() => _guard(() async {
    final QuerySnapshot<Map<String, dynamic>> all = await _firestore
        .collection('notification_categories')
        .get();
    return all.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      final Object? name = data['name'];
      final Object? order = data['display_order'];
      return NotificationCategory(
        id: doc.id,
        name: name is String ? name : doc.id,
        displayOrder: order is int ? order : 0,
        isActive: data['is_active'] == true,
      );
    }).toList();
  });

  @override
  Future<Set<String>> preferences(String userId) => _guard(() async {
    final QuerySnapshot<Map<String, dynamic>> chosen = await _preferences(
      userId,
    ).get();
    return chosen.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toSet();
  });

  @override
  Future<void> addPreference(String userId, String categoryId) =>
      _guard(() async {
        final DocumentReference<Map<String, dynamic>> ref = _preferences(userId)
            .doc(categoryId);
        // A repeat of an add is harmless: the record exists already.
        if ((await ref.get()).exists) {
          return;
        }
        await ref.set(<String, Object>{
          'user_id': userId,
          'category_id': categoryId,
          'created_at': FieldValue.serverTimestamp(),
        });
      });

  @override
  Future<void> removePreference(String userId, String categoryId) =>
      _guard(() => _preferences(userId).doc(categoryId).delete());
}
