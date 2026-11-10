import 'dart:async';

import 'package:flutter/widgets.dart';

import '../features/downloads/downloads.dart';

/// Resumes stopped downloads when the app comes back to the foreground
/// (`API_AND_MODULE_CONTRACTS.md` section 6.6 rule 6; OQ-54 working
/// position: downloads run in the foreground only, and a download that
/// stopped when the reader left resumes from the bytes held). The start of
/// the app and a sign-in are handled where the access state is read.
class DownloadResumer extends StatefulWidget {
  /// Creates the resumer around [child].
  const DownloadResumer({
    required this.downloads,
    required this.child,
    super.key,
  });

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
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
