import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:listenable_stream/listenable_stream.dart';
import 'package:rxdart_ext/state_stream.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'listenable_stream example',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('listenable_stream example'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          label: const Text('GO'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          },
          icon: const Icon(Icons.home),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with DisposeBagMixin {
  final controller = TextEditingController();
  late final StateStream<String> stateStream;

  @override
  void initState() {
    super.initState();

    stateStream = controller
        .toValueStream(replayValue: true)
        .map((event) => event.text)
        .debounceTime(const Duration(milliseconds: 500))
        .where((s) => s.isNotEmpty)
        .distinct()
        .switchMap((value) => Stream.periodic(
            const Duration(milliseconds: 500), (i) => '$value..$i'))
        .publishState('initial')
      ..connect().disposedBy(bag);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(filled: true),
            ),
            Expanded(
              child: RxStreamBuilder<String>(
                stream: stateStream,
                builder: (context, state) {
                  return Center(
                    child: Text(
                      state,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
