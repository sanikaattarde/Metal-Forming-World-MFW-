import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/access_guard.dart';
import 'package:mfw_app/app/app_services.dart';
import 'package:mfw_app/app/issue_actions.dart';
import 'package:mfw_app/app/placeholder_screens.dart';
import 'package:mfw_app/app/routes.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';
import 'package:mfw_app/features/downloads/downloads.dart';
import 'package:mfw_app/features/news/news.dart';
import 'package:mfw_app/features/reader/reader.dart';

/// Builds the route table of API_AND_MODULE_CONTRACTS section 6.1
/// (PROPOSED), guarded by [redirectFor] on the latest [accessState]. The
/// router checks again whenever it changes.
///
/// The catalogue, issue details, reader, downloads and news screens read
/// [services]; the library, the sign-in steps and settings are still
/// placeholders. PROPOSED: home is the catalogue (SN-03, one screen), and
/// issue details sit under home, so that back from an issue returns there.
GoRouter buildRouter(
  ValueListenable<AccessState> accessState,
  AppServices services,
) => GoRouter(
  refreshListenable: accessState,
  redirect: (BuildContext context, GoRouterState state) =>
      redirectFor(accessState.value, state.uri),
  errorBuilder: (BuildContext context, GoRouterState state) =>
      const NotFoundScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => CatalogueScreen(
        catalogue: services.catalogue,
        covers: services.covers,
        onOpenIssue: (String issueId) => context.go(issueRoute(issueId)),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'issues/:issueId',
          builder: (BuildContext context, GoRouterState state) =>
              IssueDetailsScreen(
                catalogue: services.catalogue,
                covers: services.covers,
                issueId: state.pathParameters['issueId']!,
                actionBuilder: (BuildContext context, IssueSummary issue) =>
                    ValueListenableBuilder<AccessState>(
                      valueListenable: accessState,
                      builder:
                          (
                            BuildContext context,
                            AccessState access,
                            Widget? child,
                          ) => IssueActions(
                            issueId: issue.issueId,
                            access: access,
                            downloads: services.downloads,
                          ),
                    ),
              ),
          routes: <RouteBase>[
            GoRoute(
              path: 'read',
              builder: (BuildContext context, GoRouterState state) {
                final String issueId = state.pathParameters['issueId']!;
                // The reader clamps the page to the document (section 4.3).
                final int page =
                    int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 1;
                return ReaderScreen(
                  key: ValueKey<String>('$issueId@$page'),
                  downloads: services.downloads,
                  renderer: services.renderer,
                  pages: services.pages,
                  issueId: issueId,
                  // The default mode (GS-Q55); the setting is not built.
                  mode: ReaderMode.pageTurn,
                  initialPage: page,
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/downloads',
      builder: (BuildContext context, GoRouterState state) =>
          DownloadsScreen(downloads: services.downloads),
    ),
    GoRoute(
      path: '/library',
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.library),
    ),
    GoRoute(
      path: '/news',
      builder: (BuildContext context, GoRouterState state) => NewsListScreen(
        news: services.news,
        images: services.newsImages,
        onOpenPost: (String postId) => context.go(newsPostRoute(postId)),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: ':postId',
          builder: (BuildContext context, GoRouterState state) =>
              NewsArticleScreen(
                news: services.news,
                images: services.newsImages,
                postId: state.pathParameters['postId']!,
              ),
        ),
      ],
    ),
    GoRoute(
      path: signInRoute,
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.signIn),
    ),
    GoRoute(
      path: registerRoute,
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.register),
    ),
    GoRoute(
      path: verifyEmailRoute,
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.verifyEmail),
    ),
    GoRoute(
      path: completeProfileRoute,
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.completeProfile),
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.settings),
    ),
  ],
);
