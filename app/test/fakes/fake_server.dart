import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

import 'test_users.dart';

/// A reader account held by [FakeServer].
final class FakeAccount {
  /// Creates an account.
  FakeAccount({
    required this.userId,
    required this.email,
    required this.method,
    required this.emailVerified,
  });

  /// Opaque account ID.
  final String userId;

  /// Synthetic address.
  final String email;

  /// Sign-in method.
  final SignInMethod method;

  /// Whether the address is verified; changes when the reader verifies.
  bool emailVerified;
}

/// Server-side state shared by every fake device: accounts, profiles,
/// consent, library items and notification preferences.
///
/// Every record is keyed by the reader's ID, which stands in for the
/// own-records rule that MOD-13 enforces (RS NFR-SEC-005, NFR-SEC-006).
final class FakeServer {
  /// Creates a server holding an account for each of [accounts], and a
  /// synthetic profile for each persona whose profile is complete.
  FakeServer({
    Iterable<TestUser> accounts = readerPersonas,
    DateTime Function()? clock,
  }) : clock = clock ?? _fixedClock {
    for (final TestUser user in accounts) {
      _accounts[user.userId] = FakeAccount(
        userId: user.userId,
        email: user.email,
        method: user.method,
        emailVerified: user.emailVerified,
      );
      if (user.profileComplete) {
        _profiles[user.userId] = ReaderProfile(
          name: 'Test Reader ${user.fixtureId.substring(7)}',
          occupation: 'Test Engineer',
          domainOfWork: 'Test Domain',
        );
      }
    }
  }

  static DateTime _fixedClock() => DateTime.utc(2026);

  /// The injected clock for creation times.
  final DateTime Function() clock;

  final Map<String, FakeAccount> _accounts = <String, FakeAccount>{};
  final Map<String, ReaderProfile> _profiles = <String, ReaderProfile>{};
  final Map<String, List<ConsentRecord>> _consents =
      <String, List<ConsentRecord>>{};
  final Map<String, Map<String, Bookmark>> _bookmarks =
      <String, Map<String, Bookmark>>{};
  final Map<String, Map<String, Favourite>> _favourites =
      <String, Map<String, Favourite>>{};
  final Map<String, NotificationPreferences> _preferences =
      <String, NotificationPreferences>{};
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  int _nextAccount = 1;
  int _bookmarkWriteRequests = 0;

  /// When true, OP-07 refuses every bookmark write that passes its checks,
  /// as it would for a write the owner rules deny. The refusal is the same
  /// whatever the cause (API_AND_MODULE_CONTRACTS section 6.8, rule 2).
  bool refuseBookmarkWrites = false;

  /// When set, every read of a single bookmark record fails with it, such as
  /// a `network` failure.
  AppFailure? bookmarkReadFailure;

  /// Fires after every change.
  Stream<void> get changes => _changes.stream;

  /// How many bookmark writes have reached OP-07, counting the invalid and
  /// the refused ones, so a test can tell that a check ran before the write.
  int get bookmarkWriteRequests => _bookmarkWriteRequests;

  /// The account with [userId], if any.
  FakeAccount? accountById(String userId) => _accounts[userId];

  /// The account with [email], if any.
  FakeAccount? accountByEmail(String email) {
    for (final FakeAccount account in _accounts.values) {
      if (account.email == email) {
        return account;
      }
    }
    return null;
  }

  /// Creates an account with a new ID.
  FakeAccount createAccount({
    required String email,
    required SignInMethod method,
    required bool emailVerified,
  }) {
    final String userId = 'fx-new-${_twoDigits(_nextAccount++)}';
    final FakeAccount account = FakeAccount(
      userId: userId,
      email: email,
      method: method,
      emailVerified: emailVerified,
    );
    _accounts[userId] = account;
    _notify();
    return account;
  }

  /// Marks [email] verified, as if the reader opened the link.
  void markEmailVerified(String email) {
    accountByEmail(email)?.emailVerified = true;
    _notify();
  }

  /// The reader's saved profile; a saved profile counts as complete.
  ReaderProfile? profileOf(String userId) => _profiles[userId];

  /// Saves the reader's profile.
  void saveProfile(String userId, ReaderProfile profile) {
    _profiles[userId] = profile;
    _notify();
  }

  /// Records consent for the reader.
  void addConsent(String userId, ConsentRecord consent) {
    (_consents[userId] ??= <ConsentRecord>[]).add(consent);
    _notify();
  }

