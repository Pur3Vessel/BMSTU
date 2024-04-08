import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());


class UserData {
  final String name;
  final String gps;
  final String address;
  final String tel;

  UserData({required this.name, required this.gps, required this.address, required this.tel});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] ?? '',
      gps: json['gps'] ?? '',
      address: json['address'] ?? '',
      tel: json['tel'] ?? '',
    );
  }
}

class MapPoint {
  final String name;


  /// Широта
  final double latitude;


  /// Долгота
  final double longitude;

  final String address;

  final String tel;

  const MapPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.tel
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Dio dio = Dio();
  late YandexMapController _yandexMapController;

  @override
  void initState() {
    super.initState();
  }

  Future<List<MapPoint>> fetchData() async {
    try {
      final response = await dio.get('http://pstgu.yss.su/iu9/mobiledev/lab4_yandex_map/2023.php?x=var23');
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data;
        final List<UserData> userList = dataList.map((json) => UserData.fromJson(json)).toList();
        print(userList);
        List<MapPoint> points = [];
        for (var place in userList) {
          List<String> gps = place.gps.split(',').map((s) => s.trim()).toList();
          var xy = gps.map((s) => double.parse(s)).toList();
          var p = MapPoint(name: place.name, latitude: xy[0], longitude: xy[1], address: place.address, tel: place.tel);
          points.add(p);
        }
        return points;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void dispose() {
    _yandexMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("yandex"),
      ),
      body: FutureBuilder<List<MapPoint>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return YandexMap(
              onMapCreated: (controller) async {
                  _yandexMapController = controller;
                  await _yandexMapController.moveCamera(CameraUpdate.newCameraPosition(
                    const CameraPosition(target: Point(latitude: 50, longitude: 20), zoom: 3)
                  ));
              },
              mapObjects: getPlacemarkObjects(context, snapshot.data!),
            );
          }
        },
      ),
    );
  }

  List<PlacemarkMapObject> getPlacemarkObjects(BuildContext context, List<MapPoint> points) {
    List<PlacemarkMapObject> objects = [];
      int i = 0;
      for (var point in points) {

        print(point.name);
        print(point.address);
        var newObj = PlacemarkMapObject(mapId: MapObjectId(i.toString()),
            point: Point(latitude: point.latitude, longitude: point.longitude),
            opacity: 1,
            onTap: (_, __) => showModalBottomSheet(context: context, builder: (context) => _ModalBodyView(point: point))
        );
        objects.add(newObj);
        i += 1;
      }
      return objects;
  }
}

class _ModalBodyView extends StatelessWidget {
  const _ModalBodyView({required this.point});

  final MapPoint point;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(point.name, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Text(
          '${point.latitude}, ${point.longitude}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(point.address, style: const TextStyle(fontSize: 20)),
        Text(point.tel, style: const TextStyle(fontSize: 20))
      ]),
    );
  }
}
