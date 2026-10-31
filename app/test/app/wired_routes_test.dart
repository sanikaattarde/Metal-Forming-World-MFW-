import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';
import 'package:mfw_app/features/downloads/downloads.dart';
import 'package:mfw_app/features/news/news.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_catalogue_repository.dart';
import '../fakes/fake_download_manager.dart';
import '../fakes/fake_issue_file_service.dart';
import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';
import '../features/catalogue/labelled_cover_source.dart';
import '../features/news/fake_wordpress_site.dart';
import '../features/news/labelled_news_image_source.dart';
import '../features/reader/fake_pdf_renderer.dart';
import '../features/reader/numbered_page_source.dart';
import '../fixtures/fx_issue_files.dart';
import 'app_harness.dart';

/// One device: signed in as [user], or a visitor; the FX catalogue and
/// issue files; a 12-page fx-iss-01; and the FX-WP news site.
final class WiredRig {
  WiredRig({TestUser? user})
    : auth = FakeAuthService(FakeServer(), signedInAs: user) {
    downloads = FakeDownloadManager(
      auth,
      FakeIssueFileService(auth, files: fxIssueFiles),
    );
  }

  final FakeAuthService auth;
  late final FakeDownloadManager downloads;

  AppServices get services => AppServices(
    catalogue: FakeCatalogueRepository.fromFixtures(),
    covers: const LabelledCoverSource(),
    downloads: downloads,
    renderer: FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 12}),
    pages: const NumberedPageSource(),
    news: WordPressNewsRepository(
      transport: FakeWordPressSite.fromFixtures(),
      site: WordPressSite(
        baseUrl: Uri.parse('https://wordpress.example/'),
        categoryIds: const <String>['11', '12', '13'],
      ),
    ),
    newsImages: const LabelledNewsImageSource(),
  );

  Future<GoRouter> pump(WidgetTester tester) =>
      pumpApp(tester, auth, services: services);
}

const AppFailure _unavailable = AppFailure(FailureCode.serviceUnavailable);

