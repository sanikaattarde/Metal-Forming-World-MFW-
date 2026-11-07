/// The outcome of a repository or service call: [Ok] or [Err].
///
/// API_AND_MODULE_CONTRACTS section 4.2.
sealed class Result<T> {
  /// Base constructor for the two outcomes.
  const Result();
}

/// A successful outcome carrying [value].
final class Ok<T> extends Result<T> {
  /// Wraps [value].
  const Ok(this.value);

  /// The result of the call.
  final T value;
}

/// A failed outcome carrying [failure].
final class Err<T> extends Result<T> {
  /// Wraps [failure].
  const Err(this.failure);

  /// Why the call failed.
  final AppFailure failure;
}

/// Failure codes shared by every module.
///
/// The backend-code mapping is in API_AND_MODULE_CONTRACTS section 4.2.
/// [network], [insufficientStorage], [fileCorrupt], [invalidResponse] and
/// [cancelled] arise on the device.
enum FailureCode {
  /// Sign in to continue (backend `UNAUTHENTICATED`).
  unauthenticated,

  /// Verify your email address (`FAILED_PRECONDITION`, `EMAIL_NOT_VERIFIED`).
  emailNotVerified,

  /// Complete your profile (`FAILED_PRECONDITION`, `PROFILE_INCOMPLETE`).
  profileIncomplete,

  /// You do not have access (`FORBIDDEN`).
  forbidden,

  /// No longer available (`NOT_FOUND`).
  notFound,

  /// Check the highlighted fields (`INVALID_ARGUMENT`).
  invalidInput,

  /// File is larger than the limit, admin only (upload reason `OVER_LIMIT`).
  fileTooLarge,

  /// File is not a valid PDF, admin only (upload reason `NOT_A_PDF`).
  notAPdf,

  /// A file failed its integrity check or cannot be read (device).
  fileCorrupt,

  /// Not enough free space on the device.
  insufficientStorage,

  /// No connection, or the connection broke (device).
  network,

  /// Taking too long, try again (`UNAVAILABLE`, `DEADLINE_EXCEEDED`).
  timeout,

  /// Service unavailable, try again (`UNAVAILABLE`).
  serviceUnavailable,

  /// A response that cannot be parsed (device).
  invalidResponse,

  /// Already exists, or in use (`CONFLICT`).
  conflict,

  /// The user cancelled the action (device).
  cancelled,

  /// Something went wrong (`INTERNAL`, or anything not mapped).
  unknown,
}

/// A failure as the app sees it.
final class AppFailure {
  /// Creates a failure with [code]; not [retryable] unless stated.
  const AppFailure(this.code, {this.retryable = false, this.detail});

  /// What went wrong.
  final FailureCode code;

  /// Whether the user is offered a retry (CODING_STANDARDS section 6.1).
  final bool retryable;

  /// Diagnostic text for logs only. Never shown to users. Never contains personal data.
  final String? detail;
}
