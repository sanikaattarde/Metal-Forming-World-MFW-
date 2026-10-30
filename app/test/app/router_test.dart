import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';
import 'app_harness.dart';

void main() {
  group('Route guard with the fake AuthService [IC-01]', () {
    const Map<AccessState, String> shownFor = <AccessState, String>{
      AccessState.signedOut: ShellText.signIn,
      AccessState.emailUnverified: ShellText.verifyEmail,
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
          '${shownFor[state]}', (WidgetTester tester) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer(), signedInAs: user),
        );

        router.go('/issues/fx-iss-01/read');
        await tester.pumpAndSettle();

        expect(find.text(shownFor[state]!), findsOneWidget);
      });
    }

    testWidgets('after signing in, the reader returns to the issue '
        '[FR-AUTH-010]', (WidgetTester tester) async {
      final FakeAuthService auth = FakeAuthService(FakeServer());
      final GoRouter router = await pumpApp(tester, auth);

      router.go('/issues/fx-iss-01/read?page=4');
      await tester.pumpAndSettle();
      expect(find.text(ShellText.signIn), findsOneWidget);

      auth.signInAs(fxUsr01);
      await tester.pumpAndSettle();

      expect(find.text(ShellText.reader), findsOneWidget);
      expect(router.state.uri.toString(), '/issues/fx-iss-01/read?page=4');
    });

    for (final (String route, TestUser? user, String title)
        in <(String, TestUser?, String)>[
          ('/', null, ShellText.home),
          ('/issues/fx-iss-01', null, ShellText.issueDetails),
          ('/issues/fx-iss-01/read?page=2', fxUsr01, ShellText.reader),
          ('/downloads', null, ShellText.downloads),
          ('/library', fxUsr01, ShellText.library),
          ('/news', null, ShellText.news),
          ('/news/101', null, ShellText.article),
          ('/sign-in', null, ShellText.signIn),
          ('/register', null, ShellText.register),
          ('/verify-email', fxUsr02, ShellText.verifyEmail),
          ('/complete-profile', fxUsr03, ShellText.completeProfile),
          ('/settings', null, ShellText.settings),
        ]) {
      testWidgets('$route shows $title [MOD-01]', (WidgetTester tester) async {
        final GoRouter router = await pumpApp(
          tester,
          FakeAuthService(FakeServer(), signedInAs: user),
        );

        router.go(route);
        await tester.pumpAndSettle();

        expect(find.text(title), findsOneWidget);
      });
    }

    testWidgets('an unknown route shows the not-found screen [MOD-01]', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer()),
      );

      router.go('/no-such-page');
      await tester.pumpAndSettle();

      expect(find.text(ShellText.notFound), findsOneWidget);
    });
  });
}
