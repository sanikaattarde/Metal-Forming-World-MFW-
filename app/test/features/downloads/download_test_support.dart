import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import '../../fakes/fake_auth_service.dart';
import '../../fakes/fake_connectivity_service.dart';
import '../../fakes/fake_issue_file_service.dart';
import '../../fakes/fake_server.dart';
import '../../fakes/test_users.dart';
import 'download_fakes.dart';

/// Synthetic file bytes of [size] (no PDF structure; the reader is not
/// involved).
List<int> syntheticFile(int size) =>
    List<int>.generate(size, (int i) => i % 251);

/// One device with every MOD-06 dependency faked.
final class DownloadRig {
  /// Creates the rig signed in as [user], holding files of [sizes] bytes.
  DownloadRig({
    TestUser? user = fxUsr01,
    Map<String, int> sizes = const <String, int>{
      'fx-iss-01': 1000,
      'fx-iss-02': 1500,
    },
    int capacityBytes = 1000000,
    ConnectionType connection = ConnectionType.wifi,
    Duration chunkDelay = Duration.zero,
  }) : server = FakeServer(),
       store = FakeFileStore(capacityBytes: capacityBytes),
       registry = FakeDownloadRegistry(),
       connectivity = FakeConnectivityService(connection) {
    auth = FakeAuthService(server, signedInAs: user);
    final Map<String, List<int>> contents = <String, List<int>>{
      for (final MapEntry<String, int> entry in sizes.entries)
        entry.key: syntheticFile(entry.value),
    };
    files = FakeIssueFileService(
      auth,
      files: <String, FakeIssueFile>{
        for (final MapEntry<String, List<int>> entry in contents.entries)
          entry.key: FakeIssueFile(
            sizeBytes: entry.value.length,
            contentHash: fakeHash(entry.value),
            revision: 1,
          ),
      },
    );
    transport = FakeFileTransport(contents, chunkDelay: chunkDelay);
    manager = newManager();
  }

  /// Server-side state.
  final FakeServer server;

  /// This device's session.
  late final FakeAuthService auth;

  /// OP-FILE-01.
  late final FakeIssueFileService files;

  /// The bytes in transit.
  late final FakeFileTransport transport;

  /// App-private storage.
  final FakeFileStore store;

  /// The copy registry, which outlives a manager.
  final FakeDownloadRegistry registry;

  /// Connection type.
  final FakeConnectivityService connectivity;

  /// The manager under test.
  late IssueDownloadManager manager;

  /// A manager over the same storage and registry, as after a restart.
  IssueDownloadManager newManager() => IssueDownloadManager(
    files: files,
    transport: transport,
    store: store,
    verifier: const FakeHashVerifier(),
    registry: registry,
    connectivity: connectivity,
    currentUserId: () => auth.currentUserId,
    clock: () => DateTime.utc(2026),
  );
}
