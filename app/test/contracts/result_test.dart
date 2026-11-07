import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

String summarise(Result<int> result) => switch (result) {
  Ok<int>(:final int value) => 'ok $value',
  Err<int>(:final AppFailure failure) => 'err ${failure.code.name}',
};

void main() {
  test('Ok carries a value and Err carries an AppFailure [MOD-00]', () {
    expect(summarise(const Ok<int>(3)), 'ok 3');
    expect(
      summarise(const Err<int>(AppFailure(FailureCode.network))),
      'err network',
    );
  });

  test(
    'an AppFailure is not retryable and has no detail unless set [MOD-00]',
    () {
      const AppFailure plain = AppFailure(FailureCode.timeout);
      const AppFailure retryable = AppFailure(
        FailureCode.timeout,
        retryable: true,
        detail: 'synthetic diagnostic',
      );

      expect(plain.retryable, isFalse);
      expect(plain.detail, isNull);
      expect(retryable.retryable, isTrue);
      expect(retryable.detail, 'synthetic diagnostic');
    },
  );

  test(
    'FailureCode has exactly the seventeen documented codes, in order [MOD-00]',
    () {
      expect(
        FailureCode.values.map((FailureCode code) => code.name).toList(),
        <String>[
          'unauthenticated',
          'emailNotVerified',
          'profileIncomplete',
          'forbidden',
          'notFound',
          'invalidInput',
          'fileTooLarge',
          'notAPdf',
          'fileCorrupt',
          'insufficientStorage',
          'network',
          'timeout',
          'serviceUnavailable',
          'invalidResponse',
          'conflict',
          'cancelled',
          'unknown',
        ],
      );
    },
  );
}
