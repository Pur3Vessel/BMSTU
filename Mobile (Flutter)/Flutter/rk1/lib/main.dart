import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<num> queue1 = [];
  List<num> queue2 = [];

  void addToQueue(num value) {
    setState(() {
      if (queue1.length >= 3) {
        queue2.add(value);
      } else {
        queue1.add(value);
      }
    });
  }

  void clearQueue() {
    setState(() {
      queue1.clear();
      queue2.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue App. Queue length = 3'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (num value in queue1)
            Text(
              value is int ? value.toString() : value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.red),
            ),
          for  (num value in queue2)
            Text(
              value is int ? value.toString() : value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.green),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Enter a number'),
              onFieldSubmitted: (value) {
                addToQueue(num.parse(value));
              },
            ),
          ),
          ElevatedButton(
            onPressed: clearQueue,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}