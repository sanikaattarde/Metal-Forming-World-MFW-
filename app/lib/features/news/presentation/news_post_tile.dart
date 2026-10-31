import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/presentation/news_image_source.dart';
import 'package:mfw_app/features/news/presentation/news_text.dart';

/// One post in the news list: image, title, date and category
/// (RS FR-NEWS-001). Read as one item by screen readers.
class NewsPostTile extends StatelessWidget {
  /// Creates the tile, keyed by the post ID.
  NewsPostTile({
    required this.post,
    required this.categoryLabel,
    required this.images,
    this.onTap,
  }) : super(key: ValueKey<String>(post.postId));

  /// The post shown.
  final NewsPost post;

  /// The post's category names, or null when none is known.
  final String? categoryLabel;

  /// Draws the image.
  final NewsImageSource images;

  /// Opens the article.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String? category = categoryLabel;
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 88,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ExcludeSemantics(
                    child: images.buildImage(context, post),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.title,
                      style: text.titleMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      NewsText.date(post.publishedAt.toLocal()),
                      style: text.bodySmall,
                    ),
                    if (category != null) Text(category, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
