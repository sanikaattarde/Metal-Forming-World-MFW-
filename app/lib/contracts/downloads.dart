import 'result.dart';

/// Short-lived permission to fetch one issue file (DEC-020, PROPOSED).
final class IssueFileGrant {
  /// Creates a grant.
  const IssueFileGrant({
    required this.issueId,
    required this.access,
    required this.expiresAt,
    required this.sizeBytes,
    required this.contentHash,
    required this.revision,
  });

  /// The issue this grant is for.
  final String issueId;

  /// Opaque; shape set by DEC-020. Never logged.
  final Object access;

  /// When the grant stops working, in UTC.
  final DateTime expiresAt;

  /// File size in whole bytes.
  final int sizeBytes;

  /// For integrity checking after download.
  final String contentHash;

  /// File revision this grant is for; stored with the copy as fileRevision.
  final int revision;
}

/// Requests issue-file grants (OP-FILE-01).
///
/// PROPOSED Dart shape: the operation is in API_AND_MODULE_CONTRACTS
/// section 8, with no Dart interface. The server enforces access (DEC-009).
abstract interface class IssueFileService {
  /// Requests a grant for [issueId]. Fails with `unauthenticated`,
  /// `emailNotVerified`, `profileIncomplete` or `notFound`, and with
  /// `network` or `timeout` (retryable).
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId);
}

/// A complete, verified local issue file, handed only to MOD-07.
///
/// PROPOSED Dart shape: the contract names the type (the return type of
/// DownloadManager.openLocal) without fields. Never passed to the share
/// sheet or to another app (CODING_STANDARDS section 8.2).
final class LocalIssueFile {
  /// Creates a local file reference.
  const LocalIssueFile({
    required this.issueId,
    required this.fileRevision,
    required this.path,
  });

  /// The issue this file holds.
  final String issueId;

  /// The file revision held (section 6.6, rule 8).
  final int fileRevision;

  /// Location in app-private storage. Never logged.
  final String path;
}

/// A complete, verified copy on the device (RS DATA-013).
///
/// There is no state field: a DownloadedIssue exists only for a complete,
/// verified copy (section 6.6, rule 4).
final class DownloadedIssue {
  /// Creates a record of a kept copy.
  const DownloadedIssue({
    required this.issueId,
    required this.ownerUserId,
    required this.fileRevision,
    required this.localFile,
    required this.sizeBytes,
    required this.downloadedAt,
    required this.contentHash,
  });

  /// The issue held.
  final String issueId;

  /// The reader who downloaded it. Never logged.
  final String ownerUserId;

  /// The revision downloaded.
  final int fileRevision;

  /// The local file reference.
  final LocalIssueFile localFile;

  /// File size in whole bytes.
  final int sizeBytes;

  /// When the download completed, in UTC.
  final DateTime downloadedAt;

  /// Hash checked after the transfer.
  final String contentHash;

  // TODO(yg): add retention (kept or temporary) once OQ-08 is answered in
  // writing; it is proposed in GS-Q43.
}

/// Download status of one issue on the device.
sealed class DownloadStatus {
  /// Base constructor for the seven states.
  const DownloadStatus();
}

/// No copy and no download.
final class NotDownloaded extends DownloadStatus {
  /// Creates the state.
  const NotDownloaded();
}

/// Waiting to start.
final class Queued extends DownloadStatus {
  /// Creates the state.
  const Queued();
}

/// Transferring.
final class InProgress extends DownloadStatus {
  /// Creates the state with bytes received so far out of the total.
  const InProgress(this.receivedBytes, this.totalBytes);

  /// Bytes received so far.
  final int receivedBytes;

  /// Total bytes.
  final int totalBytes;
}

/// The network dropped; continues from [receivedBytes] when it returns.
final class WaitingForNetwork extends DownloadStatus {
  /// Creates the state with bytes received so far out of the total.
  const WaitingForNetwork(this.receivedBytes, this.totalBytes);

  /// Bytes received so far.
  final int receivedBytes;

  /// Total bytes.
  final int totalBytes;
}

/// Checking the size and content hash.
final class Verifying extends DownloadStatus {
  /// Creates the state.
  const Verifying();
}

/// A complete, verified copy exists.
final class Downloaded extends DownloadStatus {
  /// Creates the state for [issue].
  const Downloaded(this.issue);

  /// The kept copy.
  final DownloadedIssue issue;
}

/// The download failed.
final class Failed extends DownloadStatus {
  /// Creates the state with [failure].
  const Failed(this.failure);

  /// Why it failed.
  final AppFailure failure;
}

/// What a download will need, shown before it starts.
final class DownloadPlan {
  /// Creates a plan.
  const DownloadPlan({
    required this.sizeBytes,
    required this.onMobileData,
    required this.enoughSpace,
  });

  /// File size in whole bytes (RS FR-DL-003).
  final int sizeBytes;

  /// Whether the device is on mobile data (RS FR-DL-004).
  final bool onMobileData;

  /// Whether there is enough free space (RS FR-STATE-004).
  final bool enoughSpace;
}

/// Issue downloads on the device (MOD-06).
///
/// Failures: `unauthenticated`, `emailNotVerified`, `profileIncomplete`
/// (from the grant); `insufficientStorage`; `network` and `timeout`
/// (retryable); `fileCorrupt`; `notFound` (unpublished); `cancelled`.
abstract interface class DownloadManager {
  /// Emits the status of [issueId].
  Stream<DownloadStatus> watch(String issueId);

  /// Reports size, mobile data and space before a download.
  Future<Result<DownloadPlan>> prepare(String issueId);

  /// Starts a download. A copy kind, kept or temporary, is proposed:
  /// GS-Q43, OQ-08.
  Future<Result<void>> start(
    String issueId, {
    required bool mobileDataAccepted,
  });

  /// Cancels a download.
  Future<Result<void>> cancel(String issueId);

  /// Deletes a kept copy and frees its space.
  Future<Result<void>> delete(String issueId);

  /// Lists the signed-in reader's kept copies.
  Future<List<DownloadedIssue>> listDownloaded();

  /// Opens a complete, verified copy; only for MOD-07. Fails with
  /// `notFound` or `fileCorrupt`.
  Future<Result<LocalIssueFile>> openLocal(String issueId);
}
