import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_opencv/native_opencv.dart' as native_opencv;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class TestSketchImage extends StatefulWidget {
  const TestSketchImage({super.key});

  @override
  State<TestSketchImage> createState() => _TestSketchImageState();
}

class _TestSketchImageState extends State<TestSketchImage> {
  bool isAnalyzing = false;
  String? inputPath;
  String? outputPath;

  Future<void> pickImageAndDetectEdge() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      isAnalyzing = true;
      inputPath = pickedFile.path;
    });

    final tempDir = await getTemporaryDirectory();
    final fileName = 'converted_${DateTime.now().microsecondsSinceEpoch}.png';
    final String tempPath = "${tempDir.path}/$fileName";

    print(inputPath);
    print(tempPath);

    try {
      await native_opencv.cannyDetector(inputPath!, tempPath, threshold: 40);
      setState(() {
        outputPath = tempPath;
        isAnalyzing = false;
      });
    } catch (e) {
      print("Lỗi xử lý ảnh: $e");
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phát hiện cạnh")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (inputPath != null) Image.file(File(inputPath!)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImageAndDetectEdge,
              child: const Text("Chọn ảnh từ thư viện"),
            ),
            const SizedBox(height: 20),
            if (isAnalyzing) const CircularProgressIndicator(),
            if (outputPath != null) Image.file(File(outputPath!)),
          ],
        ),
      ),
    );
  }


}
