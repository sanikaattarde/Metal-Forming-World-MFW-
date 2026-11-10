import '../../../contracts/contracts.dart';

/// The profile fields of the working position (GS-Q40; OQ-01 to OQ-03 are
/// OPEN, so the set is PROVISIONAL), with the names OP-10 uses. Which of
/// them are asked for comes from configuration (`profile_required_fields`).
enum ProfileField {
  /// The reader's full name.
  fullName('full_name'),

  /// Age in whole years, 1 to 120 (OQ-02 working position; no age gate,
  /// FR-PROF-005).
  age('age_value'),

  /// Gender. The options are OPEN (OQ-01).
  gender('gender'),

  /// Occupation.
  jobTitle('job_title'),

  /// Domain of work, one of the industry segments (OQ-13).
  industrySegment('industry_segment_id');

  const ProfileField(this.wireName);

  /// The field's name in OP-10 and in the stored profile.
  final String wireName;

  /// The field for [name], or null.
  static ProfileField? byWireName(String name) {
    for (final ProfileField field in values) {
      if (field.wireName == name) {
        return field;
      }
    }
    return null;
  }
}

/// The checks the app makes before OP-10, which checks again (MOD04-P2-T01).
abstract final class ProfileRules {
  /// PLACEHOLDER: no document sets a length (DATABASE_AND_DATA_MODEL.md
  /// MA-6); the backend uses the same placeholder.
  static const int maxTextLength = 200;

  /// The age range of the working position (OQ-02). Not an age gate.
  static const int minAge = 1;

  /// See [minAge].
  static const int maxAge = 120;

  /// The gender options shown. PLACEHOLDER until OQ-01 sets them.
  static const List<String> genderOptions = <String>[
    'Female',
    'Male',
    'Prefer not to say',
  ];

  /// The age in [text] when it is a whole number in range, or null.
  static int? ageFrom(String text) {
    final int? age = int.tryParse(text.trim());
    return age != null && age >= minAge && age <= maxAge ? age : null;
  }

  /// Whether [text] is usable as a text field's value.
  static bool isText(String text) {
    final String value = text.trim();
    return value.isNotEmpty && value.length <= maxTextLength;
  }
}

/// One industry segment a reader can choose as their domain of work.
final class SegmentOption {
  /// Creates the option.
  const SegmentOption({required this.id, required this.name});

  /// The segment's identifier, sent to OP-10.
  final String id;

  /// The name shown.
  final String name;
}

/// What SCR-A-05 and SCR-A-06 need to show the form.
final class ProfileFormSpec {
  /// Creates the spec.
  const ProfileFormSpec({
    required this.fields,
    required this.segments,
    required this.current,
    required this.needsConsent,
  });

  /// The configured fields, in the order shown.
  final List<ProfileField> fields;

  /// The segments to choose from.
  final List<SegmentOption> segments;

  /// The saved profile, or null before the first save.
  final ReaderProfile? current;

  /// Whether the first save must carry the reader's acceptance of the
  /// policy and terms (FR-PRIV-001), because none was given in this session.
  final bool needsConsent;
}

/// Loads the profile form (MOD04-P2-T01). Implemented by the repository.
abstract interface class ProfileForms {
  /// The form for the signed-in reader.
  Future<Result<ProfileFormSpec>> loadForm();
}

/// The reader's own records and the public settings, as the profile needs
/// them. A port, so the logic is tested with a fake and the database plugin
/// stays in one adapter (DEC-003: Cloud Firestore).
abstract interface class ProfileDocuments {
  /// Emits the profile of [uid] (`users/{uid}/profile/current`), or null
  /// while there is none.
  Stream<Map<String, Object?>?> watchProfile(String uid);

  /// The public configuration (`config/public`), or null when missing.
  Future<Map<String, Object?>?> readPublicConfig();

  /// The industry segments (`segments`).
  Future<List<SegmentOption>> readSegments();
}
