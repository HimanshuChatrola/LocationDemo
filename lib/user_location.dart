import 'package:flutter/material.dart';

class UserLocation with ChangeNotifier {
  final String lat;
  final String lng;
  final String time;

  UserLocation({
    required this.lat,
    required this.lng,
    required this.time,
  });
}
