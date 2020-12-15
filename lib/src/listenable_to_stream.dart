import 'dart:async';

import 'package:flutter/foundation.dart';

/// Convert this [Listenable] to a [Stream].
extension ListenableToStream<T extends Listenable> on T {
  /// Convert this [Listenable] to a [Stream].
  Stream<T> toStream() {
    StreamController<T> controller;
    VoidCallback listener;

    controller = StreamController<T>(
      sync: true,
      onListen: () => addListener(listener = () => controller.add(this)),
      onCancel: () {
        try {
          removeListener(listener);
          listener = null;
        } catch (_) {}
      },
    );

    return controller.stream;
  }
}
