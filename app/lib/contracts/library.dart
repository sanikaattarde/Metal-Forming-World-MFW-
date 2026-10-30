import 'result.dart';

/// A page bookmark (RS DATA-005).
final class Bookmark {
  /// Creates a bookmark.
  const Bookmark({
    required this.bookmarkId,
    required this.issueId,
    required this.page,
    required this.createdAt,
  });

  /// Opaque bookmark ID.
  final String bookmarkId;

  /// The bookmarked issue.
  final String issueId;

  /// The bookmarked page, 1-based.
  final int page;

  /// When the bookmark was added, in UTC.
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
/// `unauthenticated`, `forbidden`, `network`, `notFound`.
abstract interface class LibraryRepository {
  /// Emits the reader's bookmarks.
  Stream<List<Bookmark>> watchBookmarks();

  /// Adds a bookmark (OP-LIB-02). Fails with `invalidInput` when the page
  /// is out of range.
  Future<Result<Bookmark>> addBookmark(String issueId, int page);

  /// Removes a bookmark (OP-LIB-03). Fails with `notFound`.
  Future<Result<void>> removeBookmark(String bookmarkId);

  /// Emits the IDs of the reader's favourite issues.
  Stream<Set<String>> watchFavouriteIssueIds();

  /// Marks or unmarks a favourite (OP-LIB-05, idempotent).
  Future<Result<void>> setFavourite(String issueId, bool favourite);
}
