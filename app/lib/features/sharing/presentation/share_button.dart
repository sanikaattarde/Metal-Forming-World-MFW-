import 'dart:async';

import 'package:flutter/material.dart';

import '../../../contracts/result.dart';

/// The Share action on issue details and an article (MOD10-P1-T01). It
/// passes where it sits on screen, so the sheet points at it on a tablet.
/// Closing the sheet is not a failure; any other failure is reported.
class ShareButton extends StatelessWidget {
  /// Creates the button.
  const ShareButton({required this.onShare, super.key});

  /// Opens the share sheet from [origin], in global coordinates.
  final Future<Result<void>> Function(Rect? origin) onShare;

  /// What a screen reader and the tooltip say.
  static const String label = 'Share';

  /// When the sheet could not open.
  static const String failed = 'Sharing is not available. Try again.';

  Future<void> _share(BuildContext context) async {
    final RenderObject? box = context.findRenderObject();
    final Rect? origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    final Result<void> result = await onShare(origin);
    if (!context.mounted) {
      return;
    }
    if (result case Err<void>(:final AppFailure failure)
        when failure.code != FailureCode.cancelled) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) => IconButton(
        tooltip: label,
        icon: const Icon(Icons.share_outlined),
        onPressed: () => unawaited(_share(context)),
      ),
    );
  }
}
