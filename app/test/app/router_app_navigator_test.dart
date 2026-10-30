import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/router_app_navigator.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_notification_service.dart';
import '../fakes/fake_server.dart';
import '../fakes/fixture_loader.dart';
import '../fakes/recording_app_navigator.dart';
import '../fakes/test_users.dart';
import 'app_harness.dart';

void main() {
  group('Notification taps go through the guard [IC-05, BR-005]', () {
    final Map<String, Object?> payloads = readJsonFixture(
      'notifications/fx_ntf_payloads.json',
    ) as Map<String, Object?>;

    NotificationTarget targetOf(String fixtureId) =>
        FakeNotificationService.targetFromPayload(payloads[fixtureId])!;

    test('openNotificationTarget calls the matching navigator method', () {
      final RecordingAppNavigator navigator = RecordingAppNavigator();

      openNotificationTarget(navigator, targetOf('FX-NTF-01'));
      openNotificationTarget(navigator, targetOf('FX-NTF-02'));

      expect(navigator.calls, <String>['issue:fx-iss-01', 'article:101']);
    });

    for (final (TestUser? user, String path) in <(TestUser?, String)>[
      (fxUsr01, '/issues/fx-iss-01/read'),
      (null, '/sign-in'),
      (fxUsr02, '/verify-email'),
      (fxUsr03, '/complete-profile'),
    ]) {
      testWidgets(
        'FX-NTF-01 for ${user?.fixtureId ?? 'FX-USR-09'} lands on $path',
        (WidgetTester tester) async {
          final GoRouter router = await pumpApp(
            tester,
            FakeAuthService(FakeServer(), signedInAs: user),
          );

          openNotificationTarget(
            RouterAppNavigator(router),
            targetOf('FX-NTF-01'),
          );
          await tester.pumpAndSettle();

          expect(router.state.uri.path, path);
        },
      );
    }

    testWidgets('FX-NTF-07 while signed out keeps the issue to return to', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer()),
      );

      openNotificationTarget(RouterAppNavigator(router), targetOf('FX-NTF-07'));
      await tester.pumpAndSettle();

      expect(
        router.state.uri.queryParameters['from'],
        '/issues/fx-iss-01/read',
      );
    });

    testWidgets('FX-NTF-02 opens the article while signed out', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(
        tester,
        FakeAuthService(FakeServer()),
      );

      openNotificationTarget(RouterAppNavigator(router), targetOf('FX-NTF-02'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/news/101');
    });
  });
}
