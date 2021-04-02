import 'dart:async';

import 'package:flutter/material.dart';
import 'package:listenable_stream/listenable_stream.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        title: Text('listenable_stream example'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          label: Text('GO'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
          icon: Icon(Icons.home),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final controller = TextEditingController();
  late final StreamSubscription<String> subscription;

  @override
  void initState() {
    super.initState();
    subscription = controller
        .toValueStream(replayValue: true)
        .map((event) => event.text)
        .debounceTime(const Duration(milliseconds: 500))
        .where((s) => s.isNotEmpty)
        .distinct()
        .switchMap((value) => Stream.periodic(
            const Duration(milliseconds: 500), (i) => '$value..$i'))
        .listen(print);
  }

  @override
  void dispose() {
    subscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main'),
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
          ],
        ),
      ),
    );
  }
}
