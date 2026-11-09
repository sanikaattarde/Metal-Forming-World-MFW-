import '../../contracts/result.dart';

/// The text shown to a reader for [failure] (MOD-02,
/// `API_AND_MODULE_CONTRACTS.md` section 6.2).
///
/// Every [FailureCode] has a message: the switch is exhaustive, so a new
/// code does not compile until it has one. The wording is a placeholder,
/// taken from the "User-facing meaning" column of section 4.2 where it has
/// one, until the M2 designs set it. [AppFailure.detail] and exception text
/// are never shown (`CODING_STANDARDS.md` section 6.1, rule 2). A retry
/// action for a retryable failure is the screen's job (rule 4), so no
/// message tells the reader to try again unless the table does.
String messageFor(AppFailure failure) => switch (failure.code) {
  FailureCode.unauthenticated => 'Sign in to continue.',
  FailureCode.emailNotVerified => 'Verify your email address to continue.',
  FailureCode.profileIncomplete => 'Complete your profile to continue.',
  FailureCode.forbidden => 'You do not have access.',
  FailureCode.notFound => 'This is no longer available.',
  FailureCode.invalidInput => 'Check the highlighted fields.',
  FailureCode.fileTooLarge => 'The file is larger than the limit.',
  FailureCode.notAPdf => 'The file is not a valid PDF.',
  FailureCode.fileCorrupt => 'This file cannot be opened. Download it again.',
  FailureCode.insufficientStorage =>
    'There is not enough free space on this device.',
  FailureCode.network => 'No connection. Check your connection.',
  FailureCode.timeout => 'This is taking too long. Try again.',
  FailureCode.serviceUnavailable => 'The service is unavailable. Try again.',
  FailureCode.invalidResponse => 'Something went wrong.',
  FailureCode.conflict =>
    'This already exists, or it changed since it was opened.',
  FailureCode.cancelled => 'Cancelled.',
  FailureCode.unknown => 'Something went wrong.',
};
