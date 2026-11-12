import 'package:flutter/material.dart';

/// The plain swipe mode (MOD07-P2-T02, RS FR-READ-007): pages slide across.
/// [page] set from outside jumps there; a swipe reports the page shown.
/// [enabled] false stops the swipe, for a zoomed page (MOD07-P2-T03).
class SwipePages extends StatefulWidget {
  /// Creates the view.
  const SwipePages({
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

  /// Called with the page shown after a swipe or a jump.
  final ValueChanged<int> onPageChanged;

  /// Whether a swipe turns the page.
  final bool enabled;

  @override
  State<SwipePages> createState() => _SwipePagesState();
}

class _SwipePagesState extends State<SwipePages> {
  late final PageController _controller = PageController(
    initialPage: widget.page,
  );

  @override
  void didUpdateWidget(SwipePages old) {
    super.didUpdateWidget(old);
    if (_controller.hasClients &&
        (_controller.page ?? widget.page.toDouble()).round() != widget.page) {
      _controller.jumpToPage(widget.page);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      physics: widget.enabled ? null : const NeverScrollableScrollPhysics(),
      itemCount: widget.pageCount,
      onPageChanged: widget.onPageChanged,
      itemBuilder: widget.itemBuilder,
    );
  }
}
