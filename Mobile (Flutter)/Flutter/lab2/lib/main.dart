import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyTriangleApp(),
    );
  }
}

class MyTriangleApp extends StatefulWidget {
  @override
  _MyTriangleAppState createState() => _MyTriangleAppState();
}

class _MyTriangleAppState extends State<MyTriangleApp> {
  double sideA = 100.0;
  double sideB = 100.0;
  double sideC = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triangle Drawer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TriangleWidget(sideA, sideB, sideC),
          SizedBox(height: 20),
          Text('Side A: ${sideA.toInt()}'),
          Slider(
            value: sideA,
            onChanged: (value) {
              setState(() {
                sideA = value;
              });
            },
            min: 75,
            max: 145,
          ),
          SizedBox(height: 20),
          Text('Side B: ${sideB.toInt()}'),
          Slider(
            value: sideB,
            onChanged: (value) {
              setState(() {
                sideB = value;
              });
            },
            min: 75,
            max: 145,
          ),
          SizedBox(height: 20),
          Text('Side C: ${sideC.toInt()}'),
          Slider(
            value: sideC,
            onChanged: (value) {
              setState(() {
                sideC = value;
              });
            },
            min: 75,
            max: 145,
          ),
        ],
      ),
    );
  }
}

class TriangleWidget extends StatelessWidget {
  final double sideA, sideB, sideC;

  TriangleWidget(this.sideA, this.sideB, this.sideC);

  @override
  Widget build(BuildContext context) {
    double angleA = calculateAngle(sideA, sideB, sideC);
    double angleB = calculateAngle(sideB, sideA, sideC);
    double angleC = 180 - angleA - angleB;

    int colorR = ((angleA / 180) * 255).toInt();
    int colorG = ((angleB / 180) * 255).toInt();
    int colorB = ((angleC / 180) * 255).toInt();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: CustomPaint(
        painter: TrianglePainter(colorR, colorG, colorB, sideA, sideB, sideC, radians(angleA), radians(angleB), radians(angleC)),
        child: Container(
          height: 200,
          width: 200,
        ),
      ),
    );
  }

  double calculateAngle(double a, double b, double c) {
    return degrees(acos((b * b + c * c - a * a) / (2 * b * c)));
  }

  double degrees(double radians) {
    return radians * (180 / pi);
  }

  double radians(double degrees) {
    return degrees * (pi / 180);
  }
}

class TrianglePainter extends CustomPainter {
  final int colorR, colorG, colorB;
  final double sideA, sideB, sideC, angleA, angleB, angleC;

  TrianglePainter(this.colorR, this.colorG, this.colorB, this.sideA, this.sideB, this.sideC, this.angleA, this.angleB, this.angleC);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, colorR, colorG, colorB)
      ..style = PaintingStyle.fill;


    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(sideA, 0);
    path.lineTo(sideC * cos(angleB), sideC * sin(angleB));

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}