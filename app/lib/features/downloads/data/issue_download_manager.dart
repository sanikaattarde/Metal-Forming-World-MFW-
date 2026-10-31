import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/domain/download_ports.dart';
import 'package:mfw_app/features/downloads/domain/file_names.dart';

// TODO(yg): T-06.3 resumes from the partial file's length (I-5), with
// WaitingForNetwork while the network is down and a new grant after expiry
// (DEC-020); until then every start begins at byte 0.
// TODO(yg): the copy kind, kept or temporary, waits for OQ-08 (GS-Q43).
// TODO(yg): offline rules and sign-out behaviour wait for T-06.5 and OQ-11.

/// [DownloadManager] over the MOD-06 ports (API_AND_MODULE_CONTRACTS
/// section 6.6; PDF_READER_AND_OFFLINE_DESIGN section 4).
///
/// Copies are kept per reader (rule 7): [listDownloaded] and [openLocal]
/// see only the signed-in reader's copies. A copy is listed only after its
/// size and hash match (rule 4, invariant I-1).
final class IssueDownloadManager implements DownloadManager {
  /// Creates the manager. [currentUserId] gives the signed-in reader's ID,
  /// or null when signed out.
  IssueDownloadManager({
    required this._files,
    required this._transport,
    required this._store,
    required this._verifier,
    required this._registry,
    required this._connectivity,
    required this._currentUserId,
    DateTime Function()? clock,
  }) : _clock = clock ?? _utcNow;

  static DateTime _utcNow() => DateTime.now().toUtc();

  final IssueFileService _files;
  final FileTransport _transport;
  final FileStore _store;
  final HashVerifier _verifier;
  final DownloadRegistry _registry;
  final ConnectivityService _connectivity;
  final String? Function() _currentUserId;
  final DateTime Function() _clock;

  final Map<(String, String), DownloadedIssue> _copies =
      <(String, String), DownloadedIssue>{};
  final Map<(String, String), DownloadStatus> _status =
      <(String, String), DownloadStatus>{};
  final Map<(String, String), Future<Result<void>>> _running =
      <(String, String), Future<Result<void>>>{};
  final Set<(String, String)> _cancelRequested = <(String, String)>{};
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  late final Future<void> _ready = _loadRegistry();

  static const Err<void> _unauthenticated = Err<void>(
    AppFailure(FailureCode.unauthenticated),
  );

  @override
  Stream<DownloadStatus> watch(String issueId) {
    StreamSubscription<void>? subscription;
    bool cancelled = false;
    late final StreamController<DownloadStatus> out;
    out = StreamController<DownloadStatus>(
      onListen: () => unawaited(
        _ready.then((_) {
          if (cancelled) {
            return;
          }
          out.add(_statusOf(issueId));
          subscription = _changes.stream.listen(
            (_) => out.add(_statusOf(issueId)),
          );
        }),
      ),
      onCancel: () {
        cancelled = true;
        return subscription?.cancel();
      },
    );
    return out.stream;
  }

  @override
  Future<Result<DownloadPlan>> prepare(String issueId) async {
    switch (await _files.requestIssueFile(issueId)) {
      case Err<IssueFileGrant>(:final AppFailure failure):
        return Err<DownloadPlan>(failure);
      case Ok<IssueFileGrant>(:final IssueFileGrant value):
        final ConnectionType connection = await _connectivity.current();
        // TODO(yg): the margin above the file size is RD-02.
        final int free = await _store.freeBytes();
        return Ok<DownloadPlan>(
          DownloadPlan(
            sizeBytes: value.sizeBytes,
            onMobileData: connection == ConnectionType.mobile,
            enoughSpace: free >= value.sizeBytes,
          ),
        );
    }
  }

