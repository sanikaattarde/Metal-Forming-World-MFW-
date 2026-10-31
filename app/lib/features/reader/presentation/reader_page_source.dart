import 'package:flutter/widgets.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Draws the pages of an open document.
///
/// A seam inside this feature, not a contract: PdfRenderer gets its
/// page-rendering methods only after DEC-005, so the adapter for the chosen
/// library implements this interface, and tests use a fake that draws
/// numbered pages.
abstract interface class ReaderPageSource {
  /// Builds page [page] (1-based) of [document], fitted to the space given.
  Widget buildPage(BuildContext context, PdfDocumentHandle document, int page);
}
