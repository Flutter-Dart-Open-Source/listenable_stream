import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'listenable_to_stream.dart';

/// Convert this [ValueListenable] to a [ValueStream].
/// The returned [ValueStream] is a Single-Subscription [Stream].
///
/// If [replayValue] is true, the returned [ValueStream] will replay latest value when listening to it.
/// Otherwise, it does not.
extension ValueListenableToValueStream<T> on ValueListenable<T> {
  /// Convert this [ValueListenable] to a [ValueStream].
  /// The returned [ValueStream] is a Single-Subscription [Stream].
  ///
  /// If [replayValue] is true, the returned [ValueStream] will replay latest value when listening to it.
  /// Otherwise, it does not.
  ValueStream<T> toValueStream({bool replayValue = false}) =>
      ValueListenableStream<T>(this, replayValue);
}

/// A Single-Subscription Stream will emits data when [ValueListenable.value] changed.
class ValueListenableStream<T> extends Stream<T> implements ValueStream<T> {
  final ValueListenable<T> _valueListenable;
  final bool _replayValue;
  Stream<T> _stream;

  /// Construct a [ValueListenableStream] from [ValueListenable].
  ValueListenableStream(this._valueListenable, this._replayValue);

  @override
  bool get isBroadcast => false;

  @override
  ErrorAndStackTrace get errorAndStackTrace => null;

  @override
  bool get hasError => false;

  @override
  bool get hasValue => true;

  @override
  T get value => _valueListenable.value;

  @override
  StreamSubscription<T> listen(
    void Function(T) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    if (_replayValue) {
      _stream ??= _valueListenable
          .toStream()
          .map((_) => _valueListenable.value)
          .shareBehavior(value);
    } else {
      _stream ??=
          _valueListenable.toStream().map((_) => _valueListenable.value);
    }

    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension _ShareValueExtension<T> on Stream<T> {
  Stream<T> shareBehavior(T seeded) {
    final controllers = <MultiStreamController<T>>[];
    StreamSubscription<T> subscription;

    var latestValue = seeded;
    var cancel = false;
    var done = false;

    final listenUpStream = () => listen(
          (event) {
            latestValue = event;
            controllers.forEach((c) => c.addSync(event));
          },
          onError: (e, StackTrace st) =>
              controllers.forEach((c) => c.addErrorSync(e, st)),
          onDone: () {
            done = true;
            subscription = null;

            controllers.forEach((c) {
              c.onCancel = null;
              c.closeSync();
            });
            controllers.clear();
          },
        );

    final onListen = (MultiStreamController<T> controller) {
      if (cancel) {
        return controller.closeSync();
      }
      controller.addSync(latestValue);
      if (done) {
        return controller.closeSync();
      }

      final wasEmpty = controllers.isEmpty;
      controllers.add(controller);
      if (wasEmpty) {
        subscription = listenUpStream();
      }

      controller.onCancel = () {
        controllers.remove(controller);
        if (controllers.isEmpty) {
          subscription?.cancel();
          subscription = null;
          cancel = true;
        }
      };
    };

    return Stream.multi(onListen, isBroadcast: true);
  }
}
