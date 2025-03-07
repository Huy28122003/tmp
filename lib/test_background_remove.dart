import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imageLib;

// import 'package:image_background_remover/image_background_remover.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:local_rembg/local_rembg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmp/utils/pick_image.dart';

class TestBackgroundRemove extends StatefulWidget {
  const TestBackgroundRemove({super.key});

  @override
  State<TestBackgroundRemove> createState() => _TestBackgroundRemoveState();
}

class _TestBackgroundRemoveState extends State<TestBackgroundRemove> {
  final ValueNotifier<ui.Image?> outImg = ValueNotifier<ui.Image?>(null);

  bool isAnalyzing = true;
  late Uint8List outputBytes;
  late Uint8List outputBytesOutline;
  bool outline = false;

  @override
  void initState() {
    super.initState();
  }

  Future<File> assetToFile(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp_image.png';

    File file = File(tempPath);
    await file.writeAsBytes(bytes);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Remover'),
      ),
      body: ValueListenableBuilder(
        valueListenable: ImagePickerService.pickedFile,
        builder: (context, image, _) {
          return GestureDetector(
            onTap: () async {
              await ImagePickerService.pickImage();
            },
            child: Container(
              alignment: Alignment.center,
              child: image == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 100,
                        ),
                        Text('No image selected.'),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.file(image),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            onPressed: () async {
                              // outImg.value = await FlutterBackgroundRemover
                              //     .removeBackground(
                              //         imageBytes: image.readAsBytesSync());

                              // outImg.value = await BackgroundRemover.instance
                              //     .removeBg(image.readAsBytesSync());

                              Uint8List imageBytes = await image.readAsBytes();

                              LocalRembgResultModel localRembgResultModel =
                                  await LocalRembg.removeBackground(
                                imageUint8List: imageBytes,
                                cropTheImage: true,
                              );
                              if (localRembgResultModel.status == 1) {
                                ui.decodeImageFromList(
                                    Uint8List.fromList(
                                        localRembgResultModel.imageBytes!),
                                    (result) {
                                  outImg.value = result;
                                });
                              } else {
                                print(
                                    "Lỗi khi xóa nền: ${localRembgResultModel.errorMessage}");
                              }
                            },
                            child: const Text('Remove Background'),
                          ),
                          ValueListenableBuilder(
                            valueListenable: outImg,
                            builder: (context, img, _) {
                              return img == null
                                  ? const SizedBox()
                                  : FutureBuilder(
                                      future: img
                                          .toByteData(
                                              format: ui.ImageByteFormat.png)
                                          .then((value) =>
                                              value!.buffer.asUint8List()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    ImageGallerySaver.saveImage(
                                                        snapshot.data!);
                                                  },
                                                  child: Text("Save"),
                                                ),
                                                Image.memory(snapshot.data!),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (snapshot.data == null)
                                                      return;

                                                    if (snapshot.data == null)
                                                      return;

                                                    imageLib.Image? image =
                                                        imageLib.decodeImage(
                                                            snapshot.data!);
                                                    if (image == null) return;

                                                    imageLib.Image
                                                        grayscaleImage =
                                                        imageLib
                                                            .grayscale(image);

                                                    outputBytes =
                                                        Uint8List.fromList(
                                                      imageLib.encodePng(
                                                          grayscaleImage),
                                                    );
                                                    setState(() {
                                                      isAnalyzing = false;
                                                    });
                                                  },
                                                  child: Text(
                                                      "Convert to GrayScale"),
                                                ),
                                                if (!isAnalyzing)
                                                  Image.memory(outputBytes),
                                                ElevatedButton(
                                                  onPressed: () async {},
                                                  child: Text(
                                                      "Convert to Outline"),
                                                ),
                                                if (outline)
                                                  Image.memory(outputBytes),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const Text('Error');
                                        }
                                      },
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
