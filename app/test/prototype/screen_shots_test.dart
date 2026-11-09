// Draws each screen and state of the branded prototype (MOD16-P1-T05) and
// checks it against the accessibility baseline proposed for OQ-25, the
// same checks as the design frames (test/design/).
//
// The checks run on every `flutter test`. To draw the images in
// test/prototype/shots/ at 780 by 1688 pixels (2x), run on a Mac:
//   flutter test --dart-define=MFW_DESIGN_FRAMES=true --update-goldens test/prototype/screen_shots_test.dart
// They are walk-through images, not goldens that guard anything: text is
// drawn differently on another machine.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';

import '../../prototype/main.dart';
import '../../prototype/model.dart';
import '../../prototype/screens_auth.dart';
import '../../prototype/screens_catalogue.dart';
import '../../prototype/screens_library.dart';
import '../../prototype/screens_news.dart';
import '../../prototype/screens_reader.dart';
import '../../prototype/screens_settings.dart';
import '../../prototype/widgets.dart';
import '../app/theme/brand_fonts.dart';

const bool _drawImages = bool.fromEnvironment('MFW_DESIGN_FRAMES');

/// The phone the frames are drawn for, in points.
const Size _phone = Size(390, 844);

/// One screen to draw: a name, the state, and the widget.
typedef Shot = (String, void Function(ProtoModel), Widget);

void _full(ProtoModel m) => m.access = Access.fullAccess;

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
  ('scr_a_06_profile', _full, const ProfileScreen()),
  (
    'scr_a_07_settings',
    (ProtoModel m) => m
      ..access = Access.fullAccess
      ..notificationsExplained = true,
    const SettingsScreen(),
  ),
  ('scr_a_07_settings_visitor', (ProtoModel m) {}, const SettingsScreen()),
  ('scr_a_08_delete_account', _full, const DeleteAccountScreen()),
  ('scr_a_10_home', (ProtoModel m) {}, const HomeScreen()),
  ('scr_a_11_catalogue', (ProtoModel m) {}, const CatalogueScreen()),
  (
    'scr_a_12_issue_details',
    _full,
    IssueDetailsScreen(issue: sampleIssues.first),
  ),
  (
    'scr_a_12_issue_details_visitor',
    (ProtoModel m) {},
    IssueDetailsScreen(issue: sampleIssues.first),
  ),
  (
    'scr_a_13_download_waiting',
    _full,
    _SheetFrame(
      child: DownloadSheet(
        issue: sampleIssues.first,
        keep: true,
        waitingAt: 0.42,
      ),
    ),
  ),
  (
    'scr_a_13_download_choice',
    _full,
    _SheetFrame(child: DownloadSheet(issue: sampleIssues.first, keep: false)),
  ),
  (
    'scr_a_14_reader',
    _full,
    ReaderScreen(issue: sampleIssues[2], initialPage: 4),
  ),
  ('scr_a_15_downloads', _full, const DownloadsScreen()),
  ('scr_a_16_17_library', _full, const LibraryScreen()),
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
    'state_empty_search',
    (ProtoModel m) => m.content = Content.empty,
    const CatalogueScreen(),
  ),
  (
    'state_news_unreachable',
    (ProtoModel m) => m.newsReachable = false,
    const NewsListScreen(),
  ),
  (
    'state_low_storage',
    (ProtoModel m) => m
      ..access = Access.fullAccess
      ..lowStorage = true,
    _SheetFrame(child: DownloadSheet(issue: sampleIssues.first, keep: true)),
  ),
  (
    'state_damaged_file',
    (ProtoModel m) => m
      ..access = Access.fullAccess
      ..damagedFile = true,
    ReaderScreen(issue: sampleIssues.first),
  ),
  (
    'state_unpublished_issue',
    (ProtoModel m) => m.unpublished = true,
    IssueDetailsScreen(issue: sampleIssues.first),
  ),
  ('state_needs_full_access', (ProtoModel m) {}, const LibraryScreen()),
];

/// A sheet over the issue details, drawn as the sheet opens.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ExcludeSemantics(
            child: IssueDetailsScreen(issue: sampleIssues.first),
          ),
        ),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(child: child),
        ),
      ],
    );
  }
}

/// Pumps [screen] on the phone. With [image], it is drawn twice as large
/// inside the captured boundary (the harness captures one pixel per
/// point), so the image is 780 by 1688 pixels; the checks run without it.
Future<void> _pump(WidgetTester tester, Shot shot, {bool image = false}) async {
  final (String _, void Function(ProtoModel) setUp, Widget screen) = shot;
  final double scale = image ? 2 : 1;
  tester.view.physicalSize = _phone * scale * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final ProtoModel model = ProtoModel()..showIds = false;
  setUp(model);
  final Widget app = Proto(
    model: model,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildMfwTheme(),
      home: screen,
    ),
  );
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey<String>('shot'),
      child: image
          ? Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: _phone.width,
                maxWidth: _phone.width,
                minHeight: _phone.height,
                maxHeight: _phone.height,
                child: app,
              ),
            )
          : app,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadBrandFonts);

  for (final Shot shot in _shots) {
    final String name = shot.$1;
    testWidgets('$name meets the tap-target baseline [OQ-25]', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _pump(tester, shot);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });

    testWidgets('$name is drawn', (WidgetTester tester) async {
      await _pump(tester, shot, image: true);
      await expectLater(
        find.byKey(const ValueKey<String>('shot')),
        matchesGoldenFile('shots/$name.png'),
      );
    }, skip: !_drawImages);
  }

  test('the app widget still builds', () {
    expect(PrototypeApp(model: ProtoModel()), isA<Widget>());
  });

  testWidgets('the screen IDs can be hidden for the walk-through with MFW', (
    WidgetTester tester,
  ) async {
    final ProtoModel model = ProtoModel();
    await tester.pumpWidget(PrototypeApp(model: model));
    expect(find.text('SCR-A-10'), findsOneWidget);
    model.showIds = false;
    await tester.pump();
    expect(find.text('SCR-A-10'), findsNothing);
  });
}