  /// The reader's bookmarks.
  List<Bookmark> bookmarksOf(String userId) => List<Bookmark>.unmodifiable(
    _bookmarks[userId]?.values ?? const <Bookmark>[],
  );

  /// OP-07 add. The record's ID is derived from the issue and the page, so
  /// a repeated add reaches the same record (rule 1). The server keeps the
  /// first record: a write with the same values changes nothing and returns
  /// the stored record, and a write that would change it is refused with
  /// `forbidden`, which looks the same as every other refusal (rule 2). A
  /// page or revision below 1 fails with `invalidInput`
  /// (`INVALID_ARGUMENT`; the revision check is PROPOSED).
  Result<Bookmark> addBookmark(
    String userId,
    String issueId,
    int page,
    int fileRevision,
  ) {
    _bookmarkWriteRequests++;
    if (page < 1 || fileRevision < 1) {
      return const Err<Bookmark>(AppFailure(FailureCode.invalidInput));
    }
    if (refuseBookmarkWrites) {
      return const Err<Bookmark>(AppFailure(FailureCode.forbidden));
    }
    final String bookmarkId = _bookmarkIdFor(issueId, page);
    final Map<String, Bookmark> own = _bookmarks[userId] ??=
        <String, Bookmark>{};
    final Bookmark? stored = own[bookmarkId];
    if (stored != null) {
      return stored.fileRevision == fileRevision
          ? Ok<Bookmark>(stored)
          : const Err<Bookmark>(AppFailure(FailureCode.forbidden));
    }
    final Bookmark bookmark = Bookmark(
      bookmarkId: bookmarkId,
      issueId: issueId,
      page: page,
      fileRevision: fileRevision,
      createdAt: clock(),
    );
    own[bookmarkId] = bookmark;
    _notify();
    return Ok<Bookmark>(bookmark);
  }

  /// OP-07 read of the reader's bookmark for [issueId] and [page]: the
  /// record, or null if there is none. Fails with [bookmarkReadFailure]
  /// when that is set.
  Result<Bookmark?> readBookmark(String userId, String issueId, int page) {
    final AppFailure? failure = bookmarkReadFailure;
    if (failure != null) {
      return Err<Bookmark?>(failure);
    }
    return Ok<Bookmark?>(_bookmarks[userId]?[_bookmarkIdFor(issueId, page)]);
  }

  /// Removes the reader's own bookmark; false if the reader has none with
  /// that ID.
  bool removeBookmark(String userId, String bookmarkId) {
    if (_bookmarks[userId]?.remove(bookmarkId) == null) {
      return false;
    }
    _notify();
    return true;
  }

  /// The reader's favourite issue IDs.
  Set<String> favouriteIssueIdsOf(String userId) =>
      Set<String>.unmodifiable(_favourites[userId]?.keys ?? const <String>[]);

  /// Marks or unmarks a favourite; repeating a call changes nothing.
  void setFavourite(String userId, String issueId, bool favourite) {
    final Map<String, Favourite> own = _favourites[userId] ??=
        <String, Favourite>{};
    if (favourite) {
      own.putIfAbsent(
        issueId,
        () => Favourite(issueId: issueId, createdAt: clock()),
      );
    } else {
      own.remove(issueId);
    }
    _notify();
  }

  /// The reader's notification preferences, if saved.
  NotificationPreferences? preferencesOf(String userId) => _preferences[userId];

  /// Saves the reader's notification preferences.
  void savePreferences(String userId, NotificationPreferences preferences) {
    _preferences[userId] = preferences;
    _notify();
  }

  /// Deletes the account and every record of the reader (OP-ACC-01).
  void deleteUser(String userId) {
    _accounts.remove(userId);
    _profiles.remove(userId);
    _consents.remove(userId);
    _bookmarks.remove(userId);
    _favourites.remove(userId);
    _preferences.remove(userId);
    _notify();
  }

  /// Whether any record of the reader is still held.
  bool holdsDataFor(String userId) =>
      _accounts.containsKey(userId) ||
      _profiles.containsKey(userId) ||
      (_consents[userId]?.isNotEmpty ?? false) ||
      (_bookmarks[userId]?.isNotEmpty ?? false) ||
      (_favourites[userId]?.isNotEmpty ?? false) ||
      _preferences.containsKey(userId);

  void _notify() => _changes.add(null);
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// The bookmark ID for an issue and a page. The format is a placeholder: the
/// real one is settled in the backend spike (DEC-003). The page comes last,
/// so two different pairs never give the same ID.
String _bookmarkIdFor(String issueId, int page) => 'fx-bkm-$issueId-$page';
