import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

/// Draws each page as a coloured A4-shaped card with its number, in place
/// of a real reader library (DEC-005).
final class NumberedPageSource implements ReaderPageSource {
  /// Creates the page source.
  const NumberedPageSource();

  static const List<Color> _colours = <Color>[
    Color(0xFFE3F2FD),
    Color(0xFFFFF3E0),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
  ];

  @override
  Widget buildPage(BuildContext context, PdfDocumentHandle document, int page) {
    return Center(
      child: AspectRatio(
        aspectRatio: 210 / 297,
        child: ColoredBox(
          color: _colours[(page - 1) % _colours.length],
          child: Center(
            child: Text('$page', style: const TextStyle(fontSize: 48)),
          ),
        ),
      ),
    );
  }
}
