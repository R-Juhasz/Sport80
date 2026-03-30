import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler {
  static final ImagePicker _picker = ImagePicker();

  static Future<ImageProvider> getProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (Platform.isAndroid || Platform.isIOS) {
        return FileImage(File(image.path));
      } else {
        final Uint8List imageData = await image.readAsBytes();
        return MemoryImage(imageData);
      }
    } else {
      throw Exception("No image selected");
    }
  }
}
