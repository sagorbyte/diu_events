import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_notification.dart';
import '../services/user_notification_service.dart';

class UserNotificationProvider with ChangeNotifier {
  final UserNotificationService _notificationService = UserNotificationService();
  StreamSubscription<List<UserNotification>>? _subscription;

  List<UserNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<UserNotification> get notifications => _notifications;
  List<UserNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasUnreadNotifications => _unreadCount > 0;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load notifications for a user
  Future<void> loadNotifications(String userId, {int? limit}) async {
    try {
      _setLoading(true);
      _setError(null);

      final notifications = await _notificationService.getUserNotifications(
        userId,
        limit: limit,
      );

      _notifications = notifications;
      await _updateUnreadCount(userId);
      
      notifyListeners();

      // Start a real-time subscription so new notifications (including the
      // historical updates we send after follow/register) arrive automatically
      // and update the UI.
      try {
        await _subscription?.cancel();
      } catch (_) {}
      _subscription = _notificationService
          .streamUserNotifications(userId)
          .listen((list) async {
        _notifications = list;
        await _updateUnreadCount(userId);
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update unread count
  Future<void> _updateUnreadCount(String userId) async {
    try {
      _unreadCount = await _notificationService.getUnreadCount(userId);
    } catch (e) {
      print('Failed to update unread count: $e');
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId, String userId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        await _updateUnreadCount(userId);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId, String userId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      await _updateUnreadCount(userId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get unread count (refresh from server)
  Future<void> refreshUnreadCount(String userId) async {
    try {
      await _updateUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      print('Failed to refresh unread count: $e');
    }
  }

  // Send notification (admin function)
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
    String? eventTitle,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notificationId = await _notificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        message: message,
        type: type,
        eventId: eventId,
        eventTitle: eventTitle,
        metadata: metadata,
      );
      
      return notificationId.isNotEmpty;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Stream notifications (for real-time updates)
  Stream<List<UserNotification>> streamNotifications(
    String userId, {
    int? limit,
    bool? unreadOnly,
  }) {
    return _notificationService.streamUserNotifications(
      userId,
      limit: limit,
      unreadOnly: unreadOnly,
    );
  }

  // Clear all notifications from memory (useful when user logs out)
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    _errorMessage = null;
    try {
      _subscription?.cancel();
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      _subscription?.cancel();
    } catch (_) {}
    super.dispose();
  }
}
