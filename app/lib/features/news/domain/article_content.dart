import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// A post body as plain parts the app draws itself (MOD09-P2-T01,
/// `CODING_STANDARDS.md` section 7, SEC-CHK-15).
///
/// The HTML WordPress sends is parsed into a tree and only text, emphasis,
/// links, headings, lists, quotes and images are kept. Nothing in it is ever
/// run: scripts, styles, forms and event attributes are dropped, and so is
/// every link that is not a web or mail address. Embedded players (an
/// iframe, a video, an audio clip) become a link to their address, opened
/// outside the app (OQ-16 media handling, working position).
sealed class ArticleBlock {
  const ArticleBlock();
}

/// A paragraph of [runs].
final class ArticleParagraph extends ArticleBlock {
  /// Creates the paragraph.
  const ArticleParagraph(this.runs);

  /// The text, in order.
  final List<ArticleRun> runs;
}

/// A heading of [level] 1 to 6.
final class ArticleHeading extends ArticleBlock {
  /// Creates the heading.
  const ArticleHeading(this.level, this.runs);

  /// 1 for `h1` to 6 for `h6`.
  final int level;

  /// The text, in order.
  final List<ArticleRun> runs;
}

/// A bulleted or numbered list.
final class ArticleList extends ArticleBlock {
  /// Creates the list.
  const ArticleList({required this.ordered, required this.items});

  /// Whether the items are numbered.
  final bool ordered;

  /// Each item's parts.
  final List<List<ArticleBlock>> items;
}

/// A quotation.
final class ArticleQuote extends ArticleBlock {
  /// Creates the quotation.
  const ArticleQuote(this.blocks);

  /// The quoted parts.
  final List<ArticleBlock> blocks;
}

/// Text shown as written, such as code.
final class ArticlePreformatted extends ArticleBlock {
  /// Creates the block.
  const ArticlePreformatted(this.text);

  /// The text with its spaces and line breaks.
  final String text;
}

/// An image at an HTTPS address.
final class ArticleImage extends ArticleBlock {
  /// Creates the image.
  const ArticleImage(this.url, {this.alt = ''});

  /// The image address, always HTTPS.
  final Uri url;

  /// The text alternative, possibly empty.
  final String alt;
}

/// An embedded player, shown as a link to [url].
final class ArticleMedia extends ArticleBlock {
  /// Creates the link.
  const ArticleMedia(this.url);

  /// The player's address, always HTTPS.
  final Uri url;
}

/// A dividing line.
final class ArticleRule extends ArticleBlock {
  /// Creates the line.
  const ArticleRule();
}

/// A piece of text with one style.
final class ArticleRun {
  /// Creates the run.
  const ArticleRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.link,
  });

  /// The text. A line break is `\n`.
  final String text;

  /// Strong or bold.
  final bool bold;

  /// Emphasis or italic.
  final bool italic;

  /// Where a tap goes, opened outside the app; null for plain text.
  final Uri? link;

  bool _sameStyle(ArticleRun other) =>
      bold == other.bold && italic == other.italic && link == other.link;
}

/// Elements whose content is never shown.
const Set<String> _dropped = <String>{
  'script',
  'style',
  'noscript',
  'template',
  'head',
  'meta',
  'link',
  'title',
  'form',
  'input',
  'button',
  'select',
  'textarea',
  'option',
  'svg',
  'math',
  'canvas',
  'map',
  'source',
  'track',
  'picture',
};

/// Elements that hold a player.
const Set<String> _players = <String>{
  'iframe',
  'video',
  'audio',
  'embed',
  'object',
};

/// Elements that start and end a block of their own.
const Set<String> _containers = <String>{
  'p',
  'div',
  'section',
  'article',
  'header',
  'footer',
  'main',
  'aside',
  'nav',
  'figure',
  'figcaption',
  'center',
  'address',
  'details',
  'summary',
  'table',
  'thead',
  'tbody',
  'tfoot',
  'tr',
  'caption',
  'dl',
  'dt',
  'dd',
};

final RegExp _spaces = RegExp(r'\s+');

/// Parses [html], a post body, into the parts the app shows. Relative
/// addresses are read against [base], the post's own address.
List<ArticleBlock> parseArticle(String html, {Uri? base}) {
  final dom.DocumentFragment fragment = html_parser.parseFragment(html);
  final _Builder builder = _Builder(base);
  for (final dom.Node node in fragment.nodes) {
    builder.walk(node, const _Style());
  }
  return builder.finish();
}

