import 'dart:typed_data';
import 'dart:ui' as ui;

/// Versions the harness was built with. A test compares them with pubspec.lock.
const String pdfrxVersion = '2.11.0';
const String pdfxVersion = '2.11.0';

/// The library names the LIBS define may hold.
const List<String> knownEngineNames = <String>['pdfrx', 'pdfx'];

/// One PDF library behind the same few calls, so the runner treats both alike.
abstract interface class PdfEngine {
  String get name;
  String get version;

  /// One-time setup the library needs before the first document.
  Future<void> initialize();

  /// Opens the file at [path]; throws if the library cannot.
  Future<EngineDocument> open(String path);
}

abstract interface class EngineDocument {
  /// Number of pages, counted from 1.
  int get pageCount;

  /// Renders page [pageNumber] (1-based) [widthPx] pixels wide, the height
  /// following the page shape, and turns the result into pixels Flutter can
  /// draw. Throws on any failure.
  Future<PageRender> render(int pageNumber, {required int widthPx});

  Future<void> close();
}

/// A rendered page. [renderMs] is the library's own work; [decodeMs] is the
/// step from the library's output to a Flutter image (a copy for pdfrx, a
/// JPEG decode for pdfx). The caller must call [dispose].
class PageRender {
  PageRender({
    required this.pageNumber,
    required this.width,
    required this.height,
    required this.renderMs,
    required this.decodeMs,
    required this.readRgba,
    required this.dispose,
    this.encodedBytes,
    this.image,
  });

  final int pageNumber;
  final int width;
  final int height;
  final double renderMs;
  final double decodeMs;

  /// Size of the library's encoded output, when it hands over an encoded image.
  final int? encodedBytes;

  /// The Flutter image, for showing on screen. Null in tests.
  final ui.Image? image;

  /// The raw pixels, for the blank-page check. Not part of any timing.
  final Future<Uint8List> Function() readRgba;
  final void Function() dispose;
}
