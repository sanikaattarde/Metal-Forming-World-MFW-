import 'dart:ui' show Size;

/// How many pages the reader shows at once.
enum ReaderLayout {
  /// One page per view.
  singlePage,

  /// Two pages side by side (RS FR-READ-009).
  twoPages,
}

/// Shortest screen side, in logical pixels, from which a device counts as a
/// tablet. ASSUMPTION: 600, the usual Android tablet threshold. The tablet
/// model is OQ-26, and the developers have no tablet.
const double tabletShortestSide = 600;

/// Two pages on tablets and in landscape, one otherwise (RS FR-READ-009).
ReaderLayout layoutFor(Size screen) {
  final bool landscape = screen.width > screen.height;
  final bool tablet = screen.shortestSide >= tabletShortestSide;
  return landscape || tablet ? ReaderLayout.twoPages : ReaderLayout.singlePage;
}

/// The pages of each view, in order, for a document of [pageCount] pages.
///
/// Two-page views use cover-alone pairing (PROPOSED; no document sets it):
/// the cover stands alone, then pages 2 and 3, 4 and 5, and so on, so even
/// pages sit on the left as in a printed magazine.
List<List<int>> spreadsFor(int pageCount, ReaderLayout layout) {
  if (layout == ReaderLayout.singlePage) {
    return <List<int>>[
      for (int page = 1; page <= pageCount; page++) <int>[page],
    ];
  }
  return <List<int>>[
    if (pageCount >= 1) <int>[1],
    for (int page = 2; page <= pageCount; page += 2)
      <int>[page, if (page + 1 <= pageCount) page + 1],
  ];
}

/// The index of the view that shows [page] (1-based) in [layout].
int viewIndexOf(int page, ReaderLayout layout) =>
    layout == ReaderLayout.singlePage ? page - 1 : page ~/ 2;
