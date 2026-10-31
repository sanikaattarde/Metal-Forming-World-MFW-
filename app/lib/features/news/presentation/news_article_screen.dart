import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/domain/html_text.dart';
import 'package:mfw_app/features/news/presentation/news_failure_view.dart';
import 'package:mfw_app/features/news/presentation/news_image_source.dart';
import 'package:mfw_app/features/news/presentation/news_text.dart';

/// A news article (SCR-A-19): image, title, date and the post's content
/// (RS FR-NEWS-002). Public (FR-NEWS-007).
///
/// The content is shown as plain text through [htmlToPlainText], so no
/// script runs and none shows (SEC-CHK-15). TODO(yg): formatting, inline
/// images and links need the HTML renderer chosen under
/// DEPENDENCY_REGISTER.md (CODING_STANDARDS section 7, item 8), with links
/// opening outside the app; offline reading and Save (T-08.3, OQ-16);
/// sharing (T-08.5).
class NewsArticleScreen extends StatefulWidget {
  /// Creates the page for [postId].
  const NewsArticleScreen({
    required this.news,
    required this.images,
    required this.postId,
    super.key,
  });

  /// MOD-09's source of posts.
  final NewsRepository news;

  /// Draws the image.
  final NewsImageSource images;

  /// The post shown.
  final String postId;

  @override
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

class _NewsArticleScreenState extends State<NewsArticleScreen> {
  late Future<Result<NewsPost>> _load = widget.news.getPost(widget.postId);

  void _retry() {
    setState(() {
      _load = widget.news.getPost(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(NewsText.article)),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Result<NewsPost>>(
          future: _load,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<Result<NewsPost>> snapshot,
              ) => switch (snapshot.connectionState == ConnectionState.done
              ? snapshot.data
              : null) {
                null => const Center(child: CircularProgressIndicator()),
                Err<NewsPost>(:final AppFailure failure) => NewsFailureView(
                  failure: failure,
                  onRetry: _retry,
                ),
                Ok<NewsPost>(:final NewsPost value) => _article(value),
              },
        ),
      ),
    );
  }

  Widget _article(NewsPost post) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<String> paragraphs = htmlToPlainText(post.contentHtml)
        .split('\n\n')
        .where((String paragraph) => paragraph.isNotEmpty)
        .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ExcludeSemantics(
              child: widget.images.buildImage(context, post),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(post.title, style: text.headlineSmall),
          ),
          const SizedBox(height: 8),
          Text(
            NewsText.date(post.publishedAt.toLocal()),
            style: text.bodySmall,
          ),
          for (final String paragraph in paragraphs) ...<Widget>[
            const SizedBox(height: 16),
            Text(paragraph, style: text.bodyLarge),
          ],
        ],
      ),
    );
  }
}