  /// Starts a download. On mobile data it fails with `invalidInput` until
  /// [mobileDataAccepted] is true (RS FR-DL-004). A second start while one
  /// runs returns the first one's result (invariant I-4).
  @override
  Future<Result<void>> start(
    String issueId, {
    required bool mobileDataAccepted,
  }) {
    final String? userId = _currentUserId();
    if (userId == null) {
      return Future<Result<void>>.value(_unauthenticated);
    }
    final (String, String) key = (userId, issueId);
    final Future<Result<void>>? running = _running[key];
    if (running != null) {
      return running;
    }
    final Future<Result<void>> download = _download(key, mobileDataAccepted)
        .whenComplete(() {
          _running.remove(key);
          _cancelRequested.remove(key);
        });
    _running[key] = download;
    return download;
  }

  /// Stops a running download and deletes its partial file (RD-01,
  /// PROPOSED). Does nothing when none runs.
  @override
  Future<Result<void>> cancel(String issueId) async {
    final String? userId = _currentUserId();
    if (userId == null) {
      return _unauthenticated;
    }
    final (String, String) key = (userId, issueId);
    final Future<Result<void>>? running = _running[key];
    if (running == null) {
      return const Ok<void>(null);
    }
    _cancelRequested.add(key);
    await running;
    return const Ok<void>(null);
  }

  /// Deletes the reader's copy and frees its space (RS FR-DL-009). The file
  /// goes first, then the row.
  @override
  Future<Result<void>> delete(String issueId) async {
    await _ready;
    final String? userId = _currentUserId();
    if (userId == null) {
      return _unauthenticated;
    }
    final DownloadedIssue? copy = _copies[(userId, issueId)];
    if (copy == null) {
      return const Err<void>(AppFailure(FailureCode.notFound));
    }
    await _store.deleteFile(copy.localFile.path);
    await _forget(copy);
    return const Ok<void>(null);
  }

  @override
  Future<List<DownloadedIssue>> listDownloaded() async {
    await _ready;
    final String? userId = _currentUserId();
    return _copies.values
        .where((DownloadedIssue copy) => copy.ownerUserId == userId)
        .toList()
      ..sort(
        (DownloadedIssue a, DownloadedIssue b) =>
            a.issueId.compareTo(b.issueId),
      );
  }

  /// Hands a complete copy to MOD-07. The length is checked again on open;
  /// a missing file drops the row (`notFound`), and a file of the wrong
  /// length is deleted as damaged (`fileCorrupt`, retryable).
  @override
  Future<Result<LocalIssueFile>> openLocal(String issueId) async {
    await _ready;
    final String? userId = _currentUserId();
    if (userId == null) {
      return const Err<LocalIssueFile>(AppFailure(FailureCode.unauthenticated));
    }
    final DownloadedIssue? copy = _copies[(userId, issueId)];
    if (copy == null) {
      return const Err<LocalIssueFile>(AppFailure(FailureCode.notFound));
    }
    final int? length = await _store.fileLength(copy.localFile.path);
    if (length == null) {
      await _forget(copy);
      return const Err<LocalIssueFile>(AppFailure(FailureCode.notFound));
    }
    if (length != copy.sizeBytes) {
      await _store.deleteFile(copy.localFile.path);
      await _forget(copy);
      return const Err<LocalIssueFile>(
        AppFailure(FailureCode.fileCorrupt, retryable: true),
      );
    }
    return Ok<LocalIssueFile>(copy.localFile);
  }

  Future<void> _loadRegistry() async {
    for (final DownloadedIssue copy in await _registry.load()) {
      _copies[(copy.ownerUserId, copy.issueId)] = copy;
    }
  }

