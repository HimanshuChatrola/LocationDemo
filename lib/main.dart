import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackground.initialize();
  AndroidAlarmManager.initialize();
  requestPermissions();
  runApp(MyApp());

  AndroidAlarmManager.periodic(const Duration(minutes: 1), 0, alarmCallback);
}

String? lat, long, _datetime;
void timerCallback() async {
  _datetime = DateTime.now().toString();
  print('Timer executed at: ${_datetime}');

  bg.BackgroundGeolocation.start();

  // bg.BackgroundGeolocation.ready(bg.Config(
  //   desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
  //   stopOnTerminate: false,
  //   startOnBoot: true,
  //   enableHeadless: true,
  //   debug: true,
  // ));

  // bg.BackgroundGeolocation.onLocation((bg.Location location) {
  //   lat = location.coords.latitude.toString();
  //   long = location.coords.longitude.toString();
  // });

  bg.BackgroundGeolocation.getCurrentPosition(
    desiredAccuracy: 0,
  ).then((bg.Location location) {
    if (location != null) {
      // double latitude = location.coords.latitude;
      // double longitude = location.coords.longitude;
      // print(
      //   "Current Location: $latitude, $longitude ,${DateTime.now()}",
      // );
      saveLocationToSharedPrefs(location);
    } else {
      print("Unable to get current location.");
    }
  }).catchError((error) {
    print("Error getting current location: $error");
  });
}

List<String> locations = [];
void saveLocationToSharedPrefs(bg.Location location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  locations = prefs.getStringList('locations') ?? [];
  locations.add(
      '${location.coords.latitude}, ${location.coords.longitude}, ${_datetime}');
  prefs.setStringList('locations', locations);
}

Future<void> displayStoredLocations() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  locations = prefs.getStringList('locations') ?? [];

  for (String locationString in locations) {
    List<String> parts = locationString.split(',');
    String latitude = parts[0];
    String longitude = parts[1];
    String time = parts[2];
    print("Stored Location: $locations");
  }
}

void alarmCallback() async {
  timerCallback();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Timer Example'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('In background location $lat, $long, ${DateTime.now()}'),
              ElevatedButton(
                child: Text("Print"),
                onPressed: () {
                  displayStoredLocations();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

void requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.scheduleExactAlarm,
    Permission.location,
    // Permission.locationWhenInUse, // For iOS
    // Permission.locationAlways, // For iOS
    Permission.ignoreBatteryOptimizations,
  ].request();

  print(statuses);
}
