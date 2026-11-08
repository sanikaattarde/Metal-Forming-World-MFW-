import 'package:flutter/foundation.dart';

// T-02.1 low-fi prototype: the state that the prototype controls change.
// Every value is made up. No MFW content is used (DEC-024).

/// The access states of SCREEN_INVENTORY_AND_NAVIGATION section 3.
enum Access {
  /// A logged-out visitor.
  signedOut('Signed out'),

  /// An email account whose address is not verified.
  emailUnverified('Email not verified'),

  /// The mandatory profile is not complete (PROVISIONAL).
  profileIncomplete('Profile incomplete'),

  /// May open and download full issues.
  fullAccess('Full access');

  const Access(this.label);

  /// The name shown in the prototype controls.
  final String label;
}

/// What a screen that fetches content shows (section 7).
enum Content {
  /// The normal view.
  normal('Normal'),

  /// FR-STATE-001.
  loading('Loading'),

  /// FR-STATE-002.
  empty('Empty');

  const Content(this.label);

  /// The name shown in the prototype controls.
  final String label;
}

/// How the next download ends (SCR-A-13).
enum DownloadOutcome {
  /// The download completes.
  completes('Completes'),

  /// The connection breaks at about half, and Resume continues (AC-4.3).
  breaks('Connection breaks'),

  /// The file does not pass its check (FR-READ-010).
  corrupt('Fails its check');

  const DownloadOutcome(this.label);

  /// The name shown in the prototype controls.
  final String label;
}

/// A made-up issue.
@immutable
class Issue {
  /// Creates an issue.
  const Issue(this.id, this.title, this.category, this.pages, this.sizeMb);

  /// The issue ID.
  final String id;

  /// The title, a placeholder.
  final String title;

  /// The category, a placeholder.
  final String category;

  /// The page count.
  final int pages;

  /// The file size in MB.
  final double sizeMb;
}

/// A made-up news article.
@immutable
class Article {
  /// Creates an article.
  const Article(this.id, this.title, this.category, {this.breaking = false});

  /// The article ID.
  final String id;

  /// The title, a placeholder.
  final String title;

  /// The category, a placeholder.
  final String category;

  /// Marked as breaking news by an admin (FR-NEWS-009, OQ-17).
  final bool breaking;
}

/// Made-up issues.
const List<Issue> sampleIssues = <Issue>[
  Issue('i12', 'Sample issue 12', 'Category A', 64, 48.2),
  Issue('i11', 'Sample issue 11', 'Category B', 72, 61.0),
  Issue('i10', 'Sample issue 10', 'Category A', 56, 39.5),
  Issue('i09', 'Sample issue 09', 'Category C', 120, 142.7),
  Issue('i08', 'Sample issue 08', 'Category B', 48, 33.1),
  Issue('i07', 'Sample issue 07', 'Category C', 60, 44.9),
];

/// Made-up news categories, the ones MFW would select (INT-WP-003).
const List<String> newsCategories = <String>['All', 'Topic 1', 'Topic 2'];

/// Made-up news articles.
const List<Article> sampleArticles = <Article>[
  Article('n5', 'Sample breaking article', 'Topic 1', breaking: true),
  Article('n4', 'Sample article four', 'Topic 2'),
  Article('n3', 'Sample article three', 'Topic 1'),
  Article('n2', 'Sample article two', 'Topic 2'),
  Article('n1', 'Sample article one', 'Topic 1'),
];

/// The prototype's state. Each change redraws every screen.
final class ProtoModel extends ChangeNotifier {
  Access _access = Access.signedOut;
  bool _online = true;
  bool _mobileData = false;
  bool _newsReachable = true;
  bool _lowStorage = false;
  bool _damagedFile = false;
  bool _unpublished = false;
  Content _content = Content.normal;
  DownloadOutcome _outcome = DownloadOutcome.completes;
  bool _swipeMode = false;
  final Set<String> _downloaded = <String>{'i10'};
  final Set<String> _favourites = <String>{};
  final Map<String, Set<int>> _bookmarks = <String, Set<int>>{
    'i10': <int>{4},
  };
  final Set<String> _savedArticles = <String>{};
  final Map<String, bool> _notificationCategories = <String, bool>{
    'New issues': true,
    'Expo specials': true,
    'Major news': false,
  };
  bool _notificationsExplained = false;

  /// The access state.
  Access get access => _access;
  set access(Access value) => _set(() => _access = value);

