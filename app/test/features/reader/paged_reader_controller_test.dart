import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../../fakes/test_helpers.dart';

void main() {
  group('PagedReaderController [MOD-07]', () {
    test('implements ReaderController and keeps the mode it is given', () {
      final PagedReaderController controller = PagedReaderController(
        pageCount: 12,
        mode: ReaderMode.swipe,
      );
      addTearDown(controller.dispose);

      expect(controller, isA<ReaderController>());
      expect(controller.mode, ReaderMode.swipe);
    });

    test('pages are 1-based and start at page 1', () async {
      final PagedReaderController controller = PagedReaderController(
        pageCount: 12,
        mode: ReaderMode.pageTurn,
      );
      addTearDown(controller.dispose);

      expect(controller.currentPage, 1);
      expect(await controller.watchCurrentPage().first, 1);
    });

    test('a page outside the document is clamped to it', () async {
      final PagedReaderController controller = PagedReaderController(
        pageCount: 12,
        mode: ReaderMode.pageTurn,
        initialPage: 40,
      );
      addTearDown(controller.dispose);
      expect(controller.currentPage, 12);

      await controller.goToPage(0);
      expect(controller.currentPage, 1);
    });

    test('watchCurrentPage emits the page, then each change', () async {
      final PagedReaderController controller = PagedReaderController(
        pageCount: 12,
        mode: ReaderMode.pageTurn,
      );
      addTearDown(controller.dispose);
      final List<int> seen = recordEvents(controller.watchCurrentPage());

      await controller.goToPage(5);
      await controller.goToPage(5);
      await controller.goToPage(12);
      await settle();

      expect(seen, <int>[1, 5, 12]);
    });
  });
}
