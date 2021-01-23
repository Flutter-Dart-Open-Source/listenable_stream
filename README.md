# listenable_stream

-   Convert Flutter's `Listenable` (eg. `ChangeNotifier`) to `Stream`.
-   Convert Flutter's `ValueListenable` (eg. `ValueNotifier`) to `ValueStream` (incl. replay and not replay).

[![Pub Version](https://img.shields.io/pub/v/listenable_stream?include_prereleases)](https://pub.dev/packages/listenable_stream)
[![codecov](https://codecov.io/gh/Flutter-Dart-Open-Source/listenable_stream/branch/master/graph/badge.svg?token=6eORcR6Web)](https://codecov.io/gh/Flutter-Dart-Open-Source/listenable_stream)
[![Flutter Tests](https://github.com/Flutter-Dart-Open-Source/listenable_stream/workflows/Flutter%20Tests/badge.svg)](https://github.com/Flutter-Dart-Open-Source/listenable_stream.git)

- [x] `Listenable` ▶ `Stream<Listenable>`
- [x] `ValueListenable<T>` ▶ `ValueStream<T>`

## Usage

### Listenable.toStream()
```dart
final ChangeNotifier changeNotifier = ChangeNotifier();
final Stream<ChangeNotifier> stream = changeNotifier.toStream();
stream.listen(print); // prints Instance of 'ChangeNotifier', Instance of 'ChangeNotifier'

changeNotifier.notifyListeners();
changeNotifier.notifyListeners();
```

### ValueListenable.toValueStream()
```dart
final ValueNotifier<int> valueNotifier = ValueNotifier(0);
final ValueListenableStream<int> stream = valueNotifier.toValueStream();
stream.listen(print); // prints 1, 2

valueNotifier.value = 1;
valueNotifier.value = 2;
print(stream.value); // prints 2
```

### ValueListenable.toValueStream(replayValue: true)
```dart
final ValueNotifier<int> valueNotifier = ValueNotifier(0);
final ValueListenableStream<int> stream = valueNotifier.toValueStream(replayValue: true);
stream.listen(print); // prints 0, 1, 2

valueNotifier.value = 1;
valueNotifier.value = 2;
print(stream.value); // prints 2
```

### Note
-   All returned Stream is **single-subscription `Stream`** (ie. it can only be listened once) and does not emits any errors.
-   `ValueListenableStream` always has value (ie. has no error). 