  /// Whether the device has a network.
  bool get online => _online;
  set online(bool value) => _set(() => _online = value);

  /// Whether the connection is mobile data (FR-DL-004).
  bool get mobileData => _mobileData;
  set mobileData(bool value) => _set(() => _mobileData = value);

  /// Whether the WordPress site answers (FR-STATE-005).
  bool get newsReachable => _newsReachable;
  set newsReachable(bool value) => _set(() => _newsReachable = value);

  /// Whether the device is low on space (FR-STATE-004).
  bool get lowStorage => _lowStorage;
  set lowStorage(bool value) => _set(() => _lowStorage = value);

  /// Whether the next issue opened is a damaged file (FR-READ-010).
  bool get damagedFile => _damagedFile;
  set damagedFile(bool value) => _set(() => _damagedFile = value);

  /// Whether the issue opened from a link is unpublished (OP-CAT-02).
  bool get unpublished => _unpublished;
  set unpublished(bool value) => _set(() => _unpublished = value);

  /// What content screens show.
  Content get content => _content;
  set content(Content value) => _set(() => _content = value);

  /// How the next download ends.
  DownloadOutcome get outcome => _outcome;
  set outcome(DownloadOutcome value) => _set(() => _outcome = value);

  /// The reader mode: page turn (false) or plain swipe (true), GS-Q55.
  bool get swipeMode => _swipeMode;
  set swipeMode(bool value) => _set(() => _swipeMode = value);

  /// Whether notifications were explained before the system prompt.
  bool get notificationsExplained => _notificationsExplained;
  set notificationsExplained(bool value) =>
      _set(() => _notificationsExplained = value);

  /// The three fixed notification categories and their switches.
  Map<String, bool> get notificationCategories =>
      Map<String, bool>.unmodifiable(_notificationCategories);

  /// Turns one notification category on or off.
  void setCategory(String name, bool on) =>
      _set(() => _notificationCategories[name] = on);

  /// Whether [issue] has a kept copy.
  bool isDownloaded(Issue issue) => _downloaded.contains(issue.id);

  /// The issues with a kept copy.
  List<Issue> get downloads =>
      sampleIssues.where((Issue issue) => isDownloaded(issue)).toList();

  /// Marks [issue] as downloaded.
  void addDownload(Issue issue) => _set(() => _downloaded.add(issue.id));

  /// Deletes the kept copy of [issue].
  void removeDownload(Issue issue) => _set(() => _downloaded.remove(issue.id));

  /// Whether [issue] is a favourite.
  bool isFavourite(Issue issue) => _favourites.contains(issue.id);

  /// The favourite issues.
  List<Issue> get favourites =>
      sampleIssues.where((Issue issue) => isFavourite(issue)).toList();

  /// Adds or removes [issue] as a favourite.
  void toggleFavourite(Issue issue) => _set(
    () => _favourites.contains(issue.id)
        ? _favourites.remove(issue.id)
        : _favourites.add(issue.id),
  );

  /// Whether page [page] of [issue] is bookmarked.
  bool isBookmarked(Issue issue, int page) =>
      _bookmarks[issue.id]?.contains(page) ?? false;

  /// The bookmarks, as issue and page.
  List<(Issue, int)> get bookmarks => <(Issue, int)>[
    for (final Issue issue in sampleIssues)
      for (final int page in (_bookmarks[issue.id] ?? <int>{}).toList()..sort())
        (issue, page),
  ];

  /// Adds or removes a bookmark.
  void toggleBookmark(Issue issue, int page) => _set(() {
    final Set<int> pages = _bookmarks.putIfAbsent(issue.id, () => <int>{});
    if (!pages.remove(page)) {
      pages.add(page);
    }
  });

  /// Whether [article] is saved for offline reading.
  bool isSaved(Article article) => _savedArticles.contains(article.id);

  /// Saves or unsaves [article] (SCR-A-19).
  void toggleSaved(Article article) => _set(
    () => _savedArticles.contains(article.id)
        ? _savedArticles.remove(article.id)
        : _savedArticles.add(article.id),
  );

  /// Clears the reader's data, as sign-out and account deletion do.
  void signOut({bool deleteAccount = false}) => _set(() {
    _access = Access.signedOut;
    if (deleteAccount) {
      _downloaded.clear();
      _favourites.clear();
      _bookmarks.clear();
    }
  });

  void _set(void Function() change) {
    change();
    notifyListeners();
  }
}
