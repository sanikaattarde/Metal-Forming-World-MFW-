import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_server.dart';
import 'fake_streams.dart';

/// Fake MOD-04 profile and consent store for one device (IC-01, IC-08).
///
/// A saved profile counts as complete. Field validation waits for OQ-01,
/// so any profile is accepted.
final class FakeProfileRepository implements ProfileRepository {
  /// Creates the repository over [_server], for the reader signed in on
  /// [_auth].
  FakeProfileRepository(this._server, this._auth);

  final FakeServer _server;
  final FakeAuthService _auth;

  ProfileStatus get _status {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return ProfileStatus.unknown;
    }
    return _server.profileOf(userId) == null
        ? ProfileStatus.incomplete
        : ProfileStatus.complete;
  }

  @override
  Stream<ProfileStatus> watchStatus() => watchDerived(
    () => _status,
    <Stream<void>>[_auth.changes, _server.changes],
  ).distinct();

  @override
  Future<Result<ReaderProfile?>> getOwnProfile() async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<ReaderProfile?>(AppFailure(FailureCode.unauthenticated));
    }
    return Ok<ReaderProfile?>(_server.profileOf(userId));
  }

  @override
  Future<Result<void>> saveOwnProfile(ReaderProfile profile) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _server.saveProfile(userId, profile);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> recordConsent(ConsentRecord consent) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _server.addConsent(userId, consent);
    return const Ok<void>(null);
  }
}
