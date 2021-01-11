import 'dart:async';

import 'package:flutter/foundation.dart' show Listenable, VoidCallback;

/// @private
/// Convert this [Listenable] to a [Stream].
Stream<R> toStreamWithTransform<T extends Listenable, R>(
  T listenable,
  R Function(T) transform,
) {
  StreamController<R> controller;
  VoidCallback listener;

  final onListenOrOnResume = () {
    try {
      listenable
          .addListener(listener = () => controller.add(transform(listenable)));
    } catch (_ /*Ignore*/) {
      controller.close();
    }
  };

  final createOnPauseOrOnCancel = ([bool closeOnError = false]) {
    return () {
      try {
        listenable.removeListener(listener);
        listener = null;
      } catch (_ /*Ignore*/) {
        if (identical(closeOnError, true)) {
          controller.close();
        }
      }
    };
  };

  controller = StreamController<R>(
    onListen: onListenOrOnResume,
    onPause: createOnPauseOrOnCancel(true),
    onResume: onListenOrOnResume,
    onCancel: createOnPauseOrOnCancel(),
  );

  return controller.stream;
}
