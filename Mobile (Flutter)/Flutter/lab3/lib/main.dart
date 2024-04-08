import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double rubyX = 0.0;
  double rubyY = 0.0;
  double crecentX = 0.0;
  double cresentY = 0.35;
  bool dropFlag = false;

  late Object ruby;
  late Object crescent_rose;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Huntress'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Cube(
              onSceneCreated: (Scene scene) {
                ruby = Object(position: Vector3(rubyX, rubyY, 0), scale: Vector3(8, 8, 8), fileName: 'assets/ruby_rose/ruby_rose.obj');
                crescent_rose = Object(position: Vector3(crecentX, cresentY, 0), scale: Vector3(8, 8, 8), fileName: 'assets/crecent_rose/crescentRose.obj');
                scene.world.add(ruby);
                scene.world.add(crescent_rose); 
              },
            ),
          ),
          Slider(
            value: rubyX,
            onChanged: (value) {
              setState(() {
                rubyX = value;
                crecentX = value;
                ruby.position.x = rubyX;
                ruby.updateTransform();
                if (!dropFlag) {
                  crescent_rose.position.x = crecentX;
                  crescent_rose.updateTransform();
                }
              });
            },
            min: -5,
            max: 5,
          ),
          Slider(
            value: rubyY,
            onChanged: (value) {
              setState(() {
                rubyY = value;
                cresentY = value;
                ruby.position.y = rubyY;
                ruby.updateTransform();
                if (!dropFlag) {
                  crescent_rose.position.y = cresentY;
                  crescent_rose.updateTransform();
                }
              });
            },
            min: -5,
            max: 5,
          ),
          ElevatedButton(
              onPressed: () {
                crescent_rose.position.z = -5;
                crescent_rose.position.x = 0;
                crescent_rose.position.y = 0;
                crescent_rose.updateTransform();
                dropFlag = true;
              },
              child: const Text('Drop'))
        ],
      ),
    );
  }
}