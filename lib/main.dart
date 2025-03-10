import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:tmp/test_background_remove.dart';
import 'package:tmp/test_detect_bluetooth.dart';

import 'package:tmp/test_detect_infrared.dart';
import 'package:tmp/test_detect_object_tflite.dart';
import 'package:tmp/test_magnetic.dart';
import 'package:tmp/test_photo_collage.dart';
import 'package:tmp/test_sketch_image.dart';
import 'package:tmp/test_speech_to_text.dart';

void main() {
  DartPingIOS.register();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestSpeechToText(),
    );
  }
}
