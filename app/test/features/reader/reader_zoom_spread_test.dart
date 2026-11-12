import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../../fakes/fake_reader_preferences.dart';
import 'reader_screen_test.dart';

Finder _pages() => find.byKey(ReaderScreen.pagesKey);

Future<void> _doubleTap(WidgetTester tester) async {
  await tester.tap(_pages());
  await tester.pump(const Duration(milliseconds: 60));
  await tester.tap(_pages());
  await tester.pumpAndSettle();
}

ZoomableUnitState _zoom(WidgetTester tester) =>
    tester.state<ZoomableUnitState>(find.byType(ZoomableUnit));

void main() {
  group('what shows at once [FR-READ-009]', () {
    test('upright: one page at a time', () {
      expect(readerUnits(pageCount: 3, spread: false), <List<int>>[
        <int>[1],
        <int>[2],
        <int>[3],
      ]);
    });

    test('a spread: the cover alone, then pages in twos', () {
      expect(readerUnits(pageCount: 6, spread: true), <List<int>>[
        <int>[1],
        <int>[2, 3],
        <int>[4, 5],
        <int>[6],
      ]);
    });

    test('a page wider than tall stands alone', () {
      expect(
        readerUnits(
          pageCount: 6,
          spread: true,
          isLandscape: (int page) => page == 3,
        ),
        <List<int>>[
          <int>[1],
          <int>[2],
          <int>[3],
          <int>[4, 5],
          <int>[6],
        ],
      );
    });

    test('unitOf finds the pair holding a page', () {
      final List<List<int>> units = readerUnits(pageCount: 5, spread: true);
      expect(unitOf(units, 3), 1);
      expect(unitOf(units, 5), 2);
      expect(unitOf(units, 9), 0);
    });
  });

  group('two pages side by side on a phone turned on its side', () {
    for (final ReaderMode mode in ReaderMode.values) {
      testWidgets('the cover, then pairs, with the buttons (${mode.name})', (
        WidgetTester tester,
      ) async {
        await pumpReader(
          tester,
          FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(5))),
          preferences: MemoryReaderPreferences(mode),
          size: phoneLandscape,
        );
        await tester.pumpAndSettle();
        expect(find.text('Page 1'), findsOneWidget);
        expect(find.text('1 / 5'), findsOneWidget);

        final Finder next = find.widgetWithIcon(
          IconButton,
          Icons.chevron_right,
        );
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(find.text('Page 2'), findsOneWidget);
        expect(find.text('Page 3'), findsOneWidget);
        expect(find.text('2–3 / 5'), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('^Page 2 of 5')), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('^Page 3 of 5')), findsOneWidget);

        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(find.text('4–5 / 5'), findsOneWidget);
        expect(tester.widget<IconButton>(next).onPressed, isNull);
      });
    }

    testWidgets('a page asked for opens with its pair, and turning the phone '
        'keeps it', (WidgetTester tester) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(5))),
        preferences: MemoryReaderPreferences(),
        initialPage: 3,
        size: phoneLandscape,
      );
      await tester.pumpAndSettle();
      expect(find.text('2–3 / 5'), findsOneWidget);

      useSize(tester, phone);
      await tester.pumpAndSettle();
      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);

      useSize(tester, phoneLandscape);
      await tester.pumpAndSettle();
      expect(find.text('2–3 / 5'), findsOneWidget);
    });

    testWidgets('a fling turns a whole pair', (WidgetTester tester) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(5))),
        preferences: MemoryReaderPreferences(ReaderMode.swipe),
        initialPage: 2,
        size: phoneLandscape,
      );
      await tester.pumpAndSettle();

      await tester.fling(_pages(), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('4–5 / 5'), findsOneWidget);
    });
  });

  group('zoom to 300% [FR-READ-005, AC-2.3]', () {
    for (final ReaderMode mode in ReaderMode.values) {
      testWidgets('a double tap zooms, draws sharper, and stops page turns '
          '(${mode.name})', (WidgetTester tester) async {
        final FakeDocument document = FakeDocument(3);
        await pumpReader(
          tester,
          FakeRenderer(Ok<PdfDocumentHandle>(document)),
          preferences: MemoryReaderPreferences(mode),
        );
        await tester.pumpAndSettle();
        expect(document.sharpness[1], 1);

        await _doubleTap(tester);
        expect(_zoom(tester).scale, closeTo(2, 0.01));
        expect(document.sharpness[1], 2);

        await tester.fling(_pages(), const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();
        expect(find.text('1 / 3'), findsOneWidget);

        await _doubleTap(tester);
        expect(_zoom(tester).scale, closeTo(1, 0.01));
        expect(document.sharpness[1], 1);

        await tester.fling(_pages(), const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();
        expect(find.text('2 / 3'), findsOneWidget);
      });
    }

    testWidgets('a pinch zooms no further than 300%, and turns no page', (
      WidgetTester tester,
    ) async {
      final FakeDocument document = FakeDocument(3);
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(document)),
        preferences: MemoryReaderPreferences(),
      );
      await tester.pumpAndSettle();
      final Offset centre = tester.getCenter(_pages());

      final TestGesture left = await tester.startGesture(
        centre - const Offset(20, 0),
        pointer: 1,
      );
      final TestGesture right = await tester.startGesture(
        centre + const Offset(20, 0),
        pointer: 2,
      );
      await tester.pump();
      for (int i = 0; i < 8; i++) {
        await left.moveBy(const Offset(-20, 0));
        await right.moveBy(const Offset(20, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await left.up();
      await right.up();
      await tester.pumpAndSettle();

      expect(_zoom(tester).scale, closeTo(ZoomableUnit.maxScale, 0.01));
      expect(document.sharpness[1], 3);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('turning to another page starts it at 100%', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(3))),
        preferences: MemoryReaderPreferences(),
      );
      await tester.pumpAndSettle();
      await _doubleTap(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);
      expect(_zoom(tester).scale, closeTo(1, 0.01));

      await tester.fling(_pages(), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('3 / 3'), findsOneWidget);
    });
  });
}
