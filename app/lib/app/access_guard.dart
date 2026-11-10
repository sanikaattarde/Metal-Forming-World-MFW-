import '../contracts/access_state.dart';
import 'routes.dart';

const Set<String> _stepRoutes = <String>{
  AppRoutes.signIn,
  AppRoutes.register,
  AppRoutes.verifyEmail,
  AppRoutes.completeProfile,
};

/// The route of the step that [state] is missing, or null for fullAccess
/// (RS FR-AUTH-010, FR-PROF-004, BR-001 to BR-003).
String? missingStepRoute(AccessState state) => switch (state) {
  AccessState.signedOut => AppRoutes.signIn,
  AccessState.emailUnverified => AppRoutes.verifyEmail,
  AccessState.profileIncomplete => AppRoutes.completeProfile,
  AccessState.fullAccess => null,
};

/// Whether [path] needs fullAccess (`API_AND_MODULE_CONTRACTS.md` sections
/// 4.1 and 6.1; the access column of `SCREEN_INVENTORY_AND_NAVIGATION.md`
/// section 5):
///
/// - the reader, which opens a full issue (SCR-A-14);
/// - the downloads screen, which lists kept copies (SCR-A-15). A kept copy
///   is hidden after sign-out on the working position of DEC-033 (OQ-11);
/// - the library, because bookmarks need fullAccess (SCR-A-16). Who may use
///   favourites is OQ-12, which may open it wider (SCR-A-17).
bool needsFullAccess(String path) {
  final String normal = _withoutTrailingSlash(path);
  if (normal == AppRoutes.downloads || normal == AppRoutes.library) {
    return true;
  }
  final List<String> segments = Uri(path: normal).pathSegments;
  return segments.length == 3 &&
      segments[0] == 'issues' &&
      segments[1].isNotEmpty &&
      segments[2] == 'read';
}

/// Whether [path] is one of the reader's own account pages, which need a
/// session but not fullAccess: the profile (SCR-A-06, MOD04-P2-T03) and
/// account deletion (SCR-A-08, MOD03-P4-T01).
bool needsSession(String path) {
  final String normal = _withoutTrailingSlash(path);
  return normal == AppRoutes.profile || normal == AppRoutes.deleteAccount;
}

/// The guard's decision for [location] in [state]: where to go instead, or
/// null to open it (DEC-014).
///
/// The guard is for the reader's experience only. The backend checks
/// access on every protected operation (DEC-009, NFR-SEC-007).
///
/// Rules, PROPOSED, from `SCREEN_INVENTORY_AND_NAVIGATION.md` section 3:
/// 1. A route that needs fullAccess sends a reader without it to the
///    missing step, keeping the route in `from` (FR-AUTH-010, FR-PROF-004).
/// 2. A step route that the reader no longer needs moves on to the next
///    missing step, or back to `from`, or home.
/// 3. A reader's own account page sends a visitor to sign in, keeping the
///    route in `from` (MOD04-P2-T03), except account deletion, which sends
///    a visitor home (MOD03-P4-T01).
/// 4. Every other route opens. An unknown one shows the not-found screen
///    (SCR-A-22).
String? redirectFor(AccessState state, Uri location) {
  final String path = _withoutTrailingSlash(location.path);
  final String? step = missingStepRoute(state);
  if (_stepRoutes.contains(path)) {
    final bool stillNeeded =
        path == step ||
        (state == AccessState.signedOut && path == AppRoutes.register);
    if (stillNeeded) {
      return null;
    }
    final String? from = _usableReturn(location.queryParameters['from']);
    return step == null ? from ?? AppRoutes.home : _withFrom(step, from);
  }
  if (step != null && needsFullAccess(path)) {
    return _withFrom(step, location.toString());
  }
  if (state == AccessState.signedOut && needsSession(path)) {
    // A visitor has no account to delete, and a reader whose account was
    // just deleted must not be sent back here after a new sign-in.
    return path == AppRoutes.deleteAccount
        ? AppRoutes.home
        : _withFrom(AppRoutes.signIn, location.toString());
  }
  return null;
}

/// [path] without trailing slashes, so `/library/` is guarded as `/library`
/// whether or not the router has already removed them (review of #62).
String _withoutTrailingSlash(String path) {
  String out = path;
  while (out.length > 1 && out.endsWith('/')) {
    out = out.substring(0, out.length - 1);
  }
  return out;
}

String _withFrom(String step, String? from) => from == null
    ? step
    : Uri(
        path: step,
        queryParameters: <String, String>{'from': from},
      ).toString();

/// Accepts only an in-app path that is not itself a step, so `from` can
/// never send the reader to another site.
String? _usableReturn(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  final Uri? uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) {
    return null;
  }
  return _stepRoutes.contains(uri.path) ? null : from;
}
