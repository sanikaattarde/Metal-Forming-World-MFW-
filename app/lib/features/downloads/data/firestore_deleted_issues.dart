import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../domain/download_ports.dart';

/// OP-03 on Cloud Firestore (MOD06-P3-T02): the IDs of the records in
/// `deleted_issues`, which anyone may read. Read from the server only, so
/// the list is current; with no connection the read fails and nothing is
/// removed until the next one. Thin on purpose: it runs only on a device
/// or simulator.
final class FirestoreDeletedIssues implements DeletedIssueList {
  /// Creates the reader over [firestore].
  FirestoreDeletedIssues(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Result<Set<String>>> deletedIssueIds() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> records = await _firestore
          .collection('deleted_issues')
          .get(const GetOptions(source: Source.server));
      return Ok<Set<String>>(<String>{
        for (final QueryDocumentSnapshot<Map<String, dynamic>> record
            in records.docs)
          record.id,
      });
    } on FirebaseException catch (error) {
      return Err<Set<String>>(
        AppFailure(
          error.code == 'unavailable'
              ? FailureCode.network
              : FailureCode.serviceUnavailable,
          retryable: true,
          detail: 'deleted issues ${error.code}',
        ),
      );
    }
  }
}

/// Removes this device's copies of the issues OP-03 lists (MOD06-P3-T02).
/// Returns how many copies went; none when the list cannot be read.
Future<int> sweepDeletedIssues(
  DeletedIssueList deleted,
  KeptCopyLifecycle copies,
) async {
  final Result<Set<String>> listed = await deleted.deletedIssueIds();
  return switch (listed) {
    Ok<Set<String>>(:final Set<String> value) => copies.removeIssues(value),
    Err<Set<String>>() => 0,
  };
}
