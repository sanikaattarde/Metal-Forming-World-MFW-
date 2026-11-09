import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import 'download_test_support.dart';

/// A DownloadManager over a real one, with failures the test turns on.
final class _Flaky implements DownloadManager {
  _Flaky(this.inner);

  final DownloadManager inner;
  int listFailures = 0;
  Result<void>? deleteResult;
  AppFailure? prepareFailure;

  @override
  Stream<DownloadStatus> watch(String issueId) => inner.watch(issueId);

  @override
  Future<Result<DownloadPlan>> prepare(String issueId) async {
    final AppFailure? f = prepareFailure;
    return f == null ? inner.prepare(issueId) : Err<DownloadPlan>(f);
  }

  @override
  Future<Result<void>> start(
    String issueId, {
    required bool mobileDataAccepted,
  }) => inner.start(issueId, mobileDataAccepted: mobileDataAccepted);

  @override
  Future<Result<void>> cancel(String issueId) => inner.cancel(issueId);

  @override
  Future<Result<void>> delete(String issueId) async =>
      deleteResult ?? await inner.delete(issueId);

  @override
  Future<List<DownloadedIssue>> listDownloaded() async {
    if (listFailures > 0) {
      listFailures--;
      throw Exception('synthetic list failure');
    }
    return inner.listDownloaded();
  }

  @override
  Future<Result<LocalIssueFile>> openLocal(String issueId) =>
      inner.openLocal(issueId);
}

Future<void> _pumpScreen(WidgetTester tester, DownloadManager downloads) =>
    tester.pumpWidget(MaterialApp(home: DownloadsScreen(downloads: downloads)));

Future<void> _pumpPanel(
  WidgetTester tester,
  DownloadManager downloads,
  String issueId,
) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: DownloadPanel(downloads: downloads, issueId: issueId),
    ),
  ),
);

void main() {
  group('IssueDownloadManager after a failure at start', () {
    test('a failed registry load is tried again on the next call', () async {
      final DownloadRig rig = DownloadRig();
      expect(
        await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
        isA<Ok<void>>(),
      );
      rig.registry.loadFailures = 1;
      rig.manager = rig.newManager();

      await expectLater(rig.manager.listDownloaded(), throwsException);
      expect(
        (await rig.manager.listDownloaded()).map(
          (DownloadedIssue c) => c.issueId,
        ),
        <String>['fx-iss-01'],
      );
    });

    test('a failed repair does not stop a kept copy from opening, and runs '
        'again before the next list', () async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      rig.store.files['/fake-app-private/downloads/orphan.pdf'] = <int>[1];
      rig.store.completeFilesFailures = 1;
      rig.manager = rig.newManager();

      expect(
        await rig.manager.openLocal('fx-iss-01'),
        isA<Ok<LocalIssueFile>>(),
      );
      expect(rig.store.files, hasLength(2));

      await rig.manager.listDownloaded();

      expect(rig.store.files, hasLength(1));
    });
  });

  group('DownloadsScreen failures', () {
    testWidgets('a list that cannot be read shows a message and Retry '
        '[FR-STATE-003]', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      final _Flaky downloads = _Flaky(rig.manager)..listFailures = 1;

      await _pumpScreen(tester, downloads);
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.listFailed), findsOneWidget);

      await tester.tap(find.text(DownloadsText.retry));
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.listFailed), findsNothing);
      expect(find.text('fx-iss-01'), findsOneWidget);
    });

    testWidgets('a refused delete says why', (WidgetTester tester) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      const AppFailure refused = AppFailure(FailureCode.unauthenticated);
      final _Flaky downloads = _Flaky(rig.manager)
        ..deleteResult = const Err<void>(refused);

      await _pumpScreen(tester, downloads);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(DownloadsText.deleteDownload));
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.failure(refused)), findsOneWidget);
      expect(find.text('fx-iss-01'), findsOneWidget);
    });

    testWidgets('pulling the list down reads it again', (
      WidgetTester tester,
    ) async {
      final DownloadRig rig = DownloadRig();
      await rig.manager.start('fx-iss-01', mobileDataAccepted: false);
      await _pumpScreen(tester, rig.manager);
      await tester.pumpAndSettle();

      await rig.manager.start('fx-iss-02', mobileDataAccepted: false);
      await tester.fling(find.text('fx-iss-01'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('fx-iss-02'), findsOneWidget);
    });
  });

  group('DownloadPanel failures', () {
    testWidgets('a Retry whose new plan is refused says why', (
      WidgetTester tester,
    ) async {
      final DownloadRig rig = DownloadRig(connection: ConnectionType.none);
      final _Flaky downloads = _Flaky(rig.manager);
      await _pumpPanel(tester, downloads, 'fx-iss-01');
      await tester.pumpAndSettle();
      await tester.tap(find.text(DownloadsText.download));
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.retry), findsOneWidget);

      const AppFailure refused = AppFailure(FailureCode.profileIncomplete);
      downloads.prepareFailure = refused;
      await tester.tap(find.text(DownloadsText.retry));
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.failure(refused)), findsWidgets);
    });

    testWidgets('a panel reused for another issue follows it', (
      WidgetTester tester,
    ) async {
      final DownloadRig rig = DownloadRig();
      await _pumpPanel(tester, rig.manager, 'fx-iss-01');
      await tester.pumpAndSettle();
      expect(find.text(DownloadsText.size(1000)), findsOneWidget);

      await _pumpPanel(tester, rig.manager, 'fx-iss-02');
      await tester.pumpAndSettle();

      expect(find.text(DownloadsText.size(1500)), findsOneWidget);
    });
  });
}
