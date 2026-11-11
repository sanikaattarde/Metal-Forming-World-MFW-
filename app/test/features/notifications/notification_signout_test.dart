// MOD11-P2-T04: a signed-out or deleted reader's device stops receiving
// notifications (OQ-55 working position: end every subscription, then the
// push registration; GS-Q46). Over fakes: the emulators have no messaging
// service, so whether unregistering alone ends topic subscriptions (OQ-55)
// is not tested here, and the app does not rely on it.
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/routes.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

import '../../app/app_harness.dart';
import '../account/fake_identity_provider.dart';
import 'notification_fakes.dart';

/// OP-12 accepting every deletion.
final class AcceptingBackend implements BackendCalls {
  final List<String> calls = <String>[];

  @override
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  ) async {
    calls.add(operation);
    return <String, Object?>{'state': 'deleted'};
  }
}

void main() {
  late FakePushMessaging push;
  late FakeNotificationDocuments documents;
  late MemoryDeviceChoices device;
  String? userId;
  late DeviceNotificationService service;

  setUp(() {
    push = FakePushMessaging()..status = PermissionOutcome.granted;
    documents = FakeNotificationDocuments();
    device = MemoryDeviceChoices();
    userId = null;
    service = serviceOver(
      push: push,
      documents: documents,
      device: device,
      userId: () => userId,
    );
  });

  group('clearDevice', () {
    test('ends each subscription, then the registration, and forgets a visitor\'s choices', () async {
      userId = 'uid-1';
      documents.stored['uid-1'] = <String>{
        'notif-new-issues',
        'notif-major-news',
      };
      await service.syncTo('uid-1');
      device.record = device.record.copyWith(
        visitorCategories: <String>{'notif-expo-specials'},
      );
      push.calls.clear();

      expect(await service.clearDevice(), isA<Ok<void>>());
      expect(push.topics, isEmpty);
      expect(push.registered, isFalse);
      expect(push.calls.last, 'unregister');
      expect(
        push.calls.where((String c) => c.startsWith('unsubscribe')),
        hasLength(2),
      );
      expect(device.record.subscribedTopics, isEmpty);
      expect(device.record.visitorCategories, isEmpty);
      // The account's records stay, for the next sign-in or for OP-12.
      expect(documents.stored['uid-1'], hasLength(2));
    });

    test(
      'a failure part-way is network, and the next start ends what is left',
      () async {
        await service.savePreferences(
          const NotificationPreferences(
            optedIn: true,
            categoryIds: <String>['notif-new-issues', 'notif-major-news'],
          ),
        );
        push.failTopic = 'notif-major-news';
        final Result<void> result = await service.clearDevice();
        expect((result as Err<void>).failure.code, FailureCode.network);
        expect(push.registered, isTrue);
        expect(push.topics, <String>{'notif-major-news'});

        await service.syncTo(null);
        expect(push.topics, isEmpty);
      },
    );

    test(
      'a sign-in forgets the visitor\'s earlier choices on the device',
      () async {
        await service.savePreferences(
          const NotificationPreferences(
            optedIn: true,
            categoryIds: <String>['notif-expo-specials'],
          ),
        );
        await service.syncTo('uid-1');
        expect(device.record.visitorCategories, isEmpty);
        await service.syncTo(null);
        expect(push.topics, isEmpty);
      },
    );
  });

  group('through the app', () {
    late FakeIdentityProvider identity;
    late AcceptingBackend backend;
    late AccountAuthService auth;
    late String uid;

    setUp(() async {
      identity = FakeIdentityProvider();
      backend = AcceptingBackend();
      auth = AccountAuthService(identity, backend: backend);
      uid = identity
          .addAccount('reader@example.test', 'right-password', verified: true)
          .uid;
      await identity.signIn(
        email: 'reader@example.test',
        password: 'right-password',
      );
      documents.stored[uid] = <String>{'notif-new-issues'};
      service = serviceOver(
        push: push,
        documents: documents,
        device: device,
        userId: () => identity.currentUser?.uid,
      );
    });

    testWidgets('sign-out from settings ends every subscription', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithNotifications(
        tester,
        auth,
        service,
      );
      expect(push.topics, <String>{'notif-new-issues'});
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountText.signOut));
      await tester.pumpAndSettle();
      expect(identity.currentUser, isNull);
      expect(push.topics, isEmpty);
      expect(push.registered, isFalse);
      expect(documents.stored[uid], <String>{'notif-new-issues'});
    });

    testWidgets('account deletion ends every subscription [IC-08]', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAppWithNotifications(
        tester,
        auth,
        service,
      );
      router.go(AppRoutes.deleteAccount);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountText.deleteMyAccount));
      await tester.pumpAndSettle();
      expect(backend.calls, <String>['requestAccountDeletion']);
      expect(push.topics, isEmpty);
      expect(push.registered, isFalse);
    });

    testWidgets('a visitor at start-up is not unregistered', (
      WidgetTester tester,
    ) async {
      await identity.signOut();
      await pumpAppWithNotifications(tester, auth, service);
      expect(push.calls, isNot(contains('unregister')));
    });
  });
}
