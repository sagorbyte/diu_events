import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImgBBImageService {
  // 🔑 Get your FREE API key from https://api.imgbb.com/
  static const String _apiKey = '7a57c0c9a0a7507947f74fe91ca410d1';
  
  final ImagePicker _picker = ImagePicker();

  // 📏 DIU Events Image Requirements - STRICT
  static const int requiredWidth = 440;
  static const int requiredHeight = 220;
  static const int maxFileSize = 1024 * 1024; // 1MB in bytes

  /// Pick image WITHOUT resizing and validate exact dimensions
  Future<XFile?> pickAndValidateImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // Pick image WITHOUT any resizing or quality reduction
      final XFile? image = await _picker.pickImage(
        source: source,
        // DO NOT SET maxWidth/maxHeight - we want original dimensions
        imageQuality: 100, // Keep original quality for dimension validation
      );
      
      if (image == null) return null;

      // Read image bytes
      final Uint8List imageBytes = await image.readAsBytes();
      
      // Validate file size first
      if (imageBytes.length > maxFileSize) {
        throw Exception(
          'Image size ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)}MB exceeds 1MB limit. '
          'Please choose a smaller image or compress it.'
        );
      }

      // Validate exact dimensions
      final ui.Image decodedImage = await _decodeImage(imageBytes);
      final int actualWidth = decodedImage.width;
      final int actualHeight = decodedImage.height;
      
      if (actualWidth != requiredWidth || actualHeight != requiredHeight) {
        throw Exception(
          'Image dimensions ${actualWidth}×${actualHeight}px do not match required 440×220px. '
          'Please resize your image to exactly 440×220 pixels before uploading.'
        );
      }

      if (kDebugMode) {
        print('✅ Image validated: ${actualWidth}×${actualHeight}px, ${(imageBytes.length / 1024).toStringAsFixed(2)}KB');
      }

      return image;
    } catch (e) {
      throw Exception('Failed to validate image: $e');
    }
  }

  /// Decode image to get actual dimensions
  Future<ui.Image> _decodeImage(Uint8List imageBytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Upload image to ImgBB with DIU Events specifications
  Future<String> uploadEventImage(
    XFile imageFile,
    String eventId, {
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
      
      // Create filename with event info
      final String fileName = customFileName ?? 
          'diu_event_${eventId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'key': _apiKey,
          'image': base64Image,
          'name': fileName,
          'expiration': '0', // Never expire (for free accounts, max is what you set)
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final imageUrl = responseData['data']['url'] as String;
          
          if (kDebugMode) {
            print('✅ Image uploaded successfully to ImgBB');
            print('📍 URL: $imageUrl');
            print('📊 Size: ${responseData['data']['size']} bytes');
          }
          
          return imageUrl;
        } else {
          throw Exception('ImgBB upload failed: ${responseData['error']['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload image to ImgBB: $e');
    }
  }

  /// Upload profile image (same requirements)
  Future<String> uploadProfileImage(XFile imageFile, String userId) async {
    return uploadEventImage(
      imageFile, 
      'profile_$userId', 
      customFileName: 'diu_profile_$userId',
    );
  }

  /// Check if image meets DIU Events requirements before upload
  Future<Map<String, dynamic>> validateImageRequirements(XFile imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final double fileSizeMB = imageBytes.length / 1024 / 1024;
      
      // Check file size
      bool isSizeValid = imageBytes.length <= maxFileSize;
      
      // Check dimensions
      final ui.Image decodedImage = await _decodeImage(imageBytes);
      final int actualWidth = decodedImage.width;
      final int actualHeight = decodedImage.height;
      bool areDimensionsValid = actualWidth == requiredWidth && actualHeight == requiredHeight;
      
      // Overall validation
      bool isOverallValid = isSizeValid && areDimensionsValid;
      
      String message;
      if (isOverallValid) {
        message = '✅ Image meets all requirements (${actualWidth}×${actualHeight}px, ${fileSizeMB.toStringAsFixed(2)}MB)';
      } else {
        List<String> issues = [];
        if (!areDimensionsValid) {
          issues.add('Dimensions: ${actualWidth}×${actualHeight}px (required: 440×220px)');
        }
        if (!isSizeValid) {
          issues.add('File size: ${fileSizeMB.toStringAsFixed(2)}MB (max: 1MB)');
        }
        message = '❌ Image issues: ${issues.join(', ')}';
      }
      
      return {
        'isValid': isOverallValid,
        'dimensionsValid': areDimensionsValid,
        'sizeValid': isSizeValid,
        'actualWidth': actualWidth,
        'actualHeight': actualHeight,
        'requiredWidth': requiredWidth,
        'requiredHeight': requiredHeight,
        'currentSizeMB': fileSizeMB,
        'maxSizeMB': 1.0,
        'message': message,
      };
    } catch (e) {
      return {
        'isValid': false,
        'message': 'Error validating image: $e',
      };
    }
  }

  /// Get image requirements info
  static Map<String, dynamic> getImageRequirements() {
    return {
      'width': requiredWidth,
      'height': requiredHeight,
      'maxSizeMB': 1,
      'format': 'JPG, PNG, GIF, WebP',
      'validation': 'STRICT - Image must be EXACTLY 440×220px',
      'recommendation': 'Use image editing tools to resize to exactly 440×220px before uploading',
      'tools': [
        'Canva (free templates)',
        'GIMP (free software)', 
        'Photoshop',
        'Online resizers (resizeimage.net, etc.)'
      ],
    };
  }

  /// ImgBB doesn't support deletion via API for free accounts
  Future<void> deleteImage(String imageUrl) async {
    if (kDebugMode) {
      print('ℹ️  ImgBB free accounts do not support image deletion via API');
      print('📝 Image URL: $imageUrl');
      print('💡 Images will remain hosted unless manually deleted from ImgBB dashboard');
    }
  }

  /// Check if URL is an ImgBB URL
  bool isImgBBUrl(String url) {
    return url.contains('ibb.co') || url.contains('imgbb.com');
  }

  /// For backwards compatibility
  bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }
}
