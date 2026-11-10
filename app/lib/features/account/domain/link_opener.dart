/// Opens a web page outside the app, such as MFW's privacy policy (CFG-07).
/// A port, so that the screens are tested without the platform plugin.
abstract interface class LinkOpener {
  /// Opens [uri]. Returns false when no app could open it.
  Future<bool> open(Uri uri);
}
