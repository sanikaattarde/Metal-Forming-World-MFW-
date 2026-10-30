import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'fake_news_controls_service.dart';
import 'test_helpers.dart';

void main() {
  group('FakeNewsControlsService [IC-06]', () {
    test('implements NewsControlsService', () {
      expect(FakeNewsControlsService(), isA<NewsControlsService>());
    });

    test('a hidden post is in the next read, not in one taken before [FR-NEWS-008]', () async {
      final FakeNewsControlsService service = FakeNewsControlsService();

      final NewsControls before = valueOf(await service.getNewsControls());
      service.hidePost('101');
      final NewsControls after = valueOf(await service.getNewsControls());

      expect(before.hiddenPostIds, isEmpty);
      expect(after.hiddenPostIds, <String>{'101'});
    });

    test('breaking posts come back with the controls [FR-NEWS-009]', () async {
      final FakeNewsControlsService service = FakeNewsControlsService()
        ..markBreaking('102');

      expect(valueOf(await service.getNewsControls()).breakingPostIds, <String>{
        '102',
      });
    });

    test('a set failure is returned [OP-NWS-01]', () async {
      final FakeNewsControlsService service = FakeNewsControlsService()
        ..failure = const AppFailure(
          FailureCode.serviceUnavailable,
          retryable: true,
        );

      expect(
        failureCodeOf(await service.getNewsControls()),
        FailureCode.serviceUnavailable,
      );
    });
  });
}
