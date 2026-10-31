/// Public API of news from WordPress (MOD-09).
///
/// Other modules use [WordPressNewsRepository] through the NewsRepository
/// contract, and [NewsListScreen] and [NewsArticleScreen]. The real
/// HttpTransport waits for a package decision and MFW's site details
/// (OQ-39). Offline reading (T-08.3) and the news controls (T-08.4) are
/// not built yet.
library;

export 'data/wordpress_json.dart';
export 'data/wordpress_news_repository.dart';
export 'data/wordpress_site.dart';
export 'domain/html_text.dart';
export 'domain/news_ports.dart';
export 'presentation/news_article_screen.dart';
export 'presentation/news_failure_view.dart';
export 'presentation/news_feed.dart';
export 'presentation/news_image_source.dart';
export 'presentation/news_list_screen.dart';
export 'presentation/news_post_tile.dart';
export 'presentation/news_text.dart';
