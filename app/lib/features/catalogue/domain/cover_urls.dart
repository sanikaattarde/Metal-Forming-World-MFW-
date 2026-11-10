/// Turns an issue's `cover_path` into the address the app loads it from.
///
/// Covers are public metadata (`DATABASE_AND_DATA_MODEL.md`, ISSUE
/// `cover_path`), readable by anyone under `covers/` in the file store
/// (`backend/storage.rules`), so the address needs no token. Any other path
/// gives no address, so the app never asks for an issue file this way.
final class CoverUrls {
  /// Covers in [bucket] of the cloud file store.
  const CoverUrls({required this.bucket}) : _emulator = null;

  /// Covers in [bucket] of the local file store emulator at [host] and
  /// [port] (ENV-LOCAL, DEC-023). Plain HTTP is used on the developer's
  /// machine only.
  const CoverUrls.emulator({
    required this.bucket,
    required String host,
    int port = 9199,
  }) : _emulator = (host: host, port: port);

  /// The file store bucket.
  final String bucket;

  final ({String host, int port})? _emulator;

  /// The address of the cover at [path], or null when [path] is not a cover.
  Uri? forPath(String? path) {
    if (path == null || !path.startsWith('covers/') || path.contains('..')) {
      return null;
    }
    final String object = Uri.encodeComponent(path);
    final ({String host, int port})? emulator = _emulator;
    final String rest =
        '/v0/b/${Uri.encodeComponent(bucket)}/o/$object?alt=media';
    return emulator == null
        ? Uri.parse('https://firebasestorage.googleapis.com$rest')
        : Uri.parse('http://${emulator.host}:${emulator.port}$rest');
  }
}
