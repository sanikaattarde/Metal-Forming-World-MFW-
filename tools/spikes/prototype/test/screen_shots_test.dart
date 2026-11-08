// Renders each prototype screen to a PNG in test/shots/, at a phone size,
// for the Figma file and the walk-through record. Run with:
//
//   flutter test test/screen_shots_test.dart --update-goldens \
//     --dart-define=FONT_DIR=<flutter>/bin/cache/artifacts/material_fonts
//
// Without FONT_DIR the test is skipped, because the default test font
// draws boxes.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_prototype/main.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/screens_auth.dart';
import 'package:mfw_prototype/screens_catalogue.dart';
import 'package:mfw_prototype/screens_library.dart';
import 'package:mfw_prototype/screens_news.dart';
import 'package:mfw_prototype/screens_reader.dart';
import 'package:mfw_prototype/screens_settings.dart';
import 'package:mfw_prototype/widgets.dart';

const String _fontDir = String.fromEnvironment('FONT_DIR');

Future<void> _loadFont(String family, List<String> files) async {
  final FontLoader loader = FontLoader(family);
  for (final String file in files) {
    final List<int> bytes = File('$_fontDir/$file').readAsBytesSync();
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}

/// One screen to draw: a name, the state, and the widget.
typedef Shot = (String, void Function(ProtoModel), Widget);

final List<Shot> _shots = <Shot>[
  ('scr_a_01_sign_in', (ProtoModel m) {}, const SignInScreen()),
  ('scr_a_02_register', (ProtoModel m) {}, const RegisterScreen()),
  ('scr_a_03_verify_email', (ProtoModel m) {}, const VerifyEmailScreen()),
  ('scr_a_04_password_reset', (ProtoModel m) {}, const PasswordResetScreen()),
  (
    'scr_a_05_complete_profile',
    (ProtoModel m) {},
    const CompleteProfileScreen(),
  ),
  ('scr_a_06_profile', (ProtoModel m) {}, const ProfileScreen()),
  (
    'scr_a_07_settings',
    (ProtoModel m) => m
      ..access = Access.fullAccess
      ..notificationsExplained = true,
    const SettingsScreen(),
  ),
  ('scr_a_08_delete_account', (ProtoModel m) {}, const DeleteAccountScreen()),
  ('scr_a_10_home', (ProtoModel m) {}, const HomeScreen()),
  ('scr_a_11_catalogue', (ProtoModel m) {}, const CatalogueScreen()),
  (
    'scr_a_12_issue_details',
    (ProtoModel m) {},
    IssueDetailsScreen(issue: sampleIssues.first),
  ),
  (
    'scr_a_13_download_waiting',
    (ProtoModel m) {},
    _SheetFrame(issue: sampleIssues.first),
  ),
  (
    'scr_a_14_reader',
    (ProtoModel m) => m.access = Access.fullAccess,
    ReaderScreen(issue: sampleIssues[2], initialPage: 4),
  ),
  (
    'scr_a_15_downloads',
    (ProtoModel m) => m.access = Access.fullAccess,
    const DownloadsScreen(),
  ),
  (
    'scr_a_16_17_library',
    (ProtoModel m) => m.access = Access.fullAccess,
    const LibraryScreen(),
  ),
  ('scr_a_18_news', (ProtoModel m) {}, const NewsListScreen()),
  (
    'scr_a_19_article',
    (ProtoModel m) {},
    ArticleScreen(article: sampleArticles.first),
  ),
  (
    'scr_a_20_notifications',
    (ProtoModel m) {},
    const NotificationExplanationScreen(),
  ),
  ('scr_a_22_not_found', (ProtoModel m) {}, const NotFoundScreen()),
  (
    'state_offline_home',
    (ProtoModel m) => m.online = false,
    const HomeScreen(),
  ),
  (
    'state_empty_downloads',
    (ProtoModel m) => m
      ..access = Access.fullAccess
      ..content = Content.empty,
    const DownloadsScreen(),
  ),
  (
    'state_news_unreachable',
    (ProtoModel m) => m.newsReachable = false,
    const NewsListScreen(),
  ),
  (
    'state_damaged_file',
    (ProtoModel m) => m
      ..access = Access.fullAccess
      ..damagedFile = true,
    ReaderScreen(issue: sampleIssues.first),
  ),
  ('state_needs_full_access', (ProtoModel m) {}, const LibraryScreen()),
];

/// SCR-A-13 in its waiting state, drawn as a sheet would be.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'SCR-A-13 · ${issue.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const LinearProgressIndicator(value: 0.5),
                const SizedBox(height: 8),
                Text('50% of ${issue.sizeMb.toStringAsFixed(1)} MB kept'),
                const Text(
                  'The download stopped because the connection was lost.',
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: () {}, child: const Text('Resume')),
                TextButton(
                  onPressed: () {},
                  child: const Text('Cancel and delete the part downloaded'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    if (_fontDir.isEmpty) {
      return;
    }
    await _loadFont('Roboto', <String>[
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]);
    await _loadFont('MaterialIcons', <String>['MaterialIcons-Regular.otf']);
  });

  for (final (String name, void Function(ProtoModel) setUp, Widget screen)
      in _shots) {
    testWidgets(name, skip: _fontDir.isEmpty, (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(1170, 2532)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final ProtoModel model = ProtoModel();
      setUp(model);
      await tester.pumpWidget(
        Proto(
          model: model,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Roboto',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.grey,
                dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
              ),
            ),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('shots/$name.png'),
      );
    });
  }

  test('the app widget still builds', () {
    expect(PrototypeApp(model: ProtoModel()), isA<Widget>());
  });
}
