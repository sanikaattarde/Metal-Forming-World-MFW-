import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_notification_service.dart';
import 'fake_server.dart';
import 'fixture_loader.dart';
import 'recording_app_navigator.dart';
import 'test_helpers.dart';
import 'test_users.dart';

void main() {
  group('FakeNotificationService and RecordingAppNavigator [IC-05]', () {
    final Map<String, Object?> payloads =
        readJsonFixture('notifications/fx_ntf_payloads.json')!
            as Map<String, Object?>;

    FakeNotificationService serviceFor(TestUser? user) {
      final FakeServer server = FakeServer();
      return FakeNotificationService(
        server,
        FakeAuthService(server, signedInAs: user),
      );
    }

    test('implement NotificationService and AppNavigator', () {
      expect(serviceFor(fxUsr01), isA<NotificationService>());
      expect(RecordingAppNavigator(), isA<AppNavigator>());
    });

    for (final (String fixtureId, NotificationTargetType type, String targetId)
        in <(String, NotificationTargetType, String)>[
          ('FX-NTF-01', NotificationTargetType.issue, 'fx-iss-01'),
          ('FX-NTF-02', NotificationTargetType.article, '101'),
          ('FX-NTF-03', NotificationTargetType.article, '102'),
          ('FX-NTF-06', NotificationTargetType.issue, 'fx-iss-08'),
          ('FX-NTF-07', NotificationTargetType.issue, 'fx-iss-01'),
        ]) {
      test('$fixtureId gives a ${type.name} target', () {
        final NotificationTarget? target = serviceFor(fxUsr01)
            .deliverTap(payloads[fixtureId]);

        expect(target?.type, type);
        expect(target?.targetId, targetId);
      });
    }

    for (final String fixtureId in <String>[
      'FX-NTF-04',
      'FX-NTF-05',
      'FX-NTF-08',
    ]) {
      test('$fixtureId is ignored safely', () async {
        final FakeNotificationService service = serviceFor(fxUsr01);
        final List<NotificationTarget> seen = recordEvents(
          service.watchOpened(),
        );

        expect(service.deliverTap(payloads[fixtureId]), isNull);
        await settle();

        expect(seen, isEmpty);
      });
    }

    test('tapped targets reach a recording AppNavigator', () async {
      final FakeNotificationService service = serviceFor(fxUsr01);
      final RecordingAppNavigator navigator = RecordingAppNavigator();
      final StreamSubscription<NotificationTarget> subscription = service
          .watchOpened()
          .listen((NotificationTarget target) {
            switch (target.type) {
              case NotificationTargetType.issue:
                navigator.openIssue(target.targetId);
              case NotificationTargetType.article:
                navigator.openArticle(target.targetId);
            }
          });
      addTearDown(subscription.cancel);

      service
        ..deliverTap(payloads['FX-NTF-01'])
        ..deliverTap(payloads['FX-NTF-02']);
      await settle();

      expect(navigator.calls, <String>['issue:fx-iss-01', 'article:101']);
    });

    test('preferences are kept per reader [MOD-11]', () async {
      final FakeServer server = FakeServer();
      final FakeAuthService auth = FakeAuthService(server, signedInAs: fxUsr01);
      final FakeNotificationService service = FakeNotificationService(
        server,
        auth,
      );

      expect(
        await service.savePreferences(
          const NotificationPreferences(
            optedIn: true,
            categoryIds: <String>['fx-cat-01'],
          ),
        ),
        isA<Ok<void>>(),
      );
      expect(valueOf(await service.getPreferences()).optedIn, isTrue);

      auth.signInAs(fxUsr06);
      expect(valueOf(await service.getPreferences()).optedIn, isFalse);
    });

    test(
      'preferences while signed out are unauthenticated [OP-NTF-03]',
      () async {
        expect(
          failureCodeOf(await serviceFor(null).getPreferences()),
          FailureCode.unauthenticated,
        );
      },
    );
  });
}
