import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../../fakes/fake_reader_preferences.dart';
import 'reader_screen_test.dart' show FakeDocument, FakeRenderer, pumpReader;

FakeRenderer _three() => FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(3)));

void main() {
  group('page-turn mode [MOD07-P2-T02, FR-READ-006, OQ-14]', () {
    testWidgets('an issue opens in page-turn mode before any choice', (
      WidgetTester tester,
    ) async {
      ReaderController? reader;
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences(),
        actions: (ReaderController r) {
          reader = r;
          return const <Widget>[];
        },
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageTurnView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      expect(reader!.mode, ReaderMode.pageTurn);
    });

    testWidgets('a fling turns forward and back', (WidgetTester tester) async {
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences(),
      );
      await tester.pumpAndSettle();
      final Finder pages = find.byKey(ReaderScreen.pagesKey);

      await tester.fling(pages, const Offset(-200, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);

      await tester.fling(pages, const Offset(200, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('a short slow drag springs back', (WidgetTester tester) async {
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences(),
      );
      await tester.pumpAndSettle();

      final TestGesture drag = await tester.startGesture(
        tester.getCenter(find.byKey(ReaderScreen.pagesKey)),
      );
      for (int i = 0; i < 5; i++) {
        await drag.moveBy(const Offset(-10, 0));
        await tester.pump(const Duration(milliseconds: 100));
      }
      // Halfway through, both pages are drawn, the next beneath.
      expect(find.text('Page 2'), findsOneWidget);
      await drag.up();
      await tester.pumpAndSettle();

      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);
    });

    testWidgets('a drag past a third of the width turns the page', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences(),
      );
      await tester.pumpAndSettle();
      final double width = tester
          .getSize(find.byKey(ReaderScreen.pagesKey))
          .width;

      final TestGesture drag = await tester.startGesture(
        tester.getCenter(find.byKey(ReaderScreen.pagesKey)),
      );
      for (int i = 0; i < 10; i++) {
        await drag.moveBy(Offset(-width / 20, 0));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await drag.up();
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('the buttons turn with the effect, and stop at either end', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences(),
      );
      await tester.pumpAndSettle();
      final Finder next = find.widgetWithIcon(IconButton, Icons.chevron_right);

      await tester.tap(next);
      await tester.pump();
      await tester.pump(PageTurnView.duration ~/ 2);
      // The turn is on the way: both pages are drawn.
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('2 / 3'), findsOneWidget);

      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(next).onPressed, isNull);
      await tester.fling(
        find.byKey(ReaderScreen.pagesKey),
        const Offset(-200, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('3 / 3'), findsOneWidget);
    });

    testWidgets('going to a far page jumps, and is reported', (
      WidgetTester tester,
    ) async {
      final FakeRenderer renderer = FakeRenderer(
        Ok<PdfDocumentHandle>(FakeDocument(10)),
      );
      late ReaderController reader;
      await pumpReader(
        tester,
        renderer,
        preferences: MemoryReaderPreferences(),
        actions: (ReaderController r) {
          reader = r;
          return const <Widget>[];
        },
      );
      await tester.pumpAndSettle();
      final List<int> seen = <int>[];
      reader.watchCurrentPage().listen(seen.add);
      await tester.pump();

      await reader.goToPage(8);
      await tester.pump();
      expect(find.text('Page 8'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
      await tester.pumpAndSettle();
      expect(seen, <int>[1, 8]);
    });

    testWidgets('with reduce motion, pages change with no effect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: ReaderScreen(
              file: const LocalIssueFile(
                issueId: 'fx-iss-01',
                fileRevision: 1,
                path: '/private/issues/issue-fx-iss-01-r1.pdf',
              ),
              title: 'Test Issue 01',
              renderer: _three(),
              preferences: MemoryReaderPreferences(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pump();
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 2'), findsOneWidget);
    });
  });

  group('the mode choice [FR-READ-008]', () {
    testWidgets('the swipe mode opens as a plain swipe', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences(ReaderMode.swipe),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(PageTurnView), findsNothing);
    });

    testWidgets('a choice that cannot be read opens in page-turn mode', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        _three(),
        preferences: MemoryReaderPreferences()..fails = true,
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageTurnView), findsOneWidget);
    });

    testWidgets('settings show the mode and keep a new choice', (
      WidgetTester tester,
    ) async {
      final MemoryReaderPreferences preferences = MemoryReaderPreferences();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: Scaffold(body: ReaderModeTile(preferences: preferences)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(ReaderModeText.title), findsOneWidget);
      expect(find.text('Page turn'), findsOneWidget);

      await tester.tap(find.text(ReaderModeText.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swipe'));
      await tester.pumpAndSettle();

      expect(preferences.written, <ReaderMode>[ReaderMode.swipe]);
      expect(find.text('Swipe'), findsOneWidget);
    });

    testWidgets('a choice that cannot be kept says so and stays as it was', (
      WidgetTester tester,
    ) async {
      final MemoryReaderPreferences preferences = MemoryReaderPreferences();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: Scaffold(body: ReaderModeTile(preferences: preferences)),
        ),
      );
      await tester.pumpAndSettle();
      preferences.fails = true;

      await tester.tap(find.text(ReaderModeText.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swipe'));
      await tester.pumpAndSettle();

      expect(find.text(ReaderModeText.failed), findsOneWidget);
      expect(find.text('Page turn'), findsOneWidget);
    });
  });

  group('JsonReaderPreferences', () {
    late Directory folder;

    setUp(() async {
      folder = await Directory.systemTemp.createTemp('reader_prefs');
    });

    tearDown(() async {
      await folder.delete(recursive: true);
    });

    test('page turn first, then the choice kept across a restart', () async {
      final JsonReaderPreferences first = JsonReaderPreferences(
        () async => folder,
      );
      expect(await first.mode(), ReaderMode.pageTurn);

      await first.setMode(ReaderMode.swipe);
      expect(
        await JsonReaderPreferences(() async => folder).mode(),
        ReaderMode.swipe,
      );
    });

    test('an unreadable file gives page turn', () async {
      await File('${folder.path}/reader_preferences.json')
          .writeAsString('{"mode": 3');

      expect(
        await JsonReaderPreferences(() async => folder).mode(),
        ReaderMode.pageTurn,
      );
    });
  });
}
