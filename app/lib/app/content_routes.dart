import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../features/catalogue/catalogue.dart';
import 'access_guard.dart';
import 'router.dart';
import 'routes.dart';

/// [base] with the reader-side screens of MOD-05 to MOD-10 that have their
/// services. A screen whose service is null stays a placeholder.
/// Navigation stays here, in the shell (DEC-013).
RouteScreens withContentScreens(
  RouteScreens base, {
  required ValueListenable<AccessState> accessState,
  CatalogueRepository? catalogue,
}) {
  if (catalogue == null) {
    return base;
  }
  return base.withContent(
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
