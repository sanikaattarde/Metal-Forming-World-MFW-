import 'package:url_launcher/url_launcher.dart';

import '../domain/link_opener.dart';

/// The [LinkOpener] adapter for `url_launcher`: the page opens in the
/// reader's browser, outside the app. Runs only on a device or simulator.
final class UrlLauncherLinkOpener implements LinkOpener {
  /// Creates the adapter.
  const UrlLauncherLinkOpener();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
