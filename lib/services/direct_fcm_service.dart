import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service to send FCM push notifications directly from Flutter app
/// This works without Cloud Functions (Spark plan compatible)
/// Uses Legacy FCM API with Web API Key
/// Note: Direct HTTP calls don't work on Web due to CORS - use Android/iOS
class DirectFCMService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Web API Key from Firebase Console
  static const String _fcmServerKey =
      'AIza5y0owaUlp_HdSHHTAkbr0F8FQXEsNEGaqLu_WN';

  // Legacy FCM endpoint (works with Web API Key)
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  /// Send push notification to a specific user
  /// Called after creating notification document in Firestore
  Future<bool> sendPushNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
    String? eventTitle,
  }) async {
    try {
      print('🔔 Attempting to send push notification to user: $userId');
      print('📱 Title: $title');
      print('💬 Message: $message');

      // Check if running on web
      if (kIsWeb) {
        print('⚠️ Running on Web platform - FCM HTTP calls blocked by CORS');
        print('⚠️ Push notifications only work on Android/iOS');
        print('⚠️ Notification saved in Firestore but push not sent');
        return false;
      }

      // Get user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('❌ User not found: $userId');
        return false;
      }

      final userData = userDoc.data();
      final String? fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        print('❌ No FCM token for user: $userId');
        return false;
      }

      print('✅ Found FCM token: ${fcmToken.substring(0, 20)}...');
      print('🚀 Sending to FCM endpoint: $_fcmEndpoint');

      // Prepare Legacy API notification payload
      final payload = {
        'to': fcmToken,
        'notification': {'title': title, 'body': message, 'sound': 'default'},
        'data': {
          'type': type,
          'eventId': eventId ?? '',
          'eventTitle': eventTitle ?? '',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'priority': 'high',
        'content_available': true,
      };

      // Send FCM Legacy API request
      print(
        '📋 Request headers: Content-Type: application/json, Authorization: key=$_fcmServerKey',
      );
      print('📋 Request payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: json.encode(payload),
      );

      print('📬 Response status: ${response.statusCode}');
      print('📬 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == 1) {
          print('✅ Push notification sent successfully to $userId');
          return true;
        } else {
          print('❌ FCM error: ${responseData['results']}');
          return false;
        }
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        print('Response: ${response.body}');
        print('');
        print(
          '⚠️⚠️⚠️ IMPORTANT: 404 Error means FCM Legacy API is not accessible',
        );
        print('This could mean:');
        print('1. Legacy FCM API is disabled in your Firebase project');
        print('2. The Web API Key is incorrect');
        print('3. You need to use the SERVER KEY (not Web API Key)');
        print('');
        print(
          'Please check Firebase Console > Project Settings > Cloud Messaging:',
        );
        print('- Look for "Server key" under Cloud Messaging API (Legacy)');
        print('- Make sure Cloud Messaging API (Legacy) is ENABLED');
        return false;
      }
    } catch (e) {
      print('❌ Error sending push notification: $e');
      return false;
    }
  }

  /// Send push notification to multiple users (bulk)
  /// Note: V1 API requires individual requests per token
  Future<Map<String, dynamic>> sendBulkPushNotification({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    String? eventId,
    String? eventTitle,
  }) async {
    int successCount = 0;
    int failureCount = 0;

    try {
      // Get all user tokens
      final userDocs = await Future.wait(
        userIds.map(
          (userId) => _firestore.collection('users').doc(userId).get(),
        ),
      );

      final List<String> validTokens = [];

      for (var doc in userDocs) {
        if (doc.exists) {
          final token = doc.data()?['fcmToken'] as String?;
          if (token != null && token.isNotEmpty) {
            validTokens.add(token);
          }
        }
      }

      if (validTokens.isEmpty) {
        print('No valid FCM tokens found');
        return {'success': 0, 'failure': userIds.length};
      }

      // Legacy API supports batch sending
      final payload = {
        'registration_ids': validTokens,
        'notification': {'title': title, 'body': message, 'sound': 'default'},
        'data': {
          'type': type,
          'eventId': eventId ?? '',
          'eventTitle': eventTitle ?? '',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'priority': 'high',
      };

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        successCount = responseData['success'] ?? 0;
        failureCount = responseData['failure'] ?? 0;

        print(
          '✅ Bulk notification sent: $successCount success, $failureCount failed',
        );
      } else {
        print('❌ Bulk send failed: ${response.statusCode}');
        failureCount = validTokens.length;
      }
    } catch (e) {
      print('❌ Error sending bulk notification: $e');
      failureCount = userIds.length;
    }

    return {'success': successCount, 'failure': failureCount};
  }

  /// Check if FCM server key is configured
  bool isConfigured() {
    return _fcmServerKey != 'YOUR_WEB_API_KEY_HERE' && _fcmServerKey.isNotEmpty;
  }
}