void main() {
  group('Routed screens over fakes [MOD-01]', () {
    testWidgets('home is the catalogue; an issue opens its details, and '
        'back returns home [FR-MAG-001, FR-MAG-005, SN-03]', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await WiredRig().pump(tester);
      expect(find.text(CatalogueText.latest), findsOneWidget);

      await tester.tap(find.text('Test Issue 01'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/issues/fx-iss-01');
      expect(find.text(CatalogueText.details), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/');
      expect(find.text(CatalogueText.latest), findsOneWidget);
    });

    for (final (TestUser? user, String step) in <(TestUser?, String)>[
      (null, '/sign-in'),
      (fxUsr02, '/verify-email'),
      (fxUsr03, '/complete-profile'),
    ]) {
      testWidgets('${user?.fixtureId ?? 'FX-USR-09'} sees one action on the '
          'issue, which starts $step and keeps the issue to return to '
          '[SCR-A-12, FR-AUTH-010]', (WidgetTester tester) async {
        final GoRouter router = await WiredRig(user: user).pump(tester);
        router.go('/issues/fx-iss-01');
        await tester.pumpAndSettle();
        expect(find.byType(DownloadPanel), findsNothing);

        await tester.tap(find.text(ShellText.readOrDownload));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, step);
        expect(router.state.uri.queryParameters['from'], '/issues/fx-iss-01');
      });
    }

    testWidgets('after signing in from the issue, the reader is back on it '
        'with the download panel [FR-AUTH-010, SCR-A-13]', (
      WidgetTester tester,
    ) async {
      final WiredRig rig = WiredRig();
      final GoRouter router = await rig.pump(tester);
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      await tester.tap(find.text(ShellText.readOrDownload));
      await tester.pumpAndSettle();

      rig.auth.signInAs(fxUsr01);
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/issues/fx-iss-01');
      expect(find.byType(DownloadPanel), findsOneWidget);
      expect(find.text(ShellText.readOrDownload), findsNothing);
    });

    testWidgets('with full access, Read waits for a kept copy, then opens '
        'the reader at page 1 [SCR-A-13, SCR-A-14, FR-DL-003]', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await WiredRig(user: fxUsr01).pump(tester);
      router.go('/issues/fx-iss-01');
      await tester.pumpAndSettle();
      final Finder read = find.widgetWithText(FilledButton, ShellText.read);
      expect(tester.widget<FilledButton>(read).onPressed, isNull);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.downloaded), findsOneWidget);
      expect(tester.widget<FilledButton>(read).onPressed, isNotNull);

      await tester.tap(read);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/issues/fx-iss-01/read');
      expect(find.text(ReaderText.pageOf(1, 12)), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/issues/fx-iss-01');
    });

    for (final (String query, int page) in <(String, int)>[
      ('?page=4', 4),
      ('?page=99', 12),
      ('?page=0', 1),
      ('?page=abc', 1),
      ('', 1),
    ]) {
      testWidgets('the reader at "$query" opens page $page [SCR-A-14, '
          'FR-READ-001]', (WidgetTester tester) async {
        final WiredRig rig = WiredRig(user: fxUsr01);
        rig.downloads.seedCopy(
          ownerUserId: fxUsr01.userId,
          issueId: 'fx-iss-01',
        );
        final GoRouter router = await rig.pump(tester);

        router.go('/issues/fx-iss-01/read$query');
        await tester.pumpAndSettle();

        expect(find.text(ReaderText.pageOf(page, 12)), findsOneWidget);
      });
    }

    testWidgets('a new page in the address opens the reader there '
        '[SCR-A-14]', (WidgetTester tester) async {
      final WiredRig rig = WiredRig(user: fxUsr01);
      rig.downloads.seedCopy(ownerUserId: fxUsr01.userId, issueId: 'fx-iss-01');
      final GoRouter router = await rig.pump(tester);
      router.go('/issues/fx-iss-01/read?page=4');
      await tester.pumpAndSettle();

      router.go('/issues/fx-iss-01/read?page=7');
      await tester.pumpAndSettle();

      expect(find.text(ReaderText.pageOf(7, 12)), findsOneWidget);
    });

    testWidgets('Downloads lists the kept copies [SCR-A-15, FR-DL-007]', (
      WidgetTester tester,
    ) async {
      final WiredRig rig = WiredRig(user: fxUsr01);
      rig.downloads.seedCopy(ownerUserId: fxUsr01.userId, issueId: 'fx-iss-02');
      final GoRouter router = await rig.pump(tester);

      router.go('/downloads');
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.title), findsOneWidget);
      expect(find.text('fx-iss-02'), findsOneWidget);
    });

    testWidgets('the news list opens an article, and back returns to the '
        'list [SCR-A-18, SCR-A-19, FR-NEWS-002]', (WidgetTester tester) async {
      final GoRouter router = await WiredRig().pump(tester);
      router.go('/news');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test post 125'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/news/125');
      expect(find.text(NewsText.article), findsOneWidget);
      expect(find.text('Test post 125'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/news');
    });

    for (final TestUser? user in <TestUser?>[null, fxUsr01]) {
      testWidgets('the issue action for ${user?.fixtureId ?? 'FX-USR-09'} '
          'fits a 320 px wide screen, with labelled 48 px targets '
          '[CODING_STANDARDS section 9]', (WidgetTester tester) async {
        final GoRouter router = await WiredRig(user: user).pump(tester);
        tester.view.physicalSize = const Size(320, 1600);
        router.go('/issues/fx-iss-01');
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });
    }
  });

  group('Without real sources, each screen says so and offers no retry '
      '[FR-STATE-003]', () {
    for (final (String route, TestUser? user, String message)
        in <(String, TestUser?, String)>[
          ('/', null, CatalogueText.failure(_unavailable)),
          ('/issues/fx-iss-01', null, CatalogueText.failure(_unavailable)),
          ('/issues/fx-iss-01/read', fxUsr01, ReaderText.notOnDevice),
          ('/downloads', null, DownloadsText.empty),
          ('/news', null, NewsText.failure(_unavailable)),
          ('/news/101', null, NewsText.failure(_unavailable)),
        ]) {
      testWidgets(route, (WidgetTester tester) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer(), signedInAs: user),
        );

        router.go(route);
        await tester.pumpAndSettle();

        expect(find.text(message), findsOneWidget);
        expect(find.text(ShellText.retry), findsNothing);
      });
    }
  });
}
