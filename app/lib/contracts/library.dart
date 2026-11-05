import 'result.dart';

/// A page bookmark (RS DATA-005).
///
/// A bookmark is unique on the reader, the issue and the page, without the
/// revision (API_AND_MODULE_CONTRACTS section 6.8, rule 1).
final class Bookmark {
  /// Creates a bookmark.
  const Bookmark({
    required this.bookmarkId,
    required this.issueId,
    required this.page,
    required this.fileRevision,
    required this.createdAt,
  });

  /// Bookmark ID, derived from the issue and the page and not generated, so
  /// a bookmark that is removed and added again has the same ID (PROPOSED;
  /// section 6.8, rule 1). The app treats it as opaque.
  final String bookmarkId;

  /// The bookmarked issue.
  final String issueId;

  /// The bookmarked page, 1-based.
  final int page;

  /// The revision of the file the reader was reading, at least 1 (PROPOSED;
  /// section 6.8, rule 3). A repeated add on a later revision keeps the
  /// first value (rule 2).
  final int fileRevision;

  /// When the bookmark was first added, in UTC.
  final DateTime createdAt;
}

/// A favourite issue (RS DATA-006).
final class Favourite {
  /// Creates a favourite.
  const Favourite({required this.issueId, required this.createdAt});

  /// The favourite issue.
  final String issueId;

  /// When it was marked, in UTC.
  final DateTime createdAt;
}

/// Bookmarks and favourites stored with the reader's account (MOD-08).
///
/// Own records only, enforced on the server. Bookmarking needs
/// `fullAccess`; favourites for incomplete access are OQ-12. Failures:
/// `unauthenticated`, `forbidden`, `network`, `notFound`, `invalidInput`.
abstract interface class LibraryRepository {
  /// Emits the reader's bookmarks.
  Stream<List<Bookmark>> watchBookmarks();

  /// Adds a bookmark (OP-LIB-02), idempotent (section 6.8, rules 2 and 5).
  ///
  /// Fails with `invalidInput` before it writes when [page] or
  /// [fileRevision] is below 1. Adding a page that is already bookmarked
  /// changes nothing and returns the stored bookmark, which keeps its first
  /// `fileRevision` and `createdAt`, even on a later revision. The server
  /// refuses a write that would change the record, and a refusal looks the
  /// same for every cause, so the repository reads the record to tell them
  /// apart: a record that exists is returned, none fails with `forbidden`,
  /// and a failed read returns the read's own failure, such as `network`.
  Future<Result<Bookmark>> addBookmark(
    String issueId,
    int page,
    int fileRevision,
  );

  /// Removes a bookmark (OP-LIB-03). Fails with `notFound`.
  Future<Result<void>> removeBookmark(String bookmarkId);

  /// Emits the IDs of the reader's favourite issues.
  Stream<Set<String>> watchFavouriteIssueIds();

  /// Marks or unmarks a favourite (OP-LIB-05, idempotent).
  Future<Result<void>> setFavourite(String issueId, bool favourite);
}
