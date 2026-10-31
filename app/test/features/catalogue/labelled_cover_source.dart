import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

/// The text a [LabelledCoverSource] draws for [issueId].
String coverMarker(String issueId) => 'cover:$issueId';

/// Draws each cover as a grey box with a text marker, so a test can see
/// which covers show without loading an image. Also used by the preview.
final class LabelledCoverSource implements IssueCoverSource {
  /// Creates the source.
  const LabelledCoverSource();

  @override
  Widget buildCover(BuildContext context, IssueSummary issue) => ColoredBox(
    color: const Color(0xFFE0E0E0),
    child: Center(
      child: Text(
        coverMarker(issue.issueId),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 6),
      ),
    ),
  );
}
