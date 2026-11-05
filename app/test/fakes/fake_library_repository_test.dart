import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fixtures/fx_library.dart';
import 'fake_auth_service.dart';
import 'fake_library_repository.dart';
import 'fake_server.dart';
import 'test_helpers.dart';
import 'test_users.dart';

Set<String> pagesOf(List<Bookmark> bookmarks) => bookmarks
    .map((Bookmark bookmark) => '${bookmark.issueId}/${bookmark.page}')
    .toSet();

/// Every field of [bookmark], so that two bookmarks can be compared.
List<Object> fieldsOf(Bookmark bookmark) => <Object>[
  bookmark.bookmarkId,
  bookmark.issueId,
  bookmark.page,
  bookmark.fileRevision,
  bookmark.createdAt,
];

void main() {
  group('FakeLibraryRepository [IC-04]', () {
    late FakeServer server;

    setUp(() {
      server = FakeServer();
      seedLibraryFixtures(server);
    });

    FakeLibraryRepository deviceOn(FakeServer on, TestUser? user) =>
        FakeLibraryRepository(on, FakeAuthService(on, signedInAs: user));

    FakeLibraryRepository deviceFor(TestUser? user) => deviceOn(server, user);

    test('implements LibraryRepository', () {
      expect(deviceFor(fxUsr01), isA<LibraryRepository>());
    });

    test(
      'reader A sees FX-LIB-01 and reader B sees FX-LIB-02 [AC-5.4]',
      () async {
        final FakeLibraryRepository readerA = deviceFor(fxUsr01);
        final FakeLibraryRepository readerB = deviceFor(fxUsr06);

        expect(pagesOf(await readerA.watchBookmarks().first), <String>{
          'fx-iss-01/7',
          'fx-iss-02/12',
        });
        expect(await readerA.watchFavouriteIssueIds().first, <String>{
          'fx-iss-03',
        });
        expect(pagesOf(await readerB.watchBookmarks().first), <String>{
          'fx-iss-01/3',
        });
        expect(await readerB.watchFavouriteIssueIds().first, <String>{
          'fx-iss-04',
        });
      },
    );

    test(
      'the seeded bookmarks are all on revision 1 [FX-LIB-01, FX-LIB-02]',
      () async {
        final List<Bookmark> seeded = <Bookmark>[
          ...await deviceFor(fxUsr01).watchBookmarks().first,
          ...await deviceFor(fxUsr06).watchBookmarks().first,
        ];

        expect(seeded, hasLength(3));
        expect(
          seeded.map((Bookmark bookmark) => bookmark.fileRevision),
          everyElement(1),
        );
      },
    );

    test('reader A cannot remove reader B\'s bookmark [SEC-CHK-05]', () async {
      final String readerBBookmarkId = server
          .bookmarksOf(fxUsr06.userId)
          .single
          .bookmarkId;

      expect(
        failureCodeOf(
          await deviceFor(fxUsr01).removeBookmark(readerBBookmarkId),
        ),
        FailureCode.notFound,
      );
      expect(server.bookmarksOf(fxUsr06.userId), hasLength(1));
    });

    test(
      'a bookmark added on one device appears on the second [FR-BKM-004]',
      () async {
        final FakeLibraryRepository firstDevice = deviceFor(fxUsr01);
        final FakeLibraryRepository secondDevice = deviceFor(fxUsr01);
        final List<List<Bookmark>> seen = recordEvents(
          secondDevice.watchBookmarks(),
        );

        final Bookmark added = valueOf(
          await firstDevice.addBookmark('fx-iss-05', 2, 1),
        );
        await settle();

        expect(added.issueId, 'fx-iss-05');
        expect(added.page, 2);
        expect(added.fileRevision, 1);
        expect(pagesOf(seen.last), contains('fx-iss-05/2'));
      },
    );

    test(
      'bookmarking needs a signed-in reader with full access [MOD-08]',
      () async {
        expect(
          failureCodeOf(await deviceFor(null).addBookmark('fx-iss-01', 1, 1)),
          FailureCode.unauthenticated,
        );
        expect(
          failureCodeOf(
            await deviceFor(fxUsr03).addBookmark('fx-iss-01', 1, 1),
          ),
          FailureCode.forbidden,
        );
      },
    );

    group('rule 1: the identifier is derived from the issue and the page', () {
      test('the same issue and page give the same identifier on any server, in any order [INV-14]', () async {
        final FakeServer first = FakeServer();
        final FakeServer second = FakeServer();
        final FakeLibraryRepository onFirst = deviceOn(first, fxUsr07);
        final FakeLibraryRepository onSecond = deviceOn(second, fxUsr07);

        final Bookmark a1 = valueOf(
          await onFirst.addBookmark('fx-iss-05', 2, 1),
        );
        final Bookmark b1 = valueOf(
          await onFirst.addBookmark('fx-iss-06', 3, 1),
        );
        final Bookmark b2 = valueOf(
          await onSecond.addBookmark('fx-iss-06', 3, 1),
        );
        final Bookmark a2 = valueOf(
          await onSecond.addBookmark('fx-iss-05', 2, 1),
        );

        expect(a2.bookmarkId, a1.bookmarkId);
        expect(b2.bookmarkId, b1.bookmarkId);
      });

      test(
        'another page or another issue gives another identifier [INV-14]',
        () async {
          final FakeServer fresh = FakeServer();
          final FakeLibraryRepository library = deviceOn(fresh, fxUsr07);

          final Set<String> ids = <String>{
            for (final (String issueId, int page) in <(String, int)>[
              ('fx-iss-05', 2),
              ('fx-iss-05', 3),
              ('fx-iss-06', 2),
            ])
              valueOf(await library.addBookmark(issueId, page, 1)).bookmarkId,
          };

          expect(ids, hasLength(3));
        },
      );

      test('the revision is not part of the identifier [MOD-08]', () async {
        final FakeServer onRevision1 = FakeServer();
        final FakeServer onRevision3 = FakeServer();

        final Bookmark first = valueOf(
          await deviceOn(onRevision1, fxUsr07).addBookmark('fx-iss-05', 2, 1),
        );
        final Bookmark third = valueOf(
          await deviceOn(onRevision3, fxUsr07).addBookmark('fx-iss-05', 2, 3),
        );

        expect(third.bookmarkId, first.bookmarkId);
      });

      test('removing a bookmark and adding it again brings back the same identifier [INV-14]', () async {
        final FakeLibraryRepository library = deviceFor(fxUsr01);

        final Bookmark first = valueOf(
          await library.addBookmark('fx-iss-05', 2, 1),
        );
        expect(await library.removeBookmark(first.bookmarkId), isA<Ok<void>>());
        final Bookmark again = valueOf(
          await library.addBookmark('fx-iss-05', 2, 1),
        );

        expect(again.bookmarkId, first.bookmarkId);
      });

      test('two readers who bookmark the same page keep separate records [SEC-CHK-05]', () async {
        // Reader B holds FX-LIB-02: FX-ISS-01 page 3.
        final Bookmark readerA = valueOf(
          await deviceFor(fxUsr01).addBookmark('fx-iss-01', 3, 1),
        );
        final Bookmark readerB = server.bookmarksOf(fxUsr06.userId).single;
        expect(readerA.bookmarkId, readerB.bookmarkId);

        expect(
          await deviceFor(fxUsr01).removeBookmark(readerA.bookmarkId),
          isA<Ok<void>>(),
        );

        expect(pagesOf(server.bookmarksOf(fxUsr06.userId)), <String>{
          'fx-iss-01/3',
        });
      });
    });

    group('rule 2: a repeated add changes nothing', () {
      test('a repeat on the same revision returns the stored bookmark and fires no change [OP-LIB-02]', () async {
        final FakeLibraryRepository library = deviceFor(fxUsr01);
        final Bookmark first = valueOf(
          await library.addBookmark('fx-iss-05', 4, 1),
        );
        final List<void> changes = recordEvents(server.changes);

        final Bookmark repeat = valueOf(
          await library.addBookmark('fx-iss-05', 4, 1),
        );

        expect(fieldsOf(repeat), fieldsOf(first));
        expect(changes, isEmpty);
        expect(
          server
              .bookmarksOf(fxUsr01.userId)
              .where((Bookmark bookmark) => bookmark.page == 4),
          hasLength(1),
        );
      });

      test('a repeat on a later revision keeps the first revision and creation time [FR-BKM-001]', () async {
        DateTime now = DateTime.utc(2026, 11, 1, 9);
        server = FakeServer(clock: () => now);
        final FakeLibraryRepository firstDevice = deviceFor(fxUsr01);
        final FakeLibraryRepository secondDevice = deviceFor(fxUsr01);

        final Bookmark first = valueOf(
          await firstDevice.addBookmark('fx-iss-05', 4, 1),
        );
        now = DateTime.utc(2026, 11, 2, 9);
        final Bookmark repeat = valueOf(
          await secondDevice.addBookmark('fx-iss-05', 4, 2),
        );

        expect(repeat.fileRevision, 1);
        expect(repeat.createdAt, DateTime.utc(2026, 11, 1, 9));
        expect(fieldsOf(repeat), fieldsOf(first));
        expect(
          fieldsOf(server.bookmarksOf(fxUsr01.userId).single),
          fieldsOf(first),
        );
      });

      test('removing and adding again stores the revision that is open [FR-BKM-007]', () async {
        DateTime now = DateTime.utc(2026, 11, 1, 9);
        server = FakeServer(clock: () => now);
        final FakeLibraryRepository library = deviceFor(fxUsr01);

        final Bookmark first = valueOf(
          await library.addBookmark('fx-iss-05', 4, 1),
        );
        expect(await library.removeBookmark(first.bookmarkId), isA<Ok<void>>());
        now = DateTime.utc(2026, 11, 2, 9);
        final Bookmark again = valueOf(
          await library.addBookmark('fx-iss-05', 4, 2),
        );

        expect(again.bookmarkId, first.bookmarkId);
        expect(again.fileRevision, 2);
        expect(again.createdAt, DateTime.utc(2026, 11, 2, 9));
      });

      test('a refusal with no record behind it is forbidden [OP-07]', () async {
        server.refuseBookmarkWrites = true;

        expect(
          failureCodeOf(
            await deviceFor(fxUsr01).addBookmark('fx-iss-05', 4, 1),
          ),
          FailureCode.forbidden,
        );
        expect(
          pagesOf(server.bookmarksOf(fxUsr01.userId)),
          isNot(contains('fx-iss-05/4')),
        );
      });

      test(
        'a refusal with a record behind it returns the record [OP-07]',
        () async {
          final Bookmark seeded = server.bookmarksOf(fxUsr01.userId).first;
          server.refuseBookmarkWrites = true;

          final Bookmark returned = valueOf(
            await deviceFor(fxUsr01)
                .addBookmark(seeded.issueId, seeded.page, seeded.fileRevision),
          );

          expect(fieldsOf(returned), fieldsOf(seeded));
        },
      );

      test(
        'a failed read after a refusal returns the read\'s own failure [OP-07]',
        () async {
          final FakeLibraryRepository firstDevice = deviceFor(fxUsr01);
          final FakeLibraryRepository secondDevice = deviceFor(fxUsr01);
          valueOf(await firstDevice.addBookmark('fx-iss-05', 4, 1));
          const AppFailure readFailure = AppFailure(
            FailureCode.network,
            retryable: true,
          );
          server.bookmarkReadFailure = readFailure;

          final Result<Bookmark> repeat = await secondDevice.addBookmark(
            'fx-iss-05',
            4,
            2,
          );

          expect(failureOf(repeat), same(readFailure));
        },
      );

      test('a first add does not read the record [OP-07]', () async {
        server.bookmarkReadFailure = const AppFailure(FailureCode.network);

        final Bookmark added = valueOf(
          await deviceFor(fxUsr01).addBookmark('fx-iss-05', 4, 1),
        );

        expect(added.page, 4);
      });
    });

    group('rule 5: page and revision are checked before the write', () {
      test('a page below 1 is invalidInput [OP-LIB-02]', () async {
        final FakeLibraryRepository library = deviceFor(fxUsr01);
        final int writesBefore = server.bookmarkWriteRequests;

        for (final int page in <int>[0, -1]) {
          expect(
            failureCodeOf(await library.addBookmark('fx-iss-05', page, 1)),
            FailureCode.invalidInput,
          );
        }

        expect(server.bookmarkWriteRequests, writesBefore);
        expect(server.bookmarksOf(fxUsr01.userId), hasLength(2));
      });

      test('a revision below 1 is invalidInput [OP-LIB-02]', () async {
        final FakeLibraryRepository library = deviceFor(fxUsr01);
        final int writesBefore = server.bookmarkWriteRequests;

        for (final int revision in <int>[0, -1]) {
          expect(
            failureCodeOf(await library.addBookmark('fx-iss-05', 2, revision)),
            FailureCode.invalidInput,
          );
        }

        expect(server.bookmarkWriteRequests, writesBefore);
        expect(server.bookmarksOf(fxUsr01.userId), hasLength(2));
      });

      test('page 1 on revision 1 is accepted [OP-LIB-02]', () async {
        final Bookmark added = valueOf(
          await deviceFor(fxUsr01).addBookmark('fx-iss-05', 1, 1),
        );

        expect(added.page, 1);
        expect(added.fileRevision, 1);
      });

      test('an invalid value is never read as a refusal [MOD-08]', () async {
        server.refuseBookmarkWrites = true;

        expect(
          failureCodeOf(
            await deviceFor(fxUsr01).addBookmark('fx-iss-05', 0, 1),
          ),
          FailureCode.invalidInput,
        );
        expect(
          failureCodeOf(
            await deviceFor(fxUsr01).addBookmark('fx-iss-05', 2, 0),
          ),
          FailureCode.invalidInput,
        );
      });
    });

    test('setFavourite is idempotent [FR-BKM-003]', () async {
      final FakeLibraryRepository library = deviceFor(fxUsr01);

      expect(await library.setFavourite('fx-iss-05', true), isA<Ok<void>>());
      expect(await library.setFavourite('fx-iss-05', true), isA<Ok<void>>());
      expect(await library.watchFavouriteIssueIds().first, <String>{
        'fx-iss-03',
        'fx-iss-05',
      });
      expect(await library.setFavourite('fx-iss-05', false), isA<Ok<void>>());
      expect(await library.setFavourite('fx-iss-05', false), isA<Ok<void>>());
      expect(await library.watchFavouriteIssueIds().first, <String>{
        'fx-iss-03',
      });
    });
  });

  group('FakeServer OP-07 manageBookmarks', () {
    late FakeServer server;

    setUp(() => server = FakeServer());

    test('a page or revision below 1 is INVALID_ARGUMENT and stores nothing [OP-07]', () {
      final List<(int, int)> invalid = <(int, int)>[
        (0, 1),
        (-1, 1),
        (1, 0),
        (1, -1),
      ];
      for (final (int page, int revision) in invalid) {
        expect(
          failureCodeOf(
            server.addBookmark(fxUsr01.userId, 'fx-iss-05', page, revision),
          ),
          FailureCode.invalidInput,
        );
      }

      expect(server.bookmarksOf(fxUsr01.userId), isEmpty);
    });

    test('a replay with the same values changes nothing, and a write that would change the record is refused [OP-07]', () {
      final Bookmark first = valueOf(
        server.addBookmark(fxUsr01.userId, 'fx-iss-05', 4, 1),
      );

      final Bookmark replay = valueOf(
        server.addBookmark(fxUsr01.userId, 'fx-iss-05', 4, 1),
      );
      final Result<Bookmark> change = server.addBookmark(
        fxUsr01.userId,
        'fx-iss-05',
        4,
        2,
      );

      expect(fieldsOf(replay), fieldsOf(first));
      expect(failureCodeOf(change), FailureCode.forbidden);
      expect(
        fieldsOf(server.bookmarksOf(fxUsr01.userId).single),
        fieldsOf(first),
      );
    });

    test('counts every write request that reaches it [OP-07]', () {
      final int before = server.bookmarkWriteRequests;

      server.addBookmark(fxUsr01.userId, 'fx-iss-05', 4, 1);
      server.addBookmark(fxUsr01.userId, 'fx-iss-05', 4, 2);
      server.addBookmark(fxUsr01.userId, 'fx-iss-05', 0, 1);

      expect(server.bookmarkWriteRequests, before + 3);
    });
  });
}
