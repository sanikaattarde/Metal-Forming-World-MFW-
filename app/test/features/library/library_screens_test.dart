import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/library/library.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../../fakes/fake_auth_service.dart';
import '../../fakes/fake_library_repository.dart';
import '../../fakes/fake_server.dart';
import '../../fakes/test_users.dart';
import '../reader/reader_screen_test.dart' show FakeDocument, FakeRenderer;

const LocalIssueFile file = LocalIssueFile(
  issueId: 'fx-iss-01',
  fileRevision: 2,
  path: '/private/issues/issue-fx-iss-01-r2.pdf',
);

FakeLibraryRepository libraryFor(FakeServer server, TestUser user) =>
    FakeLibraryRepository(server, FakeAuthService(server, signedInAs: user));

Future<String> titleOf(String issueId) async => 'Title of $issueId';

void main() {
  group('BookmarkButton in the reader [MOD08-P2-T01]', () {
    Future<void> pumpReader(
      WidgetTester tester,
      LibraryRepository library,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: ReaderScreen(
            file: file,
            title: 'Test Issue 01',
            renderer: FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(5))),
            initialPage: 3,
            actions: (ReaderController reader) => <Widget>[
              BookmarkButton(
                library: library,
                issueId: file.issueId,
                fileRevision: file.fileRevision,
                reader: reader,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('bookmarks the page shown with the file revision, and removes '
        'it again [FR-BKM-001, FR-BKM-007, rule 3]', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      await pumpReader(tester, libraryFor(server, fxUsr01));

      await tester.tap(find.byTooltip('Bookmark this page'));
      await tester.pumpAndSettle();
      final Bookmark bookmark = server.bookmarksOf('fx-usr-01').single;
      expect(bookmark.page, 3);
      expect(bookmark.fileRevision, 2);
      expect(find.text('Bookmark added.'), findsOneWidget);
      expect(
        find.byTooltip('Remove the bookmark of this page'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Remove the bookmark of this page'));
      await tester.pumpAndSettle();
      expect(server.bookmarksOf('fx-usr-01'), isEmpty);
    });

    testWidgets('follows the page: another page is not shown as bookmarked', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      await pumpReader(tester, libraryFor(server, fxUsr01));
      await tester.tap(find.byTooltip('Bookmark this page'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Bookmark this page'), findsOneWidget);
    });

    testWidgets('a refusal is said, not hidden', (WidgetTester tester) async {
      final FakeServer server = FakeServer();
      await pumpReader(tester, libraryFor(server, fxUsr03));
      await tester.tap(find.byTooltip('Bookmark this page'));
      await tester.pumpAndSettle();
      expect(find.text('You do not have access.'), findsOneWidget);
      expect(server.bookmarksOf('fx-usr-03'), isEmpty);
    });
  });

  group('LibraryScreen, SCR-A-16 [MOD08-P2-T01]', () {
    Future<List<Bookmark>> pumpLibrary(
      WidgetTester tester,
      LibraryRepository library,
    ) async {
      final List<Bookmark> opened = <Bookmark>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: LibraryScreen(
            library: library,
            titleOf: titleOf,
            onOpenBookmark: opened.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('lists bookmarks by issue with their pages, and one opens '
        'the reader at its page [FR-BKM-002, FR-BKM-006, AC-5.1]', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      final FakeLibraryRepository library = libraryFor(server, fxUsr01);
      await library.addBookmark('fx-iss-01', 12, 1);
      await library.addBookmark('fx-iss-02', 4, 1);
      await library.addBookmark('fx-iss-01', 3, 1);
      final List<Bookmark> opened = await pumpLibrary(tester, library);

      expect(find.text('TITLE OF FX-ISS-01'), findsOneWidget);
      expect(find.text('TITLE OF FX-ISS-02'), findsOneWidget);
      expect(find.text('Page 3'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Page 3')).dy,
        lessThan(tester.getTopLeft(find.text('Page 12')).dy),
      );

      await tester.tap(find.text('Page 12'));
      expect(opened.single.issueId, 'fx-iss-01');
      expect(opened.single.page, 12);
    });

    testWidgets('removes a bookmark from the list [FR-BKM-007]', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      final FakeLibraryRepository library = libraryFor(server, fxUsr01);
      await library.addBookmark('fx-iss-01', 5, 1);
      await pumpLibrary(tester, library);

      await tester.tap(find.byTooltip('Remove the bookmark'));
      await tester.pumpAndSettle();
      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(server.bookmarksOf('fx-usr-01'), isEmpty);
    });

    testWidgets('shows the empty state with no bookmarks', (
      WidgetTester tester,
    ) async {
      await pumpLibrary(tester, libraryFor(FakeServer(), fxUsr01));
      expect(find.text('No bookmarks yet'), findsOneWidget);
    });

    testWidgets('a second device of the same reader shows the same '
        'bookmarks [FR-BKM-004, AC-5.3]', (WidgetTester tester) async {
      final FakeServer server = FakeServer();
      await libraryFor(server, fxUsr01).addBookmark('fx-iss-01', 8, 1);
      await pumpLibrary(tester, libraryFor(server, fxUsr01));
      expect(find.text('Page 8'), findsOneWidget);
    });

    testWidgets('another reader sees none of them [FR-BKM-005, AC-5.4]', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      await libraryFor(server, fxUsr01).addBookmark('fx-iss-01', 8, 1);
      await pumpLibrary(tester, libraryFor(server, fxUsr06));
      expect(find.text('No bookmarks yet'), findsOneWidget);
    });

    testWidgets('meets the tap-target and label guidelines', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      final FakeLibraryRepository library = libraryFor(server, fxUsr01);
      await library.addBookmark('fx-iss-01', 5, 1);
      await pumpLibrary(tester, library);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
