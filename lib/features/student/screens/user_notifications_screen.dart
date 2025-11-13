import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/user_notification_provider.dart';
import '../../shared/widgets/notification_card.dart';
import '../../shared/models/user_notification.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  State<UserNotificationsScreen> createState() =>
      _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      notificationProvider.loadNotifications(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.hindSiliguri(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<UserNotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.hasUnreadNotifications) {
                return TextButton(
                  onPressed: () => _markAllAsRead(),
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.hindSiliguri(
                      color: const Color(0xFF3F3D9C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<UserNotificationProvider, AuthProvider>(
        builder: (context, notificationProvider, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: Text('Please log in to view notifications'),
            );
          }

          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
            );
          }

          if (notificationProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationProvider.errorMessage!,
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F3D9C),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see your notifications here',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadNotifications(),
            color: const Color(0xFF3F3D9C),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationCard(
                  notification,
                  authProvider.user!.uid,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(UserNotification notification, String userId) {
    return NotificationCard(
      notification: notification,
      dense: true,
      onTap: () => _handleNotificationTap(notification, userId),
    );
  }

  void _handleNotificationTap(UserNotification notification, String userId) {
    final notificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    if (!notification.isRead) {
      notificationProvider.markAsRead(notification.id, userId);
    }

    // You can add navigation logic here based on notification type
    // For example, navigate to event details if it's an event-related notification
  }

  void _markAllAsRead() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      notificationProvider.markAllAsRead(authProvider.user!.uid);
    }
  }

  // Time formatting handled in shared widget if needed.
}
