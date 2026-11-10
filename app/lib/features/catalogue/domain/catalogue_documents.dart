/// The catalogue's documents as the database holds them
/// (`DATABASE_AND_DATA_MODEL.md` sections 4 and 12), read by MOD-05.
///
/// A port inside this feature, so the parsing and the failure mapping are
/// tested without the database. Each map carries its document's identifier
/// under [idKey]. The access rules allow a read of published issues only
/// (`backend/firestore.rules`), and of every category and segment.
abstract interface class CatalogueDocuments {
  /// Every published issue, read from the server (OP-CAT-01).
  Future<List<Map<String, Object?>>> publishedIssues();

  /// The published issue [issueId], or null when it is missing or not
  /// published: the rules refuse both alike (OP-CAT-02).
  Future<Map<String, Object?>?> issue(String issueId);

  /// Every issue category (OP-CAT-03).
  Future<List<Map<String, Object?>>> categories();

  /// Every industry segment, for the segment filter (MOD05-P2-T02).
  Future<List<Map<String, Object?>>> segments();

  /// The key under which each map carries its document's identifier.
  static const String idKey = '__id';
}

/// A read that failed, with the database's error code, such as
/// `unavailable`, `deadline-exceeded` or `permission-denied`.
final class CatalogueReadError implements Exception {
  /// Creates the error.
  const CatalogueReadError(this.code);

  /// The database's error code.
  final String code;

  @override
  String toString() => 'CatalogueReadError($code)';
}
