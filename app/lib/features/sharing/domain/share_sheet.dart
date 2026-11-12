import 'dart:ui';

/// What the reader did with the share sheet.
enum ShareSheetOutcome {
  /// Chose where to send it.
  shared,

  /// Closed the sheet.
  dismissed,

  /// The platform does not say.
  unknown,
}

/// The device's share sheet (a port; the adapter is `share_plus`, DEP-52).
/// It takes text only, so no file can ever be shared (RS FR-SHR-006).
abstract interface class ShareSheet {
  /// Opens the sheet with [text]. [subject] is used by mail apps. [origin]
  /// is where the sheet points from on a tablet, in global coordinates.
  Future<ShareSheetOutcome> share({
    required String text,
    String? subject,
    Rect? origin,
  });
}

/// The store listings an issue's share points to (CFG-08). Both are null
/// until the app is listed, and then sharing an issue is not offered
/// (OQ-15 working position of 12 November 2026, PROVISIONAL).
final class StoreLinks {
  /// Creates the links.
  const StoreLinks({this.android, this.ios});

  /// Google Play.
  final Uri? android;

  /// The App Store.
  final Uri? ios;

  /// Whether either listing is known.
  bool get any => android != null || ios != null;
}
