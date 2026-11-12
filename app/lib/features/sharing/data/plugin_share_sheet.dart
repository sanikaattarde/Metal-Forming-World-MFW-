import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../domain/share_sheet.dart';

/// [ShareSheet] on `share_plus` (DEP-52). Text only: no file is passed.
/// Runs only on a device or simulator; tests use a fake.
final class PluginShareSheet implements ShareSheet {
  /// Creates the adapter.
  const PluginShareSheet();

  @override
  Future<ShareSheetOutcome> share({
    required String text,
    String? subject,
    Rect? origin,
  }) async {
    final ShareResult result = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
    return switch (result.status) {
      ShareResultStatus.success => ShareSheetOutcome.shared,
      ShareResultStatus.dismissed => ShareSheetOutcome.dismissed,
      ShareResultStatus.unavailable => ShareSheetOutcome.unknown,
    };
  }
}
