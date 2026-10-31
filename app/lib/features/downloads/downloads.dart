/// Public API of issue downloads, app side (MOD-06).
///
/// Other modules use [IssueDownloadManager] through the DownloadManager
/// contract, and [DownloadPanel] and [DownloadsScreen]. The ports are
/// implemented by adapters once DEC-020 and their packages are approved.
library;

export 'data/issue_download_manager.dart';
export 'domain/download_ports.dart';
export 'domain/file_names.dart';
export 'presentation/download_panel.dart';
export 'presentation/downloads_screen.dart';
export 'presentation/downloads_text.dart';
