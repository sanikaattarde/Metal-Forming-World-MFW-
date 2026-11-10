import 'dart:convert';

/// Synthetic PDFs for the reader (TEST_DATA_AND_FIXTURES section 7), made
/// in code so nothing of MFW's is used (DEC-024). Each page says "Page n" in
/// Helvetica, so a test can tell the pages apart.

/// A portrait page, A4 in points.
const (double, double) portrait = (595, 842);

/// A landscape page, A4 in points.
const (double, double) landscape = (842, 595);

/// A valid PDF with one page per entry of [pages] (width, height).
List<int> syntheticPdf(
  List<(double, double)> pages, {
  String title = 'Synthetic issue',
}) {
  final List<String> objects = <String>[];
  final int pageCount = pages.length;
  // 1 catalog, 2 page tree, 3 font, then a page and its content per page.
  final List<String> kids = <String>[
    for (int i = 0; i < pageCount; i++) '${4 + i * 2} 0 R',
  ];
  objects
    ..add('<< /Type /Catalog /Pages 2 0 R >>')
    ..add('<< /Type /Pages /Kids [${kids.join(' ')}] /Count $pageCount >>')
    ..add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');
  for (int i = 0; i < pageCount; i++) {
    final (double width, double height) = pages[i];
    final String text =
        'BT /F1 28 Tf 72 ${(height - 120).toStringAsFixed(0)} Td '
        '(Page ${i + 1}) Tj ET\n'
        'BT /F1 12 Tf 72 ${(height - 150).toStringAsFixed(0)} Td '
        '(${_escape(title)}) Tj ET\n';
    objects
      ..add(
        '<< /Type /Page /Parent 2 0 R '
        '/MediaBox [0 0 ${width.toStringAsFixed(0)} '
        '${height.toStringAsFixed(0)}] '
        '/Resources << /Font << /F1 3 0 R >> >> '
        '/Contents ${5 + i * 2} 0 R >>',
      )
      ..add('<< /Length ${text.length} >>\nstream\n${text}endstream');
  }

  final StringBuffer out = StringBuffer('%PDF-1.4\n');
  final List<int> offsets = <int>[];
  for (int i = 0; i < objects.length; i++) {
    offsets.add(out.length);
    out.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
  }
  final int xref = out.length;
  out
    ..write('xref\n0 ${objects.length + 1}\n')
    ..write('0000000000 65535 f \n');
  for (final int offset in offsets) {
    out.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  out.write(
    'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
    'startxref\n$xref\n%%EOF\n',
  );
  return ascii.encode(out.toString());
}

/// FX-PDF-01: about four portrait pages with text.
List<int> fxPdf01() => syntheticPdf(<(double, double)>[
  portrait,
  portrait,
  portrait,
  portrait,
], title: 'FX-PDF-01');

/// FX-PDF-02: portrait and landscape pages mixed.
List<int> fxPdf02() => syntheticPdf(<(double, double)>[
  portrait,
  landscape,
  portrait,
  landscape,
  portrait,
], title: 'FX-PDF-02');

/// FX-PDF-10: a truncated PDF, the first half of FX-PDF-01 only.
List<int> fxPdf10() {
  final List<int> whole = fxPdf01();
  return whole.sublist(0, whole.length ~/ 2);
}

String _escape(String text) =>
    text.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
