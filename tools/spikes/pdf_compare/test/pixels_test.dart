import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_compare/src/pixels.dart';

Uint8List _solid(int pixels, {required int value}) =>
    Uint8List(pixels * 4)..fillRange(0, pixels * 4, value);

void main() {
  test('an all-white page has no non-white pixels [T-02.3]', () {
    expect(nonWhiteFraction(_solid(100, value: 255), stride: 1), 0);
  });

  test('an all-black page is entirely non-white [T-02.3]', () {
    expect(nonWhiteFraction(_solid(100, value: 0), stride: 1), 1);
  });

  test('half of the pixels dark gives one half [T-02.3]', () {
    final rgba = _solid(100, value: 255)..fillRange(0, 200, 0);
    expect(nonWhiteFraction(rgba, stride: 1), 0.5);
  });

  test('a stride samples every nth pixel only [T-02.3]', () {
    final rgba = _solid(100, value: 255);
    rgba.fillRange(4, 8, 0);
    expect(nonWhiteFraction(rgba, stride: 1), 0.01);
    expect(nonWhiteFraction(rgba, stride: 10), 0);
  });

  test('an empty buffer gives zero instead of dividing by zero [T-02.3]', () {
    expect(nonWhiteFraction(Uint8List(0)), 0);
  });

  group('compareRgba', () {
    test('equal buffers are identical with no differing pixel [FX-PDF-11]', () {
      final a = _solid(100, value: 7);
      final result = compareRgba(a, Uint8List.fromList(a));
      expect(result.sameLength, isTrue);
      expect(result.identical, isTrue);
      expect(result.differingPixels, 0);
      expect(result.totalPixels, 100);
      expect(result.maxChannelDifference, 0);
    });

    test(
      'one pixel that differs in one channel is counted once [FX-PDF-11]',
      () {
        final a = _solid(100, value: 100);
        final b = Uint8List.fromList(a)..[42 * 4 + 1] = 107;
        final result = compareRgba(a, b);
        expect(result.identical, isFalse);
        expect(result.differingPixels, 1);
        expect(result.differingFraction, 0.01);
        expect(result.maxChannelDifference, 7);
      },
    );

    test(
      'the largest difference over all channels is reported [FX-PDF-11]',
      () {
        final a = _solid(10, value: 200);
        final b = Uint8List.fromList(a)
          ..[0] = 190
          ..[5] = 255;
        expect(compareRgba(a, b).maxChannelDifference, 55);
        expect(compareRgba(a, b).differingPixels, 2);
      },
    );

    test('buffers of different lengths are not compared pixel by pixel [FX-PDF-11]', () {
      final result = compareRgba(_solid(10, value: 0), _solid(12, value: 0));
      expect(result.sameLength, isFalse);
      expect(result.identical, isFalse);
      expect(result.toJson(), <String, Object?>{
        'sameLength': false,
        'identical': false,
      });
    });

    test('two empty buffers are not called identical [FX-PDF-11]', () {
      final result = compareRgba(Uint8List(0), Uint8List(0));
      expect(result.identical, isFalse);
      expect(result.differingFraction, 0);
    });

    test(
      'toJson carries the counts of a same-length comparison [FX-PDF-11]',
      () {
        final a = _solid(4, value: 1);
        final b = Uint8List.fromList(a)..[0] = 3;
        expect(compareRgba(a, b).toJson(), <String, Object?>{
          'sameLength': true,
          'identical': false,
          'totalPixels': 4,
          'differingPixels': 1,
          'differingFraction': 0.25,
          'maxChannelDifference': 2,
        });
      },
    );
  });
}
