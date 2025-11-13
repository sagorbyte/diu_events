import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ProfileImageService {
  // 🔑 Same API key as ImgBB service
  static const String _apiKey = 'b19c8b5e7584e0c066490f988d25f536';

  final ImagePicker _picker = ImagePicker();

  // 📏 Profile Image Requirements - Square images only
  static const int maxFileSize = 1024 * 1024; // 1MB in bytes
  static const int minSquareSize = 200; // Minimum 200x200 pixels
  static const int maxSquareSize = 1000; // Maximum 1000x1000 pixels

  /// Pick and validate square image for profile picture
  Future<XFile?> pickAndValidateSquareImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // Pick image with high quality
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Keep original quality for dimension validation
      );

      if (image == null) return null;

      // Read image bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Validate file size first
      if (imageBytes.length > maxFileSize) {
        throw Exception(
          'Image size ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)}MB exceeds 1MB limit. '
          'Please choose a smaller image or compress it.',
        );
      }

      // Validate square dimensions
      final ui.Image decodedImage = await _decodeImage(imageBytes);
      final int actualWidth = decodedImage.width;
      final int actualHeight = decodedImage.height;

      // Check if image is square
      if (actualWidth != actualHeight) {
        throw Exception(
          'Profile image must be square. Your image is ${actualWidth}×${actualHeight}px. '
          'Please select a square image (width = height).',
        );
      }

      // Check size range
      if (actualWidth < minSquareSize || actualWidth > maxSquareSize) {
        throw Exception(
          'Profile image size must be between ${minSquareSize}×${minSquareSize}px and ${maxSquareSize}×${maxSquareSize}px. '
          'Your image is ${actualWidth}×${actualHeight}px.',
        );
      }

      if (kDebugMode) {
        print(
          '✅ Square profile image validated: ${actualWidth}×${actualHeight}px, ${(imageBytes.length / 1024).toStringAsFixed(2)}KB',
        );
      }

      return image;
    } catch (e) {
      throw Exception('Failed to validate profile image: $e');
    }
  }

  /// Decode image to get actual dimensions
  Future<ui.Image> _decodeImage(Uint8List imageBytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Upload profile image to ImgBB
  Future<String> uploadProfileImage(
    XFile imageFile,
    String userId, {
    String? customFileName,
  }) async {
    try {
      // Validate API key
      if (_apiKey == 'YOUR_IMGBB_API_KEY_HERE') {
        throw Exception('Please set your ImgBB API key in the service file');
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Double-check file size
      if (imageBytes.length > maxFileSize) {
        throw Exception('Image exceeds 1MB limit');
      }

      final String base64Image = base64Encode(imageBytes);

      // Create filename with user info
      final String fileName =
          customFileName ??
          'diu_profile_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'key': _apiKey,
          'image': base64Image,
          'name': fileName,
          'expiration': '0', // Never expire
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final imageUrl = responseData['data']['url'] as String;

          if (kDebugMode) {
            print('✅ Profile image uploaded successfully to ImgBB');
            print('📍 URL: $imageUrl');
            print('📊 Size: ${responseData['data']['size']} bytes');
          }

          return imageUrl;
        } else {
          throw Exception(
            'ImgBB upload failed: ${responseData['error']['message']}',
          );
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload profile image to ImgBB: $e');
    }
  }

  /// Check if image meets profile requirements before upload
  Future<Map<String, dynamic>> validateImageRequirements(
    XFile imageFile,
  ) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final double fileSizeMB = imageBytes.length / 1024 / 1024;

      // Check file size
      bool isSizeValid = imageBytes.length <= maxFileSize;

      // Check dimensions
      final ui.Image decodedImage = await _decodeImage(imageBytes);
      final int actualWidth = decodedImage.width;
      final int actualHeight = decodedImage.height;

      bool isSquare = actualWidth == actualHeight;
      bool isSizeInRange =
          actualWidth >= minSquareSize && actualWidth <= maxSquareSize;

      return {
        'isValid': isSizeValid && isSquare && isSizeInRange,
        'fileSize': fileSizeMB,
        'fileSizeValid': isSizeValid,
        'width': actualWidth,
        'height': actualHeight,
        'isSquare': isSquare,
        'isSizeInRange': isSizeInRange,
        'errors': [
          if (!isSizeValid) 'File size exceeds 1MB limit',
          if (!isSquare) 'Image must be square (width = height)',
          if (!isSizeInRange)
            'Size must be between ${minSquareSize}×${minSquareSize}px and ${maxSquareSize}×${maxSquareSize}px',
        ],
      };
    } catch (e) {
      return {
        'isValid': false,
        'errors': ['Failed to validate image: $e'],
      };
    }
  }

  /// Delete image from ImgBB (if supported by your plan)
  Future<bool> deleteImage(String imageUrl) async {
    // Note: ImgBB free accounts don't support deletion via API
    // This is a placeholder for future implementation
    try {
      if (kDebugMode) {
        print('🗑️ Image deletion requested for: $imageUrl');
        print('⚠️ Note: ImgBB free accounts don\'t support API deletion');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete image: $e');
      }
      return false;
    }
  }

  /// Check if URL is from ImgBB
  bool isImgBBUrl(String url) {
    return url.contains('i.ibb.co') || url.contains('imgbb.com');
  }
}
