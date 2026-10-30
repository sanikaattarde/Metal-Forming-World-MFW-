import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/access_guard.dart';
import 'package:mfw_app/app/placeholder_screens.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Builds the route table of API_AND_MODULE_CONTRACTS section 6.1
/// (PROPOSED) with placeholder screens, guarded by [redirectFor] on the
/// latest [accessState]. The router checks again whenever it changes.
GoRouter buildRouter(ValueListenable<AccessState> accessState) => GoRouter(
  refreshListenable: accessState,
  redirect: (BuildContext context, GoRouterState state) =>
      redirectFor(accessState.value, state.uri),
  errorBuilder: (BuildContext context, GoRouterState state) =>
      const NotFoundScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderShellScreen(),
    ),
    GoRoute(
      path: '/issues/:issueId',
      builder: (BuildContext context, GoRouterState state) => PlaceholderScreen(
        title: ShellText.issueDetails,
        detail: state.pathParameters['issueId'],
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'read',
          builder: (BuildContext context, GoRouterState state) =>
              PlaceholderScreen(
                title: ShellText.reader,
                detail: ShellText.readerPlaceholder(
                  state.pathParameters['issueId'] ?? '',
                  state.uri.queryParameters['page'] ?? '1',
                ),
              ),
        ),
      ],
    ),
    GoRoute(
      path: '/downloads',
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.downloads),
    ),
    GoRoute(
      path: '/library',
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.library),
    ),
    GoRoute(
      path: '/news',
      builder: (BuildContext context, GoRouterState state) =>
          const PlaceholderScreen(title: ShellText.news),
      routes: <RouteBase>[
        GoRoute(
          path: ':postId',
          builder: (BuildContext context, GoRouterState state) =>
              PlaceholderScreen(
                title: ShellText.article,
                detail: state.pathParameters['postId'],
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
