import '../../contracts/result.dart';

/// The redaction rules of `CODING_STANDARDS.md` section 6.2, rule 3 (SC-16,
/// SEC-CHK-10), applied by `RedactingLogger` to every message, context
/// value and error text.
///
/// Patterns catch what can be recognised in text: email addresses, signed
/// and token-bearing links, bearer tokens, JSON Web Tokens, `key=value`
/// secrets and long opaque tokens such as push device tokens. Context keys
/// that name personal data or a secret are replaced whatever the value.
/// A reader account ID cannot be told from an issue ID by its shape, so
/// callers pass it, if at all, under a key that [isSensitiveKey] knows, and
/// never inside a message. Issue IDs and news post IDs may be logged
/// (rule 5).
abstract final class Redactor {
  /// The text written in place of a removed value.
  static const String removed = '[redacted]';

  /// [input] with every recognised secret and personal value replaced.
  static String text(String input) {
    String out = input.replaceAllMapped(_url, (Match m) => _redactUrl(m[0]!));
    out = out.replaceAll(_jwt, '[token]');
    out = out.replaceAllMapped(_authHeader, (Match m) => '${m[1]} [token]');
    out = out.replaceAllMapped(
      _keyValue,
      (Match m) => '${m[1]}${m[2]}$removed',
    );
    out = out.replaceAll(_email, '[email]');
    out = out.replaceAll(_opaque, '[token]');
    return out;
  }

  /// Whether a context [key] names personal data or a secret
  /// (`CODING_STANDARDS.md` section 6.2, rule 3).
  static bool isSensitiveKey(String key) {
    final String k = key.toLowerCase().replaceAll(_nonAlphanumeric, '');
    return _sensitiveKeys.contains(k) ||
        _sensitiveParts.any((String part) => k.contains(part));
  }

  /// [context] with sensitive keys replaced and every value redacted.
  static Map<String, Object?> context(Map<String, Object?> context) =>
      _map(context, 0);

  /// The text of [error] for a log line, redacted.
  static String error(Object error) =>
      error is AppFailure ? _failure(error) : text(error.toString());

  static Map<String, Object?> _map(Map<Object?, Object?> map, int depth) =>
      <String, Object?>{
        for (final MapEntry<Object?, Object?> e in map.entries)
          text('${e.key}'): isSensitiveKey('${e.key}')
              ? removed
              : _value(e.value, depth + 1),
      };

  static Object? _value(Object? value, int depth) {
    if (value == null || value is bool || value is num || value is Enum) {
      return value;
    }
    if (value is String) {
      return text(value);
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is AppFailure) {
      return _failure(value);
    }
    if (depth > _maxDepth) {
      return '<${value.runtimeType}>';
    }
    if (value is Map<Object?, Object?>) {
      return _map(value, depth);
    }
    if (value is Iterable<Object?>) {
      return <Object?>[for (final Object? v in value) _value(v, depth + 1)];
    }
    // An object's own text could hold a profile value or a token, so only
    // its type is written.
    return '<${value.runtimeType}>';
  }

  static String _failure(AppFailure f) {
    final String detail = f.detail == null ? '' : ', ${text(f.detail!)}';
    return 'AppFailure(${f.code.name}, retryable: ${f.retryable}$detail)';
  }

  static String _redactUrl(String raw) {
    final Uri? uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasAuthority) {
      return '[link]';
    }
    final bool hadExtra =
        uri.hasQuery || uri.hasFragment || uri.userInfo.isNotEmpty;
    final String port = uri.hasPort ? ':${uri.port}' : '';
    final String path = uri.path
        .split('/')
        .map(
          (String s) => _opaque.hasMatch(s) || _jwt.hasMatch(s) ? '[token]' : s,
        )
        .join('/');
    return '${uri.scheme}://${uri.host}$port$path${hadExtra ? '?$removed' : ''}';
  }

  static const int _maxDepth = 4;

  static final RegExp _url = RegExp(
    r'''[A-Za-z][A-Za-z0-9+.\-]*://[^\s"'<>]+''',
  );
  static final RegExp _jwt = RegExp(
    r'eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]*',
  );
  static final RegExp _authHeader = RegExp(
    r'\b(Bearer|Basic)\s+[A-Za-z0-9._~+/:\-]+=*',
    caseSensitive: false,
  );
  static final RegExp _keyValue = RegExp(
    r'''\b(password|passwd|pwd|secret|api[_\-]?key|(?:id|refresh|access|auth|device|push|fcm)?[_\-]?token|authorization|grant|signature|sig|uid|user[_\-]?id|reader[_\-]?id|account[_\-]?id|email)(["']?\s*[:=]\s*)("[^"]*"|'[^']*'|[^\s,;&]+)''',
    caseSensitive: false,
  );
  static final RegExp _email = RegExp(
    r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
  );
  static final RegExp _opaque = RegExp(r'[A-Za-z0-9_\-:+=]{64,}');
  static final RegExp _nonAlphanumeric = RegExp('[^a-z0-9]');

  static const Set<String> _sensitiveKeys = <String>{
    'name',
    'displayname',
    'firstname',
    'lastname',
    'fullname',
    'age',
    'agerange',
    'gender',
    'occupation',
    'domainofwork',
    'phone',
    'phonenumber',
    'address',
    'uid',
    'userid',
    'readerid',
    'accountid',
    'adminid',
    'profile',
    'body',
    'requestbody',
    'responsebody',
    'content',
    'contents',
    'filecontents',
    'bytes',
  };

  static const List<String> _sensitiveParts = <String>[
    'password',
    'passwd',
    'secret',
    'token',
    'apikey',
    'authorization',
    'cookie',
    'grant',
    'signature',
    'signedurl',
    'email',
  ];
}
