import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/reader/reader.dart';

/// A page that fills its view, as reader pages do inside the page view.
const Widget page = SizedBox.expand(
  child: ColoredBox(color: Color(0xFF9E9E9E)),
);

Future<void> pinch(WidgetTester tester, double from, double to) async {
  final Offset centre = tester.getCenter(find.byType(ZoomablePage));
  final TestGesture left = await tester.createGesture();
  final TestGesture right = await tester.createGesture();
  await left.down(centre - Offset(from, 0));
  await right.down(centre + Offset(from, 0));
  await tester.pump();
  for (int step = 1; step <= 10; step++) {
    final double gap = from + (to - from) * step / 10;
    await left.moveTo(centre - Offset(gap, 0));
    await right.moveTo(centre + Offset(gap, 0));
    await tester.pump();
  }
  await left.up();
  await right.up();
  await tester.pumpAndSettle();
}

void main() {
  group('Zoom from 100% to 300% [FR-READ-005, AC-2.3]', () {
    test('the limits are 100% and 300%', () {
      expect(ReaderZoom.min, 1.0);
      expect(ReaderZoom.max, 3.0);
    });

    test('a scale is clamped at both ends', () {
      expect(ReaderZoom.clamp(0.4), 1.0);
      expect(ReaderZoom.clamp(2.0), 2.0);
      expect(ReaderZoom.clamp(7.5), 3.0);
    });

    testWidgets('pinching out stops at 300%, pinching in stops at 100%', (
      WidgetTester tester,
    ) async {
      final TransformationController transform = TransformationController();
      addTearDown(transform.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomablePage(
              transformationController: transform,
              child: page,
            ),
          ),
        ),
      );

      await pinch(tester, 10, 300);
      expect(transform.value.getMaxScaleOnAxis(), closeTo(3.0, 0.001));

      await pinch(tester, 300, 5);
      expect(transform.value.getMaxScaleOnAxis(), closeTo(1.0, 0.001));
    });

    testWidgets('reports when the page is zoomed in and out', (
      WidgetTester tester,
    ) async {
      final List<bool> zoomed = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomablePage(onZoomedChanged: zoomed.add, child: page),
          ),
        ),
      );

      await pinch(tester, 10, 100);
      await pinch(tester, 100, 5);

      expect(zoomed, <bool>[true, false]);
    });
  });
}
