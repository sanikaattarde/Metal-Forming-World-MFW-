import 'dart:async';

import 'package:mfw_app/features/account/account.dart';

import 'fake_identity_provider.dart';

/// The working position's five fields (GS-Q40), as `config/public` would
/// list them.
const List<String> fiveFields = <String>[
  'full_name',
  'age_value',
  'gender',
  'job_title',
  'industry_segment_id',
];

/// A fake of the profile's backend side: the documents the app reads and
/// OP-10 `saveProfile`, which writes them as the real operation does.
/// Synthetic values only (DEC-024).
final class FakeProfileBackend implements ProfileDocuments, BackendCalls {
  FakeProfileBackend(this.identity);

  final FakeIdentityProvider identity;

  /// `config/public`, or null for a missing record.
  Map<String, Object?>? publicConfig = <String, Object?>{
    'profile_required_fields': fiveFields,
    'policy_versions': <String, Object?>{
      'privacy_policy': 'pp-test-1',
      'terms_of_use': 'tou-test-1',
    },
  };

  /// The segments.
  List<SegmentOption> segments = const <SegmentOption>[
    SegmentOption(id: 's1', name: 'Segment one'),
    SegmentOption(id: 's2', name: 'Segment two'),
  ];

  /// Profiles by account ID.
  final Map<String, Map<String, Object?>> profiles =
      <String, Map<String, Object?>>{};

  /// The consent versions stored, by account ID.
  final Map<String, Map<String, Object?>> consents =
      <String, Map<String, Object?>>{};

  /// Every call to a backend operation, in order.
  final List<(String, Map<String, Object?>)> calls =
      <(String, Map<String, Object?>)>[];

  /// The error the next call throws, once.
  BackendCallError? failNext;

  /// While set, reads fail with it.
  Object? readError;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<Map<String, Object?>?> watchProfile(String uid) async* {
    if (readError != null) {
      throw readError!;
    }
    yield profiles[uid];
    await for (final void _ in _changes.stream) {
      yield profiles[uid];
    }
  }

  @override
  Future<Map<String, Object?>?> readPublicConfig() async {
    if (readError != null) {
      throw readError!;
    }
    return publicConfig;
  }

  @override
  Future<List<SegmentOption>> readSegments() async => segments;

  /// Stores a profile directly, as an earlier save would have.
  void putProfile(String uid, Map<String, Object?> profile) {
    profiles[uid] = profile;
    _changes.add(null);
  }

  @override
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  ) async {
    calls.add((operation, data));
    final BackendCallError? error = failNext;
    if (error != null) {
      failNext = null;
      throw error;
    }
    final String uid = identity.currentUser!.uid;
    if (operation == 'saveProfile') {
      final Object? versions = data['accepted_versions'];
      if (!consents.containsKey(uid) && versions == null) {
        throw const BackendCallError(
          'INVALID_ARGUMENT',
          fields: <String>['accepted_versions'],
        );
      }
      if (versions is Map<String, Object?>) {
        consents[uid] = versions;
      }
      final Map<String, Object?> profile = Map<String, Object?>.from(
        data['profile']! as Map<String, Object?>,
      );
      putProfile(uid, profile);
      final List<String> required =
          (publicConfig!['profile_required_fields']! as List<Object?>)
              .cast<String>();
      final List<String> missing = required
          .where((String f) => !profile.containsKey(f))
          .toList();
      return missing.isEmpty
          ? <String, Object?>{'profile_status': 'complete'}
          : <String, Object?>{
              'profile_status': 'incomplete',
              'missing_fields': missing,
            };
    }
    return <String, Object?>{};
  }
}
