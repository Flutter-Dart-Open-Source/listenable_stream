import 'dart:async' show Stream, StreamController, StreamSubscription;

/// @private
/// Prepends a value to the source [Stream].
extension StartWithExtension<T> on Stream<T> {
  /// @private
  /// Prepends a value to the source [Stream].
  Stream<T> startWith(T Function() seededProvider) {
    final controller = StreamController<T>(sync: true);
    late StreamSubscription<T> subscription;

    controller.onListen = () {
      controller.add(seededProvider());
      subscription = listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    };
    controller.onPause = () => subscription.pause();
    controller.onResume = () => subscription.resume();
    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }
}
