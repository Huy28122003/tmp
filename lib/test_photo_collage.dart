import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class TestPhotoCollage extends StatefulWidget {
  const TestPhotoCollage({super.key});

  @override
  State<TestPhotoCollage> createState() => _TestPhotoCollageState();
}

class _TestPhotoCollageState extends State<TestPhotoCollage> {
  double angle = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ProImageEditor.asset(
              configs: ProImageEditorConfigs(
                paintEditor: PaintEditorConfigs(enabled: false),
                textEditor: TextEditorConfigs(enabled: false),
                cropRotateEditor: CropRotateEditorConfigs(enabled: false),
                filterEditor: FilterEditorConfigs(enabled: false),
                tuneEditor: TuneEditorConfigs(enabled: false),
                blurEditor: BlurEditorConfigs(enabled: false),
                emojiEditor: EmojiEditorConfigs(enabled: false),
                layerInteraction: LayerInteractionConfigs(),
                designMode: ImageEditorDesignMode.cupertino,
                stickerEditor: StickerEditorConfigs(
                  enabled: true,
                  buildStickers: (setLayer, scrollController) {
                    return ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 80,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        controller: scrollController,
                        itemCount: 21,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              LoadingDialog.instance.show(
                                context,
                                configs: const ProImageEditorConfigs(),
                                theme: Theme.of(context),
                              );
                              await precacheImage(
                                NetworkImage(
                                  'https://picsum.photos/id/${(index + 3) * 3}/2000',
                                ),
                                context,
                              );
                              LoadingDialog.instance.hide();
                              setLayer(
                                Transform.rotate(
                                  angle: angle,
                                  child: Sticker(index: index),
                                ),
                                exportConfigs: WidgetLayerExportConfigs(
                                  id: 'sticker-$index',
                                ),
                              );
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Sticker(index: index),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              "assets/images/person.jpeg",
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (Uint8List bytes) async {
                  _saveImageToGallery(bytes);
                },
              ),
            ),
          ),
          Slider(
              min: 0,
              max: 360,
              value: angle,
              onChanged: (value) {
                setState(() {
                  angle = value;
                });
              }),
        ],
      ),
    );
  }

  Future<void> _saveImageToGallery(Uint8List bytes) async {
    if (await Permission.photos.request().isGranted) {
      final result = await ImageGallerySaver.saveImage(bytes,
          quality: 100, name: "edited_image");
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu ảnh thành công vào Photos')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu ảnh thất bại')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có quyền lưu ảnh vào Photos')),
      );
    }
  }
}

class Sticker extends StatefulWidget {
  const Sticker({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<Sticker> createState() => StickerState();
}

class StickerState extends State<Sticker> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.network(
        'https://picsum.photos/id/${(widget.index + 3) * 3}/2000',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          return AnimatedSwitcher(
            layoutBuilder: (currentChild, previousChildren) {
              return SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
              );
            },
            duration: const Duration(milliseconds: 200),
            child: loadingProgress == null
                ? child
                : Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
