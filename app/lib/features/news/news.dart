/// Public API of the news feature (MOD-09). Other features import only this
/// file (`CODING_STANDARDS.md` section 3).
library;

export 'data/firestore_news_controls.dart';
export 'data/wordpress_news_repository.dart' show WordPressNewsRepository;
export 'domain/article_content.dart';
export 'domain/controlled_news_repository.dart';
export 'presentation/article_body.dart';
export 'presentation/article_screen.dart';
export 'presentation/news_screen.dart';
export 'presentation/news_text.dart';
