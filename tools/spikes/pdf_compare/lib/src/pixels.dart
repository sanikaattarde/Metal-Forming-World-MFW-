import 'dart:typed_data';
import 'dart:ui' as ui;

/// The share of sampled pixels that are not pure white in an RGBA or BGRA
/// buffer. It tells a blank render from a drawn one; it is not an image
/// quality measure. Every [stride]th pixel is looked at.
double nonWhiteFraction(Uint8List rgba, {int stride = 11}) {
  final pixels = rgba.length ~/ 4;
  if (pixels == 0) {
    return 0;
  }
  var sampled = 0;
  var nonWhite = 0;
  for (var pixel = 0; pixel < pixels; pixel += stride) {
    final offset = pixel * 4;
    sampled++;
    if (rgba[offset] != 255 ||
        rgba[offset + 1] != 255 ||
        rgba[offset + 2] != 255) {
      nonWhite++;
    }
  }
  return nonWhite / sampled;
}

/// How two RGBA or BGRA buffers of the same size differ, pixel by pixel.
/// Buffers of different lengths are not compared ([sameLength] is false).
class PixelComparison {
  const PixelComparison({
    required this.sameLength,
    this.totalPixels = 0,
    this.differingPixels = 0,
    this.maxChannelDifference = 0,
  });

  final bool sameLength;
  final int totalPixels;

  /// Pixels in which at least one of the four channels differs.
  final int differingPixels;

  /// The largest absolute difference of any one channel (0 to 255).
  final int maxChannelDifference;

  /// True only for two non-empty buffers with every byte equal.
  bool get identical => sameLength && totalPixels > 0 && differingPixels == 0;

  double get differingFraction =>
      totalPixels == 0 ? 0 : differingPixels / totalPixels;

  Map<String, Object?> toJson() => sameLength
      ? <String, Object?>{
          'sameLength': true,
          'identical': identical,
          'totalPixels': totalPixels,
          'differingPixels': differingPixels,
          'differingFraction': (differingFraction * 1e6).round() / 1e6,
          'maxChannelDifference': maxChannelDifference,
        }
      : <String, Object?>{'sameLength': false, 'identical': false};
}

/// Compares [a] and [b] pixel by pixel, over every pixel (no sampling).
PixelComparison compareRgba(Uint8List a, Uint8List b) {
  if (a.length != b.length) {
    return const PixelComparison(sameLength: false);
  }
  final pixels = a.length ~/ 4;
  var differing = 0;
  var largest = 0;
  for (var pixel = 0; pixel < pixels; pixel++) {
    final offset = pixel * 4;
    var pixelLargest = 0;
    for (var channel = 0; channel < 4; channel++) {
      final difference = (a[offset + channel] - b[offset + channel]).abs();
      if (difference > pixelLargest) {
        pixelLargest = difference;
      }
    }
    if (pixelLargest > 0) {
      differing++;
      if (pixelLargest > largest) {
        largest = pixelLargest;
      }
    }
  }
  return PixelComparison(
    sameLength: true,
    totalPixels: pixels,
    differingPixels: differing,
    maxChannelDifference: largest,
  );
}

/// The raw RGBA bytes of [image]. Read outside any timed section.
Future<Uint8List> readImageRgba(ui.Image image) async {
  final data = await image.toByteData();
  if (data == null) {
    throw StateError('the image has no pixel data');
  }
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
