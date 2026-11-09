import 'package:mfw_app/contracts/contracts.dart';

/// User-facing text of the downloads feature, kept together
/// (CODING_STANDARDS section 9). PLACEHOLDER wording: the M2 designs set
/// the real text, and MOD-02 will own the failure messages.
abstract final class DownloadsText {
  /// Title of SCR-A-15.
  static const String title = 'Downloads';

  /// The download action.
  static const String download = 'Download';

  /// Shown for a kept copy.
  static const String downloaded = 'Downloaded';

  /// Shown before the transfer starts.
  static const String queued = 'Waiting to start';

  /// Shown while the size and hash are checked.
  static const String verifying = 'Checking the file';

  /// Shown when the device has too little space (RS FR-STATE-004).
  static const String notEnoughSpace =
      'There is not enough free space on this device for this issue.';

  /// Title of the mobile-data warning (RS FR-DL-004).
  static const String mobileDataTitle = 'Use mobile data?';

  /// The action that accepts mobile data.
  static const String useMobileData = 'Download on mobile data';

  /// Declines an action.
  static const String cancel = 'Cancel';

  /// The retry action.
  static const String retry = 'Retry';

  /// Empty Downloads screen (RS FR-STATE-002).
  static const String empty = 'No downloaded issues yet.';

  /// Label of the delete control.
  static const String deleteDownload = 'Delete download';

  /// The connection broke (`network`, `timeout`).
  static const String failedNetwork =
      'The download stopped because the connection was lost.';

  /// The size or hash did not match (`fileCorrupt`).
  static const String failedCorrupt =
      'The downloaded file did not pass its check.';

  /// The device filled up (`insufficientStorage`).
  static const String failedStorage =
      'The download stopped because the device is full.';

  /// Any other failure.
  static const String failedOther = 'The download could not be completed.';

  /// Body of the mobile-data warning.
  static String mobileDataBody(int bytes) =>
      'You are on mobile data. This issue is ${sizeLabel(bytes)}.';

  /// The size shown before a download (RS FR-DL-003).
  static String size(int bytes) => 'Size: ${sizeLabel(bytes)}';

  /// Progress, for example "0.4 MB of 1.0 MB" (RS FR-DL-005).
  static String progress(int received, int total) =>
      '${sizeLabel(received)} of ${sizeLabel(total)}';

  /// A size in decimal units, one decimal place for MB. Display only; the
  /// meaning of "MB" for the upload limit is OQ-30.
  static String sizeLabel(int bytes) => bytes >= 1000000
      ? '${(bytes / 1000000).toStringAsFixed(1)} MB'
      : '${(bytes / 1000).toStringAsFixed(0)} KB';

  /// The message for a failed download.
  static String failure(AppFailure failure) => switch (failure.code) {
    FailureCode.network || FailureCode.timeout => failedNetwork,
    FailureCode.fileCorrupt => failedCorrupt,
    FailureCode.insufficientStorage => failedStorage,
    _ => failedOther,
  };
}
