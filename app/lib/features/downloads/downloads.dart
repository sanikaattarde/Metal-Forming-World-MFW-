/// Public API of issue downloads, app side (MOD-06).
///
/// Other modules use [IssueDownloadManager] through the DownloadManager
/// contract, and [DownloadPanel] and [DownloadsScreen]. The ports are
/// implemented by adapters once DEC-020 and their packages are approved.
library;

export 'data/functions_issue_file_service.dart';
export 'data/http_file_transport.dart';
export 'data/io_file_store.dart';
export 'data/issue_download_manager.dart';
export 'data/issue_titles.dart';
export 'data/json_download_registry.dart';
export 'data/json_pending_downloads.dart';
export 'data/sha256_hash_verifier.dart';
export 'domain/download_ports.dart';
export 'domain/file_names.dart';
export 'presentation/download_panel.dart';
export 'presentation/downloads_screen.dart';
export 'presentation/downloads_text.dart';
