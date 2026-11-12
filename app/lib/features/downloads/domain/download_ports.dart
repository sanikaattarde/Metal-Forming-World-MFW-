import 'package:mfw_app/contracts/contracts.dart';

// Ports of MOD-06, inside this feature and not contracts. PROPOSED shapes.
// The real adapters wait for DEC-020 and their own package approvals;
// tests use in-memory fakes.

/// Moves the bytes of one issue file.
abstract interface class FileTransport {
  /// Fetches the file that [grant] allows, from byte [offset], handing each
  /// chunk to [onChunk] in order. Stops at the first chunk whose [onChunk]
  /// fails and returns that failure. Fails with `network` or `timeout`
  /// (retryable) when the connection breaks.
  Future<Result<void>> fetch(
    IssueFileGrant grant, {
    required int offset,
    required Future<Result<void>> Function(List<int> chunk) onChunk,
  });
}

/// App-private storage for issue files (CODING_STANDARDS section 8.2).
///
/// Partial files are kept apart from complete ones (item 2).
abstract interface class FileStore {
  /// Free space on the device, in bytes.
  Future<int> freeBytes();

  /// Bytes held in the partial file [name]; 0 when there is none.
  Future<int> partialLength(String name);

  /// Appends [chunk] to the partial file [name]. Fails with
  /// `insufficientStorage` when the device is full.
  Future<Result<void>> appendPartial(String name, List<int> chunk);

  /// The bytes of the partial file [name], for the integrity check.
  Stream<List<int>> readPartial(String name);

  /// Deletes the partial file [name], if any.
  Future<void> deletePartial(String name);

  /// The names of every partial file, so one that can no longer be resumed
  /// is removed.
  Future<List<String>> partialFiles();

  /// Moves the partial file [partialName] to its final place as [fileName]
  /// and returns where it is. Called before the registry row is written
  /// (PDF_READER_AND_OFFLINE_DESIGN invariant I-3).
  Future<Result<String>> promotePartial(String partialName, String fileName);

  /// Length of the complete file at [path], or null when it is missing.
  Future<int?> fileLength(String path);

  /// Deletes the complete file at [path], if any.
  Future<void> deleteFile(String path);

  /// The paths of every complete file in the downloads folder, for the
  /// repair at start (`PDF_READER_AND_OFFLINE_DESIGN.md` section 4.4).
  Future<List<String>> completeFiles();
}

/// Computes the content hash that a grant's `contentHash` is compared with.
abstract interface class HashVerifier {
  /// The hash of [bytes], in the form the backend uses.
  Future<String> hashOf(Stream<List<int>> bytes);
}

/// The local registry of complete copies (RS DATA-013; DATABASE_AND_DATA_MODEL
/// section 7.1). Nothing in it is sent to the server.
abstract interface class DownloadRegistry {
  /// Every complete copy on the device, of every reader.
  Future<List<DownloadedIssue>> load();

  /// Records a complete, verified copy.
  Future<void> save(DownloadedIssue copy);

  /// Forgets the copy of [issueId] held for [ownerUserId].
  Future<void> remove({required String ownerUserId, required String issueId});
}

/// A download that was started and has not finished, so it can resume the
/// next time the app is open (`API_AND_MODULE_CONTRACTS.md` section 6.6
/// rule 6; OQ-54 working position). PROPOSED.
final class PendingDownload {
  /// Creates the record.
  const PendingDownload({
    required this.ownerUserId,
    required this.issueId,
    required this.mobileDataAccepted,
  });

  /// The reader who started it.
  final String ownerUserId;

  /// The issue.
  final String issueId;

  /// Whether the reader accepted mobile data for it (RS FR-DL-004).
  final bool mobileDataAccepted;
}

/// Downloads that were started and not finished, kept across a restart.
abstract interface class PendingDownloads {
  /// Every pending download, of every reader.
  Future<List<PendingDownload>> load();

  /// Records [pending], replacing the reader's record for the issue.
  Future<void> save(PendingDownload pending);

  /// Forgets the reader's pending download of [issueId].
  Future<void> remove({required String ownerUserId, required String issueId});
}

/// A download manager that can resume the downloads that stopped before
/// they finished (rule 6).
abstract interface class ResumableDownloads {
  /// Resumes the signed-in reader's stopped downloads.
  Future<void> resumePending();
}

/// [PendingDownloads] held in memory only, for a manager that does not
/// resume across a restart.
final class MemoryPendingDownloads implements PendingDownloads {
  final Map<(String, String), PendingDownload> _rows =
      <(String, String), PendingDownload>{};

  @override
  Future<List<PendingDownload>> load() async => _rows.values.toList();

  @override
  Future<void> save(PendingDownload pending) async =>
      _rows[(pending.ownerUserId, pending.issueId)] = pending;

  @override
  Future<void> remove({
    required String ownerUserId,
    required String issueId,
  }) async => _rows.remove((ownerUserId, issueId));
}

/// What happens to kept copies when their reader or their issue goes
/// (MOD06-P3-T02, RS FR-DL-010, IC-08; OQ-11 working position of
/// 27 October 2026, DEC-033, PROPOSED). Sign-out needs nothing here: copies
/// are kept per reader, so a signed-out device shows none, and the same
/// reader finds them again after signing in (rule 7). Unpublishing needs
/// nothing either: a kept copy still opens.
abstract interface class KeptCopyLifecycle {
  /// Removes every copy, partial file and pending download of [userId], as
  /// after account deletion. Other readers' copies stay.
  Future<void> removeReader(String userId);

  /// Removes every reader's copies of [issueIds], which were permanently
  /// deleted (OP-03), and any download of them under way. Returns how many
  /// copies went.
  Future<int> removeIssues(Set<String> issueIds);
}

/// OP-03 `listDeletedIssues`: the issues deleted for good, a public read
/// (`DATABASE_AND_DATA_MODEL.md` section 12).
abstract interface class DeletedIssueList {
  /// The IDs of the deleted issues. Fails when the list cannot be read, as
  /// offline; nothing is removed then.
  Future<Result<Set<String>>> deletedIssueIds();
}

/// The two copy kinds (MOD06-P3-T01, RS FR-READ-002, FR-DL-001, FR-DL-008;
/// OQ-08 working position of 12 November 2026, chosen by Sanika Attarde,
/// PROVISIONAL, as in the reader frames of GS-Q43): Read opens a temporary
/// copy, and Download keeps one.
///
/// A temporary copy is fetched and checked as a kept one is, but it is not
/// listed in Downloads, is not resumed after a restart, and is removed when
/// the reader closes it, or at the next start if the app stopped first. A
/// kept copy is always opened before a temporary one.
abstract interface class TemporaryCopies {
  /// Fetches a temporary copy of [issueId] for the signed-in reader, as
  /// [DownloadManager.start] fetches a kept one. Does nothing when a kept
  /// copy is on the device.
  Future<Result<void>> startTemporary(
    String issueId, {
    required bool mobileDataAccepted,
  });

  /// Whether the signed-in reader's copy of [issueId] is temporary, or one
  /// is being fetched.
  bool isTemporary(String issueId);

  /// Removes the signed-in reader's temporary copy of [issueId], and stops
  /// one being fetched.
  Future<void> discardTemporary(String issueId);
}
