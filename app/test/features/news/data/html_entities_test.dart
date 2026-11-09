import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/news/data/html_entities.dart';

void main() {
  group('decodeHtmlEntities [CODING_STANDARDS 7]', () {
    test('decodes decimal and hexadecimal references', () {
      expect(decodeHtmlEntities('Metal&#8217;s'), 'Metal’s');
      expect(decodeHtmlEntities('&#x20B9; 100'), '₹ 100');
      expect(decodeHtmlEntities('&#X20b9;'), '₹');
      expect(decodeHtmlEntities('&#128295;'), '\u{1F527}');
    });

    test('decodes the named references WordPress writes', () {
      expect(decodeHtmlEntities('A &amp; B'), 'A & B');
      expect(decodeHtmlEntities('&lt;b&gt;'), '<b>');
      expect(decodeHtmlEntities('&quot;x&quot; &hellip;'), '"x" …');
      expect(decodeHtmlEntities('Read More &raquo;'), 'Read More »');
    });

    test('leaves unknown, invalid and bare ampersands as they are', () {
      expect(decodeHtmlEntities('&unknown;'), '&unknown;');
      expect(decodeHtmlEntities('&#xD800;'), '&#xD800;');
      expect(decodeHtmlEntities('&#0;'), '&#0;');
      expect(decodeHtmlEntities('&#99999999;'), '&#99999999;');
      expect(decodeHtmlEntities('Fish & chips'), 'Fish & chips');
    });

    test('decodes once, not twice', () {
      expect(decodeHtmlEntities('&amp;amp;'), '&amp;');
    });

    test('keeps text without references unchanged', () {
      expect(decodeHtmlEntities('für Anfänger'), 'für Anfänger');
    });
  });
}
