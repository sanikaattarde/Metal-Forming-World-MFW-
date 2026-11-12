/// User-facing text of SCR-A-18 and SCR-A-19. PLACEHOLDER wording from the
/// reader frames until M2.
abstract final class NewsText {
  /// The title of both screens.
  static const String title = 'News';

  /// The filter that shows every selected category.
  static const String all = 'All';

  /// What a screen reader says while the list loads.
  static const String loading = 'Loading the news';

  /// What a screen reader says while an article loads.
  static const String loadingArticle = 'Loading the article';

  /// The site cannot be reached and nothing is shown (FR-STATE-005).
  static const String unreachable =
      'The news site cannot be reached. Try again later.';

  /// The site cannot be reached and earlier articles are shown.
  static const String unreachableKept =
      'The news site cannot be reached. These are the articles loaded before.';

  /// Retry.
  static const String retry = 'Retry';

  /// Loads the next page.
  static const String more = 'Show more';

  /// An empty category.
  static const String emptyHeading = 'No news in this category yet';

  /// The line under [emptyHeading].
  static const String emptyText =
      'Choose another category, or come back later.';

  /// No posts at all.
  static const String noneHeading = 'No news yet';

  /// The line under [noneHeading].
  static const String noneText = 'Come back later for MFW news.';

  /// The label above a breaking post's title (OQ-17, PROVISIONAL).
  static const String breaking = 'Breaking';

  /// An article that is gone or not in the selected categories.
  static const String goneHeading = 'This article is not available';

  /// The line under [goneHeading].
  static const String goneText =
      'It may have been removed. Go back to the news.';

  /// The link that stands for an embedded player (OQ-16 media handling).
  static const String openMedia = 'Open the video or audio outside the app';

  /// What a screen reader says for a post's picture.
  static String pictureOf(String title) => 'Picture for $title';

  /// What a screen reader says for a link in an article.
  static const String openLink = 'Opens outside the app';

  /// When a link could not be opened.
  static const String linkFailed = 'The link could not be opened.';

  /// Back.
  static const String back = 'Back';

  /// The tooltip of a category filter.
  static String filterTooltip(String name, {required bool selected}) =>
      selected ? '$name, shown' : 'Show $name';
}
