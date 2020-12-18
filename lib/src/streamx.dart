import 'dart:async'
    show MultiStreamController, Stream, StreamController, StreamSubscription;

/// @private
/// Prepends a value to the source [Stream].
extension StartWithExtension<T> on Stream<T> {
  /// @private
  /// Prepends a value to the source [Stream].
  Stream<T> startWith(T Function() seededProvider) {
    MultiStreamController<T> controller;
    StreamSubscription<T> subscription;

    final listenUpStream = () => listen(
          controller.addSync,
          onError: controller.addErrorSync,
          onDone: () {
            subscription = null;
            controller.closeSync();
          },
        );

    final onListen = (MultiStreamController<T> c) {
      if (controller != null) {
        return;
      }

      controller = c;
      controller.addSync(seededProvider());

      subscription = listenUpStream();
      controller.onCancel = () {
        subscription?.cancel();
        subscription = null;
      };
    };

    return Stream.multi(onListen, isBroadcast: false).toSingleSubscription();
  }
}

/// @private
/// Convert a [Stream] to Single-Subscription [Stream].
extension ToSingleSubscriptionStreamExtension<T> on Stream<T> {
  /// @private
  /// Convert a [Stream] to Single-Subscription [Stream].
  Stream<T> toSingleSubscription() {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = StreamController<T>(
      sync: true,
      onListen: () {
        subscription = listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }
}
