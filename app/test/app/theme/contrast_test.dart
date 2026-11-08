import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

/// Contrast ratio of the Web Content Accessibility Guidelines 2.x.
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double lighter = la > lb ? la : lb;
  final double darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Normal text: 4.5 to 1. Large text and the parts of a control: 3 to 1.
const double _text = 4.5;
const double _part = 3;

/// One pair the theme draws, as recorded in `DESIGN_TOKENS.md` section 5.
final class _Pair {
  const _Pair(
    this.use,
    this.foreground,
    this.background,
    this.ratio, {
    this.minimum = _text,
    this.exception,
  });

  final String use;
  final Color foreground;
  final Color background;

  /// The ratio recorded in the document, to two decimals.
  final double ratio;
  final double minimum;

  /// The open question when the pair does not reach [minimum].
  final String? exception;
}

const List<_Pair> _pairs = <_Pair>[
  _Pair('body text', MfwColours.body, MfwColours.surface, 7.29),
  _Pair('headings', MfwColours.heading, MfwColours.surface, 14.74),
  _Pair('typed input text', MfwColours.heading, MfwColours.inputFill, 13.72),
  _Pair('hint text', MfwColours.body, MfwColours.inputFill, 6.79),
  _Pair(
    'pressed button label',
    MfwColours.onAction,
    MfwColours.actionPressed,
    18.10,
  ),
  _Pair(
    'status text on success',
    MfwColours.onStatus,
    MfwColours.success,
    9.50,
  ),
  _Pair(
    'status text on warning',
    MfwColours.onStatus,
    MfwColours.warning,
    9.77,
  ),
  _Pair(
    'focused field border',
    MfwColours.actionPressed,
    MfwColours.inputFill,
    16.84,
    minimum: _part,
  ),
  _Pair(
    'error border and selected icon',
    MfwColours.action,
    MfwColours.surface,
    4.19,
    minimum: _part,
  ),
  _Pair(
    'button label',
    MfwColours.onAction,
    MfwColours.action,
    4.19,
    exception: 'OQ-25',
  ),
  _Pair(
    'red links, tab labels and small labels',
    MfwColours.action,
    MfwColours.surface,
    4.19,
    exception: 'OQ-25',
  ),
  _Pair(
    'field border',
    MfwColours.divider,
    MfwColours.surface,
    1.37,
    minimum: _part,
    exception: 'OQ-25',
  ),
];

void main() {
  group('contrast of the token pairs [NFR-UX-004, OQ-25]', () {
    for (final _Pair pair in _pairs) {
      test('${pair.use}: ${pair.ratio} to 1', () {
        final double ratio = contrastRatio(pair.foreground, pair.background);

        expect(ratio, closeTo(pair.ratio, 0.005));
        if (pair.exception == null) {
          expect(ratio, greaterThanOrEqualTo(pair.minimum));
        } else {
          // A recorded exception: if a token changes so that it passes, the
          // record in DESIGN_TOKENS.md section 5 changes with it.
          expect(ratio, lessThan(pair.minimum));
        }
      });
    }

    test('success and warning are too light for text or icons on white', () {
      expect(
        contrastRatio(MfwColours.success, MfwColours.surface),
        lessThan(_part),
      );
      expect(
        contrastRatio(MfwColours.warning, MfwColours.surface),
        lessThan(_part),
      );
    });
  });
}
