import 'package:flutter/material.dart';

/// Design tokens. PLACEHOLDER: brand assets not received.
///
/// Neutral names and grey values only: no MFW colour, font or logo before
/// the M2 designs on MFW's brand assets (RS NFR-UX-001). Contrast and touch
/// targets follow CODING_STANDARDS section 9 (PROVISIONAL, OQ-25).
abstract final class PlaceholderTokens {
  /// Screen background.
  static const Color surface = Color(0xFFFAFAFA);

  /// Text and icons on [surface].
  static const Color onSurface = Color(0xFF212121);

  /// Buttons and highlights.
  static const Color accent = Color(0xFF616161);

  /// Text and icons on [accent].
  static const Color onAccent = Color(0xFFFFFFFF);

  /// Smallest touch target in logical pixels: 48 dp on Android, which also
  /// covers 44 pt on iOS.
  static const double minTouchTarget = 48;
}

/// The app theme from [PlaceholderTokens]. PLACEHOLDER: brand assets not
/// received.
final ThemeData placeholderTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: PlaceholderTokens.accent,
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    surface: PlaceholderTokens.surface,
    onSurface: PlaceholderTokens.onSurface,
    primary: PlaceholderTokens.accent,
    onPrimary: PlaceholderTokens.onAccent,
  ),
  materialTapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.standard,
);
