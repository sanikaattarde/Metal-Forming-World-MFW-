import 'package:flutter/painting.dart';

/// Colour tokens (MOD16-P1-T01, `DESIGN_TOKENS.md` section 3).
///
/// Working position of 8 November 2026: the website's colours are used as
/// they are (`BRAND_REFERENCE.md` section 4.3). OQ-63 stays open for MFW's
/// written confirmation. The logo blue stays inside the logo and is not a
/// token.
abstract final class MfwColours {
  /// Filled buttons, the selected tab and pressed links (website buttons).
  static const Color action = Color(0xFFF0233B);

  /// Pressed or focused action (website button hover).
  static const Color actionPressed = Color(0xFF161616);

  /// Label on [action] and on [actionPressed].
  static const Color onAction = Color(0xFFFFFFFF);

  /// Headings, and text in input fields (website `h1` to `h5`).
  static const Color heading = Color(0xFF282828);

  /// Body text (website body text).
  static const Color body = Color(0xFF48586A);

  /// Page ground (website page ground).
  static const Color surface = Color(0xFFFFFFFF);

  /// Input field fill (website input fields).
  static const Color inputFill = Color(0xFFF5F7F8);

  /// Dividers and field borders (website border).
  static const Color divider = Color(0xFFDCDCDE);

  /// Error indicator: borders and icons only, never text (PROPOSED, kit
  /// colour `d49ac81`). Error text uses [heading].
  static const Color error = Color(0xFFF0233B);

  /// Success fill behind [onStatus] content (PROPOSED, kit colour
  /// `e4f358e`). Too light for an icon or text on [surface].
  static const Color success = Color(0xFF3DD800);

  /// Warning fill behind [onStatus] content (PROPOSED, kit colour
  /// `b3919de`). Too light for an icon or text on [surface].
  static const Color warning = Color(0xFFFFAE25);

  /// Text and icons on [success] and [warning] (website button hover).
  static const Color onStatus = Color(0xFF161616);
}

/// The website's three typefaces (`BRAND_REFERENCE.md` section 5.1, DEP-78).
abstract final class MfwFonts {
  /// Serif for headings, buttons and form labels.
  static const String fraunces = 'Fraunces';

  /// Sans serif for body text, input fields and small text.
  static const String inter = 'Inter';

  /// Sans serif for small uppercase labels (website `h6`).
  static const String plusJakartaSans = 'Plus Jakarta Sans';
}

/// Type tokens: the phone column of the website's type scale
/// (`BRAND_REFERENCE.md` section 5.2), in logical pixels.
///
/// The bundled files are variable fonts, so each style sets the weight axis
/// as well as [TextStyle.fontWeight]. Fraunces also sets its optical size to
/// the font size, as a browser does. The device text size applies on top
/// (OQ-25), through `MediaQuery.textScalerOf`.
abstract final class MfwType {
  /// Display (kit ID `a435f28`): Fraunces 600, 32.
  static final TextStyle display = _fraunces(
    32,
    600,
    height: 1.0,
    letterSpacing: -2,
  );

  /// Heading 1: Fraunces 600, 30.
  static final TextStyle h1 = _fraunces(
    30,
    600,
    height: 1.3,
    letterSpacing: -1.5,
  );

  /// Heading 2: Fraunces 600, 24.
  static final TextStyle h2 = _fraunces(
    24,
    600,
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// Heading 3: Fraunces 600, 20.
  static final TextStyle h3 = _fraunces(
    20,
    600,
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// Heading 4: Fraunces 400, 18.
  static final TextStyle h4 = _fraunces(18, 400, height: 1.3);

  /// Heading 5: Fraunces 500, 15.
  static final TextStyle h5 = _fraunces(15, 500, height: 1.4);

  /// Small uppercase label (website `h6`): Plus Jakarta Sans 600, 12, in
  /// [MfwColours.action]. The widget sets the text in capitals, because a
  /// [TextStyle] cannot.
  static const TextStyle label = TextStyle(
    fontFamily: MfwFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
    color: MfwColours.action,
  );

  /// Body text: Inter 400, 14.
  static const TextStyle body = TextStyle(
    fontFamily: MfwFonts.inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
    height: 1.4,
    color: MfwColours.body,
  );

  /// Text typed in an input field: Inter 400, 12.
  static const TextStyle input = TextStyle(
    fontFamily: MfwFonts.inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
    height: 1.4,
    color: MfwColours.heading,
  );

  /// Form label: Fraunces 600, 14.
  static final TextStyle formLabel = _fraunces(
    14,
    600,
    height: 1.5,
    color: MfwColours.body,
  );

  /// Button label: Fraunces 400, 13, in [MfwColours.onAction].
  static final TextStyle button = _fraunces(
    13,
    400,
    height: 1.0,
    color: MfwColours.onAction,
  );

  /// Small text (kit ID `112b6c4`): Inter 400, 11. The kit sets no colour,
  /// so it takes [MfwColours.body]; the website's grey meta text `#ADADAD`
  /// is not a token (OQ-25).
  static const TextStyle small = TextStyle(
    fontFamily: MfwFonts.inter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
    height: 1.5,
    color: MfwColours.body,
  );

  static TextStyle _fraunces(
    double size,
    int weight, {
    required double height,
    double? letterSpacing,
    Color color = MfwColours.heading,
  }) {
    return TextStyle(
      fontFamily: MfwFonts.fraunces,
      fontSize: size,
      fontWeight: FontWeight.values[weight ~/ 100 - 1],
      fontVariations: <FontVariation>[
        FontVariation('wght', weight.toDouble()),
        FontVariation('opsz', size.clamp(9, 144).toDouble()),
      ],
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}

/// Spacing tokens in logical pixels, on a 4-pixel step (PROPOSED: the
/// website records no spacing scale).
abstract final class MfwSpace {
  /// 4.
  static const double xs = 4;

  /// 8.
  static const double sm = 8;

  /// 12.
  static const double md = 12;

  /// 16, also the page margin on a phone.
  static const double lg = 16;

  /// 24.
  static const double xl = 24;

  /// 32.
  static const double xxl = 32;

  /// 48.
  static const double xxxl = 48;
}

/// Shape and size tokens (`BRAND_REFERENCE.md` section 6).
abstract final class MfwShape {
  /// Buttons, fields and cards have square corners.
  static const double radius = 0;

  /// The search field has rounded ends.
  static const double searchRadius = 30;

  /// Border width of buttons and fields.
  static const double stroke = 1;

  /// Smallest touch target (`CODING_STANDARDS.md` section 9, OQ-25).
  static const double minTouchTarget = 48;
}
