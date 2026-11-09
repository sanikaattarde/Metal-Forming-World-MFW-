import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import 'download_test_support.dart';

Future<void> pumpPanel(WidgetTester tester, DownloadRig rig) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DownloadPanel(downloads: rig.manager, issueId: 'fx-iss-01'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DownloadPanel [MOD-06]', () {
    testWidgets('shows the size before the download [FR-DL-003, AC-4.4]', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, DownloadRig());

      expect(find.text(DownloadsText.size(1000)), findsOneWidget);
      expect(find.text(DownloadsText.download), findsOneWidget);
    });

    testWidgets('shows progress, then Downloaded [FR-DL-005, AC-4.1]', (
      WidgetTester tester,
    ) async {
      final DownloadRig rig = DownloadRig(
        chunkDelay: const Duration(milliseconds: 100),
      );
      await pumpPanel(tester, rig);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      final LinearProgressIndicator bar = tester.widget(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, greaterThan(0));
      expect(bar.value, lessThan(1));

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.downloaded), findsOneWidget);
    });

    testWidgets('on mobile data the warning comes before the download, and '
        'Cancel starts nothing [FR-DL-004, AC-4.5]', (
      WidgetTester tester,
    ) async {
      final DownloadRig rig = DownloadRig(connection: ConnectionType.mobile);
      await pumpPanel(tester, rig);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.mobileDataTitle), findsOneWidget);
      expect(rig.transport.fetches, 0);

      await tester.tap(find.text(DownloadsText.cancel));
      await tester.pumpAndSettle();
      expect(rig.transport.fetches, 0);
      expect(find.text(DownloadsText.download), findsOneWidget);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      await tester.tap(find.text(DownloadsText.useMobileData));
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.downloaded), findsOneWidget);
    });

    testWidgets('a switch to mobile data after the size was shown still '
        'brings the warning first [FR-DL-004]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await pumpPanel(tester, rig);

      rig.connectivity.type = ConnectionType.mobile;
      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      expect(rig.transport.fetches, 0);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.mobileDataTitle), findsOneWidget);
    });

    testWidgets('too little space is said before any download '
        '[FR-STATE-004]', (WidgetTester tester) async {
      await pumpPanel(tester, DownloadRig(capacityBytes: 999));

      expect(find.text(DownloadsText.notEnoughSpace), findsOneWidget);
      expect(find.text(DownloadsText.download), findsNothing);
    });

    testWidgets('a failed download offers a retry that completes '
        '[FR-STATE-006]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      rig.transport.resetAfterBytes = 300;
      await pumpPanel(tester, rig);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.failedNetwork), findsOneWidget);

      await tester.tap(find.text(DownloadsText.retry));
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.downloaded), findsOneWidget);
    });

    testWidgets('a hash mismatch says the file did not pass its check '
        '[FR-READ-010]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      rig.transport.corruptOneByte = true;
      await pumpPanel(tester, rig);

      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.failedCorrupt), findsOneWidget);
      expect(find.text(DownloadsText.retry), findsOneWidget);
    });
  });
}
