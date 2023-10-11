import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

fetchLocations() {
  print(
      "${_position!.latitude.toString()}, ${_position!.longitude.toString()}, ${DateTime.now()}");
}

const task = "Background Location Service";
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    switch (taskName) {
      case 'Background Location Service':
        fetchLocations();
        break;
      default:
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(MyApp());
}

Position? _position;
late bool servicePermission = false;
late LocationPermission permission;

class MyApp extends StatelessWidget {
  Future<Position> _getCurrentLocation() async {
    // Request Permissions
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Location Service is disabled.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Location App'),
        ),
        body: Center(
          child: Column(
            children: [
              const Text("Location getting"),
              ElevatedButton(
                child: const Text("Get"),
                onPressed: () async {
                  _position = await _getCurrentLocation();
                  var uniqueId = DateTime.now().second.toString();
                  await Workmanager().registerPeriodicTask(uniqueId, task,
                      frequency: const Duration(minutes: 15),
                      constraints:
                          Constraints(networkType: NetworkType.connected));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
