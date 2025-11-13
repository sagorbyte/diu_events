import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../shared/models/user_notification.dart';
import '../../shared/providers/user_notification_provider.dart';
import '../../shared/widgets/notification_card.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/student_bottom_navigation.dart';
import 'widgets/student_hamburger_menu.dart';

class EventUpdatesScreen extends StatefulWidget {
  const EventUpdatesScreen({super.key});

  @override
  State<EventUpdatesScreen> createState() => _EventUpdatesScreenState();
}

class _EventUpdatesScreenState extends State<EventUpdatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUpdates();
      _markUpdatesAsSeen();
    });
  }

  Future<void> _loadUpdates() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      await notificationProvider.loadNotifications(authProvider.user!.uid);
    }
  }

  Future<void> _markUpdatesAsSeen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updateLastSeenUpdateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: Consumer2<UserNotificationProvider, AuthProvider>(
        builder: (context, notificationProvider, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: Text('Please log in to view notifications'),
            );
          }

          if (notificationProvider.isLoading &&
              notificationProvider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
            );
          }

          if (notificationProvider.errorMessage != null &&
              notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationProvider.errorMessage!,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUpdates,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F3D9C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
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
                    'No notifications yet',
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
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadUpdates,
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
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildNotificationCard(UserNotification notification, String userId) {
    return NotificationCard(
      notification: notification,
      dense: false,
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            'DIU ',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Text(
            'Events',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3F3D9C),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF3F3D9C), size: 28),
          onPressed: () => StudentHamburgerMenu.show(context),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return const StudentBottomNavigation(
      currentIndex: 3, // Updates screen index
      hasUnseenUpdates:
          false, // Always false since user is already viewing updates
    );
  }
}
