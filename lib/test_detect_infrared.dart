import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tmp/analyze_image_screen.dart';

class TestDetectInfrared extends StatefulWidget {
  @override
  _TestDetectInfraredState createState() => _TestDetectInfraredState();
}

class _TestDetectInfraredState extends State<TestDetectInfrared> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

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

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile imageFile = await _cameraController!.takePicture();

      final Directory tempDir = Directory.systemTemp;
      final String tempPath = tempDir.path;

      final File tempImage =
          File('$tempPath/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await imageFile.saveTo(tempImage.path);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ImageProcessing(imagePath: tempImage.path)));
    } catch (e) {
      print("Lỗi chụp ảnh: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Phát hiện camera ẩn",
        ),
      ),
      body: CameraPreview(_cameraController!),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: Icon(Icons.camera),
      ),
    );
  }
}
