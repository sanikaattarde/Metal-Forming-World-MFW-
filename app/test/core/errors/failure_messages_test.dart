import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/errors/failure_messages.dart';

void main() {
  group('messageFor', () {
    test('gives every failure code a message [MOD02-P1-T01]', () {
      for (final FailureCode code in FailureCode.values) {
        expect(messageFor(AppFailure(code)), isNotEmpty, reason: code.name);
      }
    });

    test('never shows the diagnostic detail [SC-16]', () {
      for (final FailureCode code in FailureCode.values) {
        final String message = messageFor(
          AppFailure(code, detail: 'diagnostic-detail-text'),
        );
        expect(message, isNot(contains('diagnostic')), reason: code.name);
      }
    });

    test('does not depend on the retryable flag', () {
      for (final FailureCode code in FailureCode.values) {
        expect(
          messageFor(AppFailure(code, retryable: true)),
          messageFor(AppFailure(code)),
          reason: code.name,
        );
      }
    });

    test('uses the meanings of the section 4.2 table', () {
      expect(
        messageFor(const AppFailure(FailureCode.unauthenticated)),
        'Sign in to continue.',
      );
      expect(
        messageFor(const AppFailure(FailureCode.forbidden)),
        'You do not have access.',
      );
      expect(
        messageFor(const AppFailure(FailureCode.invalidInput)),
        'Check the highlighted fields.',
      );
    });
  });
}
