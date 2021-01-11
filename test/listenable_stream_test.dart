import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_stream/listenable_stream.dart';

void _isSingleSubscriptionStream(Stream<dynamic> stream) {
  expect(stream.isBroadcast, isFalse);

  final listen = () => stream.listen(null);
  listen();
  expect(listen, throwsStateError);
}

void main() {
  group('ListenableToStream', () {
    test('Emit self when calling `notifyListeners()`', () {
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
        ),
      );

      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();

      await pumpEventQueue();
      await subscription.cancel();

      changeNotifier.notifyListeners();
      changeNotifier.notifyListeners();
    });
  });

  group('ValueListenableToStream', () {
    test('Emits changed value when calling `value` setter', () {
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
        () {
      final valueNotifier = ValueNotifier(0);
      final stream = valueNotifier.toValueStream(replayValue: true);

      expect(stream.value, 0);
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
          ),
        );

        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        await pumpEventQueue();
        await subscription.cancel();

        valueNotifier.value = 4;
        valueNotifier.value = 5;
      }

      {
        final valueNotifier = ValueNotifier(0);
        final stream = valueNotifier.toValueStream(replayValue: true);

        var i = 0;
        final subscription = stream.listen(
          expectAsync1(
            (e) => expect(e, i++),
            count: 4,
          ),
        );

        valueNotifier.value = 1;
        valueNotifier.value = 2;
        valueNotifier.value = 3;

        await pumpEventQueue();
        await subscription.cancel();

        valueNotifier.value = 4;
        valueNotifier.value = 5;
      }
    });
  });
}
