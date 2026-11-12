/// What the reader shows at once (MOD07-P2-T03, RS FR-READ-009): one page,
/// or two side by side when [spread] is true.
///
/// In a spread the cover stands alone, as in a printed magazine, and the
/// pages after it go in twos: 2 and 3, 4 and 5. A page wider than it is
/// tall, which is already a spread on its own, stands alone, and so does a
/// last page left over. Pages are 1-based.
List<List<int>> readerUnits({
  required int pageCount,
  required bool spread,
  bool Function(int page)? isLandscape,
}) {
  if (!spread) {
    return <List<int>>[
      for (int page = 1; page <= pageCount; page++) <int>[page],
    ];
  }
  final bool Function(int) wide = isLandscape ?? (int _) => false;
  final List<List<int>> units = <List<int>>[];
  int page = 1;
  while (page <= pageCount) {
    if (page == 1 || wide(page)) {
      units.add(<int>[page]);
      page += 1;
    } else if (page + 1 <= pageCount && !wide(page + 1)) {
      units.add(<int>[page, page + 1]);
      page += 2;
    } else {
      units.add(<int>[page]);
      page += 1;
    }
  }
  return units;
}

/// The index in [units] of the one holding [page].
int unitOf(List<List<int>> units, int page) {
  for (int i = 0; i < units.length; i++) {
    if (units[i].contains(page)) {
      return i;
    }
  }
  return 0;
}
