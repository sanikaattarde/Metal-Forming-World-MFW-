// MOD11-P2-T02: SCR-A-20 and SCR-A-21 through the app, over fakes of the push
// client and the records (AC-9.1, FR-NOTIF-001 to FR-NOTIF-003, FR-NOTIF-005,
// GS-Q46). No real device or push service is reached; the manual delivery
// test waits for push in MFW's accounts (MOD11-P2-T01).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/routes.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

import '../../app/app_harness.dart';
import '../account/fake_identity_provider.dart';
import 'notification_fakes.dart';

void main() {
  late FakeIdentityProvider identity;
  late AccountAuthService auth;
  late FakePushMessaging push;
  late FakeNotificationDocuments documents;
  late MemoryDeviceChoices device;
  late DeviceNotificationService service;

  setUp(() {
    identity = FakeIdentityProvider();
    auth = AccountAuthService(identity);
    push = FakePushMessaging();
    documents = FakeNotificationDocuments();
    device = MemoryDeviceChoices();
    service = serviceOver(
      push: push,
      documents: documents,
      device: device,
      userId: () => identity.currentUser?.uid,
    );
  });

  Future<GoRouter> openChoices(
    WidgetTester tester, {
    AppNavigator? navigator,
  }) async {
    final GoRouter router = await pumpAppWithNotifications(
      tester,
      auth,
      service,
      navigator: navigator,
    );
    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    await tester.tap(find.text(NotificationText.title));
    await tester.pumpAndSettle();
    return router;
  }

  SwitchListTile switchFor(WidgetTester tester, String name) =>
      tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, name));

  testWidgets(
    'AC-9.1: the first time, the explanation comes before the system prompt',
    (WidgetTester tester) async {
      final GoRouter router = await openChoices(tester);
      expect(router.state.uri.toString(), AppRoutes.notificationSettings);
      expect(find.text(NotificationText.explainBody), findsOneWidget);
      expect(push.calls, isEmpty);

      await tester.tap(find.text(NotificationText.allow));
      await tester.pumpAndSettle();
      expect(push.calls, <String>['requestPermission']);
      expect(
        find.text(NotificationText.chooseHeading.toUpperCase()),
        findsOneWidget,
      );
      expect(
        tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .map((SwitchListTile s) => (s.title! as Text).data),
        <String>['New issues', 'Expo specials', 'Major news'],
      );
    },
  );

  testWidgets(
    'FR-NOTIF-002, GS-Q46: a visitor chooses a category; it is kept on the device and subscribed',
    (WidgetTester tester) async {
      push.status = PermissionOutcome.granted;
      await openChoices(tester);
      expect(find.text(NotificationText.visitorNote), findsOneWidget);
      await tester.tap(find.text('Expo specials'));
      await tester.pumpAndSettle();
      expect(switchFor(tester, 'Expo specials').value, isTrue);
      expect(device.record.visitorCategories, <String>{'notif-expo-specials'});
      expect(push.topics, <String>{'notif-expo-specials'});
      expect(documents.calls, isEmpty);
    },
  );

  testWidgets(
    'FR-NOTIF-003: a signed-in reader changes categories; the account and the device follow',
    (WidgetTester tester) async {
      identity.addAccount(
        'reader@example.test',
        'right-password',
        verified: true,
      );
      await identity.signIn(
        email: 'reader@example.test',
        password: 'right-password',
      );
      final String uid = identity.currentUser!.uid;
      documents.stored[uid] = <String>{'notif-new-issues'};
      push.status = PermissionOutcome.granted;
      await openChoices(tester);
      // The bridge subscribed the account's choice at start-up (DATA-007).
      expect(push.topics, <String>{'notif-new-issues'});
      expect(find.text(NotificationText.visitorNote), findsNothing);
      expect(switchFor(tester, 'New issues').value, isTrue);

      await tester.tap(find.text('New issues'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Major news'));
      await tester.pumpAndSettle();
      expect(documents.stored[uid], <String>{'notif-major-news'});
      expect(push.topics, <String>{'notif-major-news'});
    },
  );

  testWidgets(
    'Not now shows the choices with a way to allow later, and is remembered',
    (WidgetTester tester) async {
      await openChoices(tester);
      await tester.tap(find.text(NotificationText.notNow));
      await tester.pumpAndSettle();
      expect(find.text(NotificationText.notAllowed), findsOneWidget);
      expect(
        find.text(NotificationText.chooseHeading.toUpperCase()),
        findsOneWidget,
      );
      expect(device.record.explained, isTrue);
      expect(push.calls, isEmpty);
    },
  );

  testWidgets(
    'blocked in the system settings: the screen says where to turn them on',
    (WidgetTester tester) async {
      push.status = PermissionOutcome.denied;
      await openChoices(tester);
      expect(find.text(NotificationText.explainBody), findsNothing);
      expect(find.text(NotificationText.blocked), findsOneWidget);
    },
  );

  testWidgets('a load that fails says so, and Retry loads again', (
    WidgetTester tester,
  ) async {
    push.status = PermissionOutcome.granted;
    documents.failNext = true;
    await openChoices(tester);
    expect(find.text(NotificationText.loadFailed), findsOneWidget);
    await tester.tap(find.text(NotificationText.retry));
    await tester.pumpAndSettle();
    expect(find.text(NotificationText.loadFailed), findsNothing);
    expect(find.text('New issues'), findsOneWidget);
  });

  testWidgets(
    'a change that cannot be saved says so, and the switch goes back',
    (WidgetTester tester) async {
      push.status = PermissionOutcome.granted;
      await openChoices(tester);
      push.failTopic = 'notif-new-issues';
      await tester.tap(find.text('New issues'));
      await tester.pumpAndSettle();
      expect(find.text(NotificationText.saveFailed), findsOneWidget);
      expect(switchFor(tester, 'New issues').value, isFalse);
    },
  );

  testWidgets(
    'FR-NOTIF-005: a tapped notification opens its target through the navigator',
    (WidgetTester tester) async {
      final RecordingNavigator navigator = RecordingNavigator();
      await pumpAppWithNotifications(
        tester,
        auth,
        service,
        navigator: navigator,
      );
      push.opened.add(<String, String>{
        'target_type': 'issue',
        'target_ref': 'i-pub',
      });
      push.opened.add(<String, String>{
        'target_type': 'news_post',
        'target_ref': '101',
      });
      await tester.pumpAndSettle();
      expect(navigator.opened, <String>['issue i-pub', 'article 101']);
    },
  );

  testWidgets('without MOD-11, settings has no notifications entry', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, auth);
    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(find.text(NotificationText.title), findsNothing);
  });
}
