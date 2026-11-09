// Renders the MOD16-P1-T02 design frames and checks them against the
// accessibility baseline proposed for OQ-25 (CODING_STANDARDS.md
// section 9): tap targets and labels.
//
// The checks run on every `flutter test`. To redraw the images in
// Documentation/design/reader/, run on a Mac:
//   flutter test --dart-define=MFW_DESIGN_FRAMES=true --update-goldens test/design/reader_frames_test.dart
// They are design images, not goldens that guard the app: text is drawn
// differently on another machine, so they are compared only when the
// define is given.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';

import '../app/theme/brand_fonts.dart';
import 'reader_frames.dart';

const bool _drawImages = bool.fromEnvironment('MFW_DESIGN_FRAMES');

/// The phone the frames are drawn for, in points.
const Size _phone = Size(390, 844);

/// Pumps [frame] on a 390 by 844 point phone. With [image], the frame is
/// drawn twice as large inside the captured boundary, because the test
/// harness captures at one pixel per point: the image is then 780 by 1688
/// pixels, a 2x drawing. The tap-target checks run without it, at the real
/// size.
Future<void> _pumpFrame(
  WidgetTester tester,
  ReaderFrame frame, {
  bool image = false,
}) async {
  final double scale = image ? 2 : 1;
  tester.view.physicalSize = _phone * scale * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final Widget screen = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildMfwTheme(),
    home: frame.screen,
  );
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey<String>('frame'),
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
                child: screen,
              ),
            )
          : screen,
    ),
  );
  // Progress indicators never settle, so pump a fixed time.
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadBrandFonts);

  group('MOD16-P1-T02 design frames', () {
    test('cover SCR-A-10 to SCR-A-19 and SCR-A-22', () {
      final Set<String> screens = <String>{
        for (final ReaderFrame f in readerFrames) f.title.substring(0, 8),
      };
      expect(screens, <String>{
        for (int n = 10; n <= 19; n++) 'SCR-A-$n',
        'SCR-A-22',
      });
    });

    test('cover the states of section 7 that apply to these screens', () {
      final String titles = readerFrames
          .map((ReaderFrame f) => f.title)
          .join('\n');
      for (final String state in <String>[
        'loading',
        'empty',
        'no network',
        'low storage',
        'failed',
        'site unreachable',
      ]) {
        expect(titles, contains(state), reason: state);
      }
    });

    for (final ReaderFrame frame in readerFrames) {
      testWidgets('${frame.title} meets the tap-target baseline [OQ-25]', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        await _pumpFrame(tester, frame);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // Text contrast is guarded by test/app/theme/contrast_test.dart; the
        // frames inherit the exceptions of DESIGN_TOKENS.md section 5.
        semantics.dispose();
      });

      testWidgets('${frame.title} is drawn', (WidgetTester tester) async {
        await _pumpFrame(tester, frame, image: true);
        await expectLater(
          find.byKey(const ValueKey<String>('frame')),
          matchesGoldenFile(
            '../../../Documentation/design/reader/${frame.name}.png',
          ),
        );
      }, skip: !_drawImages);
    }
  });
}
