import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

/// The text a [LabelledNewsImageSource] draws for a post: `image:<id>` for
/// a post with an image, `no-image:<id>` for one without.
String imageMarker(NewsPost post) =>
    '${post.imageUrl == null ? 'no-image' : 'image'}:${post.postId}';

/// Draws each news image as a grey box with a text marker, so a test can
/// see which images show without loading them. Also used by the preview.
final class LabelledNewsImageSource implements NewsImageSource {
  /// Creates the source.
  const LabelledNewsImageSource();

  @override
  Widget buildImage(BuildContext context, NewsPost post) => ColoredBox(
    color: const Color(0xFFE0E0E0),
    child: Center(
      child: Text(
        imageMarker(post),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 6),
      ),
    ),
  );
}
