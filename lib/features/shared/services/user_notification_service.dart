import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_notification.dart';
import '../../../services/fcm_v1_service.dart';

class UserNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FCMV1Service _fcmService = FCMV1Service();
  static const String collectionPath = 'user_notifications';

  // Send a notification to a specific user
  Future<String> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
    String? eventTitle,
    Map<String, dynamic>? metadata,
  }) async {
    print('🔔🔔🔔 SEND NOTIFICATION TO USER CALLED 🔔🔔🔔');
    print('   User ID: $userId');
    print('   Title: $title');
    print('   Message: $message');
    print('   Type: $type');

    try {
      // Check authentication status
      final currentUser = await FirebaseAuth.instance.currentUser;
      print('🔐 Current authenticated user: ${currentUser?.uid ?? "NONE"}');
      print('🔐 Current user email: ${currentUser?.email ?? "NONE"}');

      if (currentUser == null) {
        print('❌❌❌ USER NOT AUTHENTICATED! Cannot create notification.');
        throw Exception('User not authenticated');
      }

      final notification = UserNotification(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        message: message,
        type: type,
        eventId: eventId,
        eventTitle: eventTitle,
        isRead: false,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // write using explicit fields to ensure createdAt is stored as ISO string
      final data = notification.toJson();
      data.remove('id');
      data['createdAt'] = notification.createdAt.toIso8601String();

      print('📝 Attempting to write to Firestore collection: $collectionPath');
      print('📝 Data: $data');

      final docRef = await _firestore.collection(collectionPath).add(data);

      // Update with the generated ID
      await docRef.update({'id': docRef.id});

      // Send push notification directly (no Cloud Functions needed!)
      // This runs in the background and doesn't block the notification creation
      _sendPushNotificationAsync(
        userId: userId,
        title: title,
        message: message,
        type: type,
        eventId: eventId,
        eventTitle: eventTitle,
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // Send push notification asynchronously (doesn't block main operation)
  Future<void> _sendPushNotificationAsync({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
    String? eventTitle,
  }) async {
    try {
      print('📲 Starting push notification process for user: $userId');

      // Check if FCM is configured
      final isConfigured = await _fcmService.isConfigured();
      print('🔧 FCM configured: $isConfigured');

      if (!isConfigured) {
        print('⚠️ FCM not configured. Push notification not sent.');
        print('Please add service-account.json to your project');
        print('See FCM_V1_SETUP.md for instructions');
        return;
      }

      print('✅ FCM is configured, proceeding to send...');

      // Send push notification
      final result = await _fcmService.sendPushNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        eventId: eventId,
        eventTitle: eventTitle,
      );

      if (result) {
        print('🎉 Push notification sent successfully!');
      } else {
        print('⚠️ Push notification sending returned false');
      }
    } catch (e) {
      // Don't throw error - notification is already saved in Firestore
      print('❌ Failed to send push notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Get notifications for a user
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    int? limit,
    bool? unreadOnly,
  }) async {
    try {
      // Use simple query without orderBy to avoid composite index requirement
      // We'll sort in memory as a temporary solution while indexes are building
      Query query = _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userId);

      final snapshot = await query.get();

      List<UserNotification> notifications = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // ensure id is present in parsed map
        data['id'] = doc.id;
        return UserNotification.fromJson(data);
      }).toList();

      // Filter by read status if specified
      if (unreadOnly == true) {
        notifications = notifications.where((n) => !n.isRead).toList();
      }

      // Sort by creation date in memory (descending - newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply limit if specified
      if (limit != null && notifications.length > limit) {
        notifications = notifications.take(limit).toList();
      }

      return notifications;
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(collectionPath).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();

      final snapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(collectionPath).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get unread count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  // Stream notifications for a user (real-time updates)
  Stream<List<UserNotification>> streamUserNotifications(
    String userId, {
    int? limit,
    bool? unreadOnly,
  }) {
    try {
      // Use simple query without orderBy to avoid composite index requirement
      // We'll sort in memory as a temporary solution while indexes are building
      Query query = _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userId);

      return query.snapshots().map((snapshot) {
        List<UserNotification> notifications = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return UserNotification.fromJson(data);
        }).toList();

        // Filter by read status if specified
        if (unreadOnly == true) {
          notifications = notifications.where((n) => !n.isRead).toList();
        }

        // Sort by creation date in memory (descending - newest first)
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Apply limit if specified
        if (limit != null && notifications.length > limit) {
          notifications = notifications.take(limit).toList();
        }

        return notifications;
      });
    } catch (e) {
      throw Exception('Failed to stream notifications: $e');
    }
  }

  // Clean up old notifications (optional maintenance function)
  Future<void> cleanupOldNotifications({
    Duration? olderThan,
    int? keepLastN,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(
        olderThan ?? const Duration(days: 90),
      );

      Query query = _firestore
          .collection(collectionPath)
          .where('createdAt', isLessThan: cutoffDate.toIso8601String());

      final snapshot = await query.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup old notifications: $e');
    }
  }
}
