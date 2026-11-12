import 'package:mfw_app/contracts/contracts.dart';

import '../../../core/errors/failure_messages.dart';

/// User-facing text of the library screens and actions, kept together
/// (`CODING_STANDARDS.md` section 9). PLACEHOLDER wording from the reader
/// frames until M2.
abstract final class LibraryText {
  /// Title of SCR-A-16 and SCR-A-17.
  static const String title = 'Library';

  /// The bookmarks view (SCR-A-16).
  static const String bookmarks = 'Bookmarks';

  /// The favourites view (SCR-A-17).
  static const String favourites = 'Favourites';

  /// Spoken while the library loads.
  static const String loading = 'Loading your library';

  /// Heading with no bookmarks.
  static const String noBookmarksHeading = 'No bookmarks yet';

  /// Line with no bookmarks.
  static const String noBookmarksText =
      'Add one from the reader with the bookmark button.';

  /// Heading with no favourites.
  static const String noFavouritesHeading = 'No favourites yet';

  /// Line with no favourites.
  static const String noFavouritesText =
      'Mark an issue with the star on its page.';

  /// Removes a bookmark.
  static const String removeBookmark = 'Remove the bookmark';

  /// Bookmarks the page shown.
  static const String addBookmark = 'Bookmark this page';

  /// Removes the bookmark of the page shown.
  static const String pageBookmarked = 'Remove the bookmark of this page';

  /// Said after a bookmark is added.
  static const String bookmarkAdded = 'Bookmark added.';

  /// Said after a bookmark is removed.
  static const String bookmarkRemoved = 'Bookmark removed.';

  /// Marks an issue as a favourite.
  static const String addFavourite = 'Add to favourites';

  /// Unmarks a favourite.
  static const String removeFavourite = 'Remove from favourites';

  /// A bookmark's line, such as "Page 7".
  static String page(int page) => 'Page $page';

  /// What a screen reader says for a bookmark row.
  static String openBookmark(String title, int page) =>
      'Open $title at page $page';

  /// The text for [failure].
  static String failure(AppFailure failure) => messageFor(failure);

  /// The library read from the device (MOD08-P2-T04).
  static const String offline =
      'You are offline. These are your bookmarks and favourites on this '
      'device. Changes are sent when you are back online.';

  /// Changes made offline that the server has not had yet.
  static const String pending =
      'Some changes are waiting to be sent. They go when the connection '
      'returns.';
}
