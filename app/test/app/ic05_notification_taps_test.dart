// MOD01-P3-T01: the IC-05 consumer check end to end. Each payload of
// FX-NTF-01 to FX-NTF-08 is tapped on the device's push client and goes
// through MOD-11's service, the notification bridge, the access guard and
// the real router (RS FR-NOTIF-005, BR-005; TEST_DATA_AND_FIXTURES section
// 11). The payload reaches the app as OP-25 sends it: string values under
// `target_type` and `target_ref`. On a device this needs push in MFW's
// accounts (MOD11-P2-T01).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/reader_route.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_catalogue_repository.dart';
import '../fakes/fake_download_manager.dart';
import '../fakes/fake_issue_file_service.dart';
import '../fakes/fake_news_repository.dart';
import '../fakes/fake_server.dart';
import '../fakes/fixture_loader.dart';
import '../fakes/test_users.dart';
import '../features/notifications/notification_fakes.dart';
import '../fixtures/fx_issue_files.dart';
import 'app_harness.dart';

/// FX-NTF-[n] as the device receives it: every value a string, the fixture's
/// `type` named as OP-25 names it.
Map<String, String> payload(String id) {
  final Map<String, Object?> fixture =
      (readJsonFixture('notifications/fx_ntf_payloads.json')
              as Map<String, Object?>)[id]!
          as Map<String, Object?>;
  String text(Object? value) => value is String ? value : jsonEncode(value);
  final Object? type = fixture['type'];
  return <String, String>{
    if (type != null)
      'target_type': type == 'article' ? 'news_post' : text(type),
    if (fixture['targetId'] != null) 'target_ref': text(fixture['targetId']),
    if (fixture['sendId'] != null) 'send_id': text(fixture['sendId']),
  };
}

void main() {
  late FakePushMessaging push;

  Future<GoRouter> pumpWith(WidgetTester tester, TestUser? user) async {
    push = FakePushMessaging();
    final FakeAuthService auth = FakeAuthService(
      FakeServer(),
      signedInAs: user,
    );
    final FakeDownloadManager downloads = FakeDownloadManager(
      auth,
      FakeIssueFileService(auth, files: fxIssueFiles),
    );
    return pumpAppWithContent(
      tester,
      auth,
      catalogue: FakeCatalogueRepository.fromFixtures(),
      downloads: downloads,
      news: FakeNewsRepository(
        posts: <NewsPost>[syntheticPost('101'), syntheticPost('102')],
      ),
      notifications: serviceOver(
        push: push,
        documents: FakeNotificationDocuments(),
        device: MemoryDeviceChoices(),
        userId: () => auth.currentUserId,
      ),
    );
  }

  Future<String> tap(WidgetTester tester, GoRouter router, String id) async {
    push.opened.add(payload(id));
    await tester.pumpAndSettle();
    return router.routerDelegate.currentConfiguration.uri.path;
  }

  group('IC-05: a tapped notification opens its target through the guard', () {
    testWidgets('FX-NTF-01 opens the issue in the reader with full access', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpWith(tester, fxUsr01);
      expect(await tap(tester, router, 'FX-NTF-01'), '/issues/fx-iss-01/read');
    });

    for (final String id in <String>['FX-NTF-02', 'FX-NTF-03']) {
      testWidgets('$id opens the article, signed out too', (
        WidgetTester tester,
      ) async {
        final GoRouter router = await pumpWith(tester, null);
        final String target = id == 'FX-NTF-02' ? '101' : '102';
        expect(await tap(tester, router, id), '/news/$target');
        expect(find.text('Synthetic post $target'), findsOneWidget);
      });
    }

    for (final String id in <String>['FX-NTF-04', 'FX-NTF-05', 'FX-NTF-08']) {
      testWidgets('$id is ignored and the app stays where it was', (
        WidgetTester tester,
      ) async {
        final GoRouter router = await pumpWith(tester, fxUsr01);
        expect(await tap(tester, router, id), '/');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('FX-NTF-06, an issue since unpublished, says it is no longer '
        'available', (WidgetTester tester) async {
      final GoRouter router = await pumpWith(tester, fxUsr01);
      expect(await tap(tester, router, 'FX-NTF-06'), '/issues/fx-iss-08/read');
      expect(find.text(ReaderRouteText.goneHeading), findsOneWidget);
    });

    testWidgets('FX-NTF-07 while signed out asks to sign in first, keeping '
        'the issue [BR-005]', (WidgetTester tester) async {
      final GoRouter router = await pumpWith(tester, null);
      await tap(tester, router, 'FX-NTF-07');
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/sign-in?from=%2Fissues%2Ffx-iss-01%2Fread',
      );
    });
  });
}
