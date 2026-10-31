import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/presentation/downloads_text.dart';

/// Download prompt and progress for one issue (SCR-A-13; where it sits on
/// the issue screen is SN-04).
///
/// Shows the size before the download (RS FR-DL-003), asks before using
/// mobile data (FR-DL-004), shows progress (FR-DL-005), says when there is
/// too little space (FR-STATE-004), and offers a retry after a retryable
/// failure (FR-STATE-006).
class DownloadPanel extends StatefulWidget {
  /// Creates the panel for [issueId].
  const DownloadPanel({
    required this.downloads,
    required this.issueId,
    super.key,
  });

  /// MOD-06.
  final DownloadManager downloads;

  /// The issue to download.
  final String issueId;

  @override
  State<DownloadPanel> createState() => _DownloadPanelState();
}

class _DownloadPanelState extends State<DownloadPanel> {
  late final Stream<DownloadStatus> _status = widget.downloads.watch(
    widget.issueId,
  );
  late Future<Result<DownloadPlan>> _plan = widget.downloads.prepare(
    widget.issueId,
  );
  bool _mobileDataAccepted = false;

  Future<void> _download(DownloadPlan plan) async {
    if (plan.onMobileData && !_mobileDataAccepted) {
      final bool? accepted = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(DownloadsText.mobileDataTitle),
          content: Text(DownloadsText.mobileDataBody(plan.sizeBytes)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(DownloadsText.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(DownloadsText.useMobileData),
            ),
          ],
        ),
      );
      if (accepted != true) {
        return;
      }
      _mobileDataAccepted = true;
    }
    final Result<void> result = await widget.downloads.start(
      widget.issueId,
      mobileDataAccepted: _mobileDataAccepted,
    );
    // The connection changed to mobile data after the plan was made: show
    // a fresh plan, so the warning comes before the download.
    if (mounted &&
        result is Err<void> &&
        result.failure.code == FailureCode.invalidInput) {
      setState(() {
        _plan = widget.downloads.prepare(widget.issueId);
      });
    }
  }

  Future<void> _retry() async {
    final Result<DownloadPlan> plan = await widget.downloads.prepare(
      widget.issueId,
    );
    if (plan case Ok<DownloadPlan>(:final DownloadPlan value) when mounted) {
      await _download(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DownloadStatus>(
      stream: _status,
      builder: (BuildContext context, AsyncSnapshot<DownloadStatus> snapshot) =>
          switch (snapshot.data) {
            null => const _Busy(),
            NotDownloaded() => _planView(),
            Queued() => const Text(DownloadsText.queued),
            InProgress(:final int receivedBytes, :final int totalBytes) ||
            WaitingForNetwork(
              :final int receivedBytes,
              :final int totalBytes,
            ) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                LinearProgressIndicator(
                  value: totalBytes == 0 ? null : receivedBytes / totalBytes,
                ),
                const SizedBox(height: 8),
                Text(DownloadsText.progress(receivedBytes, totalBytes)),
              ],
            ),
            Verifying() => const Text(DownloadsText.verifying),
            Downloaded() => const Text(DownloadsText.downloaded),
            Failed(:final AppFailure failure) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(DownloadsText.failure(failure)),
                if (failure.retryable) ...<Widget>[
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => unawaited(_retry()),
                    child: const Text(DownloadsText.retry),
                  ),
                ],
              ],
            ),
          },
    );
  }

  Widget _planView() {
    return FutureBuilder<Result<DownloadPlan>>(
      future: _plan,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<Result<DownloadPlan>> snapshot,
          ) => switch (snapshot.data) {
            null => const _Busy(),
            Err<DownloadPlan>(:final AppFailure failure) => Text(
              DownloadsText.failure(failure),
            ),
            Ok<DownloadPlan>(:final DownloadPlan value) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(DownloadsText.size(value.sizeBytes)),
                const SizedBox(height: 8),
                if (value.enoughSpace)
                  FilledButton(
                    onPressed: () => unawaited(_download(value)),
                    child: const Text(DownloadsText.download),
                  )
                else
                  const Text(DownloadsText.notEnoughSpace),
              ],
            ),
          },
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
