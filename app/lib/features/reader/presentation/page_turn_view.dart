import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pages turned like a printed magazine (MOD07-P2-T02, RS FR-READ-006).
///
/// The page lifts from its left edge and swings away, showing the next one
/// beneath; turning back swings the previous page in. A drag follows the
/// finger and a fling or a drag past a third of the width completes the
/// turn. [page] set from outside, by the buttons or the slider, turns one
/// page with the effect and jumps further ones. With the system setting to
/// reduce motion, pages change without the effect.
///
/// [enabled] false stops the drag, for a zoomed page (MOD07-P2-T03).
class PageTurnView extends StatefulWidget {
  /// Creates the view.
  const PageTurnView({
    required this.page,
    required this.pageCount,
    required this.itemBuilder,
    required this.onPageChanged,
    this.enabled = true,
    super.key,
  });

  /// The page shown, 0-based.
  final int page;

  /// How many pages there are.
  final int pageCount;

  /// Builds page [index], 0-based.
  final IndexedWidgetBuilder itemBuilder;

  /// Called with the page shown once a turn is complete.
  final ValueChanged<int> onPageChanged;

  /// Whether a drag turns the page.
  final bool enabled;

  /// How long a turn lasts.
  static const Duration duration = Duration(milliseconds: 350);

  @override
  State<PageTurnView> createState() => _PageTurnViewState();
}

class _PageTurnViewState extends State<PageTurnView>
    with SingleTickerProviderStateMixin {
  late int _index = widget.page;
  int? _target;
  double _dragged = 0;
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: PageTurnView.duration,
  );

  @override
  void didUpdateWidget(PageTurnView old) {
    super.didUpdateWidget(old);
    // A second finger, or a zoom, stops a turn being dragged: it falls back.
    if (!widget.enabled && _target != null && !_turn.isAnimating) {
      _target = null;
      _turn.value = 0;
    }
    final int wanted = widget.page;
    if (wanted == _index || wanted == _target) {
      return;
    }
    // A turn still running ends where it was going; build follows.
    final int? running = _target;
    if (running != null) {
      _index = running;
      _target = null;
      _turn.value = 0;
    }
    if ((wanted - _index).abs() == 1 && !_reduceMotion) {
      _target = wanted;
      unawaited(
        _turn.forward(from: 0).then((_) {
          if (mounted && _target == wanted) {
            _finish(complete: true, report: false);
          }
        }),
      );
    } else {
      _index = wanted;
    }
  }

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  void _finish({required bool complete, required bool report}) {
    final int? target = _target;
    setState(() {
      if (complete && target != null) {
        _index = target;
      }
      _target = null;
      _turn.value = 0;
    });
    if (report && complete && target != null) {
      widget.onPageChanged(target);
    }
  }

  void _dragStart(DragStartDetails details) {
    if (_target != null) {
      _finish(complete: true, report: true);
    }
    _dragged = 0;
  }

  void _dragUpdate(DragUpdateDetails details, double width) {
    _dragged += details.delta.dx;
    if (_target == null) {
      if (_dragged < 0 && _index < widget.pageCount - 1) {
        setState(() => _target = _index + 1);
      } else if (_dragged > 0 && _index > 0) {
        setState(() => _target = _index - 1);
      } else {
        return;
      }
    }
    final bool forward = _target! > _index;
    final double progress = (forward ? -_dragged : _dragged) / width;
    _turn.value = progress.clamp(0, 1);
  }

  Future<void> _dragEnd(DragEndDetails details) async {
    final int? target = _target;
    if (target == null) {
      return;
    }
    final double velocity = details.primaryVelocity ?? 0;
    final bool forward = target > _index;
    final bool flung = forward ? velocity < -300 : velocity > 300;
    final bool complete = flung || _turn.value > 1 / 3;
    if (_reduceMotion) {
      _finish(complete: complete, report: true);
      return;
    }
    if (complete) {
      await _turn.animateTo(1, curve: Curves.easeOut);
    } else {
      await _turn.animateBack(0, curve: Curves.easeOut);
    }
    if (mounted && _target == target) {
      _finish(complete: complete, report: true);
    }
  }

  Widget _turning(Widget page, double lifted) {
    return Transform(
      alignment: Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(-lifted * math.pi / 2),
      child: page,
    );
  }

  Widget _beneath(Widget page, double covered) => Stack(
    fit: StackFit.expand,
    children: <Widget>[
      ExcludeSemantics(child: page),
      IgnorePointer(
        child: ColoredBox(color: Colors.black.withValues(alpha: 0.2 * covered)),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: widget.enabled ? _dragStart : null,
          onHorizontalDragUpdate: widget.enabled
              ? (DragUpdateDetails d) => _dragUpdate(d, width)
              : null,
          onHorizontalDragEnd: widget.enabled
              ? (DragEndDetails d) => unawaited(_dragEnd(d))
              : null,
          child: AnimatedBuilder(
            animation: _turn,
            builder: (BuildContext context, Widget? _) {
              final int? target = _target;
              final double t = _turn.value;
              if (target == null) {
                return KeyedSubtree(
                  key: ValueKey<int>(_index),
                  child: widget.itemBuilder(context, _index),
                );
              }
              final bool forward = target > _index;
              // Forward: this page lifts away over the next. Back: the
              // previous page swings in over this one.
              final int under = forward ? target : _index;
              final int over = forward ? _index : target;
              final double lifted = forward ? t : 1 - t;
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  KeyedSubtree(
                    key: ValueKey<int>(under),
                    child: _beneath(
                      widget.itemBuilder(context, under),
                      1 - lifted,
                    ),
                  ),
                  KeyedSubtree(
                    key: ValueKey<int>(over),
                    child: _turning(widget.itemBuilder(context, over), lifted),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
