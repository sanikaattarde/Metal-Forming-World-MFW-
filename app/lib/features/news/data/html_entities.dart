/// Decodes the HTML character references WordPress writes in titles and
/// category names (`CODING_STANDARDS.md` section 7, rule 8).
///
/// Numeric references (`&#8217;`, `&#x20B9;`) are all decoded. Of the named
/// ones, only those WordPress produces in plain text are; any other is left
/// as it is, so no text is lost.
String decodeHtmlEntities(String text) {
  if (!text.contains('&')) {
    return text;
  }
  return text.replaceAllMapped(_reference, (Match match) {
    final String body = match.group(1)!;
    if (body.startsWith('#')) {
      final bool hex = body.length > 1 && (body[1] == 'x' || body[1] == 'X');
      final int? code = int.tryParse(
        hex ? body.substring(2) : body.substring(1),
        radix: hex ? 16 : 10,
      );
      if (code == null || code < 1 || code > 0x10FFFF || _isSurrogate(code)) {
        return match.group(0)!;
      }
      return String.fromCharCode(code);
    }
    return _named[body] ?? match.group(0)!;
  });
}

final RegExp _reference = RegExp(
  '&(#[0-9]{1,7}|#[xX][0-9a-fA-F]{1,6}|[a-zA-Z]{2,8});',
);

bool _isSurrogate(int code) => code >= 0xD800 && code <= 0xDFFF;

const Map<String, String> _named = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': '\u00A0',
  'ndash': '\u2013',
  'mdash': '\u2014',
  'lsquo': '\u2018',
  'rsquo': '\u2019',
  'ldquo': '\u201C',
  'rdquo': '\u201D',
  'hellip': '\u2026',
  'rsaquo': '\u203A',
  'lsaquo': '\u2039',
  'raquo': '\u00BB',
  'laquo': '\u00AB',
  'copy': '\u00A9',
  'reg': '\u00AE',
  'trade': '\u2122',
  'deg': '\u00B0',
  'times': '\u00D7',
  'euro': '\u20AC',
  'pound': '\u00A3',
};
