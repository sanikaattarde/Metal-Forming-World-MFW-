import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/catalogue_documents.dart';

/// The [CatalogueDocuments] adapter for Cloud Firestore (DEC-003), over the
/// paths of `DATABASE_AND_DATA_MODEL.md` section 12.
///
/// Reads come from the server, not the device's cache: whether the
/// catalogue is shown offline is OQ-10 (MOD05-P2-T05), and a refresh must
/// show a publication change (RS FR-MAG-007, FR-MAG-008). Thin on purpose:
/// it runs only on a device or simulator.
final class FirestoreCatalogueDocuments implements CatalogueDocuments {
  /// Creates the adapter over [firestore].
  FirestoreCatalogueDocuments(this._firestore);

  final FirebaseFirestore _firestore;

  static const GetOptions _server = GetOptions(source: Source.server);

  @override
  Future<List<Map<String, Object?>>> publishedIssues() => _read(() async {
    // The rules allow only a query that asks for published issues.
    final QuerySnapshot<Map<String, dynamic>> issues = await _firestore
        .collection('issues')
        .where('publication_state', isEqualTo: 'published')
        .get(_server);
    return issues.docs.map(_withId).toList();
  });

  @override
  Future<Map<String, Object?>?> issue(String issueId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> issue = await _firestore
          .collection('issues')
          .doc(issueId)
          .get(_server);
      return issue.exists ? _withId(issue) : null;
    } on FirebaseException catch (error) {
      // The rules refuse a missing issue and an unpublished one alike.
      if (error.code == 'permission-denied') {
        return null;
      }
      throw CatalogueReadError(error.code);
    }
  }

  @override
  Future<List<Map<String, Object?>>> categories() => _read(() async {
    final QuerySnapshot<Map<String, dynamic>> categories = await _firestore
        .collection('categories')
        .get(_server);
    return categories.docs.map(_withId).toList();
  });

  @override
  Future<List<Map<String, Object?>>> segments() => _read(() async {
    final QuerySnapshot<Map<String, dynamic>> segments = await _firestore
        .collection('segments')
        .get(_server);
    return segments.docs.map(_withId).toList();
  });

  Future<T> _read<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on FirebaseException catch (error) {
      throw CatalogueReadError(error.code);
    }
  }

  static Map<String, Object?> _withId(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) => <String, Object?>{
    ...?document.data(),
    CatalogueDocuments.idKey: document.id,
  };
}
