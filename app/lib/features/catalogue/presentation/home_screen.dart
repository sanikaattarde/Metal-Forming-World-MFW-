import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/format/display_format.dart';
import '../../../core/ui/content_widgets.dart';
import '../../../core/ui/reloadable.dart';
import 'catalogue_screen.dart';
import 'catalogue_text.dart';
import 'issue_row.dart';

/// What the home screen can ask the shell to do.
final class HomeActions {
  /// Creates the set.
  const HomeActions({
    required this.onOpenIssue,
    required this.onOpenCatalogue,
    this.onOpenPost,
    this.onOpenNews,
    this.onOpenDownloads,
  });

  /// Opens SCR-A-12.
  final ValueChanged<String> onOpenIssue;

  /// Opens SCR-A-11.
  final VoidCallback onOpenCatalogue;

  /// Opens SCR-A-19 for a post.
  final ValueChanged<String>? onOpenPost;

  /// Opens SCR-A-18.
  final VoidCallback? onOpenNews;

  /// Opens SCR-A-15, offered when the catalogue cannot be read.
  final VoidCallback? onOpenDownloads;
}

/// Home (SCR-A-10): the latest issue, the archive, a way to the catalogue
/// and the latest news (RS FR-MAG-001, FR-MAG-006), as drawn in the reader
/// frames (PROPOSED until M2; whether home and catalogue are one screen is
/// SCP-002, SN-03). Open to everyone.
class HomeScreen extends StatefulWidget {
  /// Creates the screen.
  const HomeScreen({
    required this.catalogue,
    required this.actions,
    this.news,
    this.logo,
    super.key,
  });

  /// MOD-05's catalogue.
  final CatalogueRepository catalogue;

  /// MOD-09's news, when the site is set (CFG-03).
  final NewsRepository? news;

  /// The shell's actions.
  final HomeActions actions;

  /// The logo for the bar. A placeholder until MFW's file may be used
  /// (DEC-024, `BRAND_REFERENCE.md` section 8).
  final Widget? logo;

  /// How many issues the archive row shows after the latest.
  static const int archiveSize = 6;

  /// How many posts the news section shows.
  static const int newsSize = 3;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with Reloadable<HomeScreen, CatalogueContent> {
  late Future<Result<NewsPage>>? _news = widget.news?.listPosts();

  @override
  Future<Result<CatalogueContent>> fetch() => loadCatalogue(widget.catalogue);

  Future<void> _refreshAll() {
    setState(() {
      _news = widget.news?.listPosts();
    });
    return refresh();
  }

  Future<void> _retryAll() {
    setState(() {
      _news = widget.news?.listPosts();
    });
    return retry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Semantics(
          header: true,
          label: HomeText.title,
          child: ExcludeSemantics(
            child: widget.logo ?? const _LogoPlaceholder(),
          ),
        ),
      ),
      body: switch (result) {
        null => const LoadingContent(label: HomeText.loading),
        Err<CatalogueContent>(:final AppFailure failure) => RefreshIndicator(
          onRefresh: _refreshAll,
          child: _Unavailable(
            failure: failure,
            onRetry: _retryAll,
            onOpenDownloads: widget.actions.onOpenDownloads,
          ),
        ),
        Ok<CatalogueContent>(:final CatalogueContent value) => RefreshIndicator(
          onRefresh: _refreshAll,
          child: _Home(content: value, news: _news, actions: widget.actions),
        ),
      },
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({
    required this.failure,
    required this.onRetry,
    this.onOpenDownloads,
  });

  final AppFailure failure;
  final VoidCallback onRetry;
  final VoidCallback? onOpenDownloads;

  @override
  Widget build(BuildContext context) {
    final bool offline = failure.code == FailureCode.network;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        ContentNotice(
          CatalogueText.failure(failure),
          kind: offline ? NoticeKind.offline : NoticeKind.error,
          action: TextButton(
            onPressed: onRetry,
            child: const Text(CatalogueText.retry),
          ),
        ),
        if (offline) ...<Widget>[
          const EmptyState(
            icon: Icons.cloud_off_outlined,
            heading: HomeText.offlineHeading,
            text: HomeText.offlineText,
          ),
          if (onOpenDownloads != null)
            Center(
              child: OutlinedButton(
                onPressed: onOpenDownloads,
                child: const Text(HomeText.openDownloads),
              ),
            ),
        ],
      ],
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.content,
    required this.news,
    required this.actions,
  });

  final CatalogueContent content;
  final Future<Result<NewsPage>>? news;
  final HomeActions actions;

  @override
  Widget build(BuildContext context) {
    final List<IssueSummary> issues = content.issues;
    final Future<Result<NewsPage>>? posts = news;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
      children: <Widget>[
        const SectionHeading(HomeText.latestIssue),
        if (issues.isEmpty)
          const EmptyState(
            icon: Icons.menu_book_outlined,
            heading: CatalogueText.emptyHeading,
            text: CatalogueText.emptyText,
          )
        else
          _LatestIssue(
            issue: issues.first,
            categoryName: categoryNameOf(
              issues.first.categoryId,
              content.categories,
            ),
            onOpen: () => actions.onOpenIssue(issues.first.issueId),
          ),
        if (issues.length > 1) ...<Widget>[
          const SectionHeading(HomeText.archive),
          SizedBox(
            height: 196,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (final IssueSummary issue
                    in issues.skip(1).take(HomeScreen.archiveSize))
                  _ArchiveIssue(
                    key: ValueKey<String>(issue.issueId),
                    issue: issue,
                    onOpen: () => actions.onOpenIssue(issue.issueId),
                  ),
              ],
            ),
          ),
        ],
        if (issues.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: actions.onOpenCatalogue,
              child: const Text(HomeText.seeCatalogue),
            ),
          ),
        if (posts != null) ...<Widget>[
          const SectionHeading(HomeText.latestNews),
          _LatestNews(posts: posts, actions: actions),
        ],
        const SizedBox(height: MfwSpace.lg),
      ],
    );
  }
}

