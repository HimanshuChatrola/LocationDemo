import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_background/flutter_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackground.initialize();
  AndroidAlarmManager.initialize();
  requestPermissions();
  runApp(MyApp());

  AndroidAlarmManager.periodic(const Duration(minutes: 5), 0, alarmCallback);
}

String? lat, long;

void timerCallback() async {
  print('Timer executed at: ${DateTime.now()}');

  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    lat = location.coords.latitude.toString();
    long = location.coords.longitude.toString();
  });
  print("location $lat, $long, ${DateTime.now()}");
}

void alarmCallback() async {
  await AndroidAlarmManager.oneShot(
      const Duration(minutes: 5), 0, timerCallback);
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
          child: Text('In background location $lat, $long, ${DateTime.now()}'),
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
