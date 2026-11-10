import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/content_routes.dart';
import 'package:mfw_app/app/shell_text.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_catalogue_repository.dart';
import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';
import 'app_harness.dart';
import 'router_test.dart' show titled;

void main() {
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
