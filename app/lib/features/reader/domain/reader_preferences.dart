import 'package:mfw_app/contracts/contracts.dart';

/// The reader's choice of how pages turn, kept on the device (MOD07-P2-T02,
/// RS FR-READ-006 to FR-READ-008; OQ-14 working position of 27 October
/// 2026, GS-Q55: the reader opens in page-turn mode, and settings can
/// switch it to the plain swipe).
abstract interface class ReaderPreferences {
  /// The chosen mode, or [defaultMode] when none is kept.
  Future<ReaderMode> mode();

  /// Keeps [mode] for every issue opened after.
  Future<void> setMode(ReaderMode mode);

  /// The mode before any choice (OQ-14 working position).
  static const ReaderMode defaultMode = ReaderMode.pageTurn;
}
