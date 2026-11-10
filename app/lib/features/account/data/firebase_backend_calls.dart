import 'package:cloud_functions/cloud_functions.dart';

import '../domain/backend_calls.dart';

/// The [BackendCalls] adapter for callable Cloud Functions (DEC-003).
///
/// Thin on purpose: it maps the call and the error and holds no logic,
/// because it runs only on a device or simulator.
final class FirebaseBackendCalls implements BackendCalls {
  /// Creates the adapter over [functions].
  FirebaseBackendCalls(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  ) async {
    try {
      final HttpsCallableResult<Object?> result = await _functions
          .httpsCallable(operation)
          .call<Object?>(data);
      final Object? reply = result.data;
      return reply is Map
          ? Map<String, Object?>.from(reply)
          : <String, Object?>{};
    } on FirebaseFunctionsException catch (error) {
      throw backendErrorOf(error.code, error.details);
    }
  }

  /// The [BackendCallError] for a callable error [code] and its [details],
  /// as the backend sends them (`backend/functions/src/errors.ts`).
  static BackendCallError backendErrorOf(String code, Object? details) {
    String? reason;
    List<String> fields = const <String>[];
    if (details is Map) {
      final Object? given = details['reason'];
      reason = given is String ? given : null;
      final Object? named = details['fields'];
      if (named is List) {
        fields = named.whereType<String>().toList();
      }
    }
    final String category = switch (code) {
      'unauthenticated' => 'UNAUTHENTICATED',
      'permission-denied' => 'FORBIDDEN',
      'invalid-argument' => 'INVALID_ARGUMENT',
      'not-found' => reason == 'GONE' ? 'GONE' : 'NOT_FOUND',
      'aborted' || 'already-exists' => 'CONFLICT',
      'failed-precondition' => 'FAILED_PRECONDITION',
      'resource-exhausted' => 'RATE_LIMITED',
      'unavailable' => 'UNAVAILABLE',
      'deadline-exceeded' => 'UNAVAILABLE',
      'internal' => 'INTERNAL',
      _ => 'UNKNOWN',
    };
    return BackendCallError(
      category,
      reason: code == 'deadline-exceeded' ? 'DEADLINE_EXCEEDED' : reason,
      fields: fields,
    );
  }
}
