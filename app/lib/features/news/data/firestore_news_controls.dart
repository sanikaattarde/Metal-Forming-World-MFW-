import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../contracts/news.dart';
import '../../../contracts/result.dart';

/// OP-04 `listNewsControls` on Cloud Firestore (MOD09-P2-T03): a public
/// read of `news_controls`, one record per WordPress post that an admin has
/// hidden or marked breaking (OP-23, `DATABASE_AND_DATA_MODEL.md` section
/// 4.15).
///
/// A read goes to the server and, with no connection, to the records the
/// device read last (the SDK's own cache), so a post hidden earlier stays
/// hidden offline. Thin on purpose: it runs only on a device or simulator.
final class FirestoreNewsControlsService implements NewsControlsService {
  /// Creates the service over [firestore].
  FirestoreNewsControlsService(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Result<NewsControls>> getNewsControls() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> records = await _firestore
          .collection('news_controls')
          .get();
      return Ok<NewsControls>(
        newsControlsFrom(<String, Map<String, Object?>>{
          for (final QueryDocumentSnapshot<Map<String, dynamic>> record
              in records.docs)
            record.id: record.data(),
        }),
      );
    } on FirebaseException catch (error) {
      return Err<NewsControls>(
        AppFailure(
          error.code == 'unavailable'
              ? FailureCode.network
              : FailureCode.serviceUnavailable,
          retryable: true,
          detail: 'news controls ${error.code}',
        ),
      );
    }
  }
}

/// The controls in [records], by document ID. A record names its post by
/// its ID; a flag that is not `true` counts as not set, so a malformed
/// record hides nothing it does not say.
NewsControls newsControlsFrom(Map<String, Map<String, Object?>> records) {
  final Set<String> hidden = <String>{};
  final Set<String> breaking = <String>{};
  for (final MapEntry<String, Map<String, Object?>> record in records.entries) {
    if (record.value['is_hidden'] == true) {
      hidden.add(record.key);
    }
    if (record.value['is_breaking'] == true) {
      breaking.add(record.key);
    }
  }
  return NewsControls(
    hiddenPostIds: Set<String>.unmodifiable(hidden),
    breakingPostIds: Set<String>.unmodifiable(breaking.difference(hidden)),
  );
}
