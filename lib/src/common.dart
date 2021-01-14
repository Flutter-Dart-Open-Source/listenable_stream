import 'dart:async';

import 'package:flutter/foundation.dart' show Listenable, VoidCallback;

/// @private
/// Convert this [Listenable] to a [Stream].
Stream<R> toStreamWithTransform<T extends Listenable, R>(
  T listenable,
  R Function(T) transform,
) {
  final controller = StreamController<R>();
  VoidCallback? listener;

  controller.onListen = () {
    assert(listener == null);
    try {
      listenable
          .addListener(listener = () => controller.add(transform(listenable)));
    } catch (_ /*Ignore*/) {
      controller.close();
    }
  };

  controller.onCancel = () {
    return () {
      assert(listener != null);
      try {
        listenable.removeListener(listener!);
        listener = null;
      } catch (_ /*Ignore*/) {}
    };
  };

  return controller.stream;
}
