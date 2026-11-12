import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/news.dart';
import '../../../contracts/result.dart';
import '../../../core/errors/failure_messages.dart';
import '../../../core/format/display_format.dart';
import '../../../core/ui/content_widgets.dart';
import '../domain/article_content.dart';
import 'article_body.dart';
import 'news_text.dart';

/// SCR-A-19, one article (MOD09-P2-T01, RS FR-NEWS-003, FR-NEWS-007). Open
/// to visitors.
///
/// The category, title, date, picture and body. The body is drawn by the
/// app from the post's HTML and nothing in it runs (SEC-CHK-15); links open
/// outside the app.
class ArticleScreen extends StatefulWidget {
  /// Creates the screen.
  const ArticleScreen({
    required this.news,
    required this.postId,
    required this.onOpenLink,
    this.onBack,
    this.actions,
    this.fromDevice,
    super.key,
  });

  /// Whether the post just read came from the device, not the site
  /// (MOD09-P2-T02). The screen then says it is offline and loads no
  /// pictures.
  final bool Function(String postId)? fromDevice;

  /// MOD-09's news.
  final NewsRepository news;

  /// The WordPress post ID.
  final String postId;

  /// Opens a link outside the app; false when nothing could open it.
  final Future<bool> Function(Uri uri) onOpenLink;

  /// Back, when the screen covers the tab bar.
  final VoidCallback? onBack;

  /// The app bar actions for the loaded post, such as Save and Share.
  final List<Widget> Function(NewsPost post)? actions;

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  Result<NewsPost>? _post;
  List<ArticleBlock> _blocks = const <ArticleBlock>[];
  String? _category;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _post = null;
    });
    final Result<NewsPost> result = await widget.news.getPost(widget.postId);
    if (!mounted) {
      return;
    }
    setState(() {
      _post = result;
      _offline = widget.fromDevice?.call(widget.postId) ?? false;
      if (result case Ok<NewsPost>(:final NewsPost value)) {
        _blocks = parseArticle(value.contentHtml, base: value.link);
      }
    });
    if (result case Ok<NewsPost>(:final NewsPost value)) {
      unawaited(_loadCategory(value));
    }
  }

  Future<void> _loadCategory(NewsPost post) async {
    final Result<List<NewsCategory>> result = await widget.news
        .listCategories();
    if (!mounted) {
      return;
    }
    if (result case Ok<List<NewsCategory>>(:final List<NewsCategory> value)) {
      for (final NewsCategory category in value) {
        if (post.categoryIds.contains(category.categoryId)) {
          setState(() {
            _category = category.name;
          });
          return;
        }
      }
    }
  }

  Future<void> _open(Uri uri) async {
    final bool opened = await widget.onOpenLink(uri);
    if (!opened && mounted) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text(NewsText.linkFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Result<NewsPost>? post = _post;
    final List<Widget> actions = switch (post) {
      Ok<NewsPost>(:final NewsPost value) =>
        widget.actions?.call(value) ?? const <Widget>[],
      _ => const <Widget>[],
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onBack == null
            ? null
            : IconButton(
                tooltip: NewsText.back,
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
        title: const Text(NewsText.title),
        actions: actions,
      ),
      body: switch (post) {
        null => const LoadingContent(label: NewsText.loadingArticle),
        Err<NewsPost>(:final AppFailure failure) =>
          failure.code == FailureCode.notFound
              ? const EmptyState(
                  icon: Icons.article_outlined,
                  heading: NewsText.goneHeading,
                  text: NewsText.goneText,
                )
              : ListView(
                  padding: const EdgeInsets.all(MfwSpace.lg),
                  children: <Widget>[
                    ContentNotice(
                      _unreachable(failure)
                          ? NewsText.unreachable
                          : messageFor(failure),
                      kind: _unreachable(failure)
                          ? NoticeKind.offline
                          : NoticeKind.error,
                      action: TextButton(
                        onPressed: () => unawaited(_load()),
                        child: const Text(NewsText.retry),
                      ),
                    ),
                  ],
                ),
        Ok<NewsPost>(:final NewsPost value) => _Article(
          post: value,
          category: _category,
          blocks: _blocks,
          offline: _offline,
          onOpenLink: (Uri uri) => unawaited(_open(uri)),
        ),
      },
    );
  }
}

bool _unreachable(AppFailure failure) => switch (failure.code) {
  FailureCode.network ||
  FailureCode.timeout ||
  FailureCode.serviceUnavailable => true,
  _ => false,
};

class _Article extends StatelessWidget {
  const _Article({
    required this.post,
    required this.category,
    required this.blocks,
    required this.onOpenLink,
    required this.offline,
  });

  final bool offline;
  final NewsPost post;
  final String? category;
  final List<ArticleBlock> blocks;
  final ValueChanged<Uri> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final Uri? image = offline ? null : post.imageUrl;
    final String label = <String>[
      if (post.isBreaking) NewsText.breaking,
      ?category,
    ].join(' · ');
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        if (offline)
          const ContentNotice(
            NewsText.offlineArticle,
            kind: NoticeKind.offline,
          ),
        if (label.isNotEmpty) ...<Widget>[
          Text(label.toUpperCase(), style: MfwType.label),
          const SizedBox(height: MfwSpace.sm),
        ],
        Semantics(header: true, child: Text(post.title, style: MfwType.h2)),
        const SizedBox(height: MfwSpace.xs),
        Text(DisplayFormat.date(post.publishedAt), style: MfwType.small),
        const SizedBox(height: MfwSpace.lg),
        if (image != null) ...<Widget>[
          Semantics(
            image: true,
            label: NewsText.pictureOf(post.title),
            child: ExcludeSemantics(
              child: Container(
                height: 200,
                color: MfwColours.inputFill,
                alignment: Alignment.center,
                child: Image.network(
                  image.toString(),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? _,
                  ) => const Icon(Icons.image_outlined, color: MfwColours.body),
                ),
              ),
            ),
          ),
          const SizedBox(height: MfwSpace.lg),
        ],
        ArticleBody(
          blocks: blocks,
          onOpenLink: onOpenLink,
          showImages: !offline,
        ),
      ],
    );
  }
}
