import 'package:crypto/crypto.dart';

import '../domain/download_ports.dart';

/// The [HashVerifier] for the backend's `checksum_sha256`: SHA-256 in lower
/// case hexadecimal (`backend/functions/src/uploadFinalized.ts`), read as a
/// stream so a near-limit file is never held in memory.
final class Sha256HashVerifier implements HashVerifier {
  /// Creates the verifier.
  const Sha256HashVerifier();

  @override
  Future<String> hashOf(Stream<List<int>> bytes) async =>
      (await sha256.bind(bytes).first).toString();
}
