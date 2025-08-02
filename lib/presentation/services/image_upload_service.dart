import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@injectable
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio;

  ImageUploadService(this._dio);

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể chụp ảnh: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể chọn ảnh: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultipleMedia(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      throw Exception('Không thể chọn ảnh: $e');
    }
  }

  /// Upload images to server (mock)
  Future<List<String>> uploadProductImages(
    int productId,
    List<File> images,
  ) async {
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // Call mock API endpoint
      final response = await _dio.post(
        '/api/products/$productId/images',
        data: {'images': images.map((file) => file.path).toList()},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final imageUrls = List<String>.from(data['images'] as List);
        return imageUrls;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể upload ảnh: $e');
    }
  }

  /// Show image source selection dialog
  Future<File?> showImageSourceDialog({
    required Future<File?> Function() onCamera,
    required Future<File?> Function() onGallery,
  }) async {
    // This will be handled by the UI layer
    // Return null as placeholder
    return null;
  }
}
