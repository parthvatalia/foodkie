// core/utils/image_utils.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static Future<File?> pickImage({
    required ImageSource source,
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 85,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<File?> compressImage(File file) async {
    try {
      // Here you would typically use a package like flutter_image_compress
      // For now, we just return the original file
      return file;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file;
    }
  }

  static Future<File> saveImageToAppDirectory(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = '${const Uuid().v4()}${path.extension(image.path)}';
      final savedImage = await image.copy('${directory.path}/$imageName');
      return savedImage;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return image;
    }
  }
}