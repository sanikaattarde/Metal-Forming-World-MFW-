import 'package:mfw_app/contracts/contracts.dart';

/// A synthetic test persona (TEST_DATA_AND_FIXTURES section 5).
///
/// No real person and no password: the fakes never check passwords.
/// Addresses use the reserved domain example.com.
final class TestUser {
  /// Creates a persona.
  const TestUser({
    required this.fixtureId,
    required this.userId,
    required this.email,
    required this.method,
    required this.emailVerified,
    required this.profileComplete,
    required this.documentedAccessState,
  });

  /// The FX-USR ID.
  final String fixtureId;

  /// Opaque account ID used by the fakes.
  final String userId;

  /// Synthetic address.
  final String email;

  /// Sign-in method.
  final SignInMethod method;

  /// Whether the address is verified.
  final bool emailVerified;

  /// Whether the mandatory profile is complete.
  final bool profileComplete;

  /// The access state the fixture table gives this persona.
  final AccessState documentedAccessState;
}

/// FX-USR-01, reader A.
const TestUser fxUsr01 = TestUser(
  fixtureId: 'FX-USR-01',
  userId: 'fx-usr-01',
  email: 'fx-usr-01@example.com',
  method: SignInMethod.email,
  emailVerified: true,
  profileComplete: true,
  documentedAccessState: AccessState.fullAccess,
);

/// FX-USR-02, address not verified.
const TestUser fxUsr02 = TestUser(
  fixtureId: 'FX-USR-02',
  userId: 'fx-usr-02',
  email: 'fx-usr-02@example.com',
  method: SignInMethod.email,
  emailVerified: false,
  profileComplete: true,
  documentedAccessState: AccessState.emailUnverified,
);

/// FX-USR-03, profile incomplete (PROVISIONAL).
const TestUser fxUsr03 = TestUser(
  fixtureId: 'FX-USR-03',
  userId: 'fx-usr-03',
  email: 'fx-usr-03@example.com',
  method: SignInMethod.email,
  emailVerified: true,
  profileComplete: false,
  documentedAccessState: AccessState.profileIncomplete,
);

/// FX-USR-04, Google, profile complete (PROVISIONAL, C-04).
///
/// Whether a Google account can be unverified is OQ-04. It is treated as
/// verified here (ASSUMPTION), which gives the documented state.
const TestUser fxUsr04 = TestUser(
  fixtureId: 'FX-USR-04',
  userId: 'fx-usr-04',
  email: 'fx-usr-04@example.com',
  method: SignInMethod.google,
  emailVerified: true,
  profileComplete: true,
  documentedAccessState: AccessState.fullAccess,
);

/// FX-USR-05, Google, profile incomplete. Verified as for [fxUsr04].
const TestUser fxUsr05 = TestUser(
  fixtureId: 'FX-USR-05',
  userId: 'fx-usr-05',
  email: 'fx-usr-05@example.com',
  method: SignInMethod.google,
  emailVerified: true,
  profileComplete: false,
  documentedAccessState: AccessState.profileIncomplete,
);

/// FX-USR-06, reader B, for isolation tests.
const TestUser fxUsr06 = TestUser(
  fixtureId: 'FX-USR-06',
  userId: 'fx-usr-06',
  email: 'fx-usr-06@example.com',
  method: SignInMethod.email,
  emailVerified: true,
  profileComplete: true,
  documentedAccessState: AccessState.fullAccess,
);

/// FX-USR-07, the reader whose account is deleted.
const TestUser fxUsr07 = TestUser(
  fixtureId: 'FX-USR-07',
  userId: 'fx-usr-07',
  email: 'fx-usr-07@example.com',
  method: SignInMethod.email,
  emailVerified: true,
  profileComplete: true,
  documentedAccessState: AccessState.fullAccess,
);

/// Every reader persona with an account. FX-USR-09, the logged-out visitor,
/// is not an account: it is a device with nobody signed in.
const List<TestUser> readerPersonas = <TestUser>[
  fxUsr01,
  fxUsr02,
  fxUsr03,
  fxUsr04,
  fxUsr05,
  fxUsr06,
  fxUsr07,
];
