/// Where the news comes from (`DEPLOYMENT_PLAN.md` CFG-03, CFG-04).
///
/// The app holds no values yet: both rows are OPEN until MFW confirms them
/// in writing (OQ-39). The development read in `tool/` passes the working
/// position of 8 November 2026.
final class WordPressSiteConfig {
  /// Creates the configuration. [siteUri] must be an HTTPS address.
  WordPressSiteConfig({
    required this.siteUri,
    required List<String> categoryIds,
    this.pageSize = 10,
  }) : categoryIds = List<String>.unmodifiable(categoryIds) {
    if (!siteUri.isScheme('https')) {
      throw ArgumentError.value(siteUri, 'siteUri', 'Only HTTPS is allowed');
    }
    if (categoryIds.isEmpty) {
      throw ArgumentError.value(categoryIds, 'categoryIds', 'Empty');
    }
    if (pageSize < 1 || pageSize > 100) {
      throw RangeError.range(pageSize, 1, 100, 'pageSize');
    }
  }

  /// The site's address (CFG-03).
  final Uri siteUri;

  /// The WordPress category IDs the app shows, in the order shown (CFG-04,
  /// RS INT-WP-003).
  final List<String> categoryIds;

  /// Posts per page: small pages, so the site is not overloaded (RS
  /// INT-WP-004). WordPress allows at most 100.
  final int pageSize;
}
