
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static ImagePicker imagePicker = ImagePicker();

  static ValueNotifier<File?> pickedFile = ValueNotifier(null);

  static Future pickImage() async {
    try {
      final file = await imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return;
      } else {
        pickedFile.value = File(file.path);
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}