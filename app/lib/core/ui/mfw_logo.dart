import 'package:flutter/material.dart';

/// MFW's logo, from the file MFW supplied (DEP-02), shown as it is.
///
/// The asset is an RGB copy of the supplied PDF, made for the app with
/// MFW's approval to keep it in the repository (reported by YG on
/// 14 November 2026, not filed; DEC-024 exception, `DECISION_LOG.md`). The
/// logo is never recoloured, stretched or cropped: only [height] is set, and
/// the width follows from the picture.
class MfwLogo extends StatelessWidget {
  /// Creates the logo at [height].
  const MfwLogo({this.height = 32, super.key});

  /// The path of the asset, as listed in `pubspec.yaml`.
  static const String asset = 'assets/brand/mfw_logo.png';

  /// What a screen reader says for the logo.
  static const String label = 'Metal Forming World';

  /// The logo's height; the width keeps its shape.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: label,
    );
  }
}
