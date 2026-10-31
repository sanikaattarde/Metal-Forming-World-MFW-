/// User-facing text of the reader, kept together (CODING_STANDARDS
/// section 9). PLACEHOLDER wording: the M2 designs set the real text, and
/// MOD-02 will own the failure messages.
abstract final class ReaderText {
  /// Screen title.
  static const String title = 'Reader';

  /// Shown while the issue opens.
  static const String loading = 'Opening the issue';

  /// Shown for `fileCorrupt` (RS FR-READ-010).
  static const String damaged = 'This issue could not be opened.';

  /// Shown for `notFound`: no complete copy on the device.
  static const String notOnDevice = 'This issue is not on this device.';

  /// Shown for any other failure.
  static const String failed = 'Something went wrong.';

  /// The retry action.
  static const String retry = 'Retry';

  /// Label of the previous-page button.
  static const String previousPage = 'Previous page';

  /// Label of the next-page button.
  static const String nextPage = 'Next page';

  /// Position, for example "Page 2 of 12".
  static String pageOf(int page, int pageCount) => 'Page $page of $pageCount';
}
