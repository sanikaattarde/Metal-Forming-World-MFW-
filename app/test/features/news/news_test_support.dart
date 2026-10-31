import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/features/news/news.dart';

/// The site as configured for the tests: CFG-03 and CFG-04 are OPEN
/// (OQ-39), so the address is a reserved example host and the categories
/// are the FX-WP-01 ones.
final WordPressSite testSite = WordPressSite(
  baseUrl: Uri.parse('https://wordpress.example/'),
  categoryIds: const <String>['11', '12', '13'],
  timeout: const Duration(milliseconds: 50),
);

/// The repository over [transport] for [testSite].
WordPressNewsRepository repositoryOver(HttpTransport transport) =>
    WordPressNewsRepository(transport: transport, site: testSite);

/// Pumps [screen] in the placeholder theme on a surface of [size].
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(800, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: placeholderTheme, home: screen));
}
