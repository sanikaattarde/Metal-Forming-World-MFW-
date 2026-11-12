import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/content_routes.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/core/config/app_config.dart';
import 'package:mfw_app/features/downloads/downloads.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_catalogue_repository.dart';
import '../fakes/fake_download_manager.dart';
import '../fakes/fake_issue_file_service.dart';
import '../fakes/fake_library_repository.dart';
import '../fakes/fake_news_repository.dart';
import '../features/sharing/share_test.dart' show RecordingShareSheet;
import '../fixtures/fx_issue_files.dart';
import '../fakes/fake_server.dart';
import '../fakes/fake_reader_preferences.dart';
import '../features/reader/reader_screen_test.dart'
    show FakeDocument, FakeRenderer, phone, useSize;
import '../fakes/test_users.dart';
import 'app_harness.dart';
import 'router_test.dart' show titled;

void main() {
  group('Share [MOD10-P1-T01]', () {
    final AppConfig listed = AppConfig(
      environment: AppEnvironment.local,
      storeLinkAndroid: Uri.parse('https://play.example.test/details?id=x'),
      storeLinkIos: Uri.parse('https://apps.example.test/app/id1'),
    );

    testWidgets('a visitor shares an issue with both store links '
        '[FR-SHR-001, FR-SHR-002]', (WidgetTester tester) async {
      final RecordingShareSheet sheet = RecordingShareSheet();
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
        share: sheet,
        config: listed,
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();

      final String text = sheet.shared.single.text;
      expect(text, startsWith('Test Issue 01'));
      expect(text, contains('play.example.test'));
      expect(text, contains('apps.example.test'));
    });

    testWidgets('before any listing, issue details offer no Share', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
        share: RecordingShareSheet(),
        config: const AppConfig(environment: AppEnvironment.local),
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();

      expect(find.byTooltip('Share'), findsNothing);
    });

    testWidgets('an article is shared with its website address '
        '[FR-SHR-003, FR-SHR-004]', (WidgetTester tester) async {
      final RecordingShareSheet sheet = RecordingShareSheet();
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        news: FakeNewsRepository(posts: <NewsPost>[syntheticPost('9001')]),
        share: sheet,
        config: const AppConfig(environment: AppEnvironment.local),
      );
      router.go('/news/9001');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();

      expect(
        sheet.shared.single.text,
        'Synthetic post 9001\nhttps://news.example.test/synthetic-post-9001/',
      );
    });
  });

  group('Turning pages [MOD07-P2-T02]', () {
    testWidgets('Swipe chosen in settings opens the next issue in the swipe '
        'mode [FR-READ-008]', (WidgetTester tester) async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final FakeDownloadManager downloads = FakeDownloadManager(
        auth,
        FakeIssueFileService(auth, files: fxIssueFiles),
      );
      await downloads.start('fx-iss-01', mobileDataAccepted: true);
      final MemoryReaderPreferences preferences = MemoryReaderPreferences();
      final GoRouter router = await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        downloads: downloads,
        renderer: FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(4))),
        readerPreferences: preferences,
      );
      router.go('/issues/fx-iss-01/read');
      await tester.pumpAndSettle();
      expect(find.byType(PageTurnView), findsOneWidget);

      router.go('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.text(ReaderModeText.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swipe'));
      await tester.pumpAndSettle();
      expect(preferences.kept, ReaderMode.swipe);

      router.go('/issues/fx-iss-01/read');
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(PageTurnView), findsNothing);
    });
  });

  group('News routes [MOD09-P2-T01]', () {
    testWidgets('a visitor opens the News tab and an article, and back '
        'returns to the list [FR-NEWS-007]', (WidgetTester tester) async {
      final FakeNewsRepository news = FakeNewsRepository(
        posts: <NewsPost>[syntheticPost('9002', day: 2), syntheticPost('9001')],
        categories: const <NewsCategory>[
          NewsCategory(categoryId: '7', name: 'Industry News'),
        ],
      );
      await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
        news: news,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('News'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Synthetic post 9002'), findsOneWidget);

      await tester.tap(find.text('Synthetic post 9001'));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic body.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic post 9002'), findsOneWidget);
    });

    testWidgets('an article opened directly goes back to the list', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        news: FakeNewsRepository(posts: <NewsPost>[syntheticPost('9001')]),
      );
      router.go('/news/9001');
      await tester.pumpAndSettle();
      expect(find.text('Synthetic body.'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/news');
    });

    testWidgets('without a news site the routes stay placeholders', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
      );
      router.go('/news');
      await tester.pumpAndSettle();
      expect(titled(ShellText.news), findsOneWidget);
    });
  });

  group('Catalogue routes [MOD05-P2-T01]', () {
    testWidgets('a visitor opens the catalogue and an issue from it, and '
        'back returns to the catalogue [FR-MAG-001, FR-SRCH-006]', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
      );
      router.go('/catalogue');
      await tester.pumpAndSettle();
      expect(titled(ShellText.catalogue), findsOneWidget);

      await tester.tap(find.text('Test Issue 02'));
      await tester.pumpAndSettle();
      expect(titled('Test Issue 02'), findsOneWidget);
      expect(
        find.text('Sign in to read and download full issues.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(titled(ShellText.catalogue), findsOneWidget);
    });

    testWidgets('a visitor who signs in from an issue is sent to sign in '
        'with the issue kept', (WidgetTester tester) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/sign-in?from=%2Fissues%2Ffx-iss-01',
      );
    });

    testWidgets('Read with full access opens the reader route', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer(), signedInAs: fxUsr01),
        catalogue: FakeCatalogueRepository.fromFixtures(),
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read'));
      await tester.pumpAndSettle();
      expect(titled(ShellText.reader), findsOneWidget);
    });

    testWidgets('home shows the latest issue, and the tabs move between '
        'Home, News and Settings [MOD05-P2-T03]', (WidgetTester tester) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
      );
      expect(find.text('LATEST ISSUE'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(ShellText.news),
        ),
      );
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/news');

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(ShellText.home),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('LATEST ISSUE'), findsOneWidget);

      await tester.tap(find.text('View issue'));
      await tester.pumpAndSettle();
      expect(titled('Test Issue 01'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a visitor tapping Library is asked to sign in [DEC-014]', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer()),
        catalogue: FakeCatalogueRepository.fromFixtures(),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(ShellText.library),
        ),
      );
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/sign-in');
    });

    testWidgets('Download on an issue opens SCR-A-13 with the size, and the '
        'Downloads tab lists the copy [MOD06-P2-T02, FR-DL-003, FR-DL-008]', (
      WidgetTester tester,
    ) async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final GoRouter router = await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        downloads: FakeDownloadManager(
          auth,
          FakeIssueFileService(auth, files: fxIssueFiles),
        ),
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Download'));
      await tester.pumpAndSettle();
      expect(find.byType(DownloadPanel), findsOneWidget);
      expect(find.textContaining('Size:'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(DownloadPanel),
          matching: find.widgetWithText(FilledButton, 'Download'),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/downloads');
      await tester.pumpAndSettle();
      expect(find.byType(DownloadsScreen), findsOneWidget);
      expect(find.text('fx-iss-01'), findsOneWidget);
    });

    testWidgets('a copy finished after the Downloads tab was opened shows '
        'when the tab is opened again [FR-DL-008]', (
      WidgetTester tester,
    ) async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final FakeDownloadManager downloads = FakeDownloadManager(
        auth,
        FakeIssueFileService(auth, files: fxIssueFiles),
      );
      await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        downloads: downloads,
      );
      Finder tab(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );
      await tester.tap(tab('Downloads'));
      await tester.pumpAndSettle();
      expect(find.text('fx-iss-01'), findsNothing);

      await tester.tap(tab('Home'));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => downloads.start('fx-iss-01', mobileDataAccepted: true),
      );
      await tester.tap(tab('Downloads'));
      await tester.pumpAndSettle();
      expect(find.text('fx-iss-01'), findsOneWidget);
    });

    testWidgets('Read on a downloaded issue opens it in the reader, and '
        'Close returns to the issue [MOD06-P3-T03, IC-03]', (
      WidgetTester tester,
    ) async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final FakeDownloadManager downloads = FakeDownloadManager(
        auth,
        FakeIssueFileService(auth, files: fxIssueFiles),
      );
      await downloads.start('fx-iss-01', mobileDataAccepted: true);
      final GoRouter router = await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        downloads: downloads,
        renderer: FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(4))),
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 4'), findsOneWidget);
      expect(find.text('Test Issue 01'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('the Library tab lists bookmarks, and one opens the reader '
        'at its page with the bookmark shown [MOD08-P2-T01, FR-BKM-006]', (
      WidgetTester tester,
    ) async {
      useSize(tester, phone);
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr01);
      final FakeDownloadManager downloads = FakeDownloadManager(
        auth,
        FakeIssueFileService(auth, files: fxIssueFiles),
      );
      await downloads.start('fx-iss-01', mobileDataAccepted: true);
      final FakeLibraryRepository library = FakeLibraryRepository(server, auth);
      await library.addBookmark('fx-iss-01', 3, 1);
      final GoRouter router = await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        downloads: downloads,
        renderer: FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(4))),
        library: library,
      );
      router.go('/library');
      await tester.pumpAndSettle();
      expect(find.text('TEST ISSUE 01'), findsOneWidget);

      await tester.tap(find.text('Page 3'));
      await tester.pumpAndSettle();
      expect(find.text('3 / 4'), findsOneWidget);
      expect(
        find.byTooltip('Remove the bookmark of this page'),
        findsOneWidget,
      );
    });

    testWidgets('the star shows on issue details with full access only, and '
        'the Favourites view opens the issue [MOD08-P2-T02, OQ-12]', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr01);
      final GoRouter router = await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        library: FakeLibraryRepository(server, auth),
      );
      router.go('/issues/fx-iss-02');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add to favourites'));
      await tester.pumpAndSettle();
      expect(server.favouriteIssueIdsOf('fx-usr-01'), <String>{'fx-iss-02'});

      router.go('/library');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Favourites'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Issue 02'));
      await tester.pumpAndSettle();
      expect(titled('Test Issue 02'), findsOneWidget);
    });

    testWidgets('a visitor sees no star on issue details', (
      WidgetTester tester,
    ) async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server);
      final GoRouter router = await pumpAppWithContent(
        tester,
        auth,
        catalogue: FakeCatalogueRepository.fromFixtures(),
        library: FakeLibraryRepository(server, auth),
      );
      router.go('/issues/fx-iss-02');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Add to favourites'), findsNothing);
    });

    testWidgets('without a download manager, issue details offer Read only', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithContent(
        tester,
        FakeAuthService(FakeServer(), signedInAs: fxUsr01),
        catalogue: FakeCatalogueRepository.fromFixtures(),
      );
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Download'), findsNothing);
    });

    testWidgets('without a catalogue the routes stay placeholders', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer()),
      );
      router.go('/catalogue');
      await tester.pumpAndSettle();
      expect(find.text(ShellText.placeholderBody), findsOneWidget);
    });

    test('returningTo keeps the page to come back to', () {
      expect(
        returningTo('/sign-in', '/issues/a'),
        '/sign-in?from=%2Fissues%2Fa',
      );
    });
  });
}
