import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/presentation/catalogue_text.dart';
import 'package:mfw_app/features/catalogue/presentation/issue_cover_source.dart';

/// One issue in the catalogue: cover, title, date, category and description
/// (RS FR-MAG-002, FR-MAG-003). Read as one item by screen readers.
class IssueTile extends StatelessWidget {
  /// Creates the tile, keyed by the issue ID.
  IssueTile({
    required this.issue,
    required this.categoryName,
    required this.covers,
    this.onTap,
  }) : super(key: ValueKey<String>(issue.issueId));

  /// The issue shown.
  final IssueSummary issue;

  /// The category name, or null when the category is unknown.
  final String? categoryName;

  /// Draws the cover.
  final IssueCoverSource covers;

  /// Opens the issue details.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String? category = categoryName;
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 64,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ExcludeSemantics(
                    child: covers.buildCover(context, issue),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      issue.title,
                      style: text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      CatalogueText.date(issue.publicationDate),
                      style: text.bodySmall,
                    ),
                    if (category != null) Text(category, style: text.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      issue.description,
                      style: text.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
