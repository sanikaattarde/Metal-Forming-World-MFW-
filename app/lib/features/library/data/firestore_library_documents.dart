import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../domain/library_documents.dart';

/// The [LibraryDocuments] adapter for Cloud Firestore (DEC-003), over
/// `users/{uid}/bookmarks` and `users/{uid}/favourites`
/// (`DATABASE_AND_DATA_MODEL.md` section 12). Timestamps become UTC
/// `DateTime`s. Thin on purpose: it runs only on a device or simulator.
///
/// Offline (MOD08-P2-T04; OQ-10 working position of 12 November 2026,
/// PROVISIONAL): the lists come from the SDK's copy on the device, and a
/// change is kept on the device and sent when the connection returns. The
/// database does not answer such a write until then, so with no
/// connection a write returns at once, and otherwise after [serverWait] at
/// most. A refusal that comes later puts the record back in the watched
/// list. [watchSync] tells the screens which of these is the case.
final class FirestoreLibraryDocuments implements LibraryDocuments {
  /// Creates the adapter over the database. The connectivity service, when
  /// given, tells it when there is no connection at all.
  FirestoreLibraryDocuments(this._firestore, {this._connectivity});

  final FirebaseFirestore _firestore;
  final ConnectivityService? _connectivity;

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

  Future<void> _write(Future<void> Function() call) async {
    final ConnectionType? connection = await _connectivity
        ?.current()
        .then<ConnectionType?>(
          (ConnectionType c) => c,
          onError: (Object _) => null,
        );
    if (connection == ConnectionType.none) {
      // Kept on the device at once; the server answers when it can.
      unawaited(call().then<void>((_) {}, onError: (Object _) {}));
      return;
    }
    return _guard(() => call().timeout(serverWait, onTimeout: () {}));
  }

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

  @override
  Stream<LibrarySync> watchSync(String uid) {
    SnapshotMetadata? bookmarks;
    SnapshotMetadata? favourites;
    final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> subs =
        <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
    late final StreamController<LibrarySync> out;
    void emit() {
      final SnapshotMetadata? b = bookmarks;
      final SnapshotMetadata? f = favourites;
      if (b == null || f == null) {
        return;
      }
      out.add(
        LibrarySync(
          fromDevice: b.isFromCache || f.isFromCache,
          pendingChanges: b.hasPendingWrites || f.hasPendingWrites,
        ),
      );
    }

    out = StreamController<LibrarySync>(
      onListen: () {
        subs
          ..add(
            _bookmarks(uid)
                .snapshots(includeMetadataChanges: true)
                .listen((QuerySnapshot<Map<String, dynamic>> s) {
                  bookmarks = s.metadata;
                  emit();
                }, onError: out.addError),
          )
          ..add(
            _favourites(uid)
                .snapshots(includeMetadataChanges: true)
                .listen((QuerySnapshot<Map<String, dynamic>> s) {
                  favourites = s.metadata;
                  emit();
                }, onError: out.addError),
          );
      },
      onCancel: () async {
        for (final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> sub
            in subs) {
          await sub.cancel();
        }
      },
    );
    return out.stream.distinct();
  }
}
