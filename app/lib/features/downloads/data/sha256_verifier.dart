import 'package:crypto/crypto.dart';
import 'package:mfw_app/features/downloads/domain/download_ports.dart';

// Spike T-02.4: SHA-256 through package:crypto, which the lock file already
// held as a transitive package. Using it directly needs a register entry
// before it can go beyond a spike (CODING_STANDARDS section 12).

/// [HashVerifier] that returns `sha256-<hex>`.
final class Sha256Verifier implements HashVerifier {
  /// Creates the verifier.
  const Sha256Verifier();

  @override
  Future<String> hashOf(Stream<List<int>> bytes) async {
    final Digest digest = await sha256.bind(bytes).first;
    return 'sha256-$digest';
  }
}
