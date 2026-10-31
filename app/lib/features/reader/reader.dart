/// Public API of the reader (MOD-07).
///
/// Other modules use [ReaderScreen], and the DEC-005 adapter implements
/// [ReaderPageSource]. The rest is exported for tests.
library;

export 'domain/paged_reader_controller.dart';
export 'domain/reader_layout.dart';
export 'domain/reader_zoom.dart';
export 'presentation/reader_page_source.dart';
export 'presentation/reader_screen.dart';
export 'presentation/reader_session.dart';
export 'presentation/reader_text.dart';
export 'presentation/zoomable_page.dart';
