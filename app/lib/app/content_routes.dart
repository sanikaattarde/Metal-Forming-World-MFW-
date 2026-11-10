import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../features/catalogue/catalogue.dart';
import '../features/downloads/downloads.dart';
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
  DownloadManager? downloads,
  IssueTitles? titles,
  PdfRenderer? renderer,
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
                    issueId: issueId,
                    downloads: downloads,
                    renderer: renderer,
                    titleOf: (String id) => _titleOf(id, titles, catalogue),
                    initialPage: int.tryParse(
                      state.uri.queryParameters['page'] ?? '',
                    ),
                    onClose: () => _back(context),
                  );
                },
        );
  if (catalogue == null) {
    return withDownloads;
  }
  return withDownloads.withContent(
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
        actions: IssueDetailsActions(
          onRead: (IssueSummary issue) =>
              context.push(AppRoutes.reader(issue.issueId)),
          onDownload: downloads == null
              ? null
              : (IssueSummary issue) {
                  unawaited(titles?.remember(issue.issueId, issue.title));
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

void _back(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
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

/// SCR-A-15 with the titles kept beside the files, so it names the issues
/// with no network (NFR-OFF-001).
class _DownloadsTab extends StatelessWidget {
  const _DownloadsTab({required this.downloads, this.titles});

  final DownloadManager downloads;
  final IssueTitles? titles;

  @override
  Widget build(BuildContext context) {
    final IssueTitles? store = titles;
    if (store == null) {
      return DownloadsScreen(downloads: downloads);
    }
    return FutureBuilder<Map<String, String>>(
      future: store.load().catchError((Object _) => <String, String>{}),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, String>> known) {
            final Map<String, String>? names = known.data;
            if (names == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return DownloadsScreen(
              downloads: downloads,
              titleOf: (String issueId) => names[issueId] ?? issueId,
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
