import 'package:mfw_app/features/account/account.dart';

/// Records the pages opened, and can fail as a device with no browser.
final class FakeLinkOpener implements LinkOpener {
  final List<Uri> opened = <Uri>[];
  bool works = true;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return works;
  }
}
