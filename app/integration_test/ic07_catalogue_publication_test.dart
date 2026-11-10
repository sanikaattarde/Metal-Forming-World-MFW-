// IC-07 (`API_AND_MODULE_CONTRACTS.md` section 9): publishing and
// unpublishing show correctly after a refresh, through the real Firestore
// adapter and the access rules, on the local emulator (ENV-LOCAL standing in
// for ENV-TEST, which does not exist yet).
//
// Run with the Firestore emulator started from `backend/`:
//   sh scripts/run-with-env.sh npx firebase emulators:start \
//     --only firestore --project demo-mfw
// then, from `app/`:
//   flutter test integration_test/ic07_catalogue_publication_test.dart -d <id>
// The Android emulator reaches the machine as 10.0.2.2; set
// --dart-define=MFW_EMULATOR_HOST=... for another host.
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import 'support/emulator_admin.dart';

const String _definedHost = String.fromEnvironment('MFW_EMULATOR_HOST');

String get emulatorHost => _definedHost.isNotEmpty
    ? _definedHost
    : (Platform.isAndroid ? '10.0.2.2' : '127.0.0.1');

Map<String, Object?> issue(String title, String date, String state) =>
    <String, Object?>{
      'title': title,
      'description': 'Synthetic issue for IC-07.',
      'category_id': 'fx-cat-01',
      'publication_date': date,
      'year': int.parse(date.substring(0, 4)),
      'segment_ids': <String>['fx-seg-01'],
      'edition': 'E1',
      'file_size_bytes': 800000,
      'current_revision': 1,
      'publication_state': state,
    };

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late EmulatorAdmin admin;
  late DocumentCatalogueRepository catalogue;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'emulator-api-key',
        appId: Platform.isAndroid ? '1:0:android:0' : '1:0:ios:0',
        messagingSenderId: '0',
        projectId: 'demo-mfw',
      ),
    );
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator(emulatorHost, 8080);
    firestore.settings = const Settings(persistenceEnabled: false);
    catalogue = DocumentCatalogueRepository(
      FirestoreCatalogueDocuments(firestore),
      covers: CoverUrls.emulator(
        bucket: 'demo-mfw.appspot.com',
        host: emulatorHost,
      ),
    );
    admin = EmulatorAdmin(host: emulatorHost);
  });

  setUp(() async {
    await admin.clear();
    await admin.put('categories/fx-cat-01', <String, Object?>{
      'name': 'Test Category A',
    });
    await admin.put('segments/fx-seg-01', <String, Object?>{
      'name': 'Test Segment One',
    });
    await admin.put(
      'issues/fx-iss-01',
      issue('Test Issue 01', '2026-10-01', 'published'),
    );
    await admin.put(
      'issues/fx-iss-08',
      issue('Test Issue 08', '2026-10-15', 'unpublished'),
    );
  });

  test('the rules let the app read published issues only [IC-07, '
      'FR-MAG-008]', () async {
    final List<IssueSummary> issues =
        (await catalogue.listPublishedIssues() as Ok<List<IssueSummary>>).value;
    expect(issues.map((IssueSummary i) => i.issueId), <String>['fx-iss-01']);
    expect(issues.single.categoryId, 'fx-cat-01');
    expect(issues.single.fileSizeBytes, 800000);

    final Result<IssueSummary> hidden = await catalogue.getIssue('fx-iss-08');
    expect((hidden as Err<IssueSummary>).failure.code, FailureCode.notFound);

    final Result<IssueSummary> missing = await catalogue.getIssue('none');
    expect((missing as Err<IssueSummary>).failure.code, FailureCode.notFound);

    final List<IssueCategory> categories =
        (await catalogue.listCategories() as Ok<List<IssueCategory>>).value;
    expect(categories.single.name, 'Test Category A');

    final List<IndustrySegment> segments =
        (await catalogue.listSegments() as Ok<List<IndustrySegment>>).value;
    expect(segments.single.name, 'Test Segment One');
  });

  testWidgets('publish, refresh, unpublish, refresh on SCR-A-11 [IC-07, '
      'AC-1.4, AC-8.7]', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: CatalogueScreen(
          catalogue: catalogue,
          segments: catalogue,
          onOpenIssue: (String _) {},
        ),
      ),
    );
    await _settle(tester, find.text('1 issue'));
    expect(find.text('Test Issue 08'), findsNothing);

    await admin.put(
      'issues/fx-iss-08',
      issue('Test Issue 08', '2026-10-15', 'published'),
    );
    await _pull(tester);
    await _settle(tester, find.text('2 issues'));
    expect(find.text('Test Issue 08'), findsOneWidget);
    // The newest issue is listed first.
    expect(
      tester.getTopLeft(find.text('Test Issue 08')).dy,
      lessThan(tester.getTopLeft(find.text('Test Issue 01')).dy),
    );

    await admin.put(
      'issues/fx-iss-08',
      issue('Test Issue 08', '2026-10-15', 'unpublished'),
    );
    await _pull(tester);
    await _settle(tester, find.text('1 issue'));
    expect(find.text('Test Issue 08'), findsNothing);
  });

  testWidgets('an open issue that is unpublished shows as gone after a '
      'refresh on SCR-A-12 [IC-07, FR-MAG-008]', (WidgetTester tester) async {
    await admin.put(
      'issues/fx-iss-08',
      issue('Test Issue 08', '2026-10-15', 'published'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: IssueDetailsScreen(
          issueId: 'fx-iss-08',
          catalogue: catalogue,
          accessState: ValueNotifier<AccessState>(AccessState.signedOut),
          actions: IssueDetailsActions(
            onRead: (IssueSummary _) {},
            onSignIn: () {},
            onRegister: () {},
            onContinueSignUp: () {},
          ),
        ),
      ),
    );
    await _settle(tester, find.text('Synthetic issue for IC-07.'));

    await admin.put(
      'issues/fx-iss-08',
      issue('Test Issue 08', '2026-10-15', 'unpublished'),
    );
    await _pull(tester);
    await _settle(tester, find.text('This issue is no longer available'));
  });
}

Future<void> _pull(WidgetTester tester) async {
  await tester.fling(find.byType(Scrollable).first, const Offset(0, 400), 1000);
  await tester.pump();
}

/// Pumps until [finder] shows, for reads that go over the network.
Future<void> _settle(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}
