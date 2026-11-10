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

  /// The key under which each bookmark map carries its identifier.
  static const String idKey = '__id';
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
