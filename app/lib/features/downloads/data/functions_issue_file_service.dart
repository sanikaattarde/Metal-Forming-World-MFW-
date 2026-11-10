import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import '../../../core/errors/backend_failure.dart';

/// The [IssueFileService] over OP-11 `getIssueFile`
/// (`backend/functions/src/issueFile.ts`, DEC-020 AGREED): the server runs
/// its checks and answers with a short-lived signed link and the file's
/// facts. The app enforces nothing here (DEC-009).
///
/// The grant's `access` is the link as a [Uri], never logged. A refusal
/// maps through `failureFromBackend`: `UNAUTHENTICATED`,
/// `EMAIL_NOT_VERIFIED`, `PROFILE_INCOMPLETE`, `ISSUE_NOT_AVAILABLE` and
/// `GONE` become the contract's failures. A reply without the fields the
/// app needs is `invalidResponse`, so a file it could not check is never
/// fetched (FR-READ-010).
final class FunctionsIssueFileService implements IssueFileService {
  /// Creates the service over [backend].
  FunctionsIssueFileService(this._backend);

  final BackendCalls _backend;

  /// The backend operation's name.
  static const String operation = 'getIssueFile';

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async {
    final Map<String, Object?> reply;
    try {
      reply = await _backend.call(operation, <String, Object?>{
        'issue_id': issueId,
      });
    } on BackendCallError catch (error) {
      return Err<IssueFileGrant>(
        failureFromBackend(error.category, reason: error.reason),
      );
    }
    final IssueFileGrant? grant = grantFrom(issueId, reply);
    return grant == null
        ? const Err<IssueFileGrant>(
            AppFailure(FailureCode.invalidResponse, detail: 'grant shape'),
          )
        : Ok<IssueFileGrant>(grant);
  }
}

final RegExp _sha256Hex = RegExp(r'^[0-9a-f]{64}$');

/// The grant in [reply] for [issueId], or null when a field is missing or
/// malformed.
IssueFileGrant? grantFrom(String issueId, Map<String, Object?> reply) {
  final Object? url = reply['url'];
  final Object? expires = reply['expires_at'];
  final Object? revision = reply['revision'];
  final Object? size = reply['size_bytes'];
  final Object? checksum = reply['checksum_sha256'];
  final Uri? link = url is String ? Uri.tryParse(url) : null;
  if (link == null ||
      !link.hasScheme ||
      link.host.isEmpty ||
      expires is! int ||
      revision is! int ||
      revision < 1 ||
      size is! int ||
      size < 1 ||
      checksum is! String ||
      !_sha256Hex.hasMatch(checksum.toLowerCase())) {
    return null;
  }
  return IssueFileGrant(
    issueId: issueId,
    access: link,
    expiresAt: DateTime.fromMillisecondsSinceEpoch(expires, isUtc: true),
    sizeBytes: size,
    contentHash: checksum.toLowerCase(),
    revision: revision,
  );
}
