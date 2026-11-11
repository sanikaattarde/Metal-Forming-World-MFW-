import '../logging/app_logger.dart';
import '../logging/redaction.dart';

/// One usage event (RS NFR-OBS-002, DATA-014): a name and a few plain
/// values. Never a reader, an issue or a page (NFR-PRIV-003, PAC-09).
final class UsageEvent {
  /// Creates an event.
  const UsageEvent(this.name, [this.parameters = const <String, Object>{}]);

  /// The event's name, such as `app_open`.
  final String name;

  /// Its values: text, whole numbers or yes and no only.
  final Map<String, Object> parameters;
}

/// Accepts only events on the approved list (OQ-23,
/// `API_AND_MODULE_CONTRACTS.md` section 6.2).
abstract interface class UsageEvents {
  /// Records [event] if it is approved, and drops it otherwise. Never throws.
  void record(UsageEvent event);
}

/// Where accepted events go: the analytics service, which DEC-028 and OQ-23
/// leave open. None is built, so [NoUsageEventSink] is the only one.
abstract interface class UsageEventSink {
  /// Sends [event].
  Future<void> send(UsageEvent event);
}

/// Sends nothing: there is no analytics service yet.
final class NoUsageEventSink implements UsageEventSink {
  /// Creates the sink.
  const NoUsageEventSink();

  @override
  Future<void> send(UsageEvent event) async {}
}

/// The approved events and the parameters each may carry. EMPTY until MFW
/// answers OQ-23 in writing, so no event is recorded in any build.
const Map<String, Set<String>> approvedUsageEvents = <String, Set<String>>{};

/// [UsageEvents] with the approved list (MOD02-P2-T02, PAC-09).
///
/// An event is dropped when collection is off, when its name or one of its
/// parameters is not approved, when a parameter would name a reader, an
/// issue, a post or a page, whatever the list says, or when a value is not
/// plain (text of up to 100 characters with no email address or link, a
/// whole number, or yes or no). A refusal writes one log line with no value.
final class AllowlistedUsageEvents implements UsageEvents {
  /// Creates the recorder. [approved] defaults to [approvedUsageEvents].
  AllowlistedUsageEvents({
    required bool enabled,
    this._sink = const NoUsageEventSink(),
    Map<String, Set<String>> approved = approvedUsageEvents,
    this._logger,
  }) : _enabled = enabled && approved.isNotEmpty,
       _approved = approved;

  final bool _enabled;
  final UsageEventSink _sink;
  final Map<String, Set<String>> _approved;
  final AppLogger? _logger;

  /// Whether any event can be recorded at all.
  bool get collecting => _enabled;

  static final RegExp _name = RegExp(r'^[a-z][a-z0-9_]{0,39}$');

  // Parameters that would say which reader opened which issue or page
  // (NFR-PRIV-003), refused even if a list ever named them.
  static const Set<String> _forbiddenParts = <String>{
    'user',
    'uid',
    'reader',
    'account',
    'email',
    'issue',
    'post',
    'article',
    'page',
    'file',
    'token',
    'device',
  };

  static const int _maxText = 100;

  /// Why [event] would be refused, or null when it would be recorded.
  String? refusal(UsageEvent event) {
    if (!_enabled) {
      return 'off';
    }
    final Set<String>? allowed = _approved[event.name];
    if (!_name.hasMatch(event.name) || allowed == null) {
      return 'name';
    }
    for (final MapEntry<String, Object> entry in event.parameters.entries) {
      final String key = entry.key.toLowerCase();
      if (!allowed.contains(entry.key) ||
          Redactor.isSensitiveKey(entry.key) ||
          _forbiddenParts.any(key.contains)) {
        return 'parameter';
      }
      final Object value = entry.value;
      final bool plain = switch (value) {
        bool() || int() => true,
        String() => value.length <= _maxText && Redactor.text(value) == value,
        _ => false,
      };
      if (!plain) {
        return 'value';
      }
    }
    return null;
  }

  @override
  void record(UsageEvent event) {
    final String? why = refusal(event);
    if (why != null) {
      if (why != 'off') {
        _logger?.warning('usage event refused', context: {'why': why});
      }
      return;
    }
    _sink.send(event).catchError((Object _) {
      _logger?.warning('usage event not sent');
    });
  }
}
