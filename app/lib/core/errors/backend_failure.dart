import '../../contracts/result.dart';

/// Turns a backend error into an [AppFailure] (MOD-02).
///
/// The backend reports a category and, for some errors, a reason
/// (`API_AND_BACKEND_CONTRACT.md` section 2.5, DEC-026). The mapping is the
/// table of `API_AND_MODULE_CONTRACTS.md` section 4.2, whose rows are
/// PROPOSED. It is transport-neutral: the data layer that calls the backend
/// reads the two names from the platform's error and passes them here.
///
/// - A reason with a row of its own maps to that row.
/// - A reason with no row maps to its category's code, and to
///   [FailureCode.unknown] where the category has none (R-1). That covers
///   `FAILED_PRECONDITION`, which has no code of its own.
/// - An unknown category maps to [FailureCode.unknown], not retryable.
/// - `GONE` maps to [FailureCode.notFound] and `RATE_LIMITED` to
///   [FailureCode.serviceUnavailable], retryable. Both are PROPOSED by
///   MOD02-P1-T01 for the review: section 4.2 left them open. The
///   retry-after value of `RATE_LIMITED` is not carried, because
///   [AppFailure] has no field for it (issue 28).
///
/// [AppFailure.detail] holds the two names only, never the backend's
/// message, so it carries no personal data. A name that is not an
/// upper-case identifier is written as `?`.
AppFailure failureFromBackend(String category, {String? reason}) {
  final String detail = reason == null
      ? 'backend ${_safe(category)}'
      : 'backend ${_safe(category)}/${_safe(reason)}';
  final _Row? byReason = reason == null ? null : _reasons[category]?[reason];
  final _Row? row = byReason ?? _categories[category];
  if (row == null) {
    return AppFailure(FailureCode.unknown, detail: detail);
  }
  return AppFailure(row.code, retryable: row.retryable, detail: detail);
}

final class _Row {
  const _Row(this.code, {this.retryable = false});

  final FailureCode code;
  final bool retryable;
}

const Map<String, _Row> _categories = <String, _Row>{
  'UNAUTHENTICATED': _Row(FailureCode.unauthenticated),
  'FORBIDDEN': _Row(FailureCode.forbidden),
  'NOT_FOUND': _Row(FailureCode.notFound),
  'INVALID_ARGUMENT': _Row(FailureCode.invalidInput),
  'CONFLICT': _Row(FailureCode.conflict),
  'UNAVAILABLE': _Row(FailureCode.serviceUnavailable, retryable: true),
  'INTERNAL': _Row(FailureCode.unknown, retryable: true),
  // PROPOSED by MOD02-P1-T01: section 4.2 left these two open.
  'GONE': _Row(FailureCode.notFound),
  'RATE_LIMITED': _Row(FailureCode.serviceUnavailable, retryable: true),
};

const Map<String, Map<String, _Row>> _reasons = <String, Map<String, _Row>>{
  'FAILED_PRECONDITION': <String, _Row>{
    'EMAIL_NOT_VERIFIED': _Row(FailureCode.emailNotVerified),
    'PROFILE_INCOMPLETE': _Row(FailureCode.profileIncomplete),
    'ACCOUNT_CLOSED': _Row(FailureCode.forbidden),
    'ALREADY_DELETING': _Row(FailureCode.forbidden),
    'ISSUE_NOT_AVAILABLE': _Row(FailureCode.notFound),
    'NO_CURRENT_FILE': _Row(FailureCode.notFound),
    'LAST_ADMIN': _Row(FailureCode.conflict),
    'RECENT_SIGN_IN_REQUIRED': _Row(FailureCode.unauthenticated),
  },
  'UNAVAILABLE': <String, _Row>{
    'DEADLINE_EXCEEDED': _Row(FailureCode.timeout, retryable: true),
  },
};

final RegExp _identifier = RegExp(r'^[A-Z][A-Z0-9_]{0,63}$');

String _safe(String name) => _identifier.hasMatch(name) ? name : '?';
