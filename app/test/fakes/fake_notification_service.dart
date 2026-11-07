import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

import 'fake_auth_service.dart';
import 'fake_server.dart';

/// Fake MOD-11 for one device (IC-05, IC-08).
///
/// [deliverTap] stands in for the operating system handing the app a tapped
/// notification. Preferences are kept per reader on the server.
final class FakeNotificationService implements NotificationService {
  /// Creates the service over [_server], for the reader signed in on
  /// [_auth].
  FakeNotificationService(
    this._server,
    this._auth, {
    this.permissionOutcome = PermissionOutcome.granted,
  });

  final FakeServer _server;
  final FakeAuthService _auth;
  final StreamController<NotificationTarget> _opened =
      StreamController<NotificationTarget>.broadcast();

  /// What the permission request returns.
  PermissionOutcome permissionOutcome;

  /// Reads a payload in the PROPOSED shape of API_AND_MODULE_CONTRACTS
  /// section 6.11, or null when the payload is unusable. The real parser
  /// belongs to MOD-11.
  static NotificationTarget? targetFromPayload(Object? payload) {
    if (payload is! Map<String, Object?>) {
      return null;
    }
    final Object? targetId = payload['targetId'];
    if (targetId is! String || targetId.isEmpty) {
      return null;
    }
    final NotificationTargetType? type = switch (payload['type']) {
      'issue' => NotificationTargetType.issue,
      'article' => NotificationTargetType.article,
      _ => null,
    };
    if (type == null) {
      return null;
    }
    return NotificationTarget(type: type, targetId: targetId);
  }

  /// Hands the app a tapped notification. Returns the target it emitted on
  /// [watchOpened], or null when the payload was ignored.
  NotificationTarget? deliverTap(Object? payload) {
    final NotificationTarget? target = targetFromPayload(payload);
    if (target != null) {
      _opened.add(target);
    }
    return target;
  }

  @override
  Future<Result<PermissionOutcome>> explainAndRequestPermission() async =>
      Ok<PermissionOutcome>(permissionOutcome);

  @override
  Future<Result<NotificationPreferences>> getPreferences() async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<NotificationPreferences>(
        AppFailure(FailureCode.unauthenticated),
      );
    }
    return Ok<NotificationPreferences>(
      _server.preferencesOf(userId) ??
          const NotificationPreferences(
            optedIn: false,
            categoryIds: <String>[],
          ),
    );
  }

  @override
  Future<Result<void>> savePreferences(NotificationPreferences p) async {
    final String? userId = _auth.currentUserId;
    if (userId == null) {
      return const Err<void>(AppFailure(FailureCode.unauthenticated));
    }
    _server.savePreferences(userId, p);
    return const Ok<void>(null);
  }

  @override
  Stream<NotificationTarget> watchOpened() => _opened.stream;
}
