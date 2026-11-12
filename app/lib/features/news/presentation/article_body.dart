import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../domain/article_content.dart';
import 'news_text.dart';

/// A post body drawn from [blocks] (SCR-A-19). Nothing from the post runs:
/// [parseArticle] kept only text, links, images and player links, and each
/// link is opened outside the app through [onOpenLink] (SEC-CHK-15).
///
/// With [showImages] false, as offline, pictures are left out, so the body
/// reads without the network.
class ArticleBody extends StatefulWidget {
  /// Creates the body.
  const ArticleBody({
    required this.blocks,
    required this.onOpenLink,
    this.showImages = true,
    super.key,
  });

  /// The body's parts.
  final List<ArticleBlock> blocks;

  /// Opens a link outside the app.
  final ValueChanged<Uri> onOpenLink;

  /// Whether pictures are loaded.
  final bool showImages;

  @override
  State<ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends State<ArticleBody> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final ArticleBlock block in widget.blocks) _block(block),
      ],
    );
  }

  Widget _block(ArticleBlock block) {
    return switch (block) {
      ArticleParagraph(:final List<ArticleRun> runs) => _spaced(
        Text.rich(TextSpan(children: _spans(runs)), style: MfwType.body),
      ),
      ArticleHeading(:final int level, :final List<ArticleRun> runs) => _spaced(
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(children: _spans(runs)),
            style: level <= 2
                ? MfwType.h3
                : (level == 3 ? MfwType.h4 : MfwType.h5),
          ),
        ),
      ),
      ArticleList(:final bool ordered, :final List<List<ArticleBlock>> items) =>
        _spaced(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 28,
                      child: Text(
                        ordered ? '${i + 1}.' : '•',
                        style: MfwType.body,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (final ArticleBlock inner in items[i])
                            _block(inner),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ArticleQuote(:final List<ArticleBlock> blocks) => _spaced(
        Container(
          padding: const EdgeInsets.only(left: MfwSpace.md),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: MfwColours.divider, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final ArticleBlock inner in blocks) _block(inner),
            ],
          ),
        ),
      ),
      ArticlePreformatted(:final String text) => _spaced(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            text,
            style: MfwType.body.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ),
      ArticleImage(:final Uri url, :final String alt) =>
        widget.showImages
            ? _spaced(
                Semantics(
                  image: true,
                  label: alt.isEmpty ? null : alt,
                  child: ExcludeSemantics(
                    child: Image.network(
                      url.toString(),
                      fit: BoxFit.fitWidth,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? _,
                      ) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ArticleMedia(:final Uri url) => _spaced(
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => widget.onOpenLink(url),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text(NewsText.openMedia),
          ),
        ),
      ),
      ArticleRule() => _spaced(const Divider()),
    };
  }

  List<InlineSpan> _spans(List<ArticleRun> runs) {
    return <InlineSpan>[for (final ArticleRun run in runs) _span(run)];
  }

  InlineSpan _span(ArticleRun run) {
    final Uri? link = run.link;
    TextStyle style = TextStyle(
      fontWeight: run.bold ? FontWeight.w700 : null,
      fontVariations: run.bold
          ? const <FontVariation>[FontVariation('wght', 700)]
          : null,
      fontStyle: run.italic ? FontStyle.italic : null,
    );
    if (link == null) {
      return TextSpan(text: run.text, style: style);
    }
    style = style.copyWith(
      color: MfwColours.action,
      decoration: TextDecoration.underline,
      decorationColor: MfwColours.action,
    );
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () => widget.onOpenLink(link);
    _recognizers.add(recognizer);
    return TextSpan(
      text: run.text,
      style: style,
      recognizer: recognizer,
      semanticsLabel: run.text,
    );
  }

  Widget _spaced(Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: MfwSpace.lg),
    child: child,
  );
}
