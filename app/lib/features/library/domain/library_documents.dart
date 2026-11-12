/// The reader's own bookmark and favourite documents
/// (`DATABASE_AND_DATA_MODEL.md` sections 4.10, 4.11 and 12), as MOD-08
/// reads and writes them. A port, so the rules of
/// `API_AND_MODULE_CONTRACTS.md` section 6.8 are tested without the
/// database. The access rules (`backend/firestore.rules`) let a reader read
/// and write their own records only, refuse any change to a stored record,
/// and need the key of a bookmark to be `<issue_id>_<page_number>`.
abstract interface class LibraryDocuments {
  /// The bookmark documents of [uid], as they change.
  Stream<List<Map<String, Object?>>> watchBookmarks(String uid);

  /// Creates or repeats the bookmark [bookmarkId] of [uid] with [fields].
  /// Throws [LibraryWriteError] when the rules refuse it.
  Future<void> writeBookmark(
    String uid,
    String bookmarkId,
    Map<String, Object?> fields,
  );

  /// The bookmark [bookmarkId] of [uid], or null when there is none.
  Future<Map<String, Object?>?> readBookmark(String uid, String bookmarkId);

  /// Deletes the bookmark [bookmarkId] of [uid].
  Future<void> deleteBookmark(String uid, String bookmarkId);

  /// The issue identifiers of [uid]'s favourites, as they change.
  Stream<Set<String>> watchFavourites(String uid);

  /// Creates or repeats the favourite [issueId] of [uid] with [fields].
  Future<void> writeFavourite(
    String uid,
    String issueId,
    Map<String, Object?> fields,
  );

  /// Whether [uid] has [issueId] as a favourite.
  Future<bool> hasFavourite(String uid, String issueId);

  /// Deletes the favourite [issueId] of [uid].
  Future<void> deleteFavourite(String uid, String issueId);

  /// Where [uid]'s records come from and whether changes wait to be sent,
  /// as it changes (MOD08-P2-T04).
  Stream<LibrarySync> watchSync(String uid);

  /// The key under which each bookmark map carries its identifier.
  static const String idKey = '__id';
}

/// Where the reader's library stands (MOD08-P2-T04, RS FR-BKM-008; OQ-10
/// working position of 12 November 2026, PROVISIONAL): read from the
/// device because the server cannot be reached, and with changes kept on
/// the device that the server has not had yet.
final class LibrarySync {
  /// Creates the state.
  const LibrarySync({required this.fromDevice, required this.pendingChanges});

  /// In step with the server, nothing waiting.
  static const LibrarySync current = LibrarySync(
    fromDevice: false,
    pendingChanges: false,
  );

  /// Read from the device's copy.
  final bool fromDevice;

  /// Changes wait to be sent.
  final bool pendingChanges;

  @override
  bool operator ==(Object other) =>
      other is LibrarySync &&
      other.fromDevice == fromDevice &&
      other.pendingChanges == pendingChanges;

  @override
  int get hashCode => Object.hash(fromDevice, pendingChanges);
}

/// A library that says where it stands (MOD08-P2-T04), for the notices on
/// SCR-A-16 and SCR-A-17.
abstract interface class LibrarySyncSource {
  /// The signed-in reader's state, as it changes.
  Stream<LibrarySync> watchSync();
}

/// A write or read the database refused or could not make, with its error
/// code, such as `permission-denied` or `unavailable`.
final class LibraryWriteError implements Exception {
  /// Creates the error.
  const LibraryWriteError(this.code);

  /// The database's error code.
  final String code;

  @override
  String toString() => 'LibraryWriteError($code)';
}
