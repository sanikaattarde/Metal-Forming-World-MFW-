import 'package:flutter/widgets.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// An open document the reader can show (MOD-07).
///
/// `PdfDocumentHandle` leaves page rendering to DEC-005; this feature adds
/// it here, so the library behind it (pdfrx, YG's position of 10 November
/// 2026, PROPOSED) stays inside `features/reader/data/` and can change
/// without touching other modules (MOD07-P2-T01).
abstract interface class ReaderDocument implements PdfDocumentHandle {
  /// Page [pageNumber] (1-based), drawn to fit the space it is given and
  /// placed by [alignment]. [sharpness] above 1 draws it at that many times
  /// the screen's resolution, for a zoomed page (MOD07-P2-T03), within a
  /// memory budget.
  Widget page(
    int pageNumber, {
    double sharpness = 1,
    Alignment alignment = Alignment.center,
  });

  /// Whether page [pageNumber] is wider than it is tall, for the two-page
  /// spread (MOD07-P2-T03).
  bool isLandscape(int pageNumber);
}
