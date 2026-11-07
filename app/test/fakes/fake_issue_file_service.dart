import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';

/// A file the fake server can grant. Size, hash and revision are synthetic.
final class FakeIssueFile {
  /// Creates a grantable file.
  const FakeIssueFile({
    required this.sizeBytes,
    required this.contentHash,
    required this.revision,
  });

  /// File size in whole bytes.
  final int sizeBytes;

  /// Synthetic content hash.
  final String contentHash;

  /// Current file revision.
  final int revision;
}

/// The opaque access value inside a fake grant. Each grant gets its own.
final class FakeGrantAccess {
  /// Creates the value for the grant numbered [serial].
  FakeGrantAccess(this.serial);

  /// Which grant this is, counting from 1.
  final int serial;
}

/// Fake OP-FILE-01 (IC-02): a grant only with full access, otherwise the
/// failure that matches the access state.
final class FakeIssueFileService implements IssueFileService {
  /// Creates the service. [isPublished] defaults to every file being
  /// published.
  FakeIssueFileService(
    this._auth, {
    required this._files,
    bool Function(String issueId)? isPublished,
    DateTime Function()? clock,
    this.grantLifetime = const Duration(minutes: 15),
  }) : _isPublished = isPublished ?? _alwaysPublished,
       _clock = clock ?? _fixedClock;

  static bool _alwaysPublished(String issueId) => true;
  static DateTime _fixedClock() => DateTime.utc(2026);

  final FakeAuthService _auth;
  final Map<String, FakeIssueFile> _files;
  final bool Function(String issueId) _isPublished;
  final DateTime Function() _clock;

  /// Synthetic grant lifetime; DEC-020 sets the real one.
  final Duration grantLifetime;

  /// How many grants were issued.
  int grantsIssued = 0;

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async {
    switch (_auth.currentAccessState) {
      case AccessState.signedOut:
        return const Err<IssueFileGrant>(
          AppFailure(FailureCode.unauthenticated),
        );
      case AccessState.emailUnverified:
        return const Err<IssueFileGrant>(
          AppFailure(FailureCode.emailNotVerified),
        );
      case AccessState.profileIncomplete:
        return const Err<IssueFileGrant>(
          AppFailure(FailureCode.profileIncomplete),
        );
      case AccessState.fullAccess:
        break;
    }
    final FakeIssueFile? file = _files[issueId];
    if (file == null || !_isPublished(issueId)) {
      return const Err<IssueFileGrant>(AppFailure(FailureCode.notFound));
    }
    grantsIssued++;
    return Ok<IssueFileGrant>(
      IssueFileGrant(
        issueId: issueId,
        access: FakeGrantAccess(grantsIssued),
        expiresAt: _clock().add(grantLifetime),
        sizeBytes: file.sizeBytes,
        contentHash: file.contentHash,
        revision: file.revision,
      ),
    );
  }
}
