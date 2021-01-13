import 'dart:async';

import 'package:flutter/foundation.dart' show Listenable;

import 'common.dart';

/// Convert this [Listenable] to a [Stream].
extension ListenableToStream<T extends Listenable> on T {
  /// Convert this [Listenable] to a [Stream].
  Stream<T> toStream() => toStreamWithTransform<T, T>(this, (t) => t);
}
