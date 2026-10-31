import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import 'download_test_support.dart';

Future<void> pumpScreen(WidgetTester tester, DownloadRig rig) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DownloadsScreen(
        downloads: rig.manager,
        titleOf: (String issueId) => 'Title of $issueId',
      ),
    ),
  );
}

void main() {
  group('DownloadsScreen [MOD-06]', () {
    testWidgets('lists two downloaded issues with their size; a partial one '
        'is not listed [FR-DL-008, AC-4.7]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig(
        sizes: const <String, int>{
          'fx-iss-01': 1000,
          'fx-iss-02': 1500,
          'fx-iss-03': 800,
        },
      );
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      await rig.manager.start('fx-iss-02', mobileDataAccepted: false);
      rig.transport.gate = Completer<void>();
      unawaited(rig.manager.start('fx-iss-03', mobileDataAccepted: false));

      await pumpScreen(tester, rig);
      await tester.pumpAndSettle();

      expect(find.text('Title of fx-iss-01'), findsOneWidget);
      expect(find.text('Title of fx-iss-02'), findsOneWidget);
      expect(find.text('Title of fx-iss-03'), findsNothing);
      expect(find.text(DownloadsText.sizeLabel(1500)), findsOneWidget);
      rig.transport.gate!.complete();
    });

    testWidgets('deleting from the screen removes the entry and frees the '
        'space [FR-DL-009, AC-4.6]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      await pumpScreen(tester, rig);
      await tester.pumpAndSettle();
      final int freeBefore = rig.store.capacityBytes - rig.store.usedBytes;

      await tester.tap(find.byTooltip(DownloadsText.deleteDownload));
      await tester.pumpAndSettle();

      expect(find.text('Title of fx-iss-01'), findsNothing);
      expect(rig.store.capacityBytes - rig.store.usedBytes, freeBefore + 1000);
      expect(find.text(DownloadsText.empty), findsOneWidget);
    });

    testWidgets('with nothing downloaded it says so [FR-STATE-002]', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, DownloadRig());
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.empty), findsOneWidget);
    });

    testWidgets('the delete control has a label and is at least 48 by 48 '
        '[OQ-25]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      await pumpScreen(tester, rig);
      await tester.pumpAndSettle();

      final Size size = tester.getSize(
        find.byTooltip(DownloadsText.deleteDownload),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
