import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/reader/reader.dart';

void main() {
  group('Two-page layout [FR-READ-009, AC-2.4]', () {
    for (final (String device, Size size, ReaderLayout expected)
        in <(String, Size, ReaderLayout)>[
          ('phone in portrait', const Size(390, 844), ReaderLayout.singlePage),
          ('phone in landscape', const Size(844, 390), ReaderLayout.twoPages),
          ('tablet in portrait', const Size(800, 1280), ReaderLayout.twoPages),
          ('tablet in landscape', const Size(1280, 800), ReaderLayout.twoPages),
        ]) {
      test('a $device shows ${expected.name}', () {
        expect(layoutFor(size), expected);
      });
    }

    test('the tablet breakpoint is the shortest side of 600 (OQ-26)', () {
      expect(layoutFor(const Size(599, 900)), ReaderLayout.singlePage);
      expect(layoutFor(const Size(600, 900)), ReaderLayout.twoPages);
    });

    test('one page per view in the single-page layout', () {
      expect(spreadsFor(3, ReaderLayout.singlePage), <List<int>>[
        <int>[1],
        <int>[2],
        <int>[3],
      ]);
    });

    test('cover-alone pairing: the cover, then 2 and 3, 4 and 5', () {
      expect(spreadsFor(6, ReaderLayout.twoPages), <List<int>>[
        <int>[1],
        <int>[2, 3],
        <int>[4, 5],
        <int>[6],
      ]);
      expect(spreadsFor(5, ReaderLayout.twoPages), <List<int>>[
        <int>[1],
        <int>[2, 3],
        <int>[4, 5],
      ]);
    });

    test('the view index of a page follows the pairing', () {
      expect(
        <int>[
          1,
          2,
          3,
          4,
          5,
        ].map((int p) => viewIndexOf(p, ReaderLayout.twoPages)),
        <int>[0, 1, 1, 2, 2],
      );
      expect(viewIndexOf(4, ReaderLayout.singlePage), 3);
    });
  });
}
