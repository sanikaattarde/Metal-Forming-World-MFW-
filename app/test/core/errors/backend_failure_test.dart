import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/errors/backend_failure.dart';

typedef _Case = (String category, String? reason, FailureCode code, bool retry);

void main() {
  group('failureFromBackend follows API_AND_MODULE_CONTRACTS section 4.2', () {
    const List<_Case> table = <_Case>[
      ('UNAUTHENTICATED', null, FailureCode.unauthenticated, false),
      (
        'FAILED_PRECONDITION',
        'EMAIL_NOT_VERIFIED',
        FailureCode.emailNotVerified,
        false,
      ),
      (
        'FAILED_PRECONDITION',
        'PROFILE_INCOMPLETE',
        FailureCode.profileIncomplete,
        false,
      ),
      ('FAILED_PRECONDITION', 'ACCOUNT_CLOSED', FailureCode.forbidden, false),
      ('FAILED_PRECONDITION', 'ALREADY_DELETING', FailureCode.forbidden, false),
      (
        'FAILED_PRECONDITION',
        'ISSUE_NOT_AVAILABLE',
        FailureCode.notFound,
        false,
      ),
      ('FAILED_PRECONDITION', 'NO_CURRENT_FILE', FailureCode.notFound, false),
      ('FAILED_PRECONDITION', 'LAST_ADMIN', FailureCode.conflict, false),
      (
        'FAILED_PRECONDITION',
        'RECENT_SIGN_IN_REQUIRED',
        FailureCode.unauthenticated,
        false,
      ),
      ('FORBIDDEN', null, FailureCode.forbidden, false),
      ('NOT_FOUND', null, FailureCode.notFound, false),
      ('INVALID_ARGUMENT', null, FailureCode.invalidInput, false),
      ('CONFLICT', null, FailureCode.conflict, false),
      ('UNAVAILABLE', null, FailureCode.serviceUnavailable, true),
      ('UNAVAILABLE', 'DEADLINE_EXCEEDED', FailureCode.timeout, true),
      ('INTERNAL', null, FailureCode.unknown, true),
    ];

    for (final _Case c in table) {
      test('${c.$1} ${c.$2 ?? ''} maps to ${c.$3.name}', () {
        final AppFailure f = failureFromBackend(c.$1, reason: c.$2);
        expect(f.code, c.$3);
        expect(f.retryable, c.$4);
      });
    }
  });

  group('failureFromBackend for what the table does not list', () {
    test('a reason with no row takes its category code (R-1)', () {
      final AppFailure f = failureFromBackend('CONFLICT', reason: 'IN_USE');
      expect(f.code, FailureCode.conflict);
      expect(f.retryable, isFalse);
    });

    test('FAILED_PRECONDITION with an unknown reason is unknown (R-1)', () {
      final AppFailure f = failureFromBackend(
        'FAILED_PRECONDITION',
        reason: 'NEW_REASON',
      );
      expect(f.code, FailureCode.unknown);
      expect(f.retryable, isFalse);
    });

    test('an unknown category is unknown and not retryable', () {
      final AppFailure f = failureFromBackend('SOMETHING_NEW');
      expect(f.code, FailureCode.unknown);
      expect(f.retryable, isFalse);
    });

    test('GONE is notFound, not retryable (PROPOSED)', () {
      final AppFailure f = failureFromBackend('GONE');
      expect(f.code, FailureCode.notFound);
      expect(f.retryable, isFalse);
    });

    test('RATE_LIMITED is serviceUnavailable, retryable (PROPOSED)', () {
      final AppFailure f = failureFromBackend('RATE_LIMITED');
      expect(f.code, FailureCode.serviceUnavailable);
      expect(f.retryable, isTrue);
    });
  });

  group('failureFromBackend detail', () {
    test('holds the category and reason names only', () {
      expect(
        failureFromBackend('FAILED_PRECONDITION', reason: 'LAST_ADMIN').detail,
        'backend FAILED_PRECONDITION/LAST_ADMIN',
      );
      expect(failureFromBackend('NOT_FOUND').detail, 'backend NOT_FOUND');
    });

    test('writes a name that is not an identifier as ? [SC-16]', () {
      final AppFailure f = failureFromBackend(
        'reader@example.test',
        reason: 'no such user 42',
      );
      expect(f.detail, 'backend ?/?');
      expect(f.code, FailureCode.unknown);
    });
  });
}
