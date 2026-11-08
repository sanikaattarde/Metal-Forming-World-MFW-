import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('colour tokens [NFR-UX-001, OQ-63]', () {
    test('take the website values of BRAND_REFERENCE section 4.3', () {
      expect(MfwColours.action, const Color(0xFFF0233B));
      expect(MfwColours.actionPressed, const Color(0xFF161616));
      expect(MfwColours.heading, const Color(0xFF282828));
      expect(MfwColours.body, const Color(0xFF48586A));
      expect(MfwColours.surface, const Color(0xFFFFFFFF));
      expect(MfwColours.inputFill, const Color(0xFFF5F7F8));
      expect(MfwColours.divider, const Color(0xFFDCDCDE));
    });

    test('propose the state colours from the website kit', () {
      expect(MfwColours.error, const Color(0xFFF0233B));
      expect(MfwColours.success, const Color(0xFF3DD800));
      expect(MfwColours.warning, const Color(0xFFFFAE25));
    });
  });

  group('type tokens [NFR-UX-001]', () {
    test('use the phone column of BRAND_REFERENCE section 5.2', () {
      final Map<TextStyle, (String, double, int)> expected =
          <TextStyle, (String, double, int)>{
            MfwType.display: (MfwFonts.fraunces, 32, 600),
            MfwType.h1: (MfwFonts.fraunces, 30, 600),
            MfwType.h2: (MfwFonts.fraunces, 24, 600),
            MfwType.h3: (MfwFonts.fraunces, 20, 600),
            MfwType.h4: (MfwFonts.fraunces, 18, 400),
            MfwType.h5: (MfwFonts.fraunces, 15, 500),
            MfwType.label: (MfwFonts.plusJakartaSans, 12, 600),
            MfwType.body: (MfwFonts.inter, 14, 400),
            MfwType.input: (MfwFonts.inter, 12, 400),
            MfwType.formLabel: (MfwFonts.fraunces, 14, 600),
            MfwType.button: (MfwFonts.fraunces, 13, 400),
            MfwType.small: (MfwFonts.inter, 11, 400),
          };
      for (final MapEntry<TextStyle, (String, double, int)> entry
          in expected.entries) {
        final (String family, double size, int weight) = entry.value;
        final TextStyle style = entry.key;
        expect(style.fontFamily, family);
        expect(style.fontSize, size);
        expect(style.fontWeight, FontWeight.values[weight ~/ 100 - 1]);
        expect(
          style.fontVariations,
          contains(FontVariation('wght', weight.toDouble())),
          reason: 'the bundled files are variable fonts',
        );
      }
    });

    test('set the Fraunces optical size to the font size', () {
      expect(MfwType.h1.fontVariations, contains(FontVariation('opsz', 30)));
      expect(
        MfwType.button.fontVariations,
        contains(FontVariation('opsz', 13)),
      );
    });

    test('name only the families the app bundles [DEP-78]', () async {
      final String manifest = await rootBundle.loadString('FontManifest.json');
      final Set<String> bundled = <String>{
        for (final Object? entry in jsonDecode(manifest) as List<Object?>)
          (entry! as Map<String, Object?>)['family']! as String,
      };

      expect(
        bundled,
        containsAll(<String>[
          MfwFonts.fraunces,
          MfwFonts.inter,
          MfwFonts.plusJakartaSans,
        ]),
      );
    });
  });

  test('touch targets are at least 48 by 48 [CODING_STANDARDS 9]', () {
    expect(MfwShape.minTouchTarget, greaterThanOrEqualTo(48));
  });
}
