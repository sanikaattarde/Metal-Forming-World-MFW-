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

/// The raw RGBA bytes of [image]. Read outside any timed section.
Future<Uint8List> readImageRgba(ui.Image image) async {
  final data = await image.toByteData();
  if (data == null) {
    throw StateError('the image has no pixel data');
  }
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
