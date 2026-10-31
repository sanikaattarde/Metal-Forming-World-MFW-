import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import 'fake_pdf_renderer.dart';
import 'numbered_page_source.dart';
import 'reader_test_support.dart';

const Size phonePortrait = Size(390, 844);
const Size phoneLandscape = Size(844, 390);

Future<void> pumpReader(
  WidgetTester tester, {
  required FakePdfRenderer renderer,
  String issueId = 'fx-iss-01',
  Size size = phonePortrait,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: ReaderScreen(
        downloads: downloadsHolding(<String>[issueId]),
        renderer: renderer,
        pages: const NumberedPageSource(),
        issueId: issueId,
        mode: ReaderMode.pageTurn,
      ),
    ),
  );
}

FakePdfRenderer twelvePages() =>
    FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 12});

void main() {
  group('ReaderScreen with the fake page source [MOD-07]', () {
    testWidgets('shows loading while the issue opens [FR-STATE-001]', (
      WidgetTester tester,
    ) async {
      final FakePdfRenderer renderer = twelvePages()..gate = Completer<void>();

      await pumpReader(tester, renderer: renderer);
      await tester.pump();
      expect(find.text(ReaderText.loading), findsOneWidget);

      renderer.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text(ReaderText.pageOf(1, 12)), findsOneWidget);
    });

    testWidgets('a phone in portrait shows one page; Next shows page 2', (
      WidgetTester tester,
    ) async {
      await pumpReader(tester, renderer: twelvePages());
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);

      await tester.tap(find.byTooltip(ReaderText.nextPage));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text(ReaderText.pageOf(2, 12)), findsOneWidget);
    });

    testWidgets('swiping turns the page [FR-READ-003]', (
      WidgetTester tester,
    ) async {
      await pumpReader(tester, renderer: twelvePages());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text(ReaderText.pageOf(2, 12)), findsOneWidget);
    });

    testWidgets('in landscape the cover stands alone, then pages 2 and 3 are '
        'side by side [FR-READ-009, AC-2.4]', (WidgetTester tester) async {
      await pumpReader(tester, renderer: twelvePages(), size: phoneLandscape);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);

      await tester.tap(find.byTooltip(ReaderText.nextPage));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(
        tester.getCenter(find.text('2')).dx,
        lessThan(tester.getCenter(find.text('3')).dx),
      );
    });

    testWidgets('turning the phone keeps the reader on the same page', (
      WidgetTester tester,
    ) async {
      await pumpReader(tester, renderer: twelvePages(), size: phoneLandscape);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(ReaderText.nextPage));
      await tester.pumpAndSettle();

      tester.view.physicalSize = phonePortrait * 3;
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('a damaged file shows an error with Retry and does not crash '
        '[FR-READ-010, AC-2.6]', (WidgetTester tester) async {
      final FakePdfRenderer renderer = FakePdfRenderer(
        pageCounts: <String, int>{'fx-pdf-10': 4},
        damagedIssueIds: <String>{'fx-pdf-10'},
      );

      await pumpReader(tester, renderer: renderer, issueId: 'fx-pdf-10');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(ReaderText.damaged), findsOneWidget);
      expect(find.text(ReaderText.retry), findsOneWidget);

      renderer.damagedIssueIds.clear();
      await tester.tap(find.text(ReaderText.retry));
      await tester.pumpAndSettle();

      expect(find.text(ReaderText.pageOf(1, 4)), findsOneWidget);
    });

    testWidgets('a missing copy says so and offers no retry [FR-STATE-003]', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = phonePortrait * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: ReaderScreen(
            downloads: downloadsHolding(<String>[]),
            renderer: twelvePages(),
            pages: const NumberedPageSource(),
            issueId: 'fx-iss-01',
            mode: ReaderMode.pageTurn,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(ReaderText.notOnDevice), findsOneWidget);
      expect(find.text(ReaderText.retry), findsNothing);
    });

    testWidgets('pages zoom from 100% to 300% [FR-READ-005, AC-2.3]', (
      WidgetTester tester,
    ) async {
      await pumpReader(tester, renderer: twelvePages());
      await tester.pumpAndSettle();

      final InteractiveViewer viewer = tester.widget<InteractiveViewer>(
        find.descendant(
          of: find.byType(ZoomablePage),
          matching: find.byType(InteractiveViewer),
        ),
      );
      expect(viewer.minScale, ReaderZoom.min);
      expect(viewer.maxScale, ReaderZoom.max);
    });

    testWidgets('a pinch inside the reader zooms the page and does not turn '
        'it [FR-READ-005]', (WidgetTester tester) async {
      await pumpReader(tester, renderer: twelvePages());
      await tester.pumpAndSettle();
      final Offset centre = tester.getCenter(find.byType(PageView));
      final TestGesture left = await tester.createGesture();
      final TestGesture right = await tester.createGesture();
      await left.down(centre - const Offset(10, 0));
      await right.down(centre + const Offset(10, 0));
      await tester.pump();
      for (int step = 1; step <= 10; step++) {
        await left.moveTo(centre - Offset(10.0 + 12 * step, 0));
        await right.moveTo(centre + Offset(10.0 + 12 * step, 0));
        await tester.pump();
      }
      await left.up();
      await right.up();
      await tester.pumpAndSettle();

      final InteractiveViewer viewer = tester.widget<InteractiveViewer>(
        find.descendant(
          of: find.byType(ZoomablePage),
          matching: find.byType(InteractiveViewer),
        ),
      );
      expect(
        viewer.transformationController!.value.getMaxScaleOnAxis(),
        greaterThan(1.5),
      );
      expect(find.text(ReaderText.pageOf(1, 12)), findsOneWidget);
    });

    testWidgets('page buttons have labels and are at least 48 by 48 [OQ-25]', (
      WidgetTester tester,
    ) async {
      await pumpReader(tester, renderer: twelvePages());
      await tester.pumpAndSettle();

      for (final String label in <String>[
        ReaderText.previousPage,
        ReaderText.nextPage,
      ]) {
        final Size size = tester.getSize(find.byTooltip(label));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });
  });
}