/// [raw] as an address the app may open outside itself: HTTPS, HTTP or
/// mail, read against [base]. Null for anything else, such as a script.
Uri? safeLink(String? raw, {Uri? base}) {
  final Uri? uri = _resolve(raw, base);
  if (uri == null) {
    return null;
  }
  return switch (uri.scheme) {
    'https' || 'http' => uri.host.isEmpty ? null : uri,
    'mailto' => uri,
    _ => null,
  };
}

/// [raw] as an HTTPS address of a picture or player, or null.
Uri? _secureSource(String? raw, Uri? base) {
  final Uri? uri = _resolve(raw, base);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return null;
  }
  return uri;
}

Uri? _resolve(String? raw, Uri? base) {
  final String text = raw?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  final Uri? parsed = Uri.tryParse(text);
  if (parsed == null) {
    return null;
  }
  if (parsed.hasScheme) {
    return parsed.replace(scheme: parsed.scheme.toLowerCase());
  }
  // A protocol-relative address takes HTTPS, so no picture comes over HTTP.
  if (text.startsWith('//')) {
    return Uri.tryParse('https:$text');
  }
  return base?.resolveUri(parsed);
}

final class _Style {
  const _Style({this.bold = false, this.italic = false, this.link});

  final bool bold;
  final bool italic;
  final Uri? link;

  _Style copy({bool? bold, bool? italic, Uri? link}) => _Style(
    bold: bold ?? this.bold,
    italic: italic ?? this.italic,
    link: link ?? this.link,
  );
}

final class _Builder {
  _Builder(this._base);

  final Uri? _base;
  final List<ArticleBlock> _blocks = <ArticleBlock>[];
  List<ArticleRun> _runs = <ArticleRun>[];

  List<ArticleBlock> finish() {
    _flush();
    return List<ArticleBlock>.unmodifiable(_blocks);
  }

  void walk(dom.Node node, _Style style) {
    if (node is dom.Text) {
      _text(node.text.replaceAll(_spaces, ' '), style);
      return;
    }
    if (node is! dom.Element) {
      return;
    }
    final String tag = node.localName ?? '';
    if (_dropped.contains(tag)) {
      return;
    }
    if (_players.contains(tag)) {
      _flush();
      final Uri? url =
          _secureSource(node.attributes['src'], _base) ??
          _secureSource(node.attributes['data'], _base) ??
          _firstSource(node);
      if (url != null) {
        _blocks.add(ArticleMedia(url));
      }
      return;
    }
    switch (tag) {
      case 'br':
        _text('\n', style);
      case 'img':
        final Uri? url = _secureSource(node.attributes['src'], _base);
        if (url != null) {
          _flush();
          _blocks.add(ArticleImage(url, alt: node.attributes['alt'] ?? ''));
        }
      case 'hr':
        _flush();
        _blocks.add(const ArticleRule());
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        _flush();
        final List<ArticleBlock> inner = _sub(node.nodes, style);
        final List<ArticleRun> runs = <ArticleRun>[
          for (final ArticleBlock block in inner)
            if (block is ArticleParagraph) ...block.runs,
        ];
        if (runs.isNotEmpty) {
          _blocks.add(ArticleHeading(int.parse(tag.substring(1)), runs));
        }
        // An image inside a heading is still shown.
        _blocks.addAll(inner.where((ArticleBlock b) => b is! ArticleParagraph));
      case 'ul' || 'ol':
        _flush();
        final List<List<ArticleBlock>> items = <List<ArticleBlock>>[
          for (final dom.Element item in node.children)
            if (item.localName == 'li') _sub(item.nodes, style),
        ].where((List<ArticleBlock> item) => item.isNotEmpty).toList();
        if (items.isNotEmpty) {
          _blocks.add(ArticleList(ordered: tag == 'ol', items: items));
        }
      case 'blockquote':
        _flush();
        final List<ArticleBlock> inner = _sub(node.nodes, style);
        if (inner.isNotEmpty) {
          _blocks.add(ArticleQuote(inner));
        }
      case 'pre':
        _flush();
        final String text = node.text;
        if (text.trim().isNotEmpty) {
          _blocks.add(ArticlePreformatted(text));
        }
      case 'td' || 'th':
        for (final dom.Node child in node.nodes) {
          walk(child, style);
        }
        _text(' ', style);
      case 'strong' || 'b':
        _children(node, style.copy(bold: true));
      case 'em' || 'i' || 'cite':
        _children(node, style.copy(italic: true));
      case 'a':
        final Uri? link = safeLink(node.attributes['href'], base: _base);
        _children(node, link == null ? style : style.copy(link: link));
      default:
        if (_containers.contains(tag)) {
          _flush();
          _children(node, style);
          _flush();
        } else {
          _children(node, style);
        }
    }
  }

