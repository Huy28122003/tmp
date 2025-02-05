import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'main.dart';

class TestDetectObjectTflite extends StatefulWidget {
  const TestDetectObjectTflite({super.key});

  @override
  State<TestDetectObjectTflite> createState() => _TestDetectObjectTfliteState();
}

class _TestDetectObjectTfliteState extends State<TestDetectObjectTflite> {
  late CameraImage cameraImage;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  late final interpreter;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    _cameraController = CameraController(cameras![0], ResolutionPreset.high);

    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void runModel() {}

  void model() async {
     interpreter = await Interpreter.fromAsset('assets/tflite/ssd_mobilenet.tflite');
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Align(
            alignment: Alignment.bottomCenter,
            child: IconButton(onPressed: () {}, icon: Icon(Icons.camera)),
          )
        ],
      )),
    );
  }
}
