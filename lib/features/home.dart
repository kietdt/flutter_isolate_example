import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  static int calculateLarge(int count) {
    int sum = 0;
    for (int i = 0; i < count; i++) {
      sum++;
    }
    return sum;
  }

  static void calculateLargeReceivePort(List payload) {
    SendPort sendPort = payload[0];
    int count = payload[1];
    int sum = 0;
    for (int i = 0; i < count; i++) {
      sum++;
    }
    // cách 1
    // sendPort.send(sum);

    // cách 2, flutter > 2.15
    Isolate.exit(sendPort, sum);
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String sum = "Not Calculate";

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  final count = 1000000000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(sum),
          Center(
            child: _buildSpin(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPlusPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSpin() {
    return RotationTransition(
      turns: _animation,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          children: [
            Container(
              width: 140,
              height: 120,
              decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.rectangle,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(70))),
            ),
            Container(
              width: 140,
              height: 120,
              decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.rectangle,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(70))),
            ),
            Container(
              width: 140,
              height: 120,
              decoration: const BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.rectangle,
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(70))),
            ),
            Container(
              width: 140,
              height: 120,
              decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(70))),
            ),
          ],
        ),
      ),
    );
  }

  void onPlusPressed() async {
    // onCalculateLargeNumber();
    onCalculateLargeNumberIsolateCompute();
    // onCalculateLargeNumberIsolateReceivePort();

    /// ??? -> có ảnh hưởng gì không? => không
    // await onSleepSomeSeconds();
  }

  void onCalculateLargeNumber() async {
    updateSum("Calculating...");

    sum = MyHomePage.calculateLarge(count).toString();

    updateSum(sum.toString());
  }

  Future onSleepSomeSeconds() async {
    int second = 3;
    updateSum("sleeping in $second");
    await Future.delayed(Duration(seconds: second));
    updateSum("finish in $second");
  }

  void updateSum(String sum) {
    setState(() {
      this.sum = sum;
    });
  }

  /// Isolate

  void onCalculateLargeNumberIsolateCompute() async {
    updateSum("Calculating with Compute...");

    // static function
    sum = (await compute(MyHomePage.calculateLarge, count)).toString();

    // function on Top
    // sum = (await compute(calculateLargeOnTop, count)).toString();

    updateSum(sum);
  }

  void onCalculateLargeNumberIsolateReceivePort() async {
    updateSum("Calculating with ReceivePort...");

    ReceivePort receivePort = ReceivePort();

    var isolate = await Isolate.spawn(MyHomePage.calculateLargeReceivePort,
        [receivePort.sendPort, count + 1]);

    receivePort.listen((value) {
      updateSum(value.toString());
      receivePort.close();
    });

    isolate.kill(priority: Isolate.immediate);
  }
}
