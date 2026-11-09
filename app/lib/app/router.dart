import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/access_state.dart';
import 'access_guard.dart';
import 'placeholder_screens.dart';
import 'routes.dart';
import 'shell_text.dart';

/// Builds the route table of `API_AND_MODULE_CONTRACTS.md` section 6.1
/// (PROPOSED), guarded by [redirectFor] on the latest [accessState]. The
/// router checks again whenever it changes (DEC-014).
///
/// Every route shows a placeholder until its feature task builds the
/// screen. Issue details sit under home, so that back from an issue returns
/// there, and the reader sits under the issue.
GoRouter buildRouter(ValueListenable<AccessState> accessState) {
  late final GoRouter router;
  router = GoRouter(
    refreshListenable: accessState,
    redirect: (BuildContext context, GoRouterState state) =>
        redirectFor(accessState.value, state.uri),
    errorBuilder: (BuildContext context, GoRouterState state) =>
        NotFoundScreen(onGoHome: () => router.go(AppRoutes.home)),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const PlaceholderScreen(title: ShellText.home),
        routes: <RouteBase>[
          GoRoute(
            path: 'issues/:issueId',
            builder: (BuildContext context, GoRouterState state) =>
                PlaceholderScreen(
                  title: ShellText.issue,
                  detail: state.pathParameters['issueId'],
                ),
            routes: <RouteBase>[
              GoRoute(
                path: 'read',
                builder: (BuildContext context, GoRouterState state) =>
                    PlaceholderScreen(
                      title: ShellText.reader,
                      detail: state.pathParameters['issueId'],
                    ),
              ),
            ],
          ),
        ],
      ),
      _placeholder(AppRoutes.downloads, ShellText.downloads),
      _placeholder(AppRoutes.library, ShellText.library),
      GoRoute(
        path: AppRoutes.news,
        builder: (BuildContext context, GoRouterState state) =>
            const PlaceholderScreen(title: ShellText.news),
        routes: <RouteBase>[
          GoRoute(
            path: ':postId',
            builder: (BuildContext context, GoRouterState state) =>
                PlaceholderScreen(
                  title: ShellText.newsArticle,
                  detail: state.pathParameters['postId'],
                ),
          ),
        ],
      ),
      _placeholder(AppRoutes.signIn, ShellText.signIn),
      _placeholder(AppRoutes.register, ShellText.register),
      _placeholder(AppRoutes.verifyEmail, ShellText.verifyEmail),
      _placeholder(AppRoutes.completeProfile, ShellText.completeProfile),
      _placeholder(AppRoutes.settings, ShellText.settings),
    ],
  );
  return router;
}

GoRoute _placeholder(String path, String title) => GoRoute(
  path: path,
  builder: (BuildContext context, GoRouterState state) =>
      PlaceholderScreen(title: title),
);
