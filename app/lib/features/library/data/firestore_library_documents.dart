import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/library_documents.dart';

/// The [LibraryDocuments] adapter for Cloud Firestore (DEC-003), over
/// `users/{uid}/bookmarks` and `users/{uid}/favourites`
/// (`DATABASE_AND_DATA_MODEL.md` section 12). Timestamps become UTC
/// `DateTime`s. Thin on purpose: it runs only on a device or simulator.
///
/// With no connection a write is kept on the device and sent when the
/// connection returns, but the database does not answer it until then. A
/// write therefore returns after [serverWait] at most, so the reader's
/// bookmark and star are not held for the whole time offline. A refusal
/// that comes later puts the record back in the watched list. More offline
/// behaviour is MOD08-P2-T04, with OQ-10.
final class FirestoreLibraryDocuments implements LibraryDocuments {
  /// Creates the adapter over [firestore].
  FirestoreLibraryDocuments(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _bookmarks(String uid) =>
      _firestore.collection('users').doc(uid).collection('bookmarks');

  CollectionReference<Map<String, dynamic>> _favourites(String uid) =>
      _firestore.collection('users').doc(uid).collection('favourites');

  static Map<String, Object?> _plain(String id, Map<String, dynamic> data) =>
      <String, Object?>{
        for (final MapEntry<String, dynamic> entry in data.entries)
          entry.key: switch (entry.value) {
            final Timestamp at => at.toDate().toUtc(),
            final Object? other => other,
          },
        LibraryDocuments.idKey: id,
      };

  /// How long a write waits for the database's answer.
  static const Duration serverWait = Duration(seconds: 10);

  Future<void> _write(Future<void> Function() call) =>
      _guard(() => call().timeout(serverWait, onTimeout: () {}));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseException catch (error) {
      throw LibraryWriteError(error.code);
    }
  }

  @override
  Stream<List<Map<String, Object?>>> watchBookmarks(String uid) =>
      _bookmarks(uid).snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) =>
            <Map<String, Object?>>[
              for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                  in snapshot.docs)
                _plain(doc.id, doc.data()),
            ],
      );

  @override
  Future<void> writeBookmark(
    String uid,
    String bookmarkId,
    Map<String, Object?> fields,
  ) => _write(() => _bookmarks(uid).doc(bookmarkId).set(fields));

  @override
  Future<Map<String, Object?>?> readBookmark(String uid, String bookmarkId) =>
      _guard(() async {
        final DocumentSnapshot<Map<String, dynamic>> doc = await _bookmarks(uid)
            .doc(bookmarkId)
            .get();
        return doc.exists ? _plain(doc.id, doc.data()!) : null;
      });

  @override
  Future<void> deleteBookmark(String uid, String bookmarkId) =>
      _write(() => _bookmarks(uid).doc(bookmarkId).delete());

  @override
  Stream<Set<String>> watchFavourites(String uid) =>
      _favourites(uid).snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => <String>{
          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs)
            doc.id,
        },
      );

  @override
  Future<void> writeFavourite(
    String uid,
    String issueId,
    Map<String, Object?> fields,
  ) => _write(() => _favourites(uid).doc(issueId).set(fields));

  @override
  Future<bool> hasFavourite(String uid, String issueId) =>
      _guard(() async => (await _favourites(uid).doc(issueId).get()).exists);

  @override
  Future<void> deleteFavourite(String uid, String issueId) =>
      _write(() => _favourites(uid).doc(issueId).delete());
}
