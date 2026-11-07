import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_streams.dart';

/// What happens to a deleted reader's copies. OQ-11 is open, so the fake
/// can do either.
enum DownloadsAfterAccountDeletion {
  /// The copies are deleted.
  removeCopies,

  /// The copies stay, hidden from every other reader.
  keepCopies,
}

/// Fake MOD-06 for one device (IC-03, IC-08).
///
/// Copies are keyed by owner and issue (section 6.6, rule 7). A download
/// completes at once. The mobile-data rule, resume and the copy kind are
/// not modelled: WB-06 builds them.
final class FakeDownloadManager implements DownloadManager {
  /// Creates the manager. Copies of [damagedIssueIds] fail to open with
  /// `fileCorrupt`.
  FakeDownloadManager(
    this._auth,
    this._files, {
    Set<String> damagedIssueIds = const <String>{},
    this.connection = ConnectionType.wifi,
    this.freeBytes = 1000000000,
    this.afterAccountDeletion = DownloadsAfterAccountDeletion.removeCopies,
    DateTime Function()? clock,
  }) : _damaged = damagedIssueIds,
       _clock = clock ?? _fixedClock {
    _auth.addDeletionHook(_onAccountDeleted);
  }

  static DateTime _fixedClock() => DateTime.utc(2026);

  final FakeAuthService _auth;
  final IssueFileService _files;
  final Set<String> _damaged;
  final DateTime Function() _clock;
  final Map<(String, String), DownloadedIssue> _copies =
      <(String, String), DownloadedIssue>{};
  final Set<(String, String)> _partial = <(String, String)>{};
  final Map<(String, String), DownloadStatus> _status =
      <(String, String), DownloadStatus>{};
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  /// The connection type that [prepare] reports.
  ConnectionType connection;

  /// Free space that [prepare] compares with the file size.
  int freeBytes;

  /// What account deletion does to the deleted reader's copies (OQ-11).
  final DownloadsAfterAccountDeletion afterAccountDeletion;

  /// Adds a complete, verified copy owned by [ownerUserId].
  void seedCopy({
    required String ownerUserId,
    required String issueId,
    int fileRevision = 1,
    int sizeBytes = 800000,
    String contentHash = 'fx-hash-seeded',
  }) {
    _copies[(ownerUserId, issueId)] = _copyOf(
      ownerUserId,
      issueId,
      fileRevision,
      sizeBytes,
      contentHash,
    );
    _notify();
  }

  /// Adds a partial file, which is never listed or opened.
  void seedPartial({required String ownerUserId, required String issueId}) {
    _partial.add((ownerUserId, issueId));
    _notify();
  }

  /// Whether a complete copy is held for [ownerUserId], whoever is signed in.
  bool holdsCopy({required String ownerUserId, required String issueId}) =>
      _copies.containsKey((ownerUserId, issueId));

  @override
  Stream<DownloadStatus> watch(String issueId) => watchDerived(
    () => _statusOf(issueId),
    <Stream<void>>[_changes.stream, _auth.changes],
  );

  @override
  Future<Result<DownloadPlan>> prepare(String issueId) async {
    final Result<IssueFileGrant> grant = await _files.requestIssueFile(issueId);
    return switch (grant) {
      Err<IssueFileGrant>(:final AppFailure failure) => Err<DownloadPlan>(
        failure,
      ),
      Ok<IssueFileGrant>(:final IssueFileGrant value) => Ok<DownloadPlan>(
        DownloadPlan(
          sizeBytes: value.sizeBytes,
          onMobileData: connection == ConnectionType.mobile,
          enoughSpace: freeBytes >= value.sizeBytes,
        ),
      ),
    };
  }

  @override
  Future<Result<void>> start(
    String issueId, {
    required bool mobileDataAccepted,
  }) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    final IssueFileGrant grant;
    switch (await _files.requestIssueFile(issueId)) {
      case Err<IssueFileGrant>(:final AppFailure failure):
        _setStatus(userId, issueId, Failed(failure));
        return Err<void>(failure);
      case Ok<IssueFileGrant>(:final IssueFileGrant value):
        grant = value;
    }
    _setStatus(userId, issueId, const Queued());
    _setStatus(userId, issueId, InProgress(0, grant.sizeBytes));
    _setStatus(userId, issueId, InProgress(grant.sizeBytes, grant.sizeBytes));
    _setStatus(userId, issueId, const Verifying());
    _status.remove((userId, issueId));
    _partial.remove((userId, issueId));
    _copies[(userId, issueId)] = _copyOf(
      userId,
      issueId,
      grant.revision,
      grant.sizeBytes,
      grant.contentHash,
    );
    _notify();
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> cancel(String issueId) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _status.remove((userId, issueId));
    _partial.remove((userId, issueId));
    _notify();
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> delete(String issueId) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    if (_copies.remove((userId, issueId)) == null) {
      return const Err<void>(AppFailure(FailureCode.notFound));
    }
    _notify();
    return const Ok<void>(null);
  }

  @override
  Future<List<DownloadedIssue>> listDownloaded() async {
    final String? userId = _auth.currentUserId;
    return _copies.values
        .where((DownloadedIssue copy) => copy.ownerUserId == userId)
        .toList()
      ..sort(
        (DownloadedIssue a, DownloadedIssue b) =>
            a.issueId.compareTo(b.issueId),
      );
  }

  @override
  Future<Result<LocalIssueFile>> openLocal(String issueId) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<LocalIssueFile>(AppFailure(FailureCode.unauthenticated));
    }
    final DownloadedIssue? copy = _copies[(userId, issueId)];
    if (copy == null) {
      return const Err<LocalIssueFile>(AppFailure(FailureCode.notFound));
    }
    if (_damaged.contains(issueId)) {
      return const Err<LocalIssueFile>(
        AppFailure(FailureCode.fileCorrupt, retryable: true),
      );
    }
    return Ok<LocalIssueFile>(copy.localFile);
  }

  DownloadStatus _statusOf(String issueId) {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const NotDownloaded();
    }
    final DownloadedIssue? copy = _copies[(userId, issueId)];
    if (copy != null) {
      return Downloaded(copy);
    }
    return _status[(userId, issueId)] ?? const NotDownloaded();
  }

  DownloadedIssue _copyOf(
    String ownerUserId,
    String issueId,
    int fileRevision,
    int sizeBytes,
    String contentHash,
  ) => DownloadedIssue(
    issueId: issueId,
    ownerUserId: ownerUserId,
    fileRevision: fileRevision,
    localFile: LocalIssueFile(
      issueId: issueId,
      fileRevision: fileRevision,
      path: '/fake-app-private/issues/$issueId.pdf',
    ),
    sizeBytes: sizeBytes,
    downloadedAt: _clock(),
    contentHash: contentHash,
  );

  void _setStatus(String userId, String issueId, DownloadStatus status) {
    _status[(userId, issueId)] = status;
    _notify();
  }

  void _onAccountDeleted(String userId) {
    if (afterAccountDeletion == DownloadsAfterAccountDeletion.keepCopies) {
      return;
    }
    _copies.removeWhere(
      ((String, String) key, DownloadedIssue copy) => key.$1 == userId,
    );
    _partial.removeWhere(((String, String) key) => key.$1 == userId);
    _status.removeWhere(
      ((String, String) key, DownloadStatus status) => key.$1 == userId,
    );
    _notify();
  }

  void _notify() => _changes.add(null);
}
