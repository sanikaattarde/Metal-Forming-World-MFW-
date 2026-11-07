/// Access state of the current user, derived from RS §3.2 and §9.2.
///
/// States are evaluated in the order listed: the first one that applies is
/// the state. Whether [emailUnverified] can apply to a Google account is
/// OQ-04. API_AND_MODULE_CONTRACTS section 4.1.
enum AccessState {
  /// Logged-out visitor.
  signedOut,

  /// Email account whose address is not verified (RS BR-002).
  emailUnverified,

  /// Mandatory profile not complete (RS BR-003, PROVISIONAL).
  profileIncomplete,

  /// May open and download full issues.
  fullAccess,
}
