import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility class for handling image operations
///
/// Provides methods for picking, resizing, and converting images
class ImageHandler {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the specified source (camera or gallery)
  ///
  /// Returns the selected image file or null if cancelled
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Resize an image to the specified width and height
  ///
  /// [imageFile] The image file to resize
  /// [width] Target width (default: 800)
  /// [height] Target height (default: 600)
  ///
  /// Returns the resized image file
  static Future<File> resizeImage(
    File imageFile, {
    int width = 800,
    int height = 600,
  }) async {
    try {
      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize the image while maintaining aspect ratio
      img.Image resized = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.linear,
      );

      // Encode the resized image as JPEG
      final List<int> resizedBytes = img.encodeJpg(resized, quality: 85);

      // Create a new file for the resized image
      final String dir = (await getTemporaryDirectory()).path;
      final String fileName = 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(dir, fileName);

      final File resizedFile = File(filePath);
      await resizedFile.writeAsBytes(resizedBytes);

      return resizedFile;
    } catch (e) {
      print('Error resizing image: $e');
      rethrow;
    }
  }

  /// Convert an image file to base64 string
  ///
  /// [imageFile] The image file to convert
  ///
  /// Returns base64 encoded string
  static Future<String> imageToBase64(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      rethrow;
    }
  }

  /// Convert base64 string to image file
  ///
  /// [base64String] The base64 encoded string
  /// [fileName] Optional file name (default: auto-generated)
  ///
  /// Returns the decoded image file
  static Future<File> base64ToImage(String base64String, {String? fileName}) async {
    try {
      final Uint8List bytes = base64Decode(base64String);

      final String dir = (await getTemporaryDirectory()).path;
      final String name = fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(dir, name);

      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print('Error converting base64 to image: $e');
      rethrow;
    }
  }

  /// Get the size of an image file in bytes
  static Future<int> getImageSize(File imageFile) async {
    try {
      return await imageFile.length();
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }

  /// Get image dimensions (width and height)
  static Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }

  /// Compress an image to reduce file size
  ///
  /// [imageFile] The image file to compress
  /// [quality] Compression quality (0-100, default: 80)
  ///
  /// Returns the compressed image file
  static Future<File> compressImage(File imageFile, {int quality = 80}) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Encode with specified quality
      final List<int> compressedBytes = img.encodeJpg(image, quality: quality);

      // Create a new file for the compressed image
      final String dir = (await getTemporaryDirectory()).path;
      final String fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(dir, fileName);

      final File compressedFile = File(filePath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      rethrow;
    }
  }

  /// Delete a temporary image file
  static Future<void> deleteImage(File imageFile) async {
    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
