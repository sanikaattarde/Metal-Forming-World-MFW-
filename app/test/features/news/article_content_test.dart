import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/news/news.dart';

final Uri _base = Uri.parse('https://news.example.test/synthetic-post-1/');

List<ArticleBlock> _parse(String html) => parseArticle(html, base: _base);

void main() {
  group('no script ever runs or shows [SEC-CHK-15]', () {
    test('FX-WP-05: the script is dropped, the text and image are kept', () {
      final Map<String, Object?> post = jsonDecode(
        File('test/fixtures/wordpress/fx_wp_05_post_with_script.json')
            .readAsStringSync(),
      ) as Map<String, Object?>;
      final String html =
          (post['content']! as Map<String, Object?>)['rendered']! as String;

      final List<ArticleBlock> blocks = _parse(html);
      final String text = plainTextOf(blocks);

      expect(text, contains('Synthetic body with embedded media.'));
      expect(text, isNot(contains('document.title')));
      expect(text, isNot(contains('synthetic script')));
      expect(
        blocks.whereType<ArticleImage>().single.url.host,
        'news.example.test',
      );
    });

    test('style, form, svg and noscript content is never shown', () {
      final String text = plainTextOf(
        _parse(
          '<style>p{color:red}</style><p>Kept</p>'
          '<form><input value="x"><button>Send</button></form>'
          '<noscript>no script</noscript><svg><text>svg</text></svg>',
        ),
      );

      expect(text, 'Kept');
    });

    test('event attributes are ignored and a script link is plain text', () {
      final List<ArticleBlock> blocks = _parse(
        '<p onclick="alert(1)">Click <a href="javascript:alert(1)">here</a> '
        'or <a href="data:text/html,x">there</a></p>',
      );

      final ArticleParagraph paragraph = blocks.single as ArticleParagraph;
      expect(
        paragraph.runs.map((ArticleRun r) => r.text).join(),
        'Click here or there',
      );
      expect(paragraph.runs.every((ArticleRun r) => r.link == null), isTrue);
    });
  });

  group('links open outside the app', () {
    test(
      'web and mail links are kept, relative ones read against the post',
      () {
        final List<ArticleBlock> blocks = _parse(
          '<p><a href="https://example.test/a">web</a> '
          '<a href="mailto:editor@example.test">mail</a> '
          '<a href="/about/">relative</a></p>',
        );

        final List<Uri?> links = (blocks.single as ArticleParagraph).runs
            .map((ArticleRun r) => r.link)
            .whereType<Uri>()
            .toList();
        expect(links, <Uri>[
          Uri.parse('https://example.test/a'),
          Uri.parse('mailto:editor@example.test'),
          Uri.parse('https://news.example.test/about/'),
        ]);
      },
    );

    test('safeLink refuses other schemes and hostless web addresses', () {
      expect(safeLink('file:///etc/passwd'), isNull);
      expect(safeLink('intent://x'), isNull);
      expect(safeLink('https://'), isNull);
      expect(safeLink(''), isNull);
      expect(safeLink('HTTPS://Example.test/x')?.scheme, 'https');
    });
  });

  group('media [OQ-16 working position]', () {
    test('an iframe or video becomes a link to its HTTPS address', () {
      final List<ArticleBlock> blocks = _parse(
        '<iframe src="https://video.example.test/embed/1"></iframe>'
        '<video><source src="https://video.example.test/2.mp4"></video>'
        '<audio src="http://audio.example.test/3.mp3"></audio>',
      );

      expect(
        blocks.whereType<ArticleMedia>().map((ArticleMedia m) => '${m.url}'),
        <String>[
          'https://video.example.test/embed/1',
          'https://video.example.test/2.mp4',
        ],
      );
    });

    test(
      'an image over HTTP is not loaded; a protocol-relative one is HTTPS',
      () {
        final List<ArticleBlock> blocks = _parse(
          '<img src="http://news.example.test/a.jpg">'
          '<img src="//cdn.example.test/b.jpg" alt="B">',
        );

        final ArticleImage image = blocks.single as ArticleImage;
        expect(image.url, Uri.parse('https://cdn.example.test/b.jpg'));
        expect(image.alt, 'B');
      },
    );
  });

  group('structure', () {
    test('headings, lists, quotes, rules and emphasis', () {
      final List<ArticleBlock> blocks = _parse(
        '<h2>Heading</h2>'
        '<ul><li>One</li><li><strong>Two</strong></li></ul>'
        '<ol><li>First</li></ol>'
        '<blockquote><p>Quoted</p></blockquote><hr>'
        '<p>Some <em>stress</em> and <b>weight</b>.</p>',
      );

      expect(blocks[0], isA<ArticleHeading>());
      expect((blocks[0] as ArticleHeading).level, 2);
      final ArticleList bullets = blocks[1] as ArticleList;
      expect(bullets.ordered, isFalse);
      expect(bullets.items, hasLength(2));
      final ArticleRun two =
          (bullets.items[1].single as ArticleParagraph).runs.single;
      expect(two.bold, isTrue);
      expect((blocks[2] as ArticleList).ordered, isTrue);
      expect(blocks[3], isA<ArticleQuote>());
      expect(blocks[4], isA<ArticleRule>());
      final List<ArticleRun> runs = (blocks[5] as ArticleParagraph).runs;
      expect(
        runs.map((ArticleRun r) => r.text).join(),
        'Some stress and weight.',
      );
      expect(
        runs.firstWhere((ArticleRun r) => r.text == 'stress').italic,
        isTrue,
      );
    });

    test('spaces collapse as in a browser, and a line break is kept', () {
      final ArticleParagraph paragraph =
          _parse('<p>  One\n\n   two <br>three  </p>').single
              as ArticleParagraph;

      expect(paragraph.runs.single.text, 'One two \nthree');
    });

    test('an empty body has no parts', () {
      expect(_parse(''), isEmpty);
      expect(_parse('<p> </p><div>\n</div>'), isEmpty);
    });

    test('an image inside a paragraph splits it', () {
      final List<ArticleBlock> blocks = _parse(
        '<p>Before<img src="https://news.example.test/i.jpg">after</p>',
      );

      expect(blocks.map((ArticleBlock b) => b.runtimeType), <Type>[
        ArticleParagraph,
        ArticleImage,
        ArticleParagraph,
      ]);
    });
  });
}
