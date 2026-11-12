import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/catalogue_documents.dart';

/// The [CatalogueDocuments] adapter for Cloud Firestore (DEC-003), over the
/// paths of `DATABASE_AND_DATA_MODEL.md` section 12.
///
/// Reads come from the server, so a refresh shows a publication change
/// (RS FR-MAG-007, FR-MAG-008). When the server cannot be reached, a read
/// falls back to the copy the SDK keeps on the device from earlier reads,
/// and [lastReadFromCache] says so (MOD05-P2-T05, NFR-OFF-002; OQ-10
/// working position of 12 November 2026, PROVISIONAL). With nothing kept,
/// the read fails as before. Thin on purpose: it runs only on a device or
/// simulator.
final class FirestoreCatalogueDocuments implements CatalogueDocuments {
  /// Creates the adapter over [firestore].
  FirestoreCatalogueDocuments(this._firestore);

  final FirebaseFirestore _firestore;

  static const GetOptions _server = GetOptions(source: Source.server);
  static const GetOptions _cache = GetOptions(source: Source.cache);

  bool _fromCache = false;

  @override
  bool get lastReadFromCache => _fromCache;

  /// The codes for a server that cannot be reached now.
  static bool _offline(String code) =>
      code == 'unavailable' || code == 'deadline-exceeded';

  /// [query] from the server, or, offline, from the device's copy when it
  /// holds any document.
  Future<QuerySnapshot<Map<String, dynamic>>> _query(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> fresh = await query.get(
        _server,
      );
      _fromCache = false;
      return fresh;
    } on FirebaseException catch (error) {
      if (!_offline(error.code)) {
        rethrow;
      }
      final QuerySnapshot<Map<String, dynamic>>? kept = await query
          .get(_cache)
          .then<QuerySnapshot<Map<String, dynamic>>?>(
            (QuerySnapshot<Map<String, dynamic>> s) => s,
            onError: (Object _) => null,
          );
      if (kept == null || kept.docs.isEmpty) {
        rethrow;
      }
      _fromCache = true;
      return kept;
    }
  }

  @override
  Future<List<Map<String, Object?>>> publishedIssues() => _read(() async {
    // The rules allow only a query that asks for published issues.
    final QuerySnapshot<Map<String, dynamic>> issues = await _query(
      _firestore
          .collection('issues')
          .where('publication_state', isEqualTo: 'published'),
    );
    return issues.docs.map(_withId).toList();
  });

  @override
  Future<Map<String, Object?>?> issue(String issueId) async {
    final DocumentReference<Map<String, dynamic>> ref = _firestore
        .collection('issues')
        .doc(issueId);
    try {
      final DocumentSnapshot<Map<String, dynamic>> issue = await ref.get(
        _server,
      );
      _fromCache = false;
      return issue.exists ? _withId(issue) : null;
    } on FirebaseException catch (error) {
      // The rules refuse a missing issue and an unpublished one alike.
      if (error.code == 'permission-denied') {
        return null;
      }
      if (_offline(error.code)) {
        final DocumentSnapshot<Map<String, dynamic>>? kept = await ref
            .get(_cache)
            .then<DocumentSnapshot<Map<String, dynamic>>?>(
              (DocumentSnapshot<Map<String, dynamic>> s) => s,
              onError: (Object _) => null,
            );
        if (kept != null &&
            kept.exists &&
            kept.data()?['publication_state'] == 'published') {
          _fromCache = true;
          return _withId(kept);
        }
      }
      throw CatalogueReadError(error.code);
    }
  }

  @override
  Future<List<Map<String, Object?>>> categories() => _read(() async {
    final QuerySnapshot<Map<String, dynamic>> categories = await _query(
      _firestore.collection('categories'),
    );
    return categories.docs.map(_withId).toList();
  });

  @override
  Future<List<Map<String, Object?>>> segments() => _read(() async {
    final QuerySnapshot<Map<String, dynamic>> segments = await _query(
      _firestore.collection('segments'),
    );
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
