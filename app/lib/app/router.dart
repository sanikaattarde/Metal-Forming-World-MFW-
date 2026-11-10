import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/access_state.dart';
import 'access_guard.dart';
import 'placeholder_screens.dart';
import 'routes.dart';
import 'shell_text.dart';

/// Builds a route's screen.
typedef ScreenBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

/// The screens that feature tasks have built, by route. A route whose
/// builder is null shows its placeholder, so a test can build the router
/// with none of them.
final class RouteScreens {
  /// Creates the set; every screen left out stays a placeholder.
  const RouteScreens({
    this.signIn,
    this.passwordReset,
    this.register,
    this.verifyEmail,
  });

  /// SCR-A-01 (MOD03-P2-T02).
  final ScreenBuilder? signIn;

  /// SCR-A-04 (MOD03-P2-T02).
  final ScreenBuilder? passwordReset;

  /// SCR-A-02 (MOD03-P2-T01).
  final ScreenBuilder? register;

  /// SCR-A-03 (MOD03-P2-T01).
  final ScreenBuilder? verifyEmail;
}

/// Builds the route table of `API_AND_MODULE_CONTRACTS.md` section 6.1
/// (PROPOSED), guarded by [redirectFor] on the latest [accessState]. The
/// router checks again whenever it changes (DEC-014).
///
/// A route shows its screen from [screens], or a placeholder until its
/// feature task builds one. Issue details sit under home, so that back from
/// an issue returns there, and the reader sits under the issue.
GoRouter buildRouter(
  ValueListenable<AccessState> accessState, {
  RouteScreens screens = const RouteScreens(),
}) {
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
      _route(AppRoutes.signIn, ShellText.signIn, screens.signIn),
      _route(
        AppRoutes.passwordReset,
        ShellText.passwordReset,
        screens.passwordReset,
      ),
      _route(AppRoutes.register, ShellText.register, screens.register),
      _route(AppRoutes.verifyEmail, ShellText.verifyEmail, screens.verifyEmail),
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

GoRoute _route(String path, String title, ScreenBuilder? screen) =>
    screen == null
    ? _placeholder(path, title)
    : GoRoute(path: path, builder: screen);
