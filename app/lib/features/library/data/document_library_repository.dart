import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

import '../domain/library_documents.dart';

/// MOD-08's [LibraryRepository] over the reader's own documents
/// (MOD08-P2-T01, MOD08-P2-T02), following `API_AND_MODULE_CONTRACTS.md`
/// section 6.8:
///
/// - A bookmark's identifier is `<issueId>_<page>` (rule 1, PROPOSED), so
///   adding a page twice is the same record.
/// - [addBookmark] checks page and revision first (rule 5), and full access
///   (the rules cannot look up the account, `SECURITY_AND_ACCESS_CONTROL.md`
///   T25). A repeated add is refused by the rules when it would change the
///   record, so a refusal reads the record: one that exists is returned with
///   its first revision and date (rule 2), none is `forbidden`.
/// - Favourites need full access too: YG's answer to OQ-12 of 10 November
///   2026, PROVISIONAL until MFW answers.
/// - Reading offline follows the database's own cache until OQ-10 decides
///   (MOD08-P2-T04).
final class DocumentLibraryRepository implements LibraryRepository {
  /// Creates the repository over [documents], for the reader that
  /// [currentUserId] names, whose access [accessState] gives.
  DocumentLibraryRepository(
    this._documents, {
    required this._currentUserId,
    required this._accessState,
    Stream<String?>? userChanges,
    DateTime Function()? clock,
  }) : _userChanges = userChanges ?? const Stream<String?>.empty(),
       _clock = clock ?? _utcNow;

  static DateTime _utcNow() => DateTime.now().toUtc();

  final LibraryDocuments _documents;
  final String? Function() _currentUserId;
  final AccessState Function() _accessState;
  final Stream<String?> _userChanges;
  final DateTime Function() _clock;

  /// The identifier of the bookmark of [issueId] at [page] (rule 1).
  static String bookmarkIdOf(String issueId, int page) => '${issueId}_$page';

  @override
  Stream<List<Bookmark>> watchBookmarks() => _perUser(
    (String uid) => _documents
        .watchBookmarks(uid)
        .map(
          (List<Map<String, Object?>> rows) =>
              <Bookmark>[
                for (final Map<String, Object?> row in rows) ?bookmarkFrom(row),
              ]..sort((Bookmark a, Bookmark b) {
                final int byIssue = a.issueId.compareTo(b.issueId);
                return byIssue != 0 ? byIssue : a.page.compareTo(b.page);
              }),
        ),
    const <Bookmark>[],
  );

  @override
  Future<Result<Bookmark>> addBookmark(
    String issueId,
    int page,
    int fileRevision,
  ) async {
    final String? uid = _currentUserId();
    if (uid == null) {
      return const Err<Bookmark>(AppFailure(FailureCode.unauthenticated));
    }
    if (_accessState() != AccessState.fullAccess) {
      return const Err<Bookmark>(AppFailure(FailureCode.forbidden));
    }
    if (issueId.isEmpty || page < 1 || fileRevision < 1) {
      return const Err<Bookmark>(AppFailure(FailureCode.invalidInput));
    }
    final String id = bookmarkIdOf(issueId, page);
    final DateTime now = _clock();
    try {
      await _documents.writeBookmark(uid, id, <String, Object?>{
        'bookmark_id': id,
        'user_id': uid,
        'issue_id': issueId,
        'page_number': page,
        'file_revision': fileRevision,
        'created_at': now,
      });
      return Ok<Bookmark>(
        Bookmark(
          bookmarkId: id,
          issueId: issueId,
          page: page,
          fileRevision: fileRevision,
          createdAt: now,
        ),
      );
    } on LibraryWriteError catch (error) {
      if (error.code != 'permission-denied') {
        return Err<Bookmark>(failureFromLibrary(error.code));
      }
    }
    // Rule 2: the refusal looks the same for every cause; the record tells.
    try {
      final Map<String, Object?>? stored = await _documents.readBookmark(
        uid,
        id,
      );
      final Bookmark? bookmark = stored == null
          ? null
          : bookmarkFrom(<String, Object?>{
              ...stored,
              LibraryDocuments.idKey: id,
            });
      return bookmark == null
          ? const Err<Bookmark>(AppFailure(FailureCode.forbidden))
          : Ok<Bookmark>(bookmark);
    } on LibraryWriteError catch (error) {
      return Err<Bookmark>(failureFromLibrary(error.code));
    }
  }

