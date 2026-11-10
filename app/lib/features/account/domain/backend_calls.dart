import 'dart:math';

/// A refusal from a backend operation: its category and, when it has one,
/// its reason (`API_AND_BACKEND_CONTRACT.md` section 2.5). The names go to
/// `failureFromBackend`. The backend's message is never kept.
final class BackendCallError implements Exception {
  /// Creates the error.
  const BackendCallError(
    this.category, {
    this.reason,
    this.fields = const <String>[],
  });

  /// The category, in upper case, for example `INVALID_ARGUMENT`.
  final String category;

  /// The reason, for example `EMAIL_NOT_VERIFIED`, or null.
  final String? reason;

  /// The fields the backend named as missing or not valid, when it named
  /// any. Field names only, never values.
  final List<String> fields;

  @override
  String toString() => 'BackendCallError($category/${reason ?? '-'})';
}

/// Calls the backend's operations (OP-nn) as the signed-in reader. A port,
/// so that the account logic is tested with a fake and the platform plugin
/// stays in one thin adapter (DEC-003: callable Cloud Functions).
abstract interface class BackendCalls {
  /// Calls [operation] with [data]. Returns the reply's fields, or throws
  /// [BackendCallError] for a refusal and failure alike.
  Future<Map<String, Object?>> call(
    String operation,
    Map<String, Object?> data,
  );
}

/// Makes the request identifiers that let the backend recognise a repeated
/// request (`API_AND_BACKEND_CONTRACT.md` section 2.4). Random, so they say
/// nothing about the reader.
String newRequestId([Random? random]) {
  final Random source = random ?? Random.secure();
  return List<String>.generate(
    16,
    (_) => source.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
