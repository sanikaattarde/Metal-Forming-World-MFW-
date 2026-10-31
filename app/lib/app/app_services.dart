import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfw_app/app/unavailable_services.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';
import 'package:mfw_app/features/news/news.dart';
import 'package:mfw_app/features/reader/reader.dart';

/// What the routed screens read, handed to them by the router (MOD-01).
///
/// Anything not given is a PLACEHOLDER that says it is unavailable, until
/// its real source exists. Tests and previews pass fakes.
final class AppServices {
  /// Creates the set.
  const AppServices({
    this.catalogue = const UnavailableCatalogueRepository(),
    this.covers = const NetworkCoverSource(),
    this.downloads = const UnavailableDownloadManager(),
    this.renderer = const UnavailablePdfRenderer(),
    this.pages = const UnavailablePageSource(),
    this.news = const UnavailableNewsRepository(),
    this.newsImages = const NetworkNewsImageSource(),
  });

  /// MOD-05's published issues.
  final CatalogueRepository catalogue;

  /// Draws issue covers.
  final IssueCoverSource covers;

  /// MOD-06.
  final DownloadManager downloads;

  /// The reader library wrapper (DEC-005).
  final PdfRenderer renderer;

  /// Draws reader pages.
  final ReaderPageSource pages;

  /// MOD-09.
  final NewsRepository news;

  /// Draws news images.
  final NewsImageSource newsImages;
}

/// The routed screens' sources. Tests override it.
final Provider<AppServices> appServicesProvider = Provider<AppServices>(
  (Ref ref) => const AppServices(),
);
