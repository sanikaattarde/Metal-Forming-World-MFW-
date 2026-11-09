// The T-02.1 walk-through against SCREEN_INVENTORY_AND_NAVIGATION
// sections 3, 5 and 7, as a test. Each step finds the screen by its
// SCR-A-nn ID.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../prototype/main.dart';
import '../../prototype/model.dart';

/// Runs on the 390 by 844 point phone of the design frames.
Future<ProtoModel> _start(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ProtoModel model = ProtoModel();
  await tester.pumpWidget(PrototypeApp(model: model));
  return model;
}

Future<void> _tapText(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('each tab shows its screen', (WidgetTester tester) async {
    final ProtoModel model = await _start(tester);
    model.access = Access.fullAccess;
    await tester.pump();
    expect(find.text('SCR-A-10'), findsOneWidget);
    final Map<String, String> tabs = <String, String>{
      'News': 'SCR-A-18',
      'Library': 'SCR-A-16 and SCR-A-17',
      'Downloads': 'SCR-A-15',
      'Settings': 'SCR-A-07',
    };
    for (final MapEntry<String, String> tab in tabs.entries) {
      await tester.tap(find.text(tab.key).last);
      await tester.pumpAndSettle();
      expect(find.text(tab.value), findsOneWidget, reason: tab.key);
    }
  });

  testWidgets('the entry rule takes a visitor through every step to the '
      'reader', (WidgetTester tester) async {
    final ProtoModel model = await _start(tester);
    await _tapText(tester, 'View issue');
    expect(find.text('SCR-A-12'), findsOneWidget);

    await _tapText(tester, 'Read');
    expect(find.text('SCR-A-01'), findsOneWidget);
    await _tapText(tester, 'New here? Create an account');
    expect(find.text('SCR-A-02'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await _tapText(tester, 'Create account');
    expect(find.text('SCR-A-03'), findsOneWidget);
    await _tapText(tester, 'I have verified my email');
    expect(find.text('SCR-A-05'), findsOneWidget);
    await _tapText(tester, 'Save and continue');
    expect(model.access, Access.fullAccess);

    expect(find.textContaining('SCR-A-13'), findsOneWidget);
    await _tapText(tester, 'Download and read');
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('SCR-A-14'), findsOneWidget);
    expect(model.isDownloaded(sampleIssues.first), isFalse);
  });

  testWidgets('a broken download keeps its progress and resumes, and a '
      'kept copy is listed', (WidgetTester tester) async {
    final ProtoModel model = await _start(tester);
    model
      ..access = Access.fullAccess
      ..outcome = DownloadOutcome.breaks;
    await tester.pump();
    await _tapText(tester, 'View issue');
    await _tapText(tester, 'Download');
    await tester.tap(find.widgetWithText(FilledButton, 'Download'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Resume'), findsOneWidget);
    expect(find.textContaining('kept'), findsOneWidget);

    await _tapText(tester, 'Resume');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(model.isDownloaded(sampleIssues.first), isTrue);
    expect(find.text('Downloaded for offline reading'), findsOneWidget);
  });

  testWidgets('the remaining screens open from their entry points', (
    WidgetTester tester,
  ) async {
    final ProtoModel model = await _start(tester);
    model.access = Access.fullAccess;
    await tester.pump();

    await tester.tap(find.byTooltip('Search the catalogue'));
    await tester.pumpAndSettle();
    expect(find.text('SCR-A-11'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(sampleArticles.first.title),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _tapText(tester, sampleArticles.first.title);
    expect(find.text('SCR-A-19'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await _tapText(tester, 'Your profile');
    expect(find.text('SCR-A-06'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _tapText(tester, 'Turn on notifications');
    expect(find.text('SCR-A-20'), findsOneWidget);
    await _tapText(tester, 'Continue');
    await _tapText(tester, 'Allow');
    expect(find.text('New issues'), findsOneWidget);
    await _tapText(tester, 'Delete account');
    expect(find.text('SCR-A-08'), findsOneWidget);
    await _tapText(tester, 'Delete my account');
    expect(model.access, Access.signedOut);
    expect(model.downloads, isEmpty);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    await _tapText(tester, 'Sign in or create an account');
    await _tapText(tester, 'Forgot your password?');
    expect(find.text('SCR-A-04'), findsOneWidget);
  });

  testWidgets('a notification tap, an unknown link and an unpublished issue', (
    WidgetTester tester,
  ) async {
    final ProtoModel model = await _start(tester);
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );

    unawaited(navigator.pushNamed('/issues/i09'));
    await tester.pumpAndSettle();
    expect(find.text('Sample issue 09'), findsWidgets);
    navigator.pop();
    await tester.pumpAndSettle();

    unawaited(navigator.pushNamed('/no-such-page'));
    await tester.pumpAndSettle();
    expect(find.text('SCR-A-22'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    model.unpublished = true;
    unawaited(navigator.pushNamed('/issues/i12'));
    await tester.pumpAndSettle();
    expect(find.text('This issue is no longer available.'), findsOneWidget);
  });

  testWidgets('the states of section 7 show', (WidgetTester tester) async {
    final ProtoModel model = await _start(tester);
    model
      ..access = Access.fullAccess
      ..online = false;
    await tester.pump();
    expect(
      find.text('No connection. Downloaded issues are still available.'),
      findsOneWidget,
    );
    expect(find.text('This needs a connection.'), findsOneWidget);

    model
      ..online = true
      ..content = Content.empty;
    await tester.tap(find.text('Downloads').last);
    await tester.pumpAndSettle();
    expect(find.text('No downloaded issues yet.'), findsOneWidget);

    model
      ..content = Content.normal
      ..newsReachable = false;
    await tester.tap(find.text('News').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be refreshed'), findsOneWidget);

    model
      ..content = Content.loading
      ..newsReachable = true;
    await tester.pump();
    expect(find.bySemanticsLabel('Loading'), findsWidgets);
  });
}

void unawaited(Future<void> future) {}
