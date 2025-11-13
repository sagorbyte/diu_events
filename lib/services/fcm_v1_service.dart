import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

/// FCM V1 API Service using Service Account authentication
/// Works on FREE Spark plan (no external API costs)
/// Uses Firebase Admin SDK service account for OAuth2 tokens
class FCMV1Service {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Your Firebase project ID
  static const String _projectId = 'diu-events-app';

  // FCM V1 API endpoint
  static String get _fcmEndpoint =>
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  // OAuth2 scopes required for FCM
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  /// Get OAuth2 access token from service account JSON
  Future<String> _getAccessToken() async {
    try {
      // Load service account JSON from assets
      final serviceAccountJson = await rootBundle.loadString(
        'service-account.json',
      );
      final serviceAccount = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );

      // Get OAuth2 client
      final client = await clientViaServiceAccount(serviceAccount, _scopes);

      // Get access token
      final accessToken = client.credentials.accessToken.data;

      // Close client
      client.close();

      return accessToken;
    } catch (e) {
      print('❌ Error getting access token: $e');
      print('');
      print('⚠️ Make sure you have:');
      print('1. Downloaded service-account.json from Firebase Console');
      print('2. Placed it in the project root directory');
      print('3. Added it to pubspec.yaml assets');
      print('4. Run: flutter pub get');
      rethrow;
    }
  }

  /// Send push notification to a specific user using FCM V1 API
  Future<bool> sendPushNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
    String? eventTitle,
  }) async {
    try {
      print('🔔 Attempting to send FCM V1 push notification to user: $userId');
      print('📱 Title: $title');
      print('💬 Message: $message');

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

      // Get OAuth2 access token
      print('🔑 Getting OAuth2 access token...');
      final accessToken = await _getAccessToken();
      print('✅ Got access token');

      // Prepare FCM V1 API payload
      final payload = {
        'message': {
          'token': fcmToken,
          'notification': {'title': title, 'body': message},
          'data': {
            'type': type,
            'eventId': eventId ?? '',
            'eventTitle': eventTitle ?? '',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'channelId': 'diu_events_notifications',
            },
          },
          'apns': {
            'payload': {
              'aps': {'sound': 'default'},
            },
          },
        },
      };

      print('🚀 Sending to FCM V1 endpoint: $_fcmEndpoint');

      // Send FCM V1 API request
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(payload),
      );

      print('📬 Response status: ${response.statusCode}');
      print('📬 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Push notification sent successfully to $userId');
        return true;
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Error sending push notification: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Send push notification to multiple users (bulk)
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
      print('📮 Sending bulk notifications to ${userIds.length} users...');

      // Send to each user individually (V1 API doesn't support batch)
      for (final userId in userIds) {
        final success = await sendPushNotification(
          userId: userId,
          title: title,
          message: message,
          type: type,
          eventId: eventId,
          eventTitle: eventTitle,
        );

        if (success) {
          successCount++;
        } else {
          failureCount++;
        }
      }

      print(
        '✅ Bulk notification complete: $successCount success, $failureCount failed',
      );
    } catch (e) {
      print('❌ Error sending bulk notification: $e');
      failureCount = userIds.length;
    }

    return {'success': successCount, 'failure': failureCount};
  }

  /// Check if FCM V1 service is configured
  Future<bool> isConfigured() async {
    try {
      // Try to load service account JSON
      await rootBundle.loadString('service-account.json');
      return true;
    } catch (e) {
      return false;
    }
  }
}
