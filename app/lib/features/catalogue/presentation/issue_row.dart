import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/ui/content_widgets.dart';
import 'catalogue_text.dart';

/// One issue in a list: its cover, title, category and date (RS
/// FR-MAG-002, FR-MAG-003). Tapping it opens the issue.
class IssueRow extends StatelessWidget {
  /// Creates the row.
  const IssueRow({
    required this.issue,
    required this.categoryName,
    required this.onOpen,
    super.key,
  });

  /// The issue.
  final IssueSummary issue;

  /// The name of the issue's category.
  final String categoryName;

  /// Opens the issue.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MfwSpace.sm),
          child: Row(
            children: <Widget>[
              CoverImage(
                url: issue.coverImageUrl,
                semanticLabel: CatalogueText.coverOf(issue.title),
                width: 54,
              ),
              const SizedBox(width: MfwSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(issue.title, style: MfwType.h5),
                    const SizedBox(height: MfwSpace.xs),
                    Text(
                      CatalogueText.listMeta(
                        categoryName,
                        issue.publicationDate,
                      ),
                      style: MfwType.small,
                    ),
                    if (issue.description.isNotEmpty) ...<Widget>[
                      const SizedBox(height: MfwSpace.xs),
                      Text(
                        issue.description,
                        style: MfwType.small,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

/// The name of [categoryId] in [categories], or the identifier itself when
/// the category is not listed.
String categoryNameOf(String categoryId, List<IssueCategory> categories) {
  for (final IssueCategory category in categories) {
    if (category.categoryId == categoryId) {
      return category.name;
    }
  }
  return categoryId;
}
