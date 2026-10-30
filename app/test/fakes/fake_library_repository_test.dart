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

void main() {
  group('FakeLibraryRepository [IC-04]', () {
    late FakeServer server;

    setUp(() {
      server = FakeServer();
      seedLibraryFixtures(server);
    });

    FakeLibraryRepository deviceFor(TestUser? user) => FakeLibraryRepository(
      server,
      FakeAuthService(server, signedInAs: user),
    );

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
          await firstDevice.addBookmark('fx-iss-05', 2),
        );
        await settle();

        expect(added.issueId, 'fx-iss-05');
        expect(added.page, 2);
        expect(pagesOf(seen.last), contains('fx-iss-05/2'));
      },
    );

    test(
      'bookmarking needs a signed-in reader with full access [MOD-08]',
      () async {
        expect(
          failureCodeOf(await deviceFor(null).addBookmark('fx-iss-01', 1)),
          FailureCode.unauthenticated,
        );
        expect(
          failureCodeOf(await deviceFor(fxUsr03).addBookmark('fx-iss-01', 1)),
          FailureCode.forbidden,
        );
      },
    );

    test('a page below 1 is invalidInput [OP-LIB-02]', () async {
      expect(
        failureCodeOf(await deviceFor(fxUsr01).addBookmark('fx-iss-01', 0)),
        FailureCode.invalidInput,
      );
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
}
