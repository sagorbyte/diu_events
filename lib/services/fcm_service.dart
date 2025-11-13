import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Top-level function to handle background messages
/// This must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling a background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission for notifications (iOS and web)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User declined or has not accepted notification permission');
      }

      // Get the FCM token
      String? token = await getToken();
      if (token != null) {
        print('FCM Token: $token');
      }

      // Setup message handlers
      _setupMessageHandlers();

      // Handle token refresh
      _messaging.onTokenRefresh.listen(_handleTokenRefresh);
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Get the FCM token
  Future<String?> getToken() async {
    try {
      String? token;

      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // For iOS/macOS, get APNs token first
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          token = await _messaging.getToken();
        }
      } else {
        // For Android and other platforms
        token = await _messaging.getToken();
      }

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore for a user
  Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('FCM token saved for user: $userId');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Remove FCM token from Firestore (on logout)
  Future<void> removeTokenFromFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      print('FCM token removed for user: $userId');
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }

  /// Handle token refresh
  void _handleTokenRefresh(String token) async {
    print('FCM token refreshed: $token');
    // You'll need to update this in Firestore with current user's ID
    // This is typically handled by the auth provider
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Check if app was opened from a terminated state via notification
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  /// Handle messages when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // You can show a local notification or update UI here
    // For now, we'll just log it
  }

  /// Handle messages when app is opened from background
  void _handleBackgroundMessage(RemoteMessage message) {
    print('App opened from notification: ${message.messageId}');
    print('Data: ${message.data}');

    // Navigate to relevant screen based on notification data
    // You can use a navigation service or callback here
    final String? type = message.data['type'];
    final String? eventId = message.data['eventId'];

    if (type != null && eventId != null) {
      // Handle navigation based on type
      // This will be implemented in your navigation logic
      print('Navigate to: $type for event: $eventId');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Delete the FCM token (on logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      print('FCM token deleted');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}
