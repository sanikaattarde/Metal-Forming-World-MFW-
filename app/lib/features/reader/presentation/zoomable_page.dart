import 'package:flutter/material.dart';
import 'package:mfw_app/features/reader/domain/reader_zoom.dart';

/// One reader view that zooms by pinching, from 100% to 300%
/// (RS FR-READ-005, AC-2.3).
class ZoomablePage extends StatefulWidget {
  /// Creates a zoomable view of [child].
  const ZoomablePage({
    required this.child,
    this.transformationController,
    this.onZoomedChanged,
    super.key,
  });

  /// The page or pages to show.
  final Widget child;

  /// Holds the zoom; one is made when not given.
  final TransformationController? transformationController;

  /// Called with true when the view is zoomed in beyond 100%, and with false
  /// when it is back at 100%.
  final ValueChanged<bool>? onZoomedChanged;

  @override
  State<ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<ZoomablePage> {
  TransformationController? _own;
  bool _zoomed = false;

  TransformationController get _controller =>
      widget.transformationController ?? (_own ??= TransformationController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
  }

  @override
  void didUpdateWidget(ZoomablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final TransformationController? previous =
        oldWidget.transformationController ?? _own;
    if (previous != _controller) {
      previous?.removeListener(_onTransform);
      _controller.addListener(_onTransform);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransform);
    _own?.dispose();
    super.dispose();
  }

  void _onTransform() {
    final bool zoomed =
        _controller.value.getMaxScaleOnAxis() > ReaderZoom.min + 0.01;
    if (zoomed != _zoomed) {
      _zoomed = zoomed;
      widget.onZoomedChanged?.call(zoomed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: ReaderZoom.min,
      maxScale: ReaderZoom.max,
      child: widget.child,
    );
  }
}
