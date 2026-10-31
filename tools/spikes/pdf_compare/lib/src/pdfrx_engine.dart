import 'dart:ui' as ui;

import 'package:pdfrx/pdfrx.dart' as rx;

import 'engines.dart';
import 'pixels.dart';

/// pdfrx: PDFium through FFI. render() gives raw BGRA pixels, which Flutter
/// takes as an image without decoding a compressed format.
class PdfrxEngine implements PdfEngine {
  @override
  String get name => 'pdfrx';

  @override
  String get version => pdfrxVersion;

  @override
  Future<void> initialize() => rx.pdfrxFlutterInitialize();

  @override
  Future<EngineDocument> open(String path) async =>
      _PdfrxDocument(await rx.PdfDocument.openFile(path));
}

class _PdfrxDocument implements EngineDocument {
  _PdfrxDocument(this._document);

  final rx.PdfDocument _document;

  @override
  int get pageCount => _document.pages.length;

  @override
  Future<PageRender> render(int pageNumber, {required int widthPx}) async {
    final page = _document.pages[pageNumber - 1];
    final heightPx = (widthPx * page.height / page.width).round();

    final renderTimer = Stopwatch()..start();
    final raw = await page.render(
      fullWidth: widthPx.toDouble(),
      fullHeight: heightPx.toDouble(),
    );
    renderTimer.stop();
    if (raw == null) {
      throw StateError('pdfrx returned no image for page $pageNumber');
    }

    final decodeTimer = Stopwatch()..start();
    final ui.Image image;
    try {
      image = await raw.createImage();
    } finally {
      raw.dispose();
    }
    decodeTimer.stop();

    return PageRender(
      pageNumber: pageNumber,
      width: image.width,
      height: image.height,
      renderMs: renderTimer.elapsedMicroseconds / 1000,
      decodeMs: decodeTimer.elapsedMicroseconds / 1000,
      image: image,
      readRgba: () => readImageRgba(image),
      dispose: image.dispose,
    );
  }

  @override
  Future<void> close() => _document.dispose();
}
