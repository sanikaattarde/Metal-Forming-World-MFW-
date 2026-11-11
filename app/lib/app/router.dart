import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/access_state.dart';
import 'access_guard.dart';
import 'placeholder_screens.dart';
import 'routes.dart';
import 'shell_text.dart';
import 'tab_shell.dart';

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
    this.completeProfile,
    this.profile,
    this.settings,
    this.deleteAccount,
    this.notificationSettings,
    this.home,
    this.catalogue,
    this.issue,
    this.downloads,
    this.reader,
    this.library,
  });

  /// SCR-A-15 (MOD06-P2-T02).
  final ScreenBuilder? downloads;

  /// SCR-A-14 (MOD07-P2-T01, MOD06-P3-T03).
  final ScreenBuilder? reader;

  /// SCR-A-16 and SCR-A-17 (MOD08-P2-T01, MOD08-P2-T02).
  final ScreenBuilder? library;

  /// SCR-A-10 (MOD05-P2-T03).
  final ScreenBuilder? home;

  /// SCR-A-11 (MOD05-P2-T01).
  final ScreenBuilder? catalogue;

  /// SCR-A-12 (MOD05-P2-T01).
  final ScreenBuilder? issue;

  /// This set with the reader-side screens given here; the account screens
  /// stay as they are.
  RouteScreens withContent({
    ScreenBuilder? home,
    ScreenBuilder? catalogue,
    ScreenBuilder? issue,
    ScreenBuilder? downloads,
    ScreenBuilder? reader,
    ScreenBuilder? library,
  }) => RouteScreens(
    signIn: signIn,
    passwordReset: passwordReset,
    register: register,
    verifyEmail: verifyEmail,
    completeProfile: completeProfile,
    profile: profile,
    settings: settings,
    deleteAccount: deleteAccount,
    notificationSettings: notificationSettings,
    home: home ?? this.home,
    catalogue: catalogue ?? this.catalogue,
    issue: issue ?? this.issue,
    downloads: downloads ?? this.downloads,
    reader: reader ?? this.reader,
    library: library ?? this.library,
  );

  /// SCR-A-07 (MOD04-P2-T04).
  final ScreenBuilder? settings;

  /// SCR-A-08 (MOD03-P4-T01).
  final ScreenBuilder? deleteAccount;

  /// SCR-A-21 with SCR-A-20 (MOD11-P2-T02).
  final ScreenBuilder? notificationSettings;

  /// SCR-A-06 (MOD04-P2-T03).
  final ScreenBuilder? profile;

  /// SCR-A-05 (MOD04-P2-T01).
  final ScreenBuilder? completeProfile;

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
  final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );
  router = GoRouter(
    navigatorKey: root,
    refreshListenable: accessState,
    redirect: (BuildContext context, GoRouterState state) =>
        redirectFor(accessState.value, state.uri),
    errorBuilder: (BuildContext context, GoRouterState state) =>
        NotFoundScreen(onGoHome: () => router.go(AppRoutes.home)),
    routes: <RouteBase>[
      // The five tabs of the reader frames (READER_SCREEN_DESIGNS section 4,
      // PROPOSED). Each keeps its own history. A page opened from a tab
      // (an issue, the reader, an article, account deletion) covers the
      // tab bar, on the root navigator.
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell shell,
        ) => TabShell(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder:
                    screens.home ??
                    (BuildContext context, GoRouterState state) =>
                        const PlaceholderScreen(title: ShellText.home),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'issues/:issueId',
                    parentNavigatorKey: root,
                    builder:
                        screens.issue ??
                        (BuildContext context, GoRouterState state) =>
                            PlaceholderScreen(
                              title: ShellText.issue,
                              detail: state.pathParameters['issueId'],
                            ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'read',
                        parentNavigatorKey: root,
                        builder:
                            screens.reader ??
                            (BuildContext context, GoRouterState state) =>
                                PlaceholderScreen(
                                  title: ShellText.reader,
                                  detail: state.pathParameters['issueId'],
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.news,
                builder: (BuildContext context, GoRouterState state) =>
                    const PlaceholderScreen(title: ShellText.news),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':postId',
                    parentNavigatorKey: root,
                    builder: (BuildContext context, GoRouterState state) =>
                        PlaceholderScreen(
                          title: ShellText.newsArticle,
                          detail: state.pathParameters['postId'],
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              _route(AppRoutes.library, ShellText.library, screens.library),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              _route(
                AppRoutes.downloads,
                ShellText.downloads,
                screens.downloads,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                builder:
                    screens.settings ??
                    (BuildContext context, GoRouterState state) =>
                        const PlaceholderScreen(title: ShellText.settings),
                routes: <RouteBase>[
                  _route(
                    'delete-account',
                    ShellText.deleteAccount,
                    screens.deleteAccount,
                    parent: root,
                  ),
                  _route(
                    'notifications',
                    ShellText.notifications,
                    screens.notificationSettings,
                    parent: root,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _route(AppRoutes.catalogue, ShellText.catalogue, screens.catalogue),
      _route(AppRoutes.signIn, ShellText.signIn, screens.signIn),
      _route(
        AppRoutes.passwordReset,
        ShellText.passwordReset,
        screens.passwordReset,
      ),
      _route(AppRoutes.register, ShellText.register, screens.register),
      _route(AppRoutes.verifyEmail, ShellText.verifyEmail, screens.verifyEmail),
      _route(
        AppRoutes.completeProfile,
        ShellText.completeProfile,
        screens.completeProfile,
      ),
      _route(AppRoutes.profile, ShellText.profile, screens.profile),
    ],
  );
  return router;
}

GoRoute _placeholder(
  String path,
  String title, {
  GlobalKey<NavigatorState>? parent,
}) => GoRoute(
  path: path,
  parentNavigatorKey: parent,
  builder: (BuildContext context, GoRouterState state) =>
      PlaceholderScreen(title: title),
);

GoRoute _route(
  String path,
  String title,
  ScreenBuilder? screen, {
  GlobalKey<NavigatorState>? parent,
}) => screen == null
    ? _placeholder(path, title, parent: parent)
    : GoRoute(path: path, parentNavigatorKey: parent, builder: screen);
