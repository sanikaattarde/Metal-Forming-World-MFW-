import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/news/news.dart';

void main() {
  group('decodeEntities [CODING_STANDARDS section 7]', () {
    test('decimal and hexadecimal references', () {
      expect(decodeEntities('a &#8211; b &#x20B9; c &#X20b9;'), 'a – b ₹ c ₹');
    });

    test('the named entities WordPress titles use', () {
      expect(
        decodeEntities('&amp; &lt; &gt; &quot; &apos; &nbsp;&hellip;'),
        '& < > " \'  …',
      );
      expect(
        decodeEntities('&lsquo;a&rsquo; &ldquo;b&rdquo; &ndash; &mdash;'),
        '‘a’ “b” – —',
      );
    });

    test("WordPress's &#038; ampersand", () {
      expect(decodeEntities('Forming &#038; Pressing'), 'Forming & Pressing');
    });

    test('decodes once, so double-encoded text keeps one level', () {
      expect(decodeEntities('&amp;#8217; &amp;amp;'), '&#8217; &amp;');
    });

    test('an unknown name or a broken reference is left as it is', () {
      expect(
        decodeEntities('&unknown; & &#; &#xZZ;'),
        '&unknown; & &#; &#xZZ;',
      );
    });

    test('a reference outside Unicode becomes the replacement character', () {
      expect(decodeEntities('&#0;&#xD800;&#1114112;'), '���');
    });

    test('non-ASCII text passes through', () {
      expect(decodeEntities('Café ₹ Größe'), 'Café ₹ Größe');
    });
  });

  group('stripTags', () {
    test('removes tags and keeps their text', () {
      expect(stripTags('Test <em>post</em> <b>101</b>'), 'Test post 101');
    });
  });

  group('htmlToPlainText [SEC-CHK-15, AC-7.5]', () {
    test('paragraphs and line breaks become blank lines and new lines', () {
      expect(
        htmlToPlainText('<p>One.</p>\n<p>Two<br>three<br/>four.</p>'),
        'One.\n\nTwo\nthree\nfour.',
      );
    });

    test('script, style, iframe and template elements go with their '
        'content', () {
      final String text = htmlToPlainText(
        '<p>Before.</p><script>alert(1)</script>'
        '<SCRIPT type="text/javascript">alert(2)</SCRIPT>'
        '<style>p { color: red; }</style>'
        '<iframe src="https://video.example/x">frame</iframe>'
        '<template><p>hidden</p></template>'
        '<p>After.</p>',
      );

      expect(text, 'Before.\n\nAfter.');
    });

    test('an unclosed script removes everything after it', () {
      expect(htmlToPlainText('<p>Kept.</p><script>alert(1)'), 'Kept.');
    });

    test('comments are removed', () {
      expect(htmlToPlainText('<p>A<!-- note --> B</p>'), 'A B');
    });

    test('event attributes go with their tag', () {
      expect(
        htmlToPlainText('<p>Image:<img src="x" onerror="alert(1)"> done</p>'),
        'Image: done',
      );
    });

    test('escaped markup stays as text and runs nothing', () {
      expect(
        htmlToPlainText('<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>'),
        '<script>alert(1)</script>',
      );
    });

    test('spaces collapse and entities are decoded', () {
      expect(
        htmlToPlainText('<p>  Prices in &#8377;   &amp;\tnotes&hellip;  </p>'),
        'Prices in ₹ & notes…',
      );
    });
  });
}
