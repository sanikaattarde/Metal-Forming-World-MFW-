import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../features/catalogue/catalogue.dart';
import '../features/downloads/downloads.dart';
import '../features/account/account.dart';
import '../features/library/library.dart';
import '../features/news/news.dart';
import '../features/reader/reader.dart';
import '../features/sharing/sharing.dart';
import 'access_guard.dart';
import 'reader_route.dart';
import 'router.dart';
import 'routes.dart';

/// [base] with the reader-side screens of MOD-05 to MOD-10 that have their
/// services. A screen whose service is null stays a placeholder.
/// Navigation stays here, in the shell (DEC-013).
RouteScreens withContentScreens(
  RouteScreens base, {
  required ValueListenable<AccessState> accessState,
  CatalogueRepository? catalogue,
  NewsRepository? news,
  OfflineNewsRepository? offlineNews,
  DownloadManager? downloads,
  IssueTitles? titles,
  PdfRenderer? renderer,
  LibraryRepository? library,
  LinkOpener? links,
  ShareSheet? share,
  StoreLinks storeLinks = const StoreLinks(),
  ReaderPreferences? readerPreferences,
}) {
  final RouteScreens withDownloads = downloads == null
      ? base
      : base.withContent(
          downloads: (BuildContext context, GoRouterState state) =>
              _DownloadsTab(downloads: downloads, titles: titles),
          reader: renderer == null
              ? null
              : (BuildContext context, GoRouterState state) {
                  final String issueId = state.pathParameters['issueId'] ?? '';
                  return ReaderRoute(
                    key: ValueKey<String>(issueId),
                    preferences: readerPreferences,
                    issueId: issueId,
                    downloads: downloads,
                    renderer: renderer,
                    titleOf: (String id) => _titleOf(id, titles, catalogue),
                    initialPage: int.tryParse(
                      state.uri.queryParameters['page'] ?? '',
                    ),
                    onClose: () => _back(context),
                    actions: library == null
                        ? null
                        : (
                            String issueId,
                            LocalIssueFile file,
                            ReaderController reader,
                          ) => <Widget>[
                            BookmarkButton(
                              library: library,
                              issueId: issueId,
                              fileRevision: file.fileRevision,
                              reader: reader,
                            ),
                          ],
                  );
                },
        );
  final RouteScreens withLibrary = library == null
      ? withDownloads
      : withDownloads.withContent(
          library: (BuildContext context, GoRouterState state) => LibraryScreen(
            library: library,
            titleOf: (String id) => _titleOf(id, titles, catalogue),
            onOpenBookmark: (Bookmark bookmark) => context.push(
              AppRoutes.reader(bookmark.issueId, page: bookmark.page),
            ),
            onOpenIssue: (String issueId) =>
                context.push(AppRoutes.issue(issueId)),
          ),
        );
  final RouteScreens withNews = news == null
      ? withLibrary
      : withLibrary.withContent(
          news: (BuildContext context, GoRouterState state) => NewsScreen(
            news: news,
            onOpenPost: (String postId) =>
                context.push(AppRoutes.newsPost(postId)),
            loadSaved: offlineNews == null
                ? null
                : () => _savedArticles(offlineNews, news),
          ),
          newsArticle: (BuildContext context, GoRouterState state) {
            final String postId = state.pathParameters['postId'] ?? '';
            return ArticleScreen(
              key: ValueKey<String>(postId),
              news: news,
              postId: postId,
              onOpenLink: (Uri uri) async => await links?.open(uri) ?? false,
              onBack: () => _backTo(context, AppRoutes.news),
              fromDevice: offlineNews?.fromDevice,
              actions: (NewsPost post) => <Widget>[
                if (offlineNews != null)
                  SaveArticleButton(saved: offlineNews, post: post),
                if (share != null)
                  ShareButton(
                    onShare: (Rect? origin) => AppShareService(
                      sheet: share,
                      links: storeLinks,
                      origin: origin,
                    ).shareArticle(post),
                  ),
              ],
            );
          },
        );
  if (catalogue == null) {
    return withNews;
  }
  return withNews.withContent(
    home: (BuildContext context, GoRouterState state) => HomeScreen(
      catalogue: catalogue,
      news: news,
      actions: HomeActions(
        onOpenIssue: (String issueId) => context.push(AppRoutes.issue(issueId)),
        onOpenCatalogue: () => context.push(AppRoutes.catalogue),
        onOpenPost: (String postId) => context.push(AppRoutes.newsPost(postId)),
        onOpenNews: () => context.go(AppRoutes.news),
        onOpenDownloads: () => context.go(AppRoutes.downloads),
      ),
    ),
    catalogue: (BuildContext context, GoRouterState state) => CatalogueScreen(
      catalogue: catalogue,
      segments: catalogue is SegmentSource ? catalogue as SegmentSource : null,
      onOpenIssue: (String issueId) => context.push(AppRoutes.issue(issueId)),
      onBack: () => _back(context),
    ),
    issue: (BuildContext context, GoRouterState state) {
      final String issueId = state.pathParameters['issueId'] ?? '';
      final String here = AppRoutes.issue(issueId);
      return IssueDetailsScreen(
        key: ValueKey<String>(issueId),
        issueId: issueId,
        catalogue: catalogue,
        accessState: accessState,
        // The star for a reader with full access only (OQ-12, YG's answer,
        // PROVISIONAL). Share for everyone once a store link is known
        // (OQ-15 working position, PROVISIONAL).
        appBarActions: (IssueSummary issue, AccessState state) => <Widget>[
          if (share != null && storeLinks.any)
            ShareButton(
              onShare: (Rect? origin) => AppShareService(
                sheet: share,
                links: storeLinks,
                origin: origin,
              ).shareIssue(issue),
            ),
          if (library != null && state == AccessState.fullAccess)
            FavouriteButton(library: library, issueId: issue.issueId),
        ],
        actions: IssueDetailsActions(
          onRead: (IssueSummary issue) {
            // Read downloads first (OQ-08 working position), so the title
            // is kept for the offline lists here too.
            _keepTitle(titles, issue);
            unawaited(context.push(AppRoutes.reader(issue.issueId)));
          },
          onDownload: downloads == null
              ? null
              : (IssueSummary issue) {
                  _keepTitle(titles, issue);
                  unawaited(showDownloadSheet(context, downloads, issue));
                },
          onSignIn: () => context.go(returningTo(AppRoutes.signIn, here)),
          onRegister: () => context.go(returningTo(AppRoutes.register, here)),
          onContinueSignUp: () {
            final String? step = missingStepRoute(accessState.value);
            if (step != null) {
              context.go(returningTo(step, here));
            }
          },
          onBack: () => _back(context),
        ),
      );
    },
  );
}

