/// The one place where dates and numbers are written for the reader
/// (`CODING_STANDARDS.md` section 9: English only, RS NFR-UX-003).
abstract final class DisplayFormat {
  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// [date] as a calendar date, such as "21 March 2026". The fields are read
  /// as given, so a publication date held at midnight UTC keeps its day.
  static String date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
}
