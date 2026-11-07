/// The kind of network connection, for the mobile-data warning (RS FR-DL-004).
enum ConnectionType {
  /// No connection.
  none,

  /// Wi-Fi.
  wifi,

  /// Mobile data.
  mobile,

  /// Any other connection.
  other,
}

/// Connectivity information provided by MOD-01.
abstract interface class ConnectivityService {
  /// Emits the connection type whenever it changes.
  Stream<ConnectionType> watch();

  /// The connection type now.
  Future<ConnectionType> current();
}

/// Used by MOD-11 to open notification targets (RS FR-NOTIF-005).
///
/// Both methods go through the same route guards as any other navigation
/// (RS BR-005).
abstract interface class AppNavigator {
  /// Opens the issue identified by [issueId].
  void openIssue(String issueId);

  /// Opens the news article identified by [postId].
  void openArticle(String postId);
}