  void _children(dom.Element node, _Style style) {
    for (final dom.Node child in node.nodes) {
      walk(child, style);
    }
  }

  Uri? _firstSource(dom.Element player) {
    for (final dom.Element source in player.getElementsByTagName('source')) {
      final Uri? url = _secureSource(source.attributes['src'], _base);
      if (url != null) {
        return url;
      }
    }
    return null;
  }

  List<ArticleBlock> _sub(List<dom.Node> nodes, _Style style) {
    final _Builder inner = _Builder(_base);
    for (final dom.Node node in nodes) {
      inner.walk(node, style);
    }
    return inner.finish();
  }

  void _text(String text, _Style style) {
    if (text.isEmpty) {
      return;
    }
    final ArticleRun run = ArticleRun(
      text,
      bold: style.bold,
      italic: style.italic,
      link: style.link,
    );
    if (_runs.isNotEmpty && _runs.last._sameStyle(run)) {
      final ArticleRun last = _runs.removeLast();
      _runs.add(
        ArticleRun(
          _joined(last.text, text),
          bold: run.bold,
          italic: run.italic,
          link: run.link,
        ),
      );
    } else {
      final String previous = _runs.isEmpty ? '' : _runs.last.text;
      // One space between runs, as a browser collapses them.
      final String added = previous.endsWith(' ') || previous.endsWith('\n')
          ? text.replaceFirst(RegExp('^ +'), '')
          : text;
      if (added.isNotEmpty) {
        _runs.add(
          ArticleRun(added, bold: run.bold, italic: run.italic, link: run.link),
        );
      }
    }
  }

  static String _joined(String first, String second) =>
      (first.endsWith(' ') || first.endsWith('\n')) && second.startsWith(' ')
      ? first + second.substring(1)
      : first + second;

  void _flush() {
    final List<ArticleRun> runs = _trimmed(_runs);
    _runs = <ArticleRun>[];
    if (runs.isNotEmpty) {
      _blocks.add(ArticleParagraph(List<ArticleRun>.unmodifiable(runs)));
    }
  }

  /// [runs] without the spaces and line breaks at either end.
  static List<ArticleRun> _trimmed(List<ArticleRun> runs) {
    final List<ArticleRun> out = List<ArticleRun>.of(runs);
    while (out.isNotEmpty) {
      final ArticleRun first = out.first;
      final String text = first.text.replaceFirst(RegExp(r'^[ \n]+'), '');
      if (text.isEmpty) {
        out.removeAt(0);
        continue;
      }
      out[0] = ArticleRun(
        text,
        bold: first.bold,
        italic: first.italic,
        link: first.link,
      );
      break;
    }
    while (out.isNotEmpty) {
      final ArticleRun last = out.last;
      final String text = last.text.replaceFirst(RegExp(r'[ \n]+$'), '');
      if (text.isEmpty) {
        out.removeLast();
        continue;
      }
      out[out.length - 1] = ArticleRun(
        text,
        bold: last.bold,
        italic: last.italic,
        link: last.link,
      );
      break;
    }
    return out;
  }
}

/// The plain text of [blocks], for a summary or a test.
String plainTextOf(List<ArticleBlock> blocks) => blocks
    .map(
      (ArticleBlock block) => switch (block) {
        ArticleParagraph(:final List<ArticleRun> runs) ||
        ArticleHeading(
          :final List<ArticleRun> runs,
        ) => runs.map((ArticleRun r) => r.text).join(),
        ArticleList(:final List<List<ArticleBlock>> items) =>
          items.map(plainTextOf).join('\n'),
        ArticleQuote(:final List<ArticleBlock> blocks) => plainTextOf(blocks),
        ArticlePreformatted(:final String text) => text,
        ArticleImage(:final String alt) => alt,
        ArticleMedia() || ArticleRule() => '',
      },
    )
    .where((String text) => text.isNotEmpty)
    .join('\n');
