// MOD08-P2-T04: bookmarks and favourites offline, with changes kept on the
// device until the connection returns (FR-BKM-008, NFR-OFF-002; OQ-10
// working position of 12 November 2026, PROVISIONAL). The SDK's own cache
// and queue run only on a device; here the documents port reports them.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/library/library.dart';

import 'document_library_repository_test.dart' show RuledLibraryDocuments;

const LibrarySync _offline = LibrarySync(
  fromDevice: true,
  pendingChanges: true,
);
const LibrarySync _waiting = LibrarySync(
  fromDevice: false,
  pendingChanges: true,
);

void main() {
  late RuledLibraryDocuments documents;
  late String? uid;
  late StreamController<String?> users;
  late DocumentLibraryRepository library;

  setUp(() {
    documents = RuledLibraryDocuments();
    uid = 'fx-usr-01';
    users = StreamController<String?>.broadcast(sync: true);
    library = DocumentLibraryRepository(
      documents,
      currentUserId: () => uid,
      accessState: () => AccessState.fullAccess,
      userChanges: users.stream,
      clock: () => DateTime.utc(2026, 11, 12),
    );
  });

  StreamController<LibrarySync> syncOf(String user) => documents.syncs[user] ??=
      StreamController<LibrarySync>.broadcast(sync: true);

  group('the library says where it stands', () {
    test(
      'it follows the signed-in reader, and is current while signed out',
      () async {
        final List<LibrarySync> seen = <LibrarySync>[];
        final StreamSubscription<LibrarySync> sub = library.watchSync().listen(
          seen.add,
        );
        await Future<void>.delayed(Duration.zero);
        syncOf('fx-usr-01').add(_offline);
        await Future<void>.delayed(Duration.zero);

        uid = null;
        users.add(null);
        syncOf('fx-usr-01').add(_waiting);
        await Future<void>.delayed(Duration.zero);

        expect(seen, <LibrarySync>[_offline, LibrarySync.current]);
        await sub.cancel();
      },
    );

    test(
      'a change offline is accepted on the device at once [FR-BKM-008]',
      () async {
        // The documents port answers as soon as the change is kept, so the
        // reader is not held while offline; the bookmark is in the list.
        final Result<Bookmark> added = await library.addBookmark(
          'fx-iss-01',
          4,
          1,
        );
        expect(added, isA<Ok<Bookmark>>());
        expect(
          (await library.watchBookmarks().first).single.bookmarkId,
          'fx-iss-01_4',
        );
      },
    );
  });

  group('SCR-A-16 and SCR-A-17 offline', () {
    Future<void> pump(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: LibraryScreen(
          library: library,
          titleOf: (String id) async => id,
          onOpenBookmark: (Bookmark _) {},
          onOpenIssue: (String _) {},
        ),
      ),
    );

    testWidgets('offline, the notice says the lists are from the device', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await tester.pumpAndSettle();
      expect(find.text(LibraryText.offline), findsNothing);

      syncOf('fx-usr-01').add(_offline);
      await tester.pumpAndSettle();
      expect(find.text(LibraryText.offline), findsOneWidget);
      expect(find.text(LibraryText.pending), findsNothing);

      // The notice stays over both views.
      await tester.tap(find.text('Favourites'));
      await tester.pumpAndSettle();
      expect(find.text(LibraryText.offline), findsOneWidget);
    });

    testWidgets('back online, changes still waiting say so, then the notice '
        'goes', (WidgetTester tester) async {
      await pump(tester);
      await tester.pumpAndSettle();

      syncOf('fx-usr-01').add(_waiting);
      await tester.pumpAndSettle();
      expect(find.text(LibraryText.pending), findsOneWidget);

      syncOf('fx-usr-01').add(LibrarySync.current);
      await tester.pumpAndSettle();
      expect(find.text(LibraryText.pending), findsNothing);
      expect(find.text(LibraryText.offline), findsNothing);
    });
  });
}