  Future<Result<void>> _download(
    (String, String) key,
    bool mobileDataAccepted,
  ) async {
    await _ready;
    final (String userId, String issueId) = key;
    if (_copies.containsKey(key)) {
      return const Ok<void>(null);
    }
    final ConnectionType connection = await _connectivity.current();
    if (connection == ConnectionType.none) {
      return _fail(key, const AppFailure(FailureCode.network, retryable: true));
    }
    if (connection == ConnectionType.mobile && !mobileDataAccepted) {
      return const Err<void>(
        AppFailure(
          FailureCode.invalidInput,
          detail: 'mobile data not accepted',
        ),
      );
    }
    _setStatus(key, const Queued());
    final IssueFileGrant grant;
    switch (await _files.requestIssueFile(issueId)) {
      case Err<IssueFileGrant>(:final AppFailure failure):
        return _fail(key, failure);
      case Ok<IssueFileGrant>(:final IssueFileGrant value):
        grant = value;
    }
    final String fileName = _freeFileName(issueId, grant.revision);
    final String partial = partialFileName(fileName);
    await _store.deletePartial(partial);
    if (await _store.freeBytes() < grant.sizeBytes) {
      return _fail(key, const AppFailure(FailureCode.insufficientStorage));
    }

    int received = 0;
    _setStatus(key, InProgress(received, grant.sizeBytes));
    final Result<void> transfer = await _transport.fetch(
      grant,
      offset: 0,
      onChunk: (List<int> chunk) async {
        if (_cancelRequested.contains(key)) {
          return const Err<void>(AppFailure(FailureCode.cancelled));
        }
        final Result<void> written = await _store.appendPartial(partial, chunk);
        if (written is Ok<void>) {
          received += chunk.length;
          _setStatus(key, InProgress(received, grant.sizeBytes));
        }
        return written;
      },
    );
    if (transfer case Err<void>(:final AppFailure failure)) {
      await _store.deletePartial(partial);
      if (failure.code == FailureCode.cancelled) {
        _status.remove(key);
        _notify();
        return Err<void>(failure);
      }
      return _fail(key, failure);
    }

    _setStatus(key, const Verifying());
    final bool verified =
        await _store.partialLength(partial) == grant.sizeBytes &&
        await _verifier.hashOf(_store.readPartial(partial)) ==
            grant.contentHash;
    if (!verified) {
      await _store.deletePartial(partial);
      return _fail(
        key,
        const AppFailure(FailureCode.fileCorrupt, retryable: true),
      );
    }
    final String path;
    switch (await _store.promotePartial(partial, fileName)) {
      case Err<String>(:final AppFailure failure):
        return _fail(key, failure);
      case Ok<String>(:final String value):
        path = value;
    }
    final DownloadedIssue copy = DownloadedIssue(
      issueId: issueId,
      ownerUserId: userId,
      fileRevision: grant.revision,
      localFile: LocalIssueFile(
        issueId: issueId,
        fileRevision: grant.revision,
        path: path,
      ),
      sizeBytes: grant.sizeBytes,
      downloadedAt: _clock(),
      contentHash: grant.contentHash,
    );
    await _registry.save(copy);
    _copies[key] = copy;
    _status.remove(key);
    _notify();
    return const Ok<void>(null);
  }

  /// The first file name for [issueId] that no copy on the device uses, so
  /// a second reader's copy does not replace the first (RD-05).
  String _freeFileName(String issueId, int revision) {
    final Set<String> used = <String>{
      for (final DownloadedIssue copy in _copies.values)
        copy.localFile.path.substring(copy.localFile.path.lastIndexOf('/') + 1),
    };
    for (int copy = 1; ; copy++) {
      final String name = issueFileName(issueId, revision, copy: copy);
      if (!used.contains(name)) {
        return name;
      }
    }
  }

  DownloadStatus _statusOf(String issueId) {
    final String? userId = _currentUserId();
    if (userId == null) {
      return const NotDownloaded();
    }
    final DownloadedIssue? copy = _copies[(userId, issueId)];
    if (copy != null) {
      return Downloaded(copy);
    }
    return _status[(userId, issueId)] ?? const NotDownloaded();
  }

  Future<void> _forget(DownloadedIssue copy) async {
    await _registry.remove(
      ownerUserId: copy.ownerUserId,
      issueId: copy.issueId,
    );
    _copies.remove((copy.ownerUserId, copy.issueId));
    _notify();
  }

  Err<void> _fail((String, String) key, AppFailure failure) {
    _setStatus(key, Failed(failure));
    return Err<void>(failure);
  }

  void _setStatus((String, String) key, DownloadStatus status) {
    _status[key] = status;
    _notify();
  }

  void _notify() => _changes.add(null);
}
