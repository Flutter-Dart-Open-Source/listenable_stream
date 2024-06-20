# listenable_stream

-   Convert Flutter's `Listenable` (e.g. `ChangeNotifier`) to `Stream`.
-   Convert Flutter's `ValueListenable` (e.g. `ValueNotifier`) to `ValueStream` (incl. "replay" and "not replay").

[![Pub Version](https://img.shields.io/pub/v/listenable_stream?include_prereleases)](https://pub.dev/packages/listenable_stream)
[![codecov](https://codecov.io/gh/Flutter-Dart-Open-Source/listenable_stream/branch/master/graph/badge.svg?token=6eORcR6Web)](https://codecov.io/gh/Flutter-Dart-Open-Source/listenable_stream)
[![Flutter Tests](https://github.com/Flutter-Dart-Open-Source/listenable_stream/actions/workflows/flutter.yml/badge.svg)](https://github.com/Flutter-Dart-Open-Source/listenable_stream/actions/workflows/flutter.yml)
[![GitHub](https://img.shields.io/github/license/hoc081098/flutter_bloc_pattern?color=4EB1BA)](https://opensource.org/licenses/MIT)
[![Style](https://img.shields.io/badge/style-lints-40c4ff.svg)](https://pub.dev/packages/lints)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FFlutter-Dart-Open-Source%2Flistenable_stream&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

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