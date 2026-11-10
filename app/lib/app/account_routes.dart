import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../features/account/account.dart';
import 'router.dart';
import 'routes.dart';

/// The account screens of MOD-03 and MOD-04 for the route table, over
/// [auth]. Screens take their dependencies through their constructors
/// (DEC-013); navigation stays here, in the shell.
RouteScreens accountScreens({required AuthService auth}) => RouteScreens(
  register: (BuildContext context, GoRouterState state) => RegisterScreen(
    auth: auth,
    onSignIn: () => context.go(keepFrom(AppRoutes.signIn, state)),
  ),
  verifyEmail: (BuildContext context, GoRouterState state) =>
      VerifyEmailScreen(auth: auth),
);

/// [path] with the `from` of [state] kept, so that moving between the
/// sign-in steps still returns the reader where they were going.
String keepFrom(String path, GoRouterState state) {
  final String? from = state.uri.queryParameters['from'];
  return from == null
      ? path
      : Uri(
          path: path,
          queryParameters: <String, String>{'from': from},
        ).toString();
}
