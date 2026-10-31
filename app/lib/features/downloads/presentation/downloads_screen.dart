import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/presentation/downloads_text.dart';

/// The Downloads screen (SCR-A-15): the signed-in reader's kept copies, each
/// with its size and a delete action (RS FR-DL-008, FR-DL-009). Partial
/// downloads are never listed (FR-STATE-004).
class DownloadsScreen extends StatefulWidget {
  /// Creates the screen. [titleOf] gives an issue's title; MOD-05 provides
  /// it, and the issue ID is shown until then.
  const DownloadsScreen({required this.downloads, this.titleOf, super.key});

  /// MOD-06.
  final DownloadManager downloads;

  /// Title lookup for an issue ID.
  final String Function(String issueId)? titleOf;

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<DownloadedIssue>> _copies = widget.downloads
      .listDownloaded();

  Future<void> _delete(String issueId) async {
    await widget.downloads.delete(issueId);
    if (!mounted) {
      return;
    }
    setState(() {
      _copies = widget.downloads.listDownloaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(DownloadsText.title)),
      body: FutureBuilder<List<DownloadedIssue>>(
        future: _copies,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<DownloadedIssue>> snapshot,
            ) {
              final List<DownloadedIssue>? copies = snapshot.data;
              if (copies == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (copies.isEmpty) {
                return const Center(child: Text(DownloadsText.empty));
              }
              return ListView(
                children: <Widget>[
                  for (final DownloadedIssue copy in copies)
                    ListTile(
                      key: ValueKey<String>(copy.issueId),
                      title: Text(
                        widget.titleOf?.call(copy.issueId) ?? copy.issueId,
                      ),
                      subtitle: Text(DownloadsText.sizeLabel(copy.sizeBytes)),
                      trailing: IconButton(
                        tooltip: DownloadsText.deleteDownload,
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(48),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => unawaited(_delete(copy.issueId)),
                      ),
                    ),
                ],
              );
            },
      ),
    );
  }
}
