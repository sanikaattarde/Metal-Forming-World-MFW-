import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_server.dart';
import 'fake_streams.dart';

/// Fake MOD-08 for one device, over a shared [FakeServer] (IC-04, IC-08).
///
/// Two devices on one server see the same items (RS FR-BKM-004). A reader
/// reads and changes only their own items. Bookmarks and favourites follow
/// the `fullAccess` column of section 4.1; favourites for incomplete access
/// are OQ-12. The fake does not know page counts, so only a page below 1 is
/// out of range.
final class FakeLibraryRepository implements LibraryRepository {
  /// Creates the repository over [_server], for the reader signed in on
  /// [_auth].
  FakeLibraryRepository(this._server, this._auth);

  final FakeServer _server;
  final FakeAuthService _auth;

  @override
  Stream<List<Bookmark>> watchBookmarks() => watchDerived(() {
    final String? userId = _auth.currentUserId;
    return userId == null ? const <Bookmark>[] : _server.bookmarksOf(userId);
  }, <Stream<void>>[_auth.changes, _server.changes]);

  @override
  Future<Result<Bookmark>> addBookmark(String issueId, int page) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<Bookmark>(AppFailure(FailureCode.unauthenticated));
    }
    if (_auth.currentAccessState != AccessState.fullAccess) {
      return const Err<Bookmark>(AppFailure(FailureCode.forbidden));
    }
    if (page < 1) {
      return const Err<Bookmark>(AppFailure(FailureCode.invalidInput));
    }
    return Ok<Bookmark>(_server.addBookmark(userId, issueId, page));
  }

  @override
  Future<Result<void>> removeBookmark(String bookmarkId) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    if (!_server.removeBookmark(userId, bookmarkId)) {
      return const Err<void>(AppFailure(FailureCode.notFound));
    }
    return const Ok<void>(null);
  }

  @override
  Stream<Set<String>> watchFavouriteIssueIds() => watchDerived(() {
    final String? userId = _auth.currentUserId;
    return userId == null
        ? const <String>{}
        : _server.favouriteIssueIdsOf(userId);
  }, <Stream<void>>[_auth.changes, _server.changes]);

  @override
  Future<Result<void>> setFavourite(String issueId, bool favourite) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    if (_auth.currentAccessState != AccessState.fullAccess) {
      return const Err<void>(AppFailure(FailureCode.forbidden));
    }
    _server.setFavourite(userId, issueId, favourite);
    return const Ok<void>(null);
  }
}
