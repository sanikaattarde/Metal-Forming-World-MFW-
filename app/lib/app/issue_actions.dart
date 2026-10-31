import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/access_guard.dart';
import 'package:mfw_app/app/routes.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

/// The read or download action in the issue details slot (SCR-A-12,
/// SCR-A-13).
///
/// PROPOSED until the M2 designs; where the panel sits is SN-04.
/// - Without fullAccess, one action starts the missing step and keeps the
///   issue to return to (FR-AUTH-010). The server still enforces access
///   (DEC-009).
/// - With fullAccess, the download panel, and Read once a copy is kept.
///
/// TODO(yg): Read without a kept copy needs the temporary copy (GS-Q43),
/// which waits for OQ-08 and is not in DownloadManager yet.
class IssueActions extends StatefulWidget {
  /// Creates the action for [issueId] in [access].
  const IssueActions({
    required this.issueId,
    required this.access,
    required this.downloads,
    super.key,
  });

  /// The issue shown.
  final String issueId;

  /// The reader's access state.
  final AccessState access;

  /// MOD-06.
  final DownloadManager downloads;

  @override
  State<IssueActions> createState() => _IssueActionsState();
}

class _IssueActionsState extends State<IssueActions> {
  late Stream<DownloadStatus> _status = widget.downloads.watch(widget.issueId);

  @override
  void didUpdateWidget(IssueActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issueId != widget.issueId ||
        oldWidget.downloads != widget.downloads) {
      _status = widget.downloads.watch(widget.issueId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? step = missingStepRoute(widget.access);
    if (step != null) {
      final String target = Uri(
        path: step,
        queryParameters: <String, String>{'from': issueRoute(widget.issueId)},
      ).toString();
      return FilledButton(
        onPressed: () => context.go(target),
        child: const Text(ShellText.readOrDownload),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DownloadPanel(downloads: widget.downloads, issueId: widget.issueId),
        const SizedBox(height: 16),
        StreamBuilder<DownloadStatus>(
          stream: _status,
          builder:
              (BuildContext context, AsyncSnapshot<DownloadStatus> snapshot) =>
                  FilledButton(
                    onPressed: snapshot.data is Downloaded
                        ? () => context.go(readerRoute(widget.issueId))
                        : null,
                    child: const Text(ShellText.read),
                  ),
        ),
      ],
    );
  }
}
