import 'dart:async'
    show MultiStreamController, Stream, StreamController, StreamSubscription;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace, ValueStream;

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
    final getValue = ([void _]) => _valueListenable.value;

    if (_replayValue) {
      _stream ??= _valueListenable.toStream().map(getValue).startWith(getValue);
    } else {
      _stream ??= _valueListenable.toStream().map(getValue);
    }

    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// TODO
extension StartWithExtension<T> on Stream<T> {
  /// TODO
  Stream<T> startWith(T Function() seededProvider) {
    MultiStreamController<T> multiController;
    StreamSubscription<T> upstreamSubscription;

    final listenUpStream = () => listen(
          multiController.addSync,
          onError: multiController.addErrorSync,
          onDone: () {
            upstreamSubscription = null;
            multiController.closeSync();
          },
        );

    final onListen = (MultiStreamController<T> c) {
      if (multiController != null) {
        return;
      }

      multiController = c;
      multiController.addSync(seededProvider());

      upstreamSubscription = listenUpStream();
      multiController.onCancel = () {
        upstreamSubscription?.cancel();
        upstreamSubscription = null;
      };
    };

    return Stream.multi(onListen, isBroadcast: false).toSingleSubscription();
  }

  /// TODO
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
