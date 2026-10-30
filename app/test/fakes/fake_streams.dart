import 'dart:async';

/// A stream that emits `read()` when listened to and again after each event
/// on [triggers], so a fake can offer "the current value, then changes".
///
/// The triggers must be broadcast streams.
Stream<T> watchDerived<T>(T Function() read, List<Stream<void>> triggers) {
  final List<StreamSubscription<void>> subscriptions =
      <StreamSubscription<void>>[];
  late final StreamController<T> controller;
  controller = StreamController<T>(
    onListen: () {
      controller.add(read());
      for (final Stream<void> trigger in triggers) {
        subscriptions.add(trigger.listen((_) => controller.add(read())));
      }
    },
    onCancel: () async {
      for (final StreamSubscription<void> subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );
  return controller.stream;
}
