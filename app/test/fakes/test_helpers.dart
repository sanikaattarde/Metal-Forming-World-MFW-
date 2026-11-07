import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Collects every event of [stream] until the test ends.
List<T> recordEvents<T>(Stream<T> stream) {
  final List<T> events = <T>[];
  final StreamSubscription<T> subscription = stream.listen(events.add);
  addTearDown(subscription.cancel);
  return events;
}

/// Lets queued stream events reach their listeners.
Future<void> settle() => Future<void>.delayed(Duration.zero);

/// The failure in [result], or null for [Ok].
AppFailure? failureOf<T>(Result<T> result) => switch (result) {
  Ok<T>() => null,
  Err<T>(:final AppFailure failure) => failure,
};

/// The failure code in [result], or null for [Ok].
FailureCode? failureCodeOf<T>(Result<T> result) => failureOf(result)?.code;

/// The value in [result]; throws when it is an [Err].
T valueOf<T>(Result<T> result) => switch (result) {
  Ok<T>(:final T value) => value,
  Err<T>(:final AppFailure failure) => throw StateError(
    'expected Ok, got ${failure.code.name}',
  ),
};
