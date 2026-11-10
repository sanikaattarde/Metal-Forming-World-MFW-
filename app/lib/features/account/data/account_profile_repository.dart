import 'dart:async';

import '../../../contracts/contracts.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/backend_calls.dart';
import '../domain/identity_provider.dart';
import '../domain/profile_form.dart';

/// MOD-04's `ProfileRepository` (IC-01) over OP-10 `saveProfile` and the
/// reader's own profile record (MOD04-P2-T01). PROVISIONAL: the mandatory
/// profile and its fields wait for OQ-01 to OQ-03 (BR-003).
///
/// The fields asked for are the configured ones (`profile_required_fields`
/// in `config/public`), so OQ-01 can change them without a code change. A
/// profile is complete when every one of them has a value (INV-10); nothing
/// about completeness is stored. A missing or unusable configuration fails
/// closed: the status is an error, not "complete" (SC-03).
final class AccountProfileRepository
    implements ProfileRepository, ProfileForms {
  /// Creates the repository.
  AccountProfileRepository(
    this._identity,
    this._backend,
    this._documents, {
    String Function()? requestIds,
  }) : _requestIds = requestIds ?? newRequestId;

  final IdentityProvider _identity;
  final BackendCalls _backend;
  final ProfileDocuments _documents;
  final String Function() _requestIds;

  // The reader who accepted the policy and terms in this session, so that
  // the next save carries the acceptance (FR-PRIV-001, OQ-27).
  String? _consentFrom;

  static const AppFailure _unauthenticated = AppFailure(
    FailureCode.unauthenticated,
  );
  static const AppFailure _unreadable = AppFailure(
    FailureCode.serviceUnavailable,
    retryable: true,
    detail: 'profile unreadable',
  );

  @override
  Stream<ProfileStatus> watchStatus() {
    StreamSubscription<IdentityUser?>? users;
    StreamSubscription<Map<String, Object?>?>? profile;
    late final StreamController<ProfileStatus> out;
    bool first = true;
    String? following;
    int generation = 0;

    void stop() {
      final StreamSubscription<Map<String, Object?>?>? old = profile;
      profile = null;
      if (old != null) {
        unawaited(old.cancel());
      }
    }

    Future<void> follow(String uid, int mine) async {
      final List<ProfileField> fields;
      try {
        fields = await _requiredFields();
      } on Object catch (error) {
        if (mine == generation) {
          out.addError(error);
        }
        return;
      }
      if (mine != generation) {
        return;
      }
      profile = _documents
          .watchProfile(uid)
          .listen(
            (Map<String, Object?>? data) => out.add(statusOf(data, fields)),
            onError: out.addError,
          );
    }

    void onUser(IdentityUser? user) {
      final String? uid = user?.uid;
      // A reload of the same reader changes nothing here.
      if (!first && uid == following) {
        return;
      }
      first = false;
      following = uid;
      generation++;
      stop();
      out.add(ProfileStatus.unknown);
      if (uid != null) {
        unawaited(follow(uid, generation));
      }
    }

    out = StreamController<ProfileStatus>(
      onListen: () {
        users = _identity.userChanges().listen(onUser, onError: out.addError);
      },
      onCancel: () async {
        generation++;
        stop();
        await users?.cancel();
      },
    );
    return out.stream.distinct();
  }

  /// Complete when every field in [fields] has a value (INV-10).
  static ProfileStatus statusOf(
    Map<String, Object?>? data,
    List<ProfileField> fields,
  ) {
    if (data == null) {
      return ProfileStatus.incomplete;
    }
    final bool complete = fields.every((ProfileField field) {
      final Object? value = data[field.wireName];
      return value != null && value != '';
    });
    return complete ? ProfileStatus.complete : ProfileStatus.incomplete;
  }

  Future<List<ProfileField>> _requiredFields() async {
    final Map<String, Object?>? config = await _documents.readPublicConfig();
    final Object? names = config?['profile_required_fields'];
    if (names is! List || names.isEmpty) {
      throw StateError('profile_required_fields is missing');
    }
    final List<ProfileField> fields = <ProfileField>[];
    for (final Object? name in names) {
      final ProfileField? field = name is String
          ? ProfileField.byWireName(name)
          : null;
      if (field == null) {
        throw StateError('profile_required_fields names an unknown field');
      }
      fields.add(field);
    }
    // Shown in the order of [ProfileField], whatever the configured order.
    fields.sort((ProfileField a, ProfileField b) => a.index.compareTo(b.index));
    return fields;
  }

  /// The [ReaderProfile] of a stored profile record.
  static ReaderProfile profileOf(Map<String, Object?> data) {
    String? text(ProfileField field) {
      final Object? value = data[field.wireName];
      return value is String ? value : null;
    }

    final Object? age = data[ProfileField.age.wireName];
    return ReaderProfile(
      name: text(ProfileField.fullName),
      age: age is int ? age : null,
      gender: text(ProfileField.gender),
      occupation: text(ProfileField.jobTitle),
      domainOfWork: text(ProfileField.industrySegment),
    );
  }

  /// The OP-10 profile for [profile]: only the fields with a value.
  static Map<String, Object?> wireOf(
    ReaderProfile profile,
  ) => <String, Object?>{
    if (profile.name != null) ProfileField.fullName.wireName: profile.name,
    if (profile.age != null) ProfileField.age.wireName: profile.age,
    if (profile.gender != null) ProfileField.gender.wireName: profile.gender,
    if (profile.occupation != null)
      ProfileField.jobTitle.wireName: profile.occupation,
    if (profile.domainOfWork != null)
      ProfileField.industrySegment.wireName: profile.domainOfWork,
  };

  @override
  Future<Result<ReaderProfile?>> getOwnProfile() async {
    final String? uid = _identity.currentUser?.uid;
    if (uid == null) {
      return const Err<ReaderProfile?>(_unauthenticated);
    }
    try {
      final Map<String, Object?>? data = await _documents
          .watchProfile(uid)
          .first;
      return Ok<ReaderProfile?>(data == null ? null : profileOf(data));
    } on Object {
      return const Err<ReaderProfile?>(_unreadable);
    }
  }

  @override
  Future<Result<ProfileFormSpec>> loadForm() async {
    final String? uid = _identity.currentUser?.uid;
    if (uid == null) {
      return const Err<ProfileFormSpec>(_unauthenticated);
    }
    try {
      final List<ProfileField> fields = await _requiredFields();
      final List<SegmentOption> segments =
          fields.contains(ProfileField.industrySegment)
          ? await _documents.readSegments()
          : const <SegmentOption>[];
      final Map<String, Object?>? data = await _documents
          .watchProfile(uid)
          .first;
      return Ok<ProfileFormSpec>(
        ProfileFormSpec(
          fields: fields,
          segments: segments,
          current: data == null ? null : profileOf(data),
          needsConsent: data == null && _consentFrom != uid,
        ),
      );
    } on Object {
      return const Err<ProfileFormSpec>(_unreadable);
    }
  }

  @override
  Future<Result<ProfileSaveResult>> saveOwnProfile(
    ReaderProfile profile,
  ) async {
    final String? uid = _identity.currentUser?.uid;
    if (uid == null) {
      return const Err<ProfileSaveResult>(_unauthenticated);
    }
    final Map<String, Object?> data = <String, Object?>{
      'request_id': _requestIds(),
      'profile': wireOf(profile),
    };
    if (_consentFrom == uid) {
      final Map<String, Object?>? config;
      try {
        config = await _documents.readPublicConfig();
      } on Object {
        return const Err<ProfileSaveResult>(_unreadable);
      }
      final Object? versions = config?['policy_versions'];
      if (versions is! Map) {
        return const Err<ProfileSaveResult>(_unreadable);
      }
      data['accepted_versions'] = <String, Object?>{
        'privacy_policy': versions['privacy_policy'],
        'terms_of_use': versions['terms_of_use'],
      };
    }
    try {
      final Map<String, Object?> reply = await _backend.call(
        'saveProfile',
        data,
      );
      if (_consentFrom == uid) {
        _consentFrom = null;
      }
      final Object? missing = reply['missing_fields'];
      return Ok<ProfileSaveResult>(
        ProfileSaveResult(
          status: reply['profile_status'] == 'complete'
              ? ProfileStatus.complete
              : ProfileStatus.incomplete,
          missingFields: missing is List
              ? missing.whereType<String>().toList()
              : const <String>[],
        ),
      );
    } on BackendCallError catch (error) {
      return Err<ProfileSaveResult>(
        failureFromBackend(error.category, reason: error.reason),
      );
    }
  }

  /// Notes that the signed-in reader accepted the policy and terms; the
  /// next save stores the acceptance with the current versions through
  /// OP-10, which keeps the server's time (FR-PRIV-001; how consent is
  /// recorded is OQ-27, PROPOSED).
  @override
  Future<Result<void>> recordConsent(ConsentRecord consent) async {
    final String? uid = _identity.currentUser?.uid;
    if (uid == null) {
      return const Err<void>(_unauthenticated);
    }
    _consentFrom = uid;
    return const Ok<void>(null);
  }
}