/// [step] with [from] kept, so that the step returns the reader there.
String returningTo(String step, String from) =>
    Uri(path: step, queryParameters: <String, String>{'from': from}).toString();

void _back(BuildContext context) => _backTo(context, AppRoutes.home);

void _backTo(BuildContext context, String fallback) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

/// SCR-A-13 as a sheet over the issue details (where it sits is SN-04).
Future<void> showDownloadSheet(
  BuildContext context,
  DownloadManager downloads,
  IssueSummary issue,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(issue.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DownloadPanel(downloads: downloads, issueId: issue.issueId),
        ],
      ),
    ),
  ),
);

/// Keeps [issue]'s title beside the files, for the offline lists. A title
/// that cannot be written leaves the identifier shown instead.
void _keepTitle(IssueTitles? titles, IssueSummary issue) {
  unawaited(
    titles?.remember(issue.issueId, issue.title).catchError((Object _) {}),
  );
}

/// SCR-A-15 with the titles kept beside the files, so it names the issues
/// with no network (NFR-OFF-001). The titles are read once; one kept later
/// is found in memory, so a copy finished since shows its title.
class _DownloadsTab extends StatefulWidget {
  const _DownloadsTab({required this.downloads, this.titles});

  final DownloadManager downloads;
  final IssueTitles? titles;

  @override
  State<_DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<_DownloadsTab> {
  late final Future<void> _loaded =
      widget.titles?.load().then((_) {}, onError: (Object _) {}) ??
      Future<void>.value();

  @override
  Widget build(BuildContext context) {
    final IssueTitles? store = widget.titles;
    if (store == null) {
      return DownloadsScreen(downloads: widget.downloads);
    }
    return FutureBuilder<void>(
      future: _loaded,
      builder: (BuildContext context, AsyncSnapshot<void> loaded) {
        if (loaded.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return DownloadsScreen(
          downloads: widget.downloads,
          titleOf: (String issueId) => store.titleOf(issueId) ?? issueId,
        );
      },
    );
  }
}

/// An issue's title: the one kept with its download, which works offline,
/// or else the catalogue's. The identifier when neither knows it.
Future<String> _titleOf(
  String issueId,
  IssueTitles? titles,
  CatalogueRepository? catalogue,
) async {
  final String? kept = (await titles?.load().catchError(
    (Object _) => <String, String>{},
  ))?[issueId];
  if (kept != null) {
    return kept;
  }
  final Result<IssueSummary>? issue = await catalogue?.getIssue(issueId);
  return switch (issue) {
    Ok<IssueSummary>(:final IssueSummary value) => value.title,
    _ => issueId,
  };
}

/// The saved articles, with the admin's controls applied when [news] has
/// them, so a post hidden later leaves the saved list too (FR-NEWS-008).
Future<Result<List<NewsPost>>> _savedArticles(
  OfflineNewsRepository offline,
  NewsRepository news,
) async {
  final List<NewsPost> saved = await offline.saved();
  if (news is ControlledNewsRepository) {
    return news.applyTo(saved);
  }
  return Ok<List<NewsPost>>(saved);
}
