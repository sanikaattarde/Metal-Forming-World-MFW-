import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../domain/reader_preferences.dart';

/// The settings entry for turning pages, in SCR-A-07's reader-mode slot
/// (MOD07-P2-T02, RS FR-READ-008, OQ-14 working position). It shows the
/// mode in use and opens a choice of the two; the choice applies to every
/// issue opened after it.
class ReaderModeTile extends StatefulWidget {
  /// Creates the entry.
  const ReaderModeTile({required this.preferences, super.key});

  /// Where the choice is kept.
  final ReaderPreferences preferences;

  @override
  State<ReaderModeTile> createState() => _ReaderModeTileState();
}

class _ReaderModeTileState extends State<ReaderModeTile> {
  ReaderMode? _mode;

  @override
  void initState() {
    super.initState();
    unawaited(_read());
  }

  Future<void> _read() async {
    final ReaderMode mode = await widget.preferences.mode().catchError(
      (Object _) => ReaderPreferences.defaultMode,
    );
    if (mounted) {
      setState(() => _mode = mode);
    }
  }

  Future<void> _choose() async {
    final ReaderMode? chosen = await showModalBottomSheet<ReaderMode>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MfwSpace.lg,
                0,
                MfwSpace.lg,
                MfwSpace.sm,
              ),
              child: Text(ReaderModeText.title, style: MfwType.h3),
            ),
            for (final ReaderMode mode in ReaderMode.values)
              ListTile(
                title: Text(ReaderModeText.name(mode)),
                subtitle: Text(ReaderModeText.line(mode)),
                selected: mode == _mode,
                trailing: mode == _mode ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || chosen == _mode || !mounted) {
      return;
    }
    final ReaderMode? before = _mode;
    setState(() => _mode = chosen);
    try {
      await widget.preferences.setMode(chosen);
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _mode = before);
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text(ReaderModeText.failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReaderMode? mode = _mode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.auto_stories_outlined,
        color: MfwColours.heading,
      ),
      title: const Text(ReaderModeText.title),
      subtitle: Text(mode == null ? '' : ReaderModeText.name(mode)),
      trailing: const Icon(Icons.chevron_right, color: MfwColours.body),
      onTap: mode == null ? null : () => unawaited(_choose()),
    );
  }
}

/// User-facing text of the page-turning setting. PLACEHOLDER wording until
/// M2.
abstract final class ReaderModeText {
  /// The entry's title.
  static const String title = 'Turning pages';

  /// When the choice could not be kept.
  static const String failed = 'The choice could not be saved. Try again.';

  /// The name of [mode].
  static String name(ReaderMode mode) => switch (mode) {
    ReaderMode.pageTurn => 'Page turn',
    ReaderMode.swipe => 'Swipe',
  };

  /// One line on [mode].
  static String line(ReaderMode mode) => switch (mode) {
    ReaderMode.pageTurn => 'Pages turn like a printed magazine.',
    ReaderMode.swipe => 'Pages slide across, with no effect.',
  };
}
