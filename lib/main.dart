// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:untitled1/db_helper.dart';
import 'package:untitled1/user_location.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await AndroidAlarmManager.initialize();
  await FlutterBackground.initialize();

  runApp(const MyApp());

  final alarmTime = DateTime.now().add(const Duration(minutes: 5));

  await AndroidAlarmManager.periodic(
      const Duration(minutes: 5),
      exact: true,
      rescheduleOnReboot: true,
      startAt: alarmTime,
      wakeup: true,
      0,
      alarmCallback);
}

String? lat, long, _datetime;
List<String> locations = [];
void timerCallback() {
  _datetime = DateTime.now().toString();
  print('Timer executed at: ${_datetime}');

  bg.BackgroundGeolocation.start();

  bg.BackgroundGeolocation.getCurrentPosition(
    desiredAccuracy: 0,
  ).then((bg.Location location) async {
    // ignore: unnecessary_null_comparison
    if (location != null) {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // locations.add(
      //     '${location.coords.latitude}, ${location.coords.longitude}, ${_datetime}');
      // prefs.setStringList('locations', locations);
      print(
        "Current Location: ${location.coords.latitude}, ${location.coords.longitude} ,${_datetime}",
      );
      await DBHelper.insert('userlocations', {
        'lat': location.coords.latitude.toString(),
        'lng': location.coords.longitude.toString(),
        'time': _datetime.toString()
      });
    } else {
      print("Unable to get current location.");
    }
  }).catchError((error) {
    print("Error getting current location: $error");
  });
}

Widget setupAlertDialoadContainer(
    List<UserLocation> getdataList, BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    // Change as per your requirement
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
        shrinkWrap: true,
        itemCount: getdataList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
                '${getdataList[index].lat}, ${getdataList[index].lng}, ${getdataList[index].time}'),
          );
        }),
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

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.scheduleExactAlarm,
    Permission.locationAlways,
    // Permission.locationWhenInUse, // For iOS
    // Permission.locationAlways, // For iOS
    Permission.ignoreBatteryOptimizations,
    Permission.appTrackingTransparency,
  ].request();

  print(statuses);
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('In background location $lat, $long, ${DateTime.now()}'),
            ElevatedButton(
              child: const Text("Print"),
              onPressed: () async {
                //GET LAT LNG LIST FROM SAVED DATABASE
                List<Map<String, dynamic>> dataList =
                    await DBHelper.getData('userlocations');
                List<UserLocation> _getdataList = dataList
                    .map(
                      (item) => UserLocation(
                        lat: item['lat'],
                        lng: item['lng'],
                        time: item['time'],
                      ),
                    )
                    .toList();

                // SharedPreferences prefs = await SharedPreferences.getInstance();
                // locations = prefs.getStringList('locations')!;
                // print("${locations.length}");

                for (var data in _getdataList) {
                  print(data);
                }

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('All Saved locations!'),
                        content:
                            setupAlertDialoadContainer(_getdataList, context),
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
