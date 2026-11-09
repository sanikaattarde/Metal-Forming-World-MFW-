import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads every font in the app's font manifest, so that tests measure and
/// draw with the bundled typefaces instead of the test font.
Future<void> loadBrandFonts() async {
  final String manifest = await rootBundle.loadString('FontManifest.json');
  for (final Object? entry in jsonDecode(manifest) as List<Object?>) {
    final Map<String, Object?> family = entry! as Map<String, Object?>;
    final FontLoader loader = FontLoader(family['family']! as String);
    for (final Object? font in family['fonts']! as List<Object?>) {
      final Map<String, Object?> file = font! as Map<String, Object?>;
      loader.addFont(rootBundle.load(file['asset']! as String));
    }
    await loader.load();
  }
}
