import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/app/theme/font_licences.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

Widget _themed(Widget child, {double textScale = 1}) {
  return MaterialApp(
    theme: buildMfwTheme(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  final ThemeData theme = buildMfwTheme();

  group('theme from the tokens [NFR-UX-001]', () {
    test('maps the colour roles onto the colour scheme', () {
      expect(theme.colorScheme.primary, MfwColours.action);
      expect(theme.colorScheme.onPrimary, MfwColours.onAction);
      expect(theme.colorScheme.surface, MfwColours.surface);
      expect(theme.colorScheme.onSurface, MfwColours.heading);
      expect(theme.colorScheme.onSurfaceVariant, MfwColours.body);
      expect(theme.colorScheme.error, MfwColours.error);
      expect(theme.colorScheme.outline, MfwColours.divider);
      expect(theme.scaffoldBackgroundColor, MfwColours.surface);
    });

    test('uses only the three website families for text', () {
      final TextTheme text = theme.textTheme;
      final List<TextStyle?> styles = <TextStyle?>[
        text.displayLarge,
        text.displayMedium,
        text.displaySmall,
        text.headlineLarge,
        text.headlineMedium,
        text.headlineSmall,
        text.titleLarge,
        text.titleMedium,
        text.titleSmall,
        text.bodyLarge,
        text.bodyMedium,
        text.bodySmall,
        text.labelLarge,
        text.labelMedium,
        text.labelSmall,
      ];
      for (final TextStyle? style in styles) {
        expect(
          style?.fontFamily,
          isIn(<String>[
            MfwFonts.fraunces,
            MfwFonts.inter,
            MfwFonts.plusJakartaSans,
          ]),
        );
      }
      expect(text.headlineLarge?.fontSize, 30);
      expect(text.bodyMedium?.fontSize, 14);
      expect(text.bodyLarge?.fontSize, 12, reason: 'text fields');
    });

    test('filled buttons are red, and #161616 when pressed', () {
      final ButtonStyle style = theme.filledButtonTheme.style!;

      expect(
        style.backgroundColor!.resolve(<WidgetState>{}),
        MfwColours.action,
      );
      expect(
        style.backgroundColor!.resolve(<WidgetState>{WidgetState.pressed}),
        MfwColours.actionPressed,
      );
      expect(
        style.backgroundColor!.resolve(<WidgetState>{WidgetState.focused}),
        MfwColours.actionPressed,
      );
      expect(
        style.side!.resolve(<WidgetState>{})!.color,
        MfwColours.action,
        reason: 'a 1 px border in the button colour',
      );
      expect(
        style.shape!.resolve(<WidgetState>{}),
        const RoundedRectangleBorder(),
        reason: 'square corners',
      );
    });

    test('a selected filter chip has a white label on #161616 [AC-7.3]', () {
      final ChipThemeData chips = theme.chipTheme;
      final Color label = chips.labelStyle!.color!;

      expect(chips.selectedColor, MfwColours.actionPressed);
      expect(
        WidgetStateProperty.resolveAs(label, <WidgetState>{
          WidgetState.selected,
        }),
        MfwColours.onAction,
      );
      expect(
        WidgetStateProperty.resolveAs(label, <WidgetState>{}),
        MfwColours.heading,
      );
    });

    test('field errors are marked by the border, with dark text', () {
      final InputDecorationThemeData input = theme.inputDecorationTheme;

      expect(input.filled, isTrue);
      expect(input.fillColor, MfwColours.inputFill);
      expect(
        (input.errorBorder! as OutlineInputBorder).borderSide.color,
        MfwColours.error,
      );
      expect(input.errorStyle?.color, MfwColours.heading);
    });

    testWidgets('buttons are at least 48 pixels tall [CODING_STANDARDS 9]', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _themed(FilledButton(onPressed: () {}, child: const Text('Read'))),
      );

      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(MfwShape.minTouchTarget),
      );
    });

    testWidgets('text follows the device text size [OQ-25]', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_themed(const Text('News')));
      final double normal = tester.getSize(find.text('News')).height;

      await tester.pumpWidget(_themed(const Text('News'), textScale: 2));
      final double large = tester.getSize(find.text('News')).height;

      // Line heights are rounded to whole pixels, so the ratio is near 2.
      expect(large / normal, closeTo(2, 0.1));
    });

    testWidgets('the app shell uses the theme [T-01.1]', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: MfwApp()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.text(ShellText.home));
      expect(Theme.of(context).colorScheme.primary, MfwColours.action);
    });
  });

  group('font licences [DEP-78]', () {
    tearDown(LicenseRegistry.reset);

    testWidgets('the licence page lists each typeface with its licence', (
      WidgetTester tester,
    ) async {
      registerFontLicences();

      final List<LicenseEntry> entries =
          await tester.runAsync(() => LicenseRegistry.licenses.toList()) ??
          <LicenseEntry>[];
      final Map<String, String> texts = <String, String>{
        for (final LicenseEntry entry in entries)
          entry.packages.single: entry.paragraphs
              .map((LicenseParagraph p) => p.text)
              .join('\n'),
      };

      expect(texts.keys, containsAll(fontLicenceAssets.keys));
      for (final String family in fontLicenceAssets.keys) {
        expect(texts[family], contains('SIL OPEN FONT LICENSE Version 1.1'));
        expect(texts[family], contains('Copyright 20'));
      }
    });
  });
}
