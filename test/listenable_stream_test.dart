import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_stream/listenable_stream.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: invalid_use_of_protected_member

void _isSingleSubscriptionStream(Stream<dynamic> stream) {
  expect(stream.isBroadcast, isFalse);

  final listen = () => stream.listen(null);
  listen();
  expect(listen, throwsStateError);
}

void main() {
  group('ListenableToStream', () {
    test('Emit self when calling `notifyListeners()`', () async {
      final changeNotifier = ChangeNotifier();
      final stream = changeNotifier.toStream();

      expect(
        stream,
        emitsInOrder(
          [
            changeNotifier,
            changeNotifier,
            changeNotifier,
          ],
        ),
      );

      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();
    });

    test('Single-Subscription Stream', () {
      final stream = ChangeNotifier().toStream();
      _isSingleSubscriptionStream(stream);
    });

    test('Cancel', () async {
      final changeNotifier = ChangeNotifier();
      final stream = changeNotifier.toStream();

      final subscription = stream.listen(
        expectAsync1(
          (e) => expect(e, changeNotifier),
          count: 3,
          max: 3,
        ),
      );

      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();

      await pumpEventQueue();
      await subscription.cancel();

      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();

      assert(!changeNotifier.hasListeners);
    });

    test('Pause resume', () async {
      final changeNotifier = ChangeNotifier();
      final stream = changeNotifier.toStream();

      final subscription = stream.listen(
        expectAsync1(
          (v) => expect(v, changeNotifier),
          count: 4,
          max: 4,
        ),
      )..pause();

      // buffer
      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      subscription.resume();

      changeNotifier.notifyListeners();
    });

    test('Emits done when Listenable.addListener throws', () {
      final changeNotifier = ChangeNotifier()..dispose();
      expect(
        changeNotifier.toStream(),
        emitsDone,
      );
    });
  });

  group('ValueListenableToStream', () {
    test('Emits changed value when calling `value` setter', () async {
      final valueNotifier = ValueNotifier(0);
      final stream = valueNotifier.toValueStream();

      expect(stream.value, 0);
      expect(
        stream,
        emitsInOrder([1, 2, 3]),
      );

      valueNotifier.value = 1;
      valueNotifier.value = 2;
      valueNotifier.value = 3;
    });

    test('Replay value and emits changed value when calling `value` setter',
        () async {
      final valueNotifier = ValueNotifier(0);
      final stream = valueNotifier.toValueStream(replayValue: true);

      expect(stream.requireValue, 0);
      expect(
        stream,
        emitsInOrder([0, 1, 2, 3]),
      );

      valueNotifier.value = 1;
      valueNotifier.value = 2;
      valueNotifier.value = 3;
    });

    test('Single-Subscription Stream', () {
      {
        final stream = ValueNotifier(0).toValueStream();
        _isSingleSubscriptionStream(stream);
      }

      {
        final stream = ValueNotifier(0).toValueStream(replayValue: true);
        _isSingleSubscriptionStream(stream);
      }
    });

    test('Cancel', () async {
      {
        final valueNotifier = ValueNotifier(0);
        final stream = valueNotifier.toValueStream();

        var i = 1;
        final subscription = stream.listen(
          expectAsync1(
            (e) => expect(e, i++),
            count: 3,
            max: 3,
          ),
        );

        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        await pumpEventQueue();
        await subscription.cancel();

        valueNotifier.value = 4;
        valueNotifier.value = 5;

        assert(!valueNotifier.hasListeners);
      }

      {
        final valueNotifier = ValueNotifier(0);
        final stream = valueNotifier.toValueStream(replayValue: true);

        var i = 0;
        final subscription = stream.listen(
          expectAsync1(
            (e) => expect(e, i++),
            count: 4,
            max: 4,
          ),
        );

        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        await pumpEventQueue();
        await subscription.cancel();

        valueNotifier.value = 4;
        valueNotifier.value = 5;

        assert(!valueNotifier.hasListeners);
      }
    });

    group('Pause resume', () {
      test('not replay', () async {
        final valueNotifier = ValueNotifier(0);
        final stream = valueNotifier.toValueStream();
        final expected = [1, 2, 3, 4, 5];

        var i = 0;
        final subscription = stream.listen(
          expectAsync1(
            (v) => expect(v, expected[i++]),
            count: expected.length,
            max: expected.length,
          ),
        )..pause();

        // buffer
        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        await Future<void>.delayed(const Duration(milliseconds: 50));
        subscription.resume();

        valueNotifier.value = 4;
        valueNotifier.value = 5;
      });

      test('replay + pause immediately', () async {
        final valueNotifier = ValueNotifier(0);
        final stream = valueNotifier.toValueStream(replayValue: true);
        final expected = [0, 1, 2, 3, 4, 5];

        var i = 0;
        final subscription = stream.listen(
          expectAsync1(
            (v) => expect(v, expected[i++]),
            count: expected.length,
            max: expected.length,
          ),
        )..pause();

        // buffer
        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        subscription.resume();

        valueNotifier.value = 4;
        valueNotifier.value = 5;
      });

      test('replay + pause after events queue.', () async {
        final valueNotifier = ValueNotifier(0);
        final stream = valueNotifier.toValueStream(replayValue: true);
        final expected = [0, 1, 2, 3, 4, 5];

        var i = 0;
        final subscription = stream.listen(
          expectAsync1(
            (v) => expect(v, expected[i++]),
            count: expected.length,
            max: expected.length,
          ),
        );

        await pumpEventQueue();
        subscription.pause();

        // buffer
        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        subscription.resume();

        valueNotifier.value = 4;
        valueNotifier.value = 5;
      });
    });

    test(
        'Emits done when ValueNotifier.addListener throws and not replay value',
        () {
      final valueNotifier = ValueNotifier(0)..dispose();
      expect(
        valueNotifier.toValueStream(),
        emitsDone,
      );
    });

    test(
        'Emits value and done when ValueNotifier.addListener throws and replay value',
        () {
      final valueNotifier = ValueNotifier(0)..dispose();
      expect(
        valueNotifier.toValueStream(replayValue: true),
        emitsInOrder([0, emitsDone]),
      );
    });

    test('Has no error', () {
      expect(() => ValueNotifier(0).toValueStream().requireError,
          throwsA(anything));

      expect(
        () => ValueNotifier(0).toValueStream(replayValue: true).requireError,
        throwsA(anything),
      );
    });
  });
}
