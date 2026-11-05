import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_server.dart';
import 'fake_streams.dart';

/// Fake MOD-08 for one device, over a shared [FakeServer] (IC-04, IC-08).
///
/// Two devices on one server see the same items (RS FR-BKM-004). A reader
/// reads and changes only their own items. Bookmarks and favourites follow
/// the `fullAccess` column of section 4.1; favourites for incomplete access
/// are OQ-12. The fake does not know page counts, so only a page or a file
/// revision below 1 is out of range (section 6.8, rule 5). It keeps no
/// bookmark list of its own, so it does not make the contract's check of the
/// list before an add. Every add goes to the server, and a repeat on another
/// revision takes the refusal path of rule 2.
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
  Future<Result<Bookmark>> addBookmark(
    String issueId,
    int page,
    int fileRevision,
  ) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<Bookmark>(AppFailure(FailureCode.unauthenticated));
    }
    if (_auth.currentAccessState != AccessState.fullAccess) {
      return const Err<Bookmark>(AppFailure(FailureCode.forbidden));
    }
    // Rule 5: checked before the write, so that a refusal below can come
    // only from ownership or a repeated add.
    if (page < 1 || fileRevision < 1) {
      return const Err<Bookmark>(AppFailure(FailureCode.invalidInput));
    }
    final Result<Bookmark> written = _server.addBookmark(
      userId,
      issueId,
      page,
      fileRevision,
    );
    if (written is Ok<Bookmark>) {
      return written;
    }
    // Rule 2: a refusal looks the same for every cause, so read the record
    // to tell them apart. A record that exists is the stored bookmark, none
    // means the write was refused for ownership, and a failed read returns
    // its own failure.
    return switch (_server.readBookmark(userId, issueId, page)) {
      Ok<Bookmark?>(:final Bookmark? value) =>
        value == null
            ? const Err<Bookmark>(AppFailure(FailureCode.forbidden))
            : Ok<Bookmark>(value),
      Err<Bookmark?>(:final AppFailure failure) => Err<Bookmark>(failure),
    };
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
