/// MFW's WordPress site as the app reads it: CFG-03 (address) and CFG-04
/// (categories). Both are OPEN until MFW answers OQ-39.
final class WordPressSite {
  /// Creates the site. Throws [ArgumentError] for an address that is not
  /// https (RS INT-WP-001), an empty category list (INT-WP-003) or a page
  /// size outside 1 to 100.
  WordPressSite({
    required this.baseUrl,
    required List<String> categoryIds,
    this.perPage = 10,
    this.timeout = const Duration(seconds: 15),
  }) : categoryIds = List<String>.unmodifiable(categoryIds) {
    if (baseUrl.scheme != 'https' || baseUrl.host.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must be an https address');
    }
    if (categoryIds.isEmpty) {
      throw ArgumentError.value(
        categoryIds,
        'categoryIds',
        'must not be empty',
      );
    }
    if (perPage < 1 || perPage > 100) {
      throw ArgumentError.value(perPage, 'perPage', 'must be 1 to 100');
    }
  }

  /// The site address; a site in a sub-folder keeps its path.
  final Uri baseUrl;

  /// The news categories MFW selects, in display order (RS INT-WP-003).
  final List<String> categoryIds;

  /// Posts per page, kept small (RS INT-WP-004). PROPOSED: 10.
  final int perPage;

  /// How long one request may take before it is a `timeout`. PROPOSED.
  final Duration timeout;

  /// The REST address of [route] under `wp-json/wp/v2`, with [query].
  /// Each route part stays one path segment, so an ID cannot change the
  /// route.
  Uri endpoint(List<String> route, Map<String, String> query) =>
      baseUrl.replace(
        pathSegments: <String>[
          ...baseUrl.pathSegments.where((String segment) => segment.isNotEmpty),
          'wp-json',
          'wp',
          'v2',
          ...route,
        ],
        queryParameters: query,
      );
}
