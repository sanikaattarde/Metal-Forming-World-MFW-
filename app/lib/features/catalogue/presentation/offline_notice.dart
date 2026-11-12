import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/ui/content_widgets.dart';
import '../domain/issue_search.dart';
import 'catalogue_text.dart';

/// [child] under a notice that it comes from the device, when [catalogue]
/// says its last answer did (MOD05-P2-T05, NFR-OFF-002).
Widget withOfflineNotice(Object catalogue, Widget child) {
  if (catalogue is! OfflineCatalogue || !catalogue.fromDevice) {
    return child;
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      const Padding(
        padding: EdgeInsets.fromLTRB(MfwSpace.lg, MfwSpace.lg, MfwSpace.lg, 0),
        child: ContentNotice(
          CatalogueText.offlineCopy,
          kind: NoticeKind.offline,
        ),
      ),
      Expanded(child: child),
    ],
  );
}