class _LatestIssue extends StatelessWidget {
  const _LatestIssue({
    required this.issue,
    required this.categoryName,
    required this.onOpen,
  });

  final IssueSummary issue;
  final String categoryName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CoverImage(
          url: issue.coverImageUrl,
          semanticLabel: CatalogueText.coverOf(issue.title),
          width: 120,
          showLabel: true,
        ),
        const SizedBox(width: MfwSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(issue.title, style: MfwType.h3),
              const SizedBox(height: MfwSpace.xs),
              Text(
                CatalogueText.listMeta(categoryName, issue.publicationDate),
                style: MfwType.small,
              ),
              const SizedBox(height: MfwSpace.lg),
              FilledButton(
                onPressed: onOpen,
                child: const Text(HomeText.viewIssue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchiveIssue extends StatelessWidget {
  const _ArchiveIssue({required this.issue, required this.onOpen, super.key});

  final IssueSummary issue;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: MfwSpace.md),
      child: Semantics(
        button: true,
        label: issue.title,
        child: InkWell(
          onTap: onOpen,
          child: SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CoverImage(
                  url: issue.coverImageUrl,
                  semanticLabel: CatalogueText.coverOf(issue.title),
                ),
                const SizedBox(height: MfwSpace.xs),
                ExcludeSemantics(
                  child: Text(
                    issue.title,
                    style: MfwType.small,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestNews extends StatelessWidget {
  const _LatestNews({required this.posts, required this.actions});

  final Future<Result<NewsPage>> posts;
  final HomeActions actions;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<NewsPage>>(
      future: posts,
      builder:
          (BuildContext context, AsyncSnapshot<Result<NewsPage>> snapshot) =>
              switch (snapshot.data) {
                null => const LinearProgressIndicator(
                  semanticsLabel: HomeText.loadingNews,
                ),
                Err<NewsPage>() => const ContentNotice(
                  HomeText.newsUnavailable,
                  kind: NoticeKind.offline,
                ),
                Ok<NewsPage>(:final NewsPage value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (value.posts.isEmpty)
                      Text(HomeText.noNews, style: MfwType.body),
                    for (final NewsPost post in value.posts.take(
                      HomeScreen.newsSize,
                    ))
                      _NewsRow(
                        key: ValueKey<String>(post.postId),
                        post: post,
                        onOpen: actions.onOpenPost == null
                            ? null
                            : () => actions.onOpenPost!(post.postId),
                      ),
                    if (actions.onOpenNews != null)
                      TextButton(
                        onPressed: actions.onOpenNews,
                        child: const Text(HomeText.seeNews),
                      ),
                  ],
                ),
              },
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.post, this.onOpen, super.key});

  final NewsPost post;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final Uri? image = post.imageUrl;
    return Semantics(
      button: onOpen != null,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MfwSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Container(
                  width: 96,
                  height: 72,
                  color: MfwColours.inputFill,
                  alignment: Alignment.center,
                  child: image == null
                      ? const Icon(Icons.image_outlined, color: MfwColours.body)
                      : Image.network(
                          image.toString(),
                          width: 96,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? _,
                              ) => const Icon(
                                Icons.image_outlined,
                                color: MfwColours.body,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: MfwSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (post.isBreaking)
                      Padding(
                        padding: const EdgeInsets.only(bottom: MfwSpace.xs),
                        child: Text(HomeText.breaking, style: MfwType.label),
                      ),
                    Text(post.title, style: MfwType.h5),
                    const SizedBox(height: MfwSpace.xs),
                    Text(
                      DisplayFormat.date(post.publishedAt),
                      style: MfwType.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: MfwColours.divider)),
      child: Text(HomeText.logoPlaceholder, style: MfwType.small),
    );
  }
}

/// User-facing text of SCR-A-10. PLACEHOLDER wording from the reader frames
/// until M2.
abstract final class HomeText {
  /// What a screen reader calls the screen.
  static const String title = 'Home';

  /// The logo placeholder's text.
  static const String logoPlaceholder = 'MFW logo';

  /// Spoken while home loads.
  static const String loading = 'Loading the latest issues';

  /// Spoken while the news loads.
  static const String loadingNews = 'Loading the latest news';

  /// The latest issue section.
  static const String latestIssue = 'Latest issue';

  /// The archive section.
  static const String archive = 'Archive';

  /// The latest news section.
  static const String latestNews = 'Latest news';

  /// Opens the latest issue.
  static const String viewIssue = 'View issue';

  /// Opens the catalogue.
  static const String seeCatalogue = 'See the catalogue';

  /// Opens the news list.
  static const String seeNews = 'See all news';

  /// The breaking label, a placeholder until OQ-17.
  static const String breaking = 'BREAKING';

  /// Shown when the news cannot be read.
  static const String newsUnavailable = 'The news cannot be loaded right now.';

  /// Shown when there are no posts.
  static const String noNews = 'No news yet.';

  /// Heading when the catalogue needs a connection.
  static const String offlineHeading = 'The latest issues need a connection';

  /// Line when the catalogue needs a connection.
  static const String offlineText =
      'Issues you downloaded are still on this device.';

  /// Opens SCR-A-15.
  static const String openDownloads = 'Open Downloads';
}
