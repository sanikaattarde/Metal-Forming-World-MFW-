import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/library/library.dart';

import '../../fakes/test_helpers.dart';

/// The reader's documents in memory, refusing what `backend/firestore.rules`
/// refuses: a write that changes a stored record, and a bookmark whose key
/// is not `<issue_id>_<page_number>`.
final class RuledLibraryDocuments implements LibraryDocuments {
  final Map<String, Map<String, Map<String, Object?>>> bookmarks =
      <String, Map<String, Map<String, Object?>>>{};
  final Map<String, Map<String, Map<String, Object?>>> favourites =
      <String, Map<String, Map<String, Object?>>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  /// When set, every read and write throws it.
  LibraryWriteError? error;

  void _check() {
    final LibraryWriteError? set = error;
    if (set != null) {
      throw set;
    }
  }

  static bool _same(Map<String, Object?> a, Map<String, Object?> b) =>
      a.length == b.length &&
      a.entries.every((MapEntry<String, Object?> e) => b[e.key] == e.value);

  /// [read] now and after each change; cancelling stops it at once.
  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> out;
    StreamSubscription<void>? changes;
    out = StreamController<T>(
      onListen: () {
        if (T == List<Map<String, Object?>>) {
          bookmarkWatches++;
        }
        out.add(read());
        changes = _changes.stream.listen((void _) => out.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  /// How many bookmark watches started.
  int bookmarkWatches = 0;

  @override
  Stream<List<Map<String, Object?>>> watchBookmarks(String uid) => _watch(
    () => <Map<String, Object?>>[
      for (final MapEntry<String, Map<String, Object?>> e
          in (bookmarks[uid] ?? <String, Map<String, Object?>>{}).entries)
        <String, Object?>{...e.value, LibraryDocuments.idKey: e.key},
    ],
  );

  @override
  Future<void> writeBookmark(
    String uid,
    String bookmarkId,
    Map<String, Object?> fields,
  ) async {
    _check();
    if (bookmarkId != '${fields['issue_id']}_${fields['page_number']}') {
      throw const LibraryWriteError('permission-denied');
    }
    final Map<String, Map<String, Object?>> own = bookmarks.putIfAbsent(
      uid,
      () => <String, Map<String, Object?>>{},
    );
    final Map<String, Object?>? stored = own[bookmarkId];
    if (stored != null && !_same(stored, fields)) {
      throw const LibraryWriteError('permission-denied');
    }
    own[bookmarkId] = Map<String, Object?>.of(fields);
    _changes.add(null);
  }

  @override
  Future<Map<String, Object?>?> readBookmark(
    String uid,
    String bookmarkId,
  ) async {
    _check();
    return bookmarks[uid]?[bookmarkId];
  }

  @override
  Future<void> deleteBookmark(String uid, String bookmarkId) async {
    _check();
    bookmarks[uid]?.remove(bookmarkId);
    _changes.add(null);
  }

  @override
  Stream<Set<String>> watchFavourites(String uid) => _watch(
    () => (favourites[uid] ?? <String, Map<String, Object?>>{}).keys.toSet(),
  );

  @override
  Future<void> writeFavourite(
    String uid,
    String issueId,
    Map<String, Object?> fields,
  ) async {
    _check();
    final Map<String, Map<String, Object?>> own = favourites.putIfAbsent(
      uid,
      () => <String, Map<String, Object?>>{},
    );
    if (own.containsKey(issueId)) {
      throw const LibraryWriteError('permission-denied');
    }
    own[issueId] = fields;
    _changes.add(null);
  }

  @override
  Future<bool> hasFavourite(String uid, String issueId) async {
    _check();
    return favourites[uid]?.containsKey(issueId) ?? false;
  }

  @override
  Future<void> deleteFavourite(String uid, String issueId) async {
    _check();
    favourites[uid]?.remove(issueId);
    _changes.add(null);
  }

  /// The state [watchSync] reports for each reader; set by a test.
  final Map<String, StreamController<LibrarySync>> syncs =
      <String, StreamController<LibrarySync>>{};

  @override
  Stream<LibrarySync> watchSync(String uid) =>
      (syncs[uid] ??= StreamController<LibrarySync>.broadcast(
        sync: true,
      )).stream;
}

void main() {
  late RuledLibraryDocuments documents;
  late String? uid;
  late AccessState access;
  late StreamController<String?> users;
  late DateTime now;
  late DocumentLibraryRepository library;

  setUp(() {
    documents = RuledLibraryDocuments();
    uid = 'fx-usr-01';
    access = AccessState.fullAccess;
    users = StreamController<String?>.broadcast(sync: true);
    now = DateTime.utc(2026, 11, 10, 9);
    library = DocumentLibraryRepository(
      documents,
      currentUserId: () => uid,
      accessState: () => access,
      userChanges: users.stream,
      clock: () => now,
    );
  });

  group('Bookmarks [MOD08-P2-T01]', () {
    test(
      'adds a bookmark keyed by issue and page [FR-BKM-001, rule 1]',
      () async {
        final Bookmark bookmark = (await library.addBookmark(
          'fx-iss-01',
          7,
          2,
        ) as Ok<Bookmark>).value;
        expect(bookmark.bookmarkId, 'fx-iss-01_7');
        expect(
          documents.bookmarks['fx-usr-01']!['fx-iss-01_7'],
          <String, Object?>{
            'bookmark_id': 'fx-iss-01_7',
            'user_id': 'fx-usr-01',
            'issue_id': 'fx-iss-01',
            'page_number': 7,
            'file_revision': 2,
            'created_at': now,
          },
        );
      },
    );

    test('adding the page again, on a later revision, returns the first '
        'bookmark unchanged [rule 2]', () async {
      await library.addBookmark('fx-iss-01', 7, 1);
      final DateTime first = now;
      now = now.add(const Duration(days: 1));
      final Bookmark again =
          (await library.addBookmark('fx-iss-01', 7, 3) as Ok<Bookmark>).value;
      expect(again.fileRevision, 1);
      expect(again.createdAt, first);
    });

    test('a page or revision below 1 is invalidInput before any write '
        '[rule 5]', () async {
      expect(
        failureCodeOf(await library.addBookmark('fx-iss-01', 0, 1)),
        FailureCode.invalidInput,
      );
      expect(
        failureCodeOf(await library.addBookmark('fx-iss-01', 1, 0)),
        FailureCode.invalidInput,
      );
      expect(documents.bookmarks, isEmpty);
    });

    test('needs a session and full access [section 4.1]', () async {
      uid = null;
      expect(
        failureCodeOf(await library.addBookmark('fx-iss-01', 1, 1)),
        FailureCode.unauthenticated,
      );
      uid = 'fx-usr-01';
      access = AccessState.profileIncomplete;
      expect(
        failureCodeOf(await library.addBookmark('fx-iss-01', 1, 1)),
        FailureCode.forbidden,
      );
    });

    test('a lost connection is a retryable network failure', () async {
      documents.error = const LibraryWriteError('unavailable');
      final AppFailure failure = failureOf(
        await library.addBookmark('fx-iss-01', 1, 1),
      )!;
      expect(failure.code, FailureCode.network);
      expect(failure.retryable, isTrue);
    });

    test('lists bookmarks by issue and page, and follows changes '
        '[FR-BKM-002]', () async {
      final List<List<String>> seen = <List<String>>[];
      final StreamSubscription<List<Bookmark>> watching = library
          .watchBookmarks()
          .listen(
            (List<Bookmark> all) =>
                seen.add(<String>[for (final Bookmark b in all) b.bookmarkId]),
          );
      await settle();
      await library.addBookmark('fx-iss-02', 3, 1);
      await library.addBookmark('fx-iss-01', 9, 1);
      await library.addBookmark('fx-iss-01', 2, 1);
      await settle();
      expect(seen.last, <String>['fx-iss-01_2', 'fx-iss-01_9', 'fx-iss-02_3']);
      await watching.cancel();
    });

    test(
      'removes a bookmark, and a missing one is notFound [FR-BKM-007]',
      () async {
        await library.addBookmark('fx-iss-01', 4, 1);
        expect(await library.removeBookmark('fx-iss-01_4'), isA<Ok<void>>());
        expect(documents.bookmarks['fx-usr-01'], isEmpty);
        expect(
          failureCodeOf(await library.removeBookmark('fx-iss-01_4')),
          FailureCode.notFound,
        );
      },
    );

    test('a reader sees only their own bookmarks, and the list follows a '
        'change of reader [FR-BKM-005]', () async {
      await library.addBookmark('fx-iss-01', 1, 1);
      final List<int> counts = <int>[];
      final StreamSubscription<List<Bookmark>> watching = library
          .watchBookmarks()
          .listen((List<Bookmark> all) => counts.add(all.length));
      await settle();
      uid = 'fx-usr-06';
      users.add('fx-usr-06');
      await settle();
      uid = null;
      users.add(null);
      await settle();
      expect(counts, <int>[1, 0, 0]);
      await watching.cancel();
    });
  });

  test('a sign-in stream that repeats the current reader does not start a '
      'second watch', () async {
    final DocumentLibraryRepository repeating = DocumentLibraryRepository(
      documents,
      currentUserId: () => uid,
      accessState: () => access,
      // Firebase repeats the signed-in reader to a new listener.
      userChanges: Stream<String?>.value('fx-usr-01'),
      clock: () => now,
    );
    final List<List<Bookmark>> seen = <List<Bookmark>>[];
    final StreamSubscription<List<Bookmark>> watching = repeating
        .watchBookmarks()
        .listen(seen.add);
    await settle();
    expect(documents.bookmarkWatches, 1);
    expect(seen, hasLength(1));
    await watching.cancel();
  });

  group('Favourites [MOD08-P2-T02]', () {
    test('marks and unmarks, idempotently [FR-BKM-003, OP-LIB-05]', () async {
      final List<Set<String>> seen = <Set<String>>[];
      final StreamSubscription<Set<String>> watching = library
          .watchFavouriteIssueIds()
          .listen(seen.add);
      await settle();
      expect(await library.setFavourite('fx-iss-01', true), isA<Ok<void>>());
      expect(await library.setFavourite('fx-iss-01', true), isA<Ok<void>>());
      await settle();
      expect(seen.last, <String>{'fx-iss-01'});
      expect(await library.setFavourite('fx-iss-01', false), isA<Ok<void>>());
      expect(await library.setFavourite('fx-iss-01', false), isA<Ok<void>>());
      await settle();
      expect(seen.last, isEmpty);
      await watching.cancel();
    });

    test(
      'favourites need full access (OQ-12, YG\'s answer, PROVISIONAL)',
      () async {
        access = AccessState.emailUnverified;
        expect(
          failureCodeOf(await library.setFavourite('fx-iss-01', true)),
          FailureCode.forbidden,
        );
        expect(documents.favourites, isEmpty);
      },
    );
  });
}
