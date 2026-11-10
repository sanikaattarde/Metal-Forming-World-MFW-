import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/router_app_navigator.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';
import 'app_harness.dart';

/// The screen whose app bar shows [title]. Scoped to the app bar, because a
/// built screen may use its title as a button label too ("Sign in").
Finder titled(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));

void main() {
  group('IC-01 consumer check: the guard on the fake AuthService', () {
    const Map<AccessState, String> shownFor = <AccessState, String>{
      AccessState.signedOut: ShellText.signIn,
      AccessState.emailUnverified: AccountText.verifyTitle,
      AccessState.profileIncomplete: ShellText.completeProfile,
      AccessState.fullAccess: ShellText.reader,
    };

    for (final TestUser? user in <TestUser?>[
      null,
      fxUsr01,
      fxUsr02,
      fxUsr03,
      fxUsr04,
      fxUsr05,
    ]) {
      final AccessState state =
          user?.documentedAccessState ?? AccessState.signedOut;
      testWidgets('${user?.fixtureId ?? 'FX-USR-09'} opening a full issue sees '
          '${shownFor[state]} [FR-AUTH-010, BR-001 to BR-003]', (
        WidgetTester tester,
      ) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer(), signedInAs: user),
        );

        router.go('/issues/fx-iss-01/read');
        await tester.pumpAndSettle();

        expect(titled(shownFor[state]!), findsOneWidget);
      });
    }

    testWidgets('after signing in, the reader returns to the issue '
        '[FR-AUTH-010]', (WidgetTester tester) async {
      final FakeAuthService auth = FakeAuthService(FakeServer());
      final GoRouter router = await pumpApp(tester, auth);

      router.go('/issues/fx-iss-01/read?page=4');
      await tester.pumpAndSettle();
      expect(titled(ShellText.signIn), findsOneWidget);

      auth.signInAs(fxUsr01);
      await tester.pumpAndSettle();

      expect(titled(ShellText.reader), findsOneWidget);
      expect(router.state.uri.toString(), '/issues/fx-iss-01/read?page=4');
    });

    testWidgets('signing out on the reader goes to sign-in [BR-001]', (
      WidgetTester tester,
    ) async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );
      final GoRouter router = await pumpApp(tester, auth);
      router.go('/issues/fx-iss-01/read');
      await tester.pumpAndSettle();
      expect(titled(ShellText.reader), findsOneWidget);

      await auth.signOut();
      await tester.pumpAndSettle();

      expect(titled(ShellText.signIn), findsOneWidget);
      expect(
        router.state.uri.queryParameters['from'],
        '/issues/fx-iss-01/read',
      );
    });
  });

  group('Route table of section 6.1 [MOD-01]', () {
    for (final (String route, TestUser? user, String title)
        in <(String, TestUser?, String)>[
          ('/', null, ShellText.home),
          ('/issues/fx-iss-01', null, ShellText.issue),
          ('/issues/fx-iss-01/read?page=2', fxUsr01, ShellText.reader),
          ('/downloads', fxUsr01, ShellText.downloads),
          ('/library', fxUsr01, ShellText.library),
          ('/news', null, ShellText.news),
          ('/news/101', null, ShellText.newsArticle),
          ('/sign-in', null, ShellText.signIn),
          ('/register', null, AccountText.registerTitle),
          ('/verify-email', fxUsr02, AccountText.verifyTitle),
          ('/complete-profile', fxUsr03, ShellText.completeProfile),
          ('/settings', null, ShellText.settings),
        ]) {
      testWidgets('$route shows $title', (WidgetTester tester) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer(), signedInAs: user),
        );

        router.go(route);
        await tester.pumpAndSettle();

        expect(titled(title), findsOneWidget);
      });
    }

    for (final String route in <String>[
      '/issues/fx-iss-01/read/',
      '/library/',
      '/downloads/',
    ]) {
      testWidgets('$route with a trailing slash still asks a visitor to sign '
          'in', (WidgetTester tester) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer()),
        );

        router.go(route);
        await tester.pumpAndSettle();

        expect(titled(ShellText.signIn), findsOneWidget);
      });
    }

    testWidgets('an unknown route shows SCR-A-22, which goes home', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer()),
      );

      router.go('/no-such-page');
      await tester.pumpAndSettle();
      expect(titled(ShellText.notFound), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, ShellText.goHome));
      await tester.pumpAndSettle();

      expect(titled(ShellText.home), findsOneWidget);
      expect(router.state.uri.path, '/');
    });
  });

  group('RouterAppNavigator goes through the guard [IC-05, BR-005]', () {
    for (final (TestUser? user, String path) in <(TestUser?, String)>[
      (fxUsr01, '/issues/fx-iss-01/read'),
      (null, '/sign-in'),
      (fxUsr02, '/verify-email'),
      (fxUsr03, '/complete-profile'),
    ]) {
      testWidgets('openIssue for ${user?.fixtureId ?? 'FX-USR-09'} lands on '
          '$path', (WidgetTester tester) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer(), signedInAs: user),
        );

        RouterAppNavigator(router).openIssue('fx-iss-01');
        await tester.pumpAndSettle();

        expect(router.state.uri.path, path);
      });
    }

    testWidgets('openArticle opens the article while signed out', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer()),
      );

      RouterAppNavigator(router).openArticle('101');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/news/101');
      expect(titled(ShellText.newsArticle), findsOneWidget);
    });

    testWidgets('an ID with a slash stays one path segment', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer(), signedInAs: fxUsr01),
      );

      RouterAppNavigator(router).openIssue('a/b');
      await tester.pumpAndSettle();

      expect(router.state.uri.pathSegments, <String>['issues', 'a/b', 'read']);
      expect(titled(ShellText.reader), findsOneWidget);
    });
  });
}
