import 'dart:async';

import 'package:flutter/widgets.dart';

import '../features/downloads/downloads.dart';

/// Resumes stopped downloads when the app comes back to the foreground
/// (`API_AND_MODULE_CONTRACTS.md` section 6.6 rule 6; OQ-54 working
/// position: downloads run in the foreground only, and a download that
/// stopped when the reader left resumes from the bytes held). The start of
/// the app and a sign-in are handled where the access state is read.
///
/// At the start and each return to the foreground it also runs [sweep],
/// which removes the copies of issues deleted for good (MOD06-P3-T02).
class DownloadResumer extends StatefulWidget {
  /// Creates the resumer around [child].
  const DownloadResumer({
    required this.downloads,
    required this.child,
    this.sweep,
    super.key,
  });

  /// Removes the copies of deleted issues, when the app can.
  final Future<Object?> Function()? sweep;

  /// MOD-06, when it can resume.
  final ResumableDownloads? downloads;

  /// The app below.
  final Widget child;

  @override
  State<DownloadResumer> createState() => _DownloadResumerState();
}

class _DownloadResumerState extends State<DownloadResumer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sweep();
  }

  void _sweep() {
    final Future<Object?> Function()? sweep = widget.sweep;
    if (sweep != null) {
      // A sweep that fails is tried again at the next return.
      unawaited(sweep().then<void>((Object? _) {}, onError: (Object _) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.downloads?.resumePending());
      _sweep();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
