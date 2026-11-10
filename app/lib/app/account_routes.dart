import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../core/config/app_config.dart';
import '../features/account/account.dart';
import 'router.dart';
import 'routes.dart';

/// The account screens of MOD-03 and MOD-04 for the route table, over
/// [auth] and, when Firebase has started, [profiles]. Screens take their
/// dependencies through their constructors (DEC-013); navigation stays
/// here, in the shell.
RouteScreens accountScreens({
  required AuthService auth,
  AccountProfileRepository? profiles,
  AppConfig? config,
  LinkOpener? links,
}) {
  // CFG-07, shown where the reader accepts them (MOD04-P2-T02).
  final Widget? policyLinks = links == null
      ? null
      : PolicyLinks(
          privacyPolicy: config?.privacyPolicy,
          termsOfUse: config?.termsOfUse,
          opener: links,
        );
  return RouteScreens(
    signIn: (BuildContext context, GoRouterState state) => SignInScreen(
      auth: auth,
      onRegister: () => context.go(keepFrom(AppRoutes.register, state)),
      onForgotPassword: () =>
          context.go(keepFrom(AppRoutes.passwordReset, state)),
    ),
    passwordReset: (BuildContext context, GoRouterState state) =>
        PasswordResetScreen(
          auth: auth,
          onBackToSignIn: () => context.go(keepFrom(AppRoutes.signIn, state)),
        ),
    register: (BuildContext context, GoRouterState state) => RegisterScreen(
      auth: auth,
      profiles: profiles,
      policyLinks: policyLinks,
      onSignIn: () => context.go(keepFrom(AppRoutes.signIn, state)),
    ),
    verifyEmail: (BuildContext context, GoRouterState state) =>
        VerifyEmailScreen(auth: auth),
    completeProfile: profiles == null
        ? null
        : (BuildContext context, GoRouterState state) => CompleteProfileScreen(
            forms: profiles,
            profiles: profiles,
            consentLinks: policyLinks,
          ),
  );
}

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
