import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

import 'brand.dart';

import 'model.dart';
import 'widgets.dart';

/// Opens [article].
void openArticle(BuildContext context, Article article) {
  unawaited(
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ArticleScreen(article: article),
      ),
    ),
  );
}

/// The FR-STATE-005 and FR-NEWS-005 notice: what was loaded before is shown.
class _StaleNotice extends StatelessWidget {
  const _StaleNotice();

  @override
  Widget build(BuildContext context) {
    return const Notice(
      'News could not be refreshed. Showing what was loaded before.',
      kind: NoticeKind.offline,
      margin: EdgeInsets.zero,
    );
  }
}

/// SCR-A-18. Only the categories MFW selects (INT-WP-003). How breaking
/// news looks is OQ-17.
class NewsListScreen extends StatefulWidget {
  /// Creates the screen.
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  String _category = newsCategories.first;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final bool stale = !model.newsReachable || !model.online;
    final List<Article> articles = model.content == Content.empty
        ? <Article>[]
        : sampleArticles
              .where(
                (Article article) =>
                    _category == newsCategories.first ||
                    article.category == _category,
              )
              .toList();
    return LofiScreen(
      id: 'SCR-A-18',
      title: 'News',
      body: Column(
        children: <Widget>[
          if (stale) const _StaleNotice(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: MfwSpace.lg,
              vertical: MfwSpace.md,
            ),
            child: Row(
              children: <Widget>[
                for (final String category in newsCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: MfwSpace.sm),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StateView(
              content: model.content == Content.loading
                  ? Content.loading
                  : articles.isEmpty
                  ? Content.empty
                  : Content.normal,
              emptyText: 'No news in this category yet.',
              emptyIcon: Icons.article_outlined,
              child: ListView(
                children: <Widget>[
                  for (final Article article in articles)
                    NewsRow(
                      title: article.title,
                      meta: article.category,
                      breaking: article.breaking,
                      onTap: () => openArticle(context, article),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SCR-A-19. Recently opened articles are cached, and Save keeps one until
/// the reader removes it (GS-Q48).
class ArticleScreen extends StatelessWidget {
  /// Creates the screen for [article].
  const ArticleScreen({required this.article, super.key});

  /// The article.
  final Article article;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final bool saved = model.isSaved(article);
    return LofiScreen(
      id: 'SCR-A-19',
      title: 'Article',
      actions: <Widget>[
        IconButton(
          tooltip: saved ? 'Remove from saved' : 'Save for offline reading',
          icon: Icon(
            saved ? Icons.offline_pin : Icons.download_for_offline_outlined,
          ),
          onPressed: () => model.toggleSaved(article),
        ),
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.share_outlined),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The system share sheet opens')),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          if (!model.online)
            const Notice(
              'You are offline. This is the copy saved on this device.',
              kind: NoticeKind.offline,
            ),
          if (article.breaking)
            Padding(
              padding: const EdgeInsets.only(bottom: MfwSpace.xs),
              child: Text('BREAKING', style: MfwType.label),
            ),
          Text(article.title, style: MfwType.h2),
          const SizedBox(height: MfwSpace.xs),
          Text(article.category, style: MfwType.small),
          const SizedBox(height: MfwSpace.lg),
          const GreyBox(
            label: '',
            aspectRatio: 16 / 9,
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: MfwSpace.lg),
          for (int line = 0; line < 4; line++)
            Padding(
              padding: const EdgeInsets.only(bottom: MfwSpace.md),
              child: Text(
                'Synthetic paragraph ${line + 1}. The article text comes from '
                'the news site, as it is published there (INT-WP-003).',
                style: MfwType.body,
              ),
            ),
        ],
      ),
    );
  }
}
