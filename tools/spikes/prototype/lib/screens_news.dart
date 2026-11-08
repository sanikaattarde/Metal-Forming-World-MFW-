import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/widgets.dart';

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
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.all(12),
      child: const Text(
        'News could not be refreshed. Showing what was loaded before.',
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                for (final String category in newsCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
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
              child: ListView(
                children: <Widget>[
                  for (final Article article in articles)
                    ListTile(
                      leading: const GreyBox(label: '', width: 56, height: 56),
                      title: Text(article.title),
                      subtitle: Text(
                        article.breaking
                            ? 'Breaking · ${article.category}'
                            : article.category,
                      ),
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
          icon: const Icon(Icons.share),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The system share sheet opens')),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (!model.online)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'You are offline. This is the copy saved on this device.',
              ),
            ),
          Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
          Text(article.category),
          const SizedBox(height: 12),
          const GreyBox(label: 'Image', aspectRatio: 16 / 9),
          const SizedBox(height: 12),
          for (int line = 0; line < 6; line++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GreyBox(label: 'Paragraph ${line + 1}', height: 48),
            ),
        ],
      ),
    );
  }
}
