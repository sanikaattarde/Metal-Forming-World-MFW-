/// Plain-text handling of WordPress HTML (CODING_STANDARDS section 7).
///
/// No HTML package is approved, so post content is shown as plain text:
/// formatting, inline images and links are not shown. The renderer that
/// keeps them, without running scripts, is chosen under
/// DEPENDENCY_REGISTER.md.
library;

const Map<String, String> _namedEntities = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'hellip': '…',
  'ndash': '–',
  'mdash': '—',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
};

final RegExp _entity = RegExp(
  r'&(#[0-9]+|#[xX][0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);',
);

final RegExp _tag = RegExp('<[^>]*>');

final RegExp _comment = RegExp(r'<!--.*?(-->|$)', dotAll: true);

/// Elements removed with everything inside them. An unclosed one removes
/// the rest of the text.
final RegExp _removedElement = RegExp(
  r'<(script|style|iframe|template|object)\b[^>]*>.*?(</\1\s*>|$)',
  caseSensitive: false,
  dotAll: true,
);

final RegExp _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);

final RegExp _blockBoundary = RegExp(
  r'</?(p|div|h[1-6]|li|ul|ol|blockquote|figure|figcaption|section|article|'
  r'header|footer|table|tr|pre)\b[^>]*>',
  caseSensitive: false,
);

final RegExp _spaces = RegExp('[ \t\r\f\v]+');

final RegExp _blankLines = RegExp(r'\n{3,}');

/// Decodes character references (`&#8217;`, `&#x20B9;`) and the named
/// entities WordPress titles use, in one pass. An unknown name is left as
/// it is; a reference outside Unicode becomes U+FFFD.
String decodeEntities(String text) =>
    text.replaceAllMapped(_entity, (Match match) {
      final String name = match[1]!;
      if (!name.startsWith('#')) {
        return _namedEntities[name] ?? match[0]!;
      }
      final bool hex = name.length > 1 && (name[1] == 'x' || name[1] == 'X');
      final int? code = int.tryParse(
        name.substring(hex ? 2 : 1),
        radix: hex ? 16 : 10,
      );
      return code != null &&
              code > 0 &&
              code <= 0x10FFFF &&
              (code < 0xD800 || code > 0xDFFF)
          ? String.fromCharCode(code)
          : '�';
    });

/// Removes tags and keeps their text.
String stripTags(String html) => html.replaceAll(_tag, '');

/// Post content as plain text (SEC-CHK-15): script, style, iframe,
/// template and object elements are removed with their content, every
/// other tag is removed, entities are decoded after the tags are gone (so
/// escaped markup stays text), and spaces collapse. Paragraphs are
/// separated by a blank line.
String htmlToPlainText(String html) {
  final String text = decodeEntities(
    stripTags(
      html
          .replaceAll(_comment, '')
          .replaceAll(_removedElement, '')
          .replaceAll(_lineBreak, '\n')
          .replaceAll(_blockBoundary, '\n\n'),
    ),
  ).replaceAll(' ', ' ');
  return text
      .split('\n')
      .map((String line) => line.replaceAll(_spaces, ' ').trim())
      .join('\n')
      .replaceAll(_blankLines, '\n\n')
      .trim();
}
