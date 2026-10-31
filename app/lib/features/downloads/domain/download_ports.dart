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

  /// Moves the partial file [partialName] to its final place as [fileName]
  /// and returns where it is. Called before the registry row is written
  /// (PDF_READER_AND_OFFLINE_DESIGN invariant I-3).
  Future<Result<String>> promotePartial(String partialName, String fileName);

  /// Length of the complete file at [path], or null when it is missing.
  Future<int?> fileLength(String path);

  /// Deletes the complete file at [path], if any.
  Future<void> deleteFile(String path);
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
