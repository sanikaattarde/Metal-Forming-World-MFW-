import 'dart:async';

import 'package:flutter/material.dart';

import '../app/theme/mfw_tokens.dart';
import '../contracts/contracts.dart';
import '../core/errors/failure_messages.dart';
import '../core/ui/content_widgets.dart';
import '../features/downloads/downloads.dart';
import '../features/reader/reader.dart';

/// The reader route (`/issues/:id/read`): MOD-06 hands MOD-07 the reader's
/// complete, verified copy through `openLocal`, and the reader opens it
/// with no network (RS FR-DL-007, IC-03, MOD06-P3-T03).
///
/// With no copy on the device, the route offers the download in place and
/// opens the reader when it completes. On the working position of DEC-033
/// Read opens a temporary copy instead; that waits for MFW's written answer
/// to OQ-08 (MOD06-P3-T01), so until then Read means download, then read.
/// A copy that turns out damaged is deleted, and the download is offered
/// again (FR-READ-010).
class ReaderRoute extends StatefulWidget {
  /// Creates the route for [issueId].
  const ReaderRoute({
    required this.issueId,
    required this.downloads,
    required this.renderer,
    required this.titleOf,
    this.initialPage,
    this.onClose,
    this.actions,
    super.key,
  });

  /// The issue.
  final String issueId;

  /// MOD-06.
  final DownloadManager downloads;

  /// MOD-07.
  final PdfRenderer renderer;

  /// The issue's title, known offline when it was downloaded.
  final Future<String> Function(String issueId) titleOf;

  /// The page to open at, 1-based.
  final int? initialPage;

  /// Closes the reader.
  final VoidCallback? onClose;

  /// The reader's bar actions, such as the bookmark (MOD08-P2-T01).
  final List<Widget> Function(
    String issueId,
    LocalIssueFile file,
    ReaderController reader,
  )?
  actions;

  @override
  State<ReaderRoute> createState() => _ReaderRouteState();
}

class _ReaderRouteState extends State<ReaderRoute> {
  Result<LocalIssueFile>? _local;
  String _title = '';
  StreamSubscription<DownloadStatus>? _watching;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_watching?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    final (Result<LocalIssueFile> local, String title) = await (
      widget.downloads.openLocal(widget.issueId),
      widget.titleOf(widget.issueId).catchError((Object _) => ''),
    ).wait;
    if (!mounted) {
      return;
    }
    setState(() {
      _local = local;
      _title = title;
    });
    if (local is Err<LocalIssueFile>) {
      _waitForCopy();
    }
  }

  /// Opens the reader as soon as a download of the issue completes.
  void _waitForCopy() {
    unawaited(_watching?.cancel());
    _watching = widget.downloads.watch(widget.issueId).listen((
      DownloadStatus status,
    ) {
      if (status is Downloaded) {
        unawaited(_watching?.cancel());
        _watching = null;
        unawaited(_load());
      }
    });
  }

  Future<void> _downloadAgain() async {
    await widget.downloads.delete(widget.issueId);
    if (!mounted) {
      return;
    }
    setState(() {
      _local = const Err<LocalIssueFile>(
        AppFailure(FailureCode.fileCorrupt, retryable: true),
      );
    });
    _waitForCopy();
  }

  @override
  Widget build(BuildContext context) {
    final Result<LocalIssueFile>? local = _local;
    return switch (local) {
      null => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: const Center(child: CircularProgressIndicator()),
      ),
      Ok<LocalIssueFile>(:final LocalIssueFile value) => ReaderScreen(
        key: ValueKey<String>(value.path),
        file: value,
        title: _title,
        renderer: widget.renderer,
        initialPage: widget.initialPage,
        onClose: widget.onClose,
        onDownloadAgain: () => unawaited(_downloadAgain()),
        actions: widget.actions == null
            ? null
            : (ReaderController reader) =>
                  widget.actions!(widget.issueId, value, reader),
      ),
      Err<LocalIssueFile>(:final AppFailure failure) => _NeedsDownload(
        issueId: widget.issueId,
        title: _title,
        failure: failure,
        downloads: widget.downloads,
        onClose: widget.onClose,
      ),
    };
  }
}

class _NeedsDownload extends StatelessWidget {
  const _NeedsDownload({
    required this.issueId,
    required this.title,
    required this.failure,
    required this.downloads,
    this.onClose,
  });

  final String issueId;
  final String title;
  final AppFailure failure;
  final DownloadManager downloads;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bool damaged = failure.code == FailureCode.fileCorrupt;
    final bool missing = damaged || failure.code == FailureCode.notFound;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: onClose == null
            ? null
            : IconButton(
                tooltip: ReaderText.close,
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          if (damaged)
            const ContentNotice(ReaderRouteText.damaged)
          else if (!missing)
            ContentNotice(messageFor(failure)),
          if (missing) ...<Widget>[
            const EmptyState(
              icon: Icons.download_outlined,
              heading: ReaderRouteText.downloadFirstHeading,
              text: ReaderRouteText.downloadFirstText,
            ),
            DownloadPanel(downloads: downloads, issueId: issueId),
          ],
        ],
      ),
    );
  }
}

/// User-facing text of the reader route. PLACEHOLDER wording until M2.
abstract final class ReaderRouteText {
  /// Heading when the issue is not on the device.
  static const String downloadFirstHeading = 'Download this issue to read it';

  /// Line when the issue is not on the device.
  static const String downloadFirstText =
      'Once it is on this device, it opens here and reads with no '
      'connection.';

  /// Notice when the copy was damaged and removed.
  static const String damaged =
      'The copy on this device was damaged and has been removed.';
}
