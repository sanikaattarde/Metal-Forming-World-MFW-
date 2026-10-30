import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/access_guard.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// The redirect as (path, from), or null when the guard lets the route open.
(String, String?)? decoded(String? redirect) {
  if (redirect == null) {
    return null;
  }
  final Uri uri = Uri.parse(redirect);
  return (uri.path, uri.queryParameters['from']);
}

String? pathOf(String? redirect) =>
    redirect == null ? null : Uri.parse(redirect).path;

void main() {
  group('redirectFor [IC-01, FR-AUTH-010]', () {
    const String readerRoute = '/issues/fx-iss-01/read?page=3';
    const Map<AccessState, String?> missingStep = <AccessState, String?>{
      AccessState.signedOut: '/sign-in',
      AccessState.emailUnverified: '/verify-email',
      AccessState.profileIncomplete: '/complete-profile',
      AccessState.fullAccess: null,
    };

    for (final AccessState state in AccessState.values) {
      for (final String route in <String>[
        '/',
        '/issues/fx-iss-01',
        '/news',
        '/news/101',
        '/settings',
        '/downloads',
        '/no-such-page',
      ]) {
        test('$route opens for ${state.name}', () {
          expect(redirectFor(state, Uri.parse(route)), isNull);
        });
      }

      for (final String route in <String>[readerRoute, '/library']) {
        test('$route needs fullAccess; ${state.name} is sent to '
            '${missingStep[state] ?? 'no step'}', () {
          final String? step = missingStep[state];

          expect(
            decoded(redirectFor(state, Uri.parse(route))),
            step == null ? isNull : equals((step, route)),
          );
        });
      }
    }

    for (final (String route, AccessState state, String? expected)
        in <(String, AccessState, String?)>[
          ('/sign-in', AccessState.signedOut, null),
          ('/register', AccessState.signedOut, null),
          ('/sign-in', AccessState.emailUnverified, '/verify-email'),
          ('/register', AccessState.profileIncomplete, '/complete-profile'),
          ('/sign-in', AccessState.fullAccess, '/'),
          ('/verify-email', AccessState.signedOut, '/sign-in'),
          ('/verify-email', AccessState.emailUnverified, null),
          ('/verify-email', AccessState.profileIncomplete, '/complete-profile'),
          ('/verify-email', AccessState.fullAccess, '/'),
          ('/complete-profile', AccessState.signedOut, '/sign-in'),
          ('/complete-profile', AccessState.emailUnverified, '/verify-email'),
          ('/complete-profile', AccessState.profileIncomplete, null),
          ('/complete-profile', AccessState.fullAccess, '/'),
        ]) {
      test(
        'step $route for ${state.name} goes to ${expected ?? 'no redirect'}',
        () {
          expect(pathOf(redirectFor(state, Uri.parse(route))), expected);
        },
      );
    }

    test('the next step keeps the issue to return to [FR-PROF-004]', () {
      final Uri signIn = Uri(
        path: '/sign-in',
        queryParameters: <String, String>{'from': readerRoute},
      );

      expect(decoded(redirectFor(AccessState.emailUnverified, signIn)), (
        '/verify-email',
        readerRoute,
      ));
      expect(redirectFor(AccessState.fullAccess, signIn), readerRoute);
    });

    for (final String unsafe in <String>[
      'https://elsewhere.example/x',
      '//elsewhere.example/x',
      'issues/fx-iss-01/read',
      '/sign-in',
    ]) {
      test('an unusable return address "$unsafe" goes home instead', () {
        expect(
          redirectFor(
            AccessState.fullAccess,
            Uri(
              path: '/sign-in',
              queryParameters: <String, String>{'from': unsafe},
            ),
          ),
          '/',
        );
      });
    }
  });
}
