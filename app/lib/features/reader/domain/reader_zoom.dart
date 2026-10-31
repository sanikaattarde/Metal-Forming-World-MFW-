/// Zoom limits for a page: 100% to 300% (RS FR-READ-005, AC-2.3).
abstract final class ReaderZoom {
  /// 100%: the page fitted to the view.
  static const double min = 1;

  /// 300%.
  static const double max = 3;

  /// [scale] limited to [min] and [max].
  static double clamp(double scale) =>
      scale < min ? min : (scale > max ? max : scale);
}
