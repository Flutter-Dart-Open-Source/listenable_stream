import 'dart:async' show Stream, StreamSubscription;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace, ValueStream;

import 'common.dart';
import 'streamx.dart';

extension _ValueListenableToStreamExtension<T> on ValueListenable<T> {
  Stream<T> toStream() =>
      toStreamWithTransform<ValueListenable<T>, T>(this, (l) => l.value);
}

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
      _stream ??=
          _valueListenable.toStream().startWith(() => _valueListenable.value);
    } else {
      _stream ??= _valueListenable.toStream();
    }

    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
