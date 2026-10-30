import 'package:mfw_app/contracts/contracts.dart';

/// Route of SCR-A-01, the sign-in step.
const String signInRoute = '/sign-in';

/// Route of SCR-A-02, the alternative to [signInRoute] for a visitor.
const String registerRoute = '/register';

/// Route of SCR-A-03, the verification step.
const String verifyEmailRoute = '/verify-email';

/// Route of SCR-A-05, the profile step.
const String completeProfileRoute = '/complete-profile';

const Set<String> _stepRoutes = <String>{
  signInRoute,
  registerRoute,
  verifyEmailRoute,
  completeProfileRoute,
};

/// The route of the step that [state] is missing, or null for fullAccess.
String? missingStepRoute(AccessState state) => switch (state) {
  AccessState.signedOut => signInRoute,
  AccessState.emailUnverified => verifyEmailRoute,
  AccessState.profileIncomplete => completeProfileRoute,
  AccessState.fullAccess => null,
};

/// Whether [path] needs fullAccess: opening a full issue, and the library,
/// because bookmarking needs it (API_AND_MODULE_CONTRACTS section 4.1;
/// SCREEN_INVENTORY_AND_NAVIGATION SCR-A-14 and SCR-A-16).
///
/// Who may use favourites is OQ-12, which may open the library wider.
/// `/downloads` is not guarded: its behaviour after sign-out is OQ-11.
bool needsFullAccess(String path) {
  if (path == '/library') {
    return true;
  }
  final List<String> segments = Uri(path: path).pathSegments;
  return segments.length == 3 &&
      segments[0] == 'issues' &&
      segments[2] == 'read';
}

/// The guard's decision for [location] in [state]: where to go instead, or
/// null to open it. User experience only; the server enforces access
/// (DEC-009).
///
/// PROPOSED rules, from SCREEN_INVENTORY_AND_NAVIGATION section 3:
/// 1. A route that needs fullAccess sends a reader without it to the
///    missing step, keeping the route in `from` (FR-AUTH-010, FR-PROF-004).
/// 2. A step route that the reader no longer needs moves on to the next
///    missing step, or back to `from`, or home.
/// 3. Every other route opens; an unknown one shows the not-found screen.
String? redirectFor(AccessState state, Uri location) {
  final String path = location.path;
  final String? step = missingStepRoute(state);
  if (_stepRoutes.contains(path)) {
    final bool stillNeeded =
        path == step ||
        (state == AccessState.signedOut && path == registerRoute);
    if (stillNeeded) {
      return null;
    }
    final String? from = _usableReturn(location.queryParameters['from']);
    return step == null ? from ?? '/' : _withFrom(step, from);
  }
  if (step != null && needsFullAccess(path)) {
    return _withFrom(step, location.toString());
  }
  return null;
}

String _withFrom(String step, String? from) => from == null
    ? step
    : Uri(
        path: step,
        queryParameters: <String, String>{'from': from},
      ).toString();

/// Accepts only an in-app path that is not itself a step.
String? _usableReturn(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  return _stepRoutes.contains(Uri.parse(from).path) ? null : from;
}
