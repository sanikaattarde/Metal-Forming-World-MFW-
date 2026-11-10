import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/profile_form.dart';

/// The [ProfileDocuments] adapter for Cloud Firestore (DEC-003), over the
/// paths of `DATABASE_AND_DATA_MODEL.md` section 12. The access rules allow
/// these reads: the reader's own profile, and the public settings and
/// segments (`backend/firestore.rules`).
///
/// Thin on purpose: it runs only on a device or simulator.
final class FirestoreProfileDocuments implements ProfileDocuments {
  /// Creates the adapter over [firestore].
  FirestoreProfileDocuments(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<Map<String, Object?>?> watchProfile(String uid) => _firestore
      .doc('users/$uid/profile/current')
      .snapshots()
      .map(
        (DocumentSnapshot<Map<String, dynamic>> snapshot) => snapshot.exists
            ? Map<String, Object?>.from(snapshot.data()!)
            : null,
      );

  @override
  Future<Map<String, Object?>?> readPublicConfig() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .doc('config/public')
        .get();
    return snapshot.exists ? Map<String, Object?>.from(snapshot.data()!) : null;
  }

  @override
  Future<List<SegmentOption>> readSegments() async {
    final QuerySnapshot<Map<String, dynamic>> segments = await _firestore
        .collection('segments')
        .get();
    return segments.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Object? name = doc.data()['name'];
      return SegmentOption(id: doc.id, name: name is String ? name : doc.id);
    }).toList();
  }
}
