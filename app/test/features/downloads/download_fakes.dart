import 'dart:async';
import 'dart:math';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

/// A synthetic hash for tests: 32-bit FNV-1a in hex. It stands in for the
/// real algorithm, which waits for a package approval.
String fakeHash(List<int> bytes) {
  int hash = 0x811c9dc5;
  for (final int byte in bytes) {
    hash ^= byte & 0xff;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return 'fnv1a32-${hash.toRadixString(16).padLeft(8, '0')}';
}

/// HashVerifier over [fakeHash].
final class FakeHashVerifier implements HashVerifier {
  /// Creates the verifier.
  const FakeHashVerifier();

  @override
  Future<String> hashOf(Stream<List<int>> bytes) async {
    final List<int> all = <int>[];
    await for (final List<int> chunk in bytes) {
      all.addAll(chunk);
    }
    return fakeHash(all);
  }
}

/// In-memory FileStore with a fixed capacity, for FX-NET-06.
final class FakeFileStore implements FileStore {
  /// Creates a store of [capacityBytes].
  FakeFileStore({this.capacityBytes = 1000000});

  /// Total space; free space is this minus what is held.
  int capacityBytes;

  /// Partial files by name.
  final Map<String, List<int>> partials = <String, List<int>>{};

  /// Complete files by path.
  final Map<String, List<int>> files = <String, List<int>>{};

  static const String _folder = '/fake-app-private/downloads';

  /// Bytes held in partial and complete files.
  int get usedBytes => <List<int>>[
    ...partials.values,
    ...files.values,
  ].fold<int>(0, (int sum, List<int> bytes) => sum + bytes.length);

  @override
  Future<int> freeBytes() async => capacityBytes - usedBytes;

  @override
  Future<int> partialLength(String name) async => partials[name]?.length ?? 0;

  @override
  Future<Result<void>> appendPartial(String name, List<int> chunk) async {
    if (usedBytes + chunk.length > capacityBytes) {
      return const Err<void>(AppFailure(FailureCode.insufficientStorage));
    }
    (partials[name] ??= <int>[]).addAll(chunk);
    return const Ok<void>(null);
  }

  @override
  Stream<List<int>> readPartial(String name) =>
      Stream<List<int>>.value(List<int>.of(partials[name] ?? const <int>[]));

  @override
  Future<void> deletePartial(String name) async => partials.remove(name);

  @override
  Future<Result<String>> promotePartial(
    String partialName,
    String fileName,
  ) async {
    final List<int>? bytes = partials.remove(partialName);
    if (bytes == null) {
      return const Err<String>(AppFailure(FailureCode.notFound));
    }
    final String path = '$_folder/$fileName';
    files[path] = bytes;
    return Ok<String>(path);
  }

  @override
  Future<int?> fileLength(String path) async => files[path]?.length;

  @override
  Future<void> deleteFile(String path) async => files.remove(path);
}

/// Fake transport over in-memory files, with the FX-NET-07 fault.
final class FakeFileTransport implements FileTransport {
  /// Creates the transport over [contents], by issue ID.
  FakeFileTransport(
    this.contents, {
    this.chunkBytes = 100,
    this.chunkDelay = Duration.zero,
  });

  /// File bytes by issue ID.
  final Map<String, List<int>> contents;

  /// Bytes per chunk.
  int chunkBytes;

  /// Pause before each chunk, so a test or a preview can see progress.
  Duration chunkDelay;

  /// FX-NET-07: the connection resets once this many bytes have been sent.
  /// Fires once, so a retry succeeds.
  int? resetAfterBytes;

  /// Flips one byte in the middle, so the hash does not match.
  bool corruptOneByte = false;

  /// Ends the transfer this many bytes early, so the size does not match.
  int? stopShortBy;

  /// When set, a fetch waits for it before sending anything.
  Completer<void>? gate;

  /// How many fetches started.
  int fetches = 0;

  @override
  Future<Result<void>> fetch(
    IssueFileGrant grant, {
    required int offset,
    required Future<Result<void>> Function(List<int> chunk) onChunk,
  }) async {
    fetches++;
    await gate?.future;
    final List<int>? source = contents[grant.issueId];
    if (source == null) {
      return const Err<void>(AppFailure(FailureCode.notFound));
    }
    List<int> bytes = List<int>.of(source);
    if (corruptOneByte) {
      bytes[bytes.length ~/ 2] ^= 0xff;
    }
    final int? short = stopShortBy;
    if (short != null) {
      bytes = bytes.sublist(0, bytes.length - short);
    }
    for (int start = offset; start < bytes.length; start += chunkBytes) {
      final int? reset = resetAfterBytes;
      if (reset != null && start >= reset) {
        resetAfterBytes = null;
        return const Err<void>(
          AppFailure(FailureCode.network, retryable: true),
        );
      }
      if (chunkDelay > Duration.zero) {
        await Future<void>.delayed(chunkDelay);
      }
      final Result<void> written = await onChunk(
        bytes.sublist(start, min(start + chunkBytes, bytes.length)),
      );
      if (written is Err<void>) {
        return written;
      }
    }
    return const Ok<void>(null);
  }
}

/// In-memory DownloadRegistry. Survives a new manager, as the real table
/// survives a restart.
final class FakeDownloadRegistry implements DownloadRegistry {
  /// Rows by owner and issue.
  final Map<(String, String), DownloadedIssue> rows =
      <(String, String), DownloadedIssue>{};

  @override
  Future<List<DownloadedIssue>> load() async => rows.values.toList();

  @override
  Future<void> save(DownloadedIssue copy) async =>
      rows[(copy.ownerUserId, copy.issueId)] = copy;

  @override
  Future<void> remove({
    required String ownerUserId,
    required String issueId,
  }) async => rows.remove((ownerUserId, issueId));
}
