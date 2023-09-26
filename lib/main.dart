import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bg.BackgroundGeolocation.start();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

void _setupLocationListener() {
  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    print(
        'Latitude: ${location.coords.latitude}, Longitude: ${location.coords.longitude}, ${DateTime.now()}');
    // Perform actions with location data here
  });
}
//Latitude: 23.0252915, Longitude: 72.4774234, 2023-09-26 16:54:45.
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracking App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Request location permissions
            var status = await Permission.location.request();
            if (status.isGranted) {
              // Initialize and configure flutter_background_geolocation
              await bg.BackgroundGeolocation.ready(bg.Config(
                locationUpdateInterval: 180000, // 5 minutes in milliseconds
                desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
                // stopTimeout: bg.Config.ACTIVITY_TYPE_AUTOMOTIVE_NAVIGATION,
                fastestLocationUpdateInterval: 180000,
                enableHeadless: true,
                forceReloadOnBoot: true,
                notification: bg.Notification(
                  title: "Location",
                  channelId: "0",
                  channelName: "Location updates",
                  sticky: true,
                  text: "See location updates in logcat..",
                ),
              ));
            }
            _setupLocationListener();
          },
          child: Text('Start Tracking'),
        ),
      ),
    );
  }
}
