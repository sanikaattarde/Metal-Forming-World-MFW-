import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

void main() {
  group('CatalogueText', () {
    test('a publication date reads as day, month name and year '
        '[FR-MAG-002]', () {
      expect(CatalogueText.date(DateTime.utc(2026, 10, 1)), '1 October 2026');
      expect(CatalogueText.date(DateTime.utc(2025, 1, 31)), '31 January 2025');
      expect(CatalogueText.date(DateTime.utc(2025, 12, 9)), '9 December 2025');
    });

    test('no connection says so [FR-STATE-003]', () {
      expect(
        CatalogueText.failure(const AppFailure(FailureCode.network)),
        CatalogueText.offline,
      );
    });

    test('an unpublished issue is no longer available [OP-CAT-02]', () {
      expect(
        CatalogueText.failure(const AppFailure(FailureCode.notFound)),
        CatalogueText.notAvailable,
      );
    });

    test('other failures share one message', () {
      for (final FailureCode code in <FailureCode>[
        FailureCode.serviceUnavailable,
        FailureCode.timeout,
        FailureCode.invalidResponse,
        FailureCode.unknown,
      ]) {
        expect(
          CatalogueText.failure(AppFailure(code)),
          CatalogueText.failed,
          reason: code.name,
        );
      }
    });
  });
}
