import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme.dart';

double contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

bool isGrey(Color color) => color.r == color.g && color.g == color.b;

void main() {
  group('Placeholder theme [OQ-25]', () {
    test('every token colour is a neutral grey, not a brand colour', () {
      for (final Color color in <Color>[
        PlaceholderTokens.surface,
        PlaceholderTokens.onSurface,
        PlaceholderTokens.accent,
        PlaceholderTokens.onAccent,
      ]) {
        expect(isGrey(color), isTrue, reason: '$color');
      }
    });

    test('text contrast is at least 4.5:1', () {
      expect(
        contrast(PlaceholderTokens.onSurface, PlaceholderTokens.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(PlaceholderTokens.onAccent, PlaceholderTokens.accent),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('the theme uses the tokens and pads touch targets to 48 dp', () {
      expect(placeholderTheme.colorScheme.surface, PlaceholderTokens.surface);
      expect(
        placeholderTheme.colorScheme.onSurface,
        PlaceholderTokens.onSurface,
      );
      expect(placeholderTheme.colorScheme.primary, PlaceholderTokens.accent);
      expect(
        placeholderTheme.materialTapTargetSize,
        MaterialTapTargetSize.padded,
      );
      expect(PlaceholderTokens.minTouchTarget, 48);
    });
  });
}
