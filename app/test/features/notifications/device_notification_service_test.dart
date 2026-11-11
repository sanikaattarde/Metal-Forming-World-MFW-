// MOD11-P2-T02: the notification service on the device, over fakes of the
// push client, the records (OP-05, OP-09) and the device's own record
// (FR-NOTIF-001 to FR-NOTIF-003, FR-NOTIF-005 to FR-NOTIF-007, DATA-007,
// GS-Q46, GS-Q47). No real device or push service is reached.
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

import 'notification_fakes.dart';

void main() {
  late FakePushMessaging push;
  late FakeNotificationDocuments documents;
  late MemoryDeviceChoices device;
  String? userId;
  late DeviceNotificationService service;

  setUp(() {
    push = FakePushMessaging();
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

  NotificationPreferences choose(List<String> ids) =>
      NotificationPreferences(optedIn: ids.isNotEmpty, categoryIds: ids);

  Future<NotificationPreferences> preferences() async =>
      (await service.getPreferences() as Ok<NotificationPreferences>).value;

  test('OP-05: the active categories only, in their order (GS-Q47)', () async {
    final Result<List<NotificationCategory>> result = await service
        .categories();
    expect(
      (result as Ok<List<NotificationCategory>>).value.map((c) => c.name),
      <String>['New issues', 'Expo specials', 'Major news'],
    );
  });

  test(
    'FR-NOTIF-001: the system is asked only on request, and the answer is kept',
    () async {
      expect(await service.permission(), PermissionOutcome.notDetermined);
      expect(await service.explained(), isFalse);
      push.answer = PermissionOutcome.denied;
      final Result<PermissionOutcome> outcome = await service
          .explainAndRequestPermission();
      expect(
        (outcome as Ok<PermissionOutcome>).value,
        PermissionOutcome.denied,
      );
      expect(await service.explained(), isTrue);
      expect(push.calls, <String>['requestPermission']);
    },
  );

  test('Not now records the explanation as answered, asking nothing', () async {
    await service.declineExplanation();
    expect(await service.explained(), isTrue);
    expect(push.calls, isEmpty);
  });

  group('a signed-in reader (DATA-007)', () {
    setUp(() => userId = 'uid-1');

    test(
      'choices are saved as the account\'s records, and the device follows',
      () async {
        expect(
          await service.savePreferences(
            choose(<String>['notif-new-issues', 'notif-major-news']),
          ),
          isA<Ok<void>>(),
        );
        expect(documents.stored['uid-1'], <String>{
          'notif-new-issues',
          'notif-major-news',
        });
        expect(push.topics, <String>{'notif-new-issues', 'notif-major-news'});
        expect((await preferences()).categoryIds, <String>[
          'notif-major-news',
          'notif-new-issues',
        ]);
        expect((await preferences()).optedIn, isTrue);
      },
    );

    test(
      'FR-NOTIF-003: after a change only the new choice is subscribed',
      () async {
        await service.savePreferences(
          choose(<String>['notif-new-issues', 'notif-major-news']),
        );
        push.calls.clear();
        await service.savePreferences(choose(<String>['notif-expo-specials']));
        expect(push.topics, <String>{'notif-expo-specials'});
        expect(
          push.calls.where((String c) => c.startsWith('unsubscribe')),
          hasLength(2),
        );
        expect(documents.stored['uid-1'], <String>{'notif-expo-specials'});
      },
    );

    test('opting out removes every choice and every topic', () async {
      await service.savePreferences(choose(<String>['notif-new-issues']));
      await service.savePreferences(
        const NotificationPreferences(
          optedIn: false,
          categoryIds: <String>['notif-new-issues'],
        ),
      );
      expect(documents.stored['uid-1'], isEmpty);
      expect(push.topics, isEmpty);
      expect((await preferences()).optedIn, isFalse);
    });

    test(
      'a sign-in on another device brings the account\'s choices (syncTo)',
      () async {
        documents.stored['uid-1'] = <String>{'notif-major-news'};
        expect(await service.syncTo('uid-1'), isA<Ok<void>>());
        expect(push.topics, <String>{'notif-major-news'});
        expect(device.record.subscribedTopics, <String>{'notif-major-news'});
      },
    );

    test(
      'the records cannot be reached: network, and the topics stay',
      () async {
        await service.savePreferences(choose(<String>['notif-new-issues']));
        documents.failNext = true;
        final Result<void> result = await service.savePreferences(
          choose(<String>['notif-major-news']),
        );
        expect((result as Err<void>).failure.code, FailureCode.network);
        expect(push.topics, <String>{'notif-new-issues'});
      },
    );

    test('a push failure part-way is resumed by the next change, and nothing unchosen is left', () async {
      push.failTopic = 'notif-major-news';
      final Result<void> first = await service.savePreferences(
        choose(<String>['notif-new-issues', 'notif-major-news']),
      );
      expect((first as Err<void>).failure.code, FailureCode.network);
      expect(push.topics, isNot(contains('notif-major-news')));
      expect(device.record.subscribedTopics, push.topics);
      await service.savePreferences(
        choose(<String>['notif-new-issues', 'notif-major-news']),
      );
      expect(push.topics, <String>{'notif-new-issues', 'notif-major-news'});
    });
  });

  group('a visitor (GS-Q46, OQ-09)', () {
    test('choices stay on the device; the backend gets no record', () async {
      await service.savePreferences(choose(<String>['notif-expo-specials']));
      expect(device.record.visitorCategories, <String>{'notif-expo-specials'});
      expect(documents.calls, isEmpty);
      expect(push.topics, <String>{'notif-expo-specials'});
      expect((await preferences()).categoryIds, <String>[
        'notif-expo-specials',
      ]);
    });

    test('at a sign-in the account\'s choices replace the visitor\'s on the device', () async {
      await service.savePreferences(choose(<String>['notif-expo-specials']));
      documents.stored['uid-1'] = <String>{'notif-new-issues'};
      await service.syncTo('uid-1');
      expect(push.topics, <String>{'notif-new-issues'});
    });
  });

  group('FR-NOTIF-005: a tapped notification opens its target', () {
    test('an issue, a post, and nothing for a send with no target', () async {
      final List<NotificationTarget> targets = <NotificationTarget>[];
      final sub = service.watchOpened().listen(targets.add);
      push.opened.add(<String, String>{
        'send_id': 's1',
        'target_type': 'issue',
        'target_ref': 'i-pub',
      });
      push.opened.add(<String, String>{
        'send_id': 's2',
        'target_type': 'news_post',
        'target_ref': '101',
      });
      push.opened.add(<String, String>{'send_id': 's3', 'target_type': 'none'});
      push.opened.add(<String, String>{
        'target_type': 'page',
        'target_ref': 'x',
      });
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(targets.map((t) => '${t.type.name} ${t.targetId}'), <String>[
        'issue i-pub',
        'article 101',
      ]);
    });
  });

  test(
    'topicFor: the category identifier, or null for a name push refuses',
    () {
      expect(topicFor('notif-new-issues'), 'notif-new-issues');
      expect(topicFor('with space'), isNull);
      expect(topicFor(''), isNull);
    },
  );
}
