// Renders the MOD16-P1-T03 design frames and checks them against the
// accessibility baseline proposed for OQ-25 (CODING_STANDARDS.md
// section 9): tap targets and labels.
//
// The checks run on every `flutter test`. To redraw the images in
// Documentation/design/account/, run on a Mac:
//   flutter test --dart-define=MFW_DESIGN_FRAMES=true --update-goldens test/design/account_frames_test.dart
// They are design images, not goldens that guard the app: text is drawn
// differently on another machine, so they are compared only when the
// define is given.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';

import '../app/theme/brand_fonts.dart';
import 'account_frames.dart';

const bool _drawImages = bool.fromEnvironment('MFW_DESIGN_FRAMES');

Future<void> _pumpFrame(WidgetTester tester, DesignFrame frame) async {
  // A 390 by 844 point phone. The images are written at 1x, 390 by 844
  // pixels.
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildMfwTheme(),
      home: RepaintBoundary(
        key: const ValueKey<String>('frame'),
        child: frame.screen,
      ),
    ),
  );
  // Progress indicators never settle, so pump a fixed time.
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadBrandFonts);

  group('MOD16-P1-T03 design frames', () {
    test('cover SCR-A-01 to SCR-A-08, SCR-A-20 and SCR-A-21', () {
      final Set<String> screens = <String>{
        for (final DesignFrame f in accountFrames) f.title.substring(0, 8),
      };
      expect(screens, <String>{
        'SCR-A-01',
        'SCR-A-02',
        'SCR-A-03',
        'SCR-A-04',
        'SCR-A-05',
        'SCR-A-06',
        'SCR-A-07',
        'SCR-A-08',
        'SCR-A-20',
        'SCR-A-21',
      });
    });

    for (final DesignFrame frame in accountFrames) {
      testWidgets('${frame.title} meets the tap-target baseline [OQ-25]', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        await _pumpFrame(tester, frame);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // Text contrast is not checked here: the token pairs and their
        // ratios are guarded by test/app/theme/contrast_test.dart, and the
        // frames inherit the exceptions of DESIGN_TOKENS.md section 5 (the
        // button label and red links, 4.19 to 1), which MFW decides at M2
        // (OQ-25, OQ-63).
        semantics.dispose();
      });

      testWidgets('${frame.title} is drawn', (WidgetTester tester) async {
        await _pumpFrame(tester, frame);
        await expectLater(
          find.byKey(const ValueKey<String>('frame')),
          matchesGoldenFile(
            '../../../Documentation/design/account/${frame.name}.png',
          ),
        );
      }, skip: !_drawImages);
    }
  });
}
