import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:tmp/test_detect_bluetooth.dart';

import 'package:tmp/test_detect_infrared.dart';
import 'package:tmp/test_detect_object_tflite.dart';

void main() {
  DartPingIOS.register();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestDetectInfrared(),
    );
  }
}
