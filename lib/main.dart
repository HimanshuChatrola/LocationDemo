import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

Future<Position> fetchLocations() async {
  print("fun called");
  return await _getCurrentLocation();
}

const task = "Background Location Service";
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'Background Location Service':
        _position = await fetchLocations();
        print(
            "${_position!.latitude.toString()}, ${_position!.longitude.toString()}, ${DateTime.now()}");
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

class MyApp extends StatelessWidget {
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Location getting"),
              ElevatedButton(
                child: const Text("Get"),
                onPressed: () async {
                  // _position = await _getCurrentLocation();
                  var uniqueId = DateTime.now().second.toString();
                  print("${DateTime.now()}");
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
