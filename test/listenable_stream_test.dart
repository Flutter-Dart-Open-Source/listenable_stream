import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_stream/listenable_stream.dart';

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
  });
}
