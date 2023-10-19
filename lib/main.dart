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
  runApp(const MyApp());

  AndroidAlarmManager.periodic(const Duration(minutes: 1), 0, alarmCallback);
}

String? lat, long, _datetime;
List<String> locations = [];
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
  ).then((bg.Location location) async {
    if (location != null) {
      // double latitude = location.coords.latitude;
      // double longitude = location.coords.longitude;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      locations.add(
          '${location.coords.latitude}, ${location.coords.longitude}, ${_datetime}');
      prefs.setStringList('locations', locations);
      print(
        "Current Location: ${location.coords.latitude}, ${location.coords.longitude} ,${DateTime.now()}",
      );
    } else {
      print("Unable to get current location.");
    }
  }).catchError((error) {
    print("Error getting current location: $error");
  });
}

Widget setupAlertDialoadContainer(
    List<String> locations, BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height,
    // Change as per your requirement
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: locations.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            '${locations[index]}',
            style: const TextStyle(fontSize: 10),
          ),
        );
      },
    ),
  );
}

void alarmCallback() async {
  timerCallback();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Timer Example'),
        ),
        body: TestPage(),
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

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('In background location $lat, $long, ${DateTime.now()}'),
            ElevatedButton(
              child: Text("Print"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                locations = prefs.getStringList('locations')!;
                print("${locations.length}");

                for (var data in locations) {
                  print(data);
                }

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('All Saved locations!'),
                        content: setupAlertDialoadContainer(locations, context),
                      );
                    });
              },
            )
          ],
        ),
      ),
    );
  }
}