  @override
  Future<Result<void>> removeBookmark(String bookmarkId) async {
    final String? uid = _currentUserId();
    if (uid == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    try {
      if (await _documents.readBookmark(uid, bookmarkId) == null) {
        return const Err<void>(AppFailure(FailureCode.notFound));
      }
      await _documents.deleteBookmark(uid, bookmarkId);
      return const Ok<void>(null);
    } on LibraryWriteError catch (error) {
      return Err<void>(failureFromLibrary(error.code));
    }
  }

  @override
  Stream<Set<String>> watchFavouriteIssueIds() => _perUser(
    (String uid) => _documents.watchFavourites(uid),
    const <String>{},
  );

  @override
  Future<Result<void>> setFavourite(String issueId, bool favourite) async {
    final String? uid = _currentUserId();
    if (uid == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    if (_accessState() != AccessState.fullAccess) {
      return const Err<void>(AppFailure(FailureCode.forbidden));
    }
    if (issueId.isEmpty) {
      return const Err<void>(AppFailure(FailureCode.invalidInput));
    }
    try {
      // Idempotent (OP-LIB-05): a favourite that is already there, or
      // already gone, is left as it is, so the rules see no change.
      final bool has = await _documents.hasFavourite(uid, issueId);
      if (favourite && !has) {
        await _documents.writeFavourite(uid, issueId, <String, Object?>{
          'user_id': uid,
          'issue_id': issueId,
          'created_at': _clock(),
        });
      } else if (!favourite && has) {
        await _documents.deleteFavourite(uid, issueId);
      }
      return const Ok<void>(null);
    } on LibraryWriteError catch (error) {
      return Err<void>(failureFromLibrary(error.code));
    }
  }

  /// [watch] for the signed-in reader, again for each new reader, and
  /// [empty] while signed out.
  Stream<T> _perUser<T>(Stream<T> Function(String uid) watch, T empty) {
    late StreamController<T> out;
    StreamSubscription<T>? current;
    StreamSubscription<String?>? users;
    void follow(String? uid) {
      unawaited(current?.cancel());
      current = null;
      if (uid == null) {
        out.add(empty);
      } else {
        current = watch(uid).listen(out.add, onError: out.addError);
      }
    }

    out = StreamController<T>(
      onListen: () {
        follow(_currentUserId());
        users = _userChanges.distinct().listen(follow);
      },
      onCancel: () async {
        await users?.cancel();
        await current?.cancel();
      },
    );
    return out.stream;
  }
}

/// The bookmark in [row], or null when it is not one.
Bookmark? bookmarkFrom(Map<String, Object?> row) {
  final Object? id = row[LibraryDocuments.idKey] ?? row['bookmark_id'];
  final Object? issueId = row['issue_id'];
  final Object? page = row['page_number'];
  final Object? revision = row['file_revision'];
  final Object? created = row['created_at'];
  if (id is! String ||
      issueId is! String ||
      page is! int ||
      page < 1 ||
      revision is! int ||
      revision < 1 ||
      created is! DateTime) {
    return null;
  }
  return Bookmark(
    bookmarkId: id,
    issueId: issueId,
    page: page,
    fileRevision: revision,
    createdAt: created.toUtc(),
  );
}

/// The failure for a library read or write that failed with [code].
AppFailure failureFromLibrary(String code) {
  final String detail = 'library $code';
  return switch (code) {
    'unavailable' => AppFailure(
      FailureCode.network,
      retryable: true,
      detail: detail,
    ),
    'deadline-exceeded' => AppFailure(
      FailureCode.timeout,
      retryable: true,
      detail: detail,
    ),
    'permission-denied' => AppFailure(FailureCode.forbidden, detail: detail),
    'unauthenticated' => AppFailure(
      FailureCode.unauthenticated,
      detail: detail,
    ),
    'not-found' => AppFailure(FailureCode.notFound, detail: detail),
    'invalid-argument' => AppFailure(FailureCode.invalidInput, detail: detail),
    _ => AppFailure(FailureCode.unknown, retryable: true, detail: detail),
  };
}
