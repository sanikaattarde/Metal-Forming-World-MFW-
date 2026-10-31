import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Draws a post's featured image, filling the space it is given
/// (RS FR-NEWS-001).
///
/// A seam, so tests and previews draw images without loading them.
abstract interface class NewsImageSource {
  /// The image of [post].
  Widget buildImage(BuildContext context, NewsPost post);
}

/// Loads featured images from the WordPress site.
///
/// Only https addresses are loaded. No image, an address that is not
/// https, an image still loading and one that fails all show
/// [NewsImagePlaceholder]. Images are cached in memory only; no image
/// package is approved.
final class NetworkNewsImageSource implements NewsImageSource {
  /// Creates the source.
  const NetworkNewsImageSource();

  @override
  Widget buildImage(BuildContext context, NewsPost post) {
    final Uri? url = post.imageUrl;
    if (url == null || url.scheme != 'https') {
      return const NewsImagePlaceholder();
    }
    return Image.network(
      url.toString(),
      fit: BoxFit.cover,
      frameBuilder:
          (
            BuildContext context,
            Widget child,
            int? frame,
            bool wasSynchronouslyLoaded,
          ) => frame == null && !wasSynchronouslyLoaded
          ? const NewsImagePlaceholder()
          : child,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => const NewsImagePlaceholder(),
    );
  }
}

/// Grey box shown in place of an image. PLACEHOLDER: the M2 designs set it.
class NewsImagePlaceholder extends StatelessWidget {
  /// Creates the placeholder.
  const NewsImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.article_outlined, color: colors.onSurfaceVariant),
      ),
    );
  }
}
