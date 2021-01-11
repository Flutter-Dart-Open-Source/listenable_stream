import 'dart:async' show Stream, StreamSubscription;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace, ValueStream;
import 'package:rxdart/src/utils/value_wrapper.dart';

import 'listenable_to_stream.dart';
import 'streamx.dart';

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
  Stream<T>? _stream;

  T _getValue([void _]) => _valueListenable.value;

  /// Construct a [ValueListenableStream] from [ValueListenable].
  ValueListenableStream(this._valueListenable, this._replayValue);

  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_replayValue) {
      _stream ??=
          _valueListenable.toStream().map(_getValue).startWith(_getValue);
    } else {
      _stream ??= _valueListenable.toStream().map(_getValue);
    }

    return _stream!.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  bool get isBroadcast => false;

  @override
  Never get errorAndStackTrace =>
      throw StateError('This Stream always has no error!');

  @override
  ValueWrapper<T> get valueWrapper => ValueWrapper(_getValue());
}
