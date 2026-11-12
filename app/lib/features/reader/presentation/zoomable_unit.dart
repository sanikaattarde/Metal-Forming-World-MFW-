import 'dart:async';

import 'package:flutter/material.dart';

/// Pinch zoom up to 300% on what the reader shows (MOD07-P2-T03, RS
/// FR-READ-005).
///
/// A double tap zooms to 200% where it lands, and a second one goes back,
/// so zoom works with one finger too. While zoomed, a drag moves around
/// the page instead of turning it ([onZoomed]). Once a gesture ends, the
/// pages are drawn again at a [sharpness] that matches the zoom, in steps
/// of a half, so the text stays sharp.
class ZoomableUnit extends StatefulWidget {
  /// Creates the wrapper.
  const ZoomableUnit({
    required this.builder,
    required this.onZoomed,
    super.key,
  });

  /// Builds the pages at [sharpness], 1 for no zoom.
  final Widget Function(BuildContext context, double sharpness) builder;

  /// Called with true when zoomed in, and false when back at 100%.
  final ValueChanged<bool> onZoomed;

  /// The largest zoom.
  static const double maxScale = 3;

  /// The zoom of a double tap.
  static const double doubleTapScale = 2;

  @override
  State<ZoomableUnit> createState() => ZoomableUnitState();
}

/// The state of [ZoomableUnit], public for tests.
class ZoomableUnitState extends State<ZoomableUnit>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  Animation<Matrix4>? _tween;
  Offset? _tapAt;
  double _sharpness = 1;
  bool _zoomed = false;

  /// The current zoom, 1 for none.
  double get scale => _transform.value.getMaxScaleOnAxis();

  /// The sharpness the pages are drawn at.
  double get sharpness => _sharpness;

  @override
  void initState() {
    super.initState();
    _animation.addListener(() {
      final Animation<Matrix4>? tween = _tween;
      if (tween != null) {
        _transform.value = tween.value;
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _settled() {
    final double now = scale;
    final bool zoomed = now > 1.01;
    if (zoomed != _zoomed) {
      _zoomed = zoomed;
      widget.onZoomed(zoomed);
    }
    // Steps of a half, so a small change does not draw the page again.
    final double sharpness = zoomed
        ? ((now * 2).ceil() / 2).clamp(1, ZoomableUnit.maxScale).toDouble()
        : 1;
    if (sharpness != _sharpness) {
      setState(() => _sharpness = sharpness);
    }
  }

  void _doubleTap() {
    final Offset at = _tapAt ?? Offset.zero;
    final Matrix4 target = scale > 1.01
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -at.dx * (ZoomableUnit.doubleTapScale - 1),
              -at.dy * (ZoomableUnit.doubleTapScale - 1),
              0,
              1,
            )
            ..scaleByDouble(
              ZoomableUnit.doubleTapScale,
              ZoomableUnit.doubleTapScale,
              1,
              1,
            ));
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _transform.value = target;
      _settled();
      return;
    }
    _tween = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOut));
    unawaited(
      _animation.forward(from: 0).then((_) {
        if (mounted) {
          _settled();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (TapDownDetails details) =>
          _tapAt = details.localPosition,
      onDoubleTap: _doubleTap,
      child: InteractiveViewer(
        transformationController: _transform,
        maxScale: ZoomableUnit.maxScale,
        // At 100% a one-finger drag turns the page; zoomed, it pans.
        panEnabled: _zoomed,
        onInteractionEnd: (ScaleEndDetails _) => _settled(),
        child: widget.builder(context, _sharpness),
      ),
    );
  }
}
