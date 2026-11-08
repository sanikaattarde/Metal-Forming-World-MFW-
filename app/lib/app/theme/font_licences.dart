import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mfw_tokens.dart';

/// The licence file bundled with each typeface (DEP-78).
const Map<String, String> fontLicenceAssets = <String, String>{
  MfwFonts.fraunces: 'assets/fonts/fraunces/OFL.txt',
  MfwFonts.inter: 'assets/fonts/inter/OFL.txt',
  MfwFonts.plusJakartaSans: 'assets/fonts/plus_jakarta_sans/OFL.txt',
};

/// Adds the SIL Open Font License of each typeface to the licence page, as
/// condition 2 of that licence asks (`CODING_STANDARDS.md` section 12).
void registerFontLicences() {
  LicenseRegistry.addLicense(_fontLicences);
}

Stream<LicenseEntry> _fontLicences() async* {
  for (final MapEntry<String, String> font in fontLicenceAssets.entries) {
    yield LicenseEntryWithLineBreaks(<String>[
      font.key,
    ], await rootBundle.loadString(font.value));
  }
}
