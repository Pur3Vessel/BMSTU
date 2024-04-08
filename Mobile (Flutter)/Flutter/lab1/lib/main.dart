import 'package:flutter/material.dart';
import 'dart:math' as math;


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rotation',
      home: Scaffold(
          body: SpeedControlWidget()
      ),
    );
  }
}

class SpeedControlWidget extends StatefulWidget {
  const SpeedControlWidget({super.key});

  @override
  State<SpeedControlWidget> createState() => _SpeedControlWidgetState();

}

class _SpeedControlWidgetState extends State<SpeedControlWidget> with TickerProviderStateMixin {
  int speed = 1;

  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: 100 ~/ (speed * 10)), // <---- скорость
    vsync: this,
  )..repeat();

  void setRotationSpeed(int value) {
    setState(() {
      speed = value;
      _controller.duration = Duration(seconds: 100 ~/ (speed * 10));
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      AnimatedBuilder(
        animation: _controller,
        child: Container(
          //width: 100.0,
          //height: 100.0,
          color: Colors.green,
          child: const Center(
            child: Text('Sova'),
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: _controller.value * 2.0 * math.pi, // <-----угол поворота на 2 пи
            child: child,
          );
      },
    ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500), // <--------------------- 5000
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            '$speed',
            // This key causes the AnimatedSwitcher to interpret this as a "new"
            // child each time the count changes, so that it will begin its animation
            // when the count changes.
            key: ValueKey<int>(speed),
            style: Theme.of(context).textTheme.displayMedium,  //<----------------- 1,2,3,4
          ),
        ),
        ElevatedButton(
          child: const Text('Повысить скорость'),
          onPressed: () {
            int newSpeed = speed >= 10 ? 10 : speed + 1;
            setRotationSpeed(newSpeed);
          },
        ),
        ElevatedButton(
          child: const Text('Понизить скорость'),
          onPressed: () {
            int newSpeed = speed <= 1 ? 1 : speed - 1;
            setRotationSpeed(newSpeed);
          },
        ),
      ],
    );
  }

}

