import 'dart:ui' as ui;

import 'package:pdfx/pdfx.dart' as fx;

import 'engines.dart';
import 'pixels.dart';

/// pdfx: the platform's own renderer behind a platform channel. render()
/// gives an encoded image (JPEG here, the library default), which Flutter has
/// to decode. The page is fetched and closed on every render, as the library
/// asks (Android allows one open page at a time); getPage is counted as part
/// of the render time.
class PdfxEngine implements PdfEngine {
  @override
  String get name => 'pdfx';

  @override
  String get version => pdfxVersion;

  @override
  Future<void> initialize() async {
    if (!await fx.hasPdfSupport()) {
      throw StateError('pdfx reports that this platform has no PDF support');
    }
  }

  @override
  Future<EngineDocument> open(String path) async =>
      _PdfxDocument(await fx.PdfDocument.openFile(path));
}

class _PdfxDocument implements EngineDocument {
  _PdfxDocument(this._document);

  final fx.PdfDocument _document;

  @override
  int get pageCount => _document.pagesCount;

  @override
  Future<PageRender> render(int pageNumber, {required int widthPx}) async {
    final renderTimer = Stopwatch()..start();
    final page = await _document.getPage(pageNumber);
    try {
      final heightPx = (widthPx * page.height / page.width).round();
      final encoded = await page.render(
        width: widthPx.toDouble(),
        height: heightPx.toDouble(),
        format: fx.PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
      );
      renderTimer.stop();
      if (encoded == null) {
        throw StateError('pdfx returned no image for page $pageNumber');
      }

      final decodeTimer = Stopwatch()..start();
      final codec = await ui.instantiateImageCodec(encoded.bytes);
      final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      decodeTimer.stop();

      return PageRender(
        pageNumber: pageNumber,
        width: image.width,
        height: image.height,
        renderMs: renderTimer.elapsedMicroseconds / 1000,
        decodeMs: decodeTimer.elapsedMicroseconds / 1000,
        encodedBytes: encoded.bytes.length,
        image: image,
        readRgba: () => readImageRgba(image),
        dispose: image.dispose,
      );
    } finally {
      await page.close();
    }
  }

  @override
  Future<void> close() => _document.close();
}
