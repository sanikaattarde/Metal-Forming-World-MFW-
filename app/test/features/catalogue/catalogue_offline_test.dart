// MOD05-P2-T05: the catalogue from the device when offline (NFR-OFF-002;
// OQ-10 working position of 12 November 2026, PROVISIONAL). The Firestore
// adapter's fallback to the SDK's copy runs only on a device; here the
// documents port says where its answer came from.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_documents.dart';
import 'catalogue_screens_test.dart';
import 'home_screen_test.dart' show pumpHome;

DocumentCatalogueRepository _catalogue({required bool fromCache}) =>
    DocumentCatalogueRepository(
      FakeCatalogueDocuments(
        issues: <String, Map<String, Object?>>{
          'fx-iss-01': issueDocument(
            title: 'Test Issue 01',
            date: '2026-10-01',
          ),
        },
        categories: <String, Map<String, Object?>>{
          'fx-cat-01': <String, Object?>{'name': 'Test Category A'},
        },
      )..fromCache = fromCache,
      covers: const CoverUrls(bucket: 'demo-mfw.appspot.com'),
    );

void main() {
  test('the repository says when its answer came from the device', () {
    expect(_catalogue(fromCache: false).fromDevice, isFalse);
    expect(_catalogue(fromCache: true).fromDevice, isTrue);
  });

  for (final bool fromCache in <bool>[true, false]) {
    final String when = fromCache ? 'from the device' : 'from the server';

    testWidgets('SCR-A-11 $when ${fromCache ? 'says' : 'does not say'} '
        'the app is offline', (WidgetTester tester) async {
      await pumpCatalogue(tester, _catalogue(fromCache: fromCache));
      await tester.pumpAndSettle();

      expect(find.text('Test Issue 01'), findsOneWidget);
      expect(
        find.text(CatalogueText.offlineCopy),
        fromCache ? findsOneWidget : findsNothing,
      );
    });

    testWidgets('SCR-A-12 $when', (WidgetTester tester) async {
      await pumpDetails(
        tester,
        _catalogue(fromCache: fromCache),
        ValueNotifier<AccessState>(AccessState.signedOut),
        Recorded().actions(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Issue 01'), findsWidgets);
      expect(
        find.text(CatalogueText.offlineCopy),
        fromCache ? findsOneWidget : findsNothing,
      );
    });

    testWidgets('SCR-A-10 $when', (WidgetTester tester) async {
      await pumpHome(
        tester,
        _catalogue(fromCache: fromCache),
        HomeActions(onOpenIssue: (String _) {}, onOpenCatalogue: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Issue 01'), findsWidgets);
      expect(
        find.text(CatalogueText.offlineCopy),
        fromCache ? findsOneWidget : findsNothing,
      );
    });
  }
}
