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
}
