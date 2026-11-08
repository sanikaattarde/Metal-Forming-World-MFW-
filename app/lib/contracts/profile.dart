import 'result.dart';

/// Whether the signed-in reader's mandatory profile is complete.
enum ProfileStatus {
  /// Not known yet, or nobody is signed in.
  unknown,

  /// The mandatory profile is not complete.
  incomplete,

  /// The mandatory profile is complete.
  complete,
}

/// The reader profile (RS DATA-004, PROVISIONAL).
///
/// PROPOSED Dart shape: the contract gives a conceptual field list only. The
/// field list is OQ-01 and the age format is OQ-02, so every field is
/// optional and [age] is opaque. Further fields wait for OQ-01.
final class ReaderProfile {
  /// Creates a profile.
  const ReaderProfile({
    this.name,
    this.age,
    this.gender,
    this.occupation,
    this.domainOfWork,
  });

  /// Reader's name. Never logged.
  final String? name;

  /// Age, in a format set by OQ-02. Never logged.
  final Object? age;

  /// Gender; values set by OQ-01. Never logged.
  final String? gender;

  /// Occupation. Never logged.
  final String? occupation;

  /// Domain of work. Never logged.
  final String? domainOfWork;
}

/// Consent to MFW's privacy policy and terms (RS DATA-012, ASSUMPTION, OQ-27).
///
/// PROPOSED Dart shape for "what was agreed, and when".
final class ConsentRecord {
  /// Creates a consent record.
  const ConsentRecord({required this.agreedTo, required this.agreedAt});

  /// Which documents, at which version, were agreed to.
  final String agreedTo;

  /// When the reader agreed, in UTC.
  final DateTime agreedAt;
}

/// The outcome of saving the reader's own profile (OP-PRF-02, OP-10).
///
/// PROPOSED Dart shape for "the profile status: complete, or the names of
/// the missing fields". Which fields are mandatory is OQ-01.
final class ProfileSaveResult {
  /// Creates an outcome. A complete profile has no missing fields, and an
  /// incomplete one names the fields still missing.
  const ProfileSaveResult({
    required this.status,
    this.missingFields = const <String>[],
  });

  /// [ProfileStatus.complete] or [ProfileStatus.incomplete], never
  /// [ProfileStatus.unknown].
  final ProfileStatus status;

  /// The names of the mandatory fields still missing. Empty when complete.
  final List<String> missingFields;
}

/// Mandatory reader profile and consent (MOD-04, owned by WS-A).
///
/// Own profile only (RS NFR-SEC-006). Failures: `invalidInput`,
/// `unauthenticated`, `network`.
abstract interface class ProfileRepository {
  /// Emits the profile status of the signed-in reader.
  Stream<ProfileStatus> watchStatus();

  /// Reads the reader's own profile, or null if none is saved (OP-PRF-01).
  Future<Result<ReaderProfile?>> getOwnProfile();

  /// Saves the reader's own profile (OP-PRF-02) and says whether the
  /// mandatory profile is now complete, or which fields are missing.
  Future<Result<ProfileSaveResult>> saveOwnProfile(ReaderProfile profile);

  /// Records consent (OP-PRF-03).
  Future<Result<void>> recordConsent(ConsentRecord consent);
}
