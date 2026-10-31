import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Draws an issue's cover, filling the space it is given (RS FR-MAG-002).
///
/// A seam, so tests and previews draw covers without loading images.
abstract interface class IssueCoverSource {
  /// The cover of [issue].
  Widget buildCover(BuildContext context, IssueSummary issue);
}

/// Loads covers from their public addresses (TD-08: covers are public-read).
///
/// Only https addresses are loaded. No cover, an address that is not https,
/// a cover still loading and a cover that fails all show [CoverPlaceholder].
/// Covers are cached in memory only; no image package is approved.
final class NetworkCoverSource implements IssueCoverSource {
  /// Creates the source.
  const NetworkCoverSource();

  @override
  Widget buildCover(BuildContext context, IssueSummary issue) {
    final Uri? url = issue.coverImageUrl;
    if (url == null || url.scheme != 'https') {
      return const CoverPlaceholder();
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
          ? const CoverPlaceholder()
          : child,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => const CoverPlaceholder(),
    );
  }
}

/// Grey box shown in place of a cover. PLACEHOLDER: the M2 designs set it.
class CoverPlaceholder extends StatelessWidget {
  /// Creates the placeholder.
  const CoverPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.menu_book_outlined, color: colors.onSurfaceVariant),
      ),
    );
  }
}
