/// Public API of the catalogue and search (MOD-05).
///
/// Other modules use [CatalogueScreen] and [IssueDetailsScreen] over the
/// CatalogueRepository contract, and [applyQuery] for search and filters.
/// The home screen (T-04.3) and refresh (T-04.4) are not built yet.
library;

export 'domain/apply_query.dart';
export 'domain/catalogue_reads.dart';
export 'presentation/catalogue_failure_view.dart';
export 'presentation/catalogue_screen.dart';
export 'presentation/catalogue_text.dart';
export 'presentation/issue_cover_source.dart';
export 'presentation/issue_details_screen.dart';
export 'presentation/issue_tile.dart';
