import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event.dart';
import '../../shared/models/event_update.dart';
import '../../shared/models/user_notification.dart';
import '../../shared/providers/user_notification_provider.dart';
import '../../shared/widgets/notification_card.dart';
import 'student_event_detail_screen.dart';
import 'widgets/student_bottom_navigation.dart';
import 'widgets/student_hamburger_menu.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // The index is tracked for potential future use (pagination or analytics).
  // ignore: unused_field
  int _currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Fetch all events for students
      eventProvider.fetchAllEvents();

      // Fetch event updates for registered events
      if (authProvider.user != null) {
        _fetchUserEventUpdates();
        // Load per-user notifications so Recent Updates can display them
        final notificationProvider = Provider.of<UserNotificationProvider>(
          context,
          listen: false,
        );
        notificationProvider.loadNotifications(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchUserEventUpdates() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user != null) {
      // Fetch updates for events the user is registered for
      final registeredEvents =
          eventProvider.events
              .where(
                (event) => event.registeredParticipants.contains(
                  authProvider.user!.uid,
                ),
              )
              .toList()
            ..sort((a, b) => b.startDate.compareTo(a.startDate));

      for (final event in registeredEvents) {
        await eventProvider.fetchEventUpdates(event.id);
      }
    }
  }

  Future<void> _refreshData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.fetchAllEvents();
    _fetchUserEventUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Slider Section
              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  final recentEvents =
                      eventProvider.events
                          .where((event) => event.isActive)
                          .toList()
                        ..sort((a, b) => b.startDate.compareTo(a.startDate));

                  final topEvents = recentEvents.take(5).toList();

                  if (topEvents.isEmpty) {
                    return _buildEmptySlider();
                  }

                  return _buildEventSlider(topEvents);
                },
              ),

              const SizedBox(height: 24),

              // Today's Events Section
              _buildSectionHeader("Today's Event"),
              const SizedBox(height: 12),
              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  final todayEvents = _getTodayEvents(eventProvider.events);

                  if (todayEvents.isEmpty) {
                    return _buildEmptySection(
                      icon: Icons.event_note,
                      message: "No events scheduled for today",
                    );
                  }

                  return _buildTodayEventsList(todayEvents);
                },
              ),

              const SizedBox(height: 24),

              // Recent Updates Section (use same UI as Updates screen, limited to latest 4)
              _buildSectionHeader("Recent Updates"),
              const SizedBox(height: 12),
              Consumer2<UserNotificationProvider, AuthProvider>(
                builder: (context, notificationProvider, authProvider, child) {
                  if (authProvider.user == null) {
                    return _buildEmptySection(
                      icon: Icons.person_off,
                      message: 'Please log in to see updates',
                    );
                  }

                  final notifications = notificationProvider.notifications;
                  if (notifications.isEmpty) {
                    return _buildEmptySection(
                      icon: Icons.notifications_none,
                      message: "No recent updates",
                    );
                  }

                  final latest = notifications.toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  final limited = latest.take(4).toList();

                  return Container(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: limited.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildNotificationCard(
                        limited[index],
                        authProvider.user!.uid,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 100), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
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

  Widget _buildEventSlider(List<Event> events) {
    return Column(
      children: [
        // Limit slider height to a maximum of 220px while keeping approximate 2:1 aspect ratio
        SizedBox(
          height: (() {
            final double candidate = MediaQuery.of(context).size.width / 2;
            return candidate > 220.0 ? 220.0 : candidate;
          })(),
          child: Swiper(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildSliderCard(event);
            },
            autoplay: true,
            autoplayDelay: 5000, // 5 seconds delay
            onIndexChanged: (index) {
              setState(() {
                _currentSliderIndex = index;
              });
            },
            pagination: const SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                activeColor: Color(0xFF3F3D9C),
                color: Colors.grey,
                size: 8.0,
                activeSize: 8.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard(Event event) {
    return GestureDetector(
      onTap: () => _openEventDetails(event),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: event.imageUrl.isNotEmpty
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 440.0,
                      maxHeight: 220.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        event.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildEventPlaceholder(event.title);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFF3F3D9C),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : _buildEventPlaceholder(event.title),
        ),
      ),
    );
  }

  Widget _buildEmptySlider() {
    return AspectRatio(
      aspectRatio: 2.0, // Match the 2:1 aspect ratio of the carousel
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No events available',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  List<Event> _getTodayEvents(List<Event> events) {
    final today = DateTime.now();
    return events.where((event) {
      return event.startDate.year == today.year &&
          event.startDate.month == today.month &&
          event.startDate.day == today.day;
    }).toList();
  }

  Widget _buildTodayEventsList(List<Event> todayEvents) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: todayEvents.length,
        itemBuilder: (context, index) {
          final event = todayEvents[index];
          return _buildTodayEventCard(event);
        },
      ),
    );
  }

  Widget _buildTodayEventCard(Event event) {
    return GestureDetector(
      onTap: () => _openEventDetails(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                      event.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildEventPlaceholder(event.title),
                    )
                  : SizedBox(
                      width: 100,
                      height: 100,
                      child: _buildEventPlaceholder(event.title),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getDateRangeText(event),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasUnseenUpdates(EventProvider eventProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) return false;

    final lastSeenTime =
        authProvider.user!.lastSeenUpdateTime ?? DateTime(2020);

    // Get all user updates
    final registeredEvents = eventProvider.events
        .where(
          (event) =>
              event.registeredParticipants.contains(authProvider.user!.uid),
        )
        .toList();

    final List<EventUpdate> userUpdates = [];
    for (final event in registeredEvents) {
      final updates = eventProvider.getUpdatesForEvent(event.id);
      userUpdates.addAll(updates);
    }

    // Check if any update is newer than last seen time
    return userUpdates.any((update) => update.createdAt.isAfter(lastSeenTime));
  }

  // EventUpdate-based recent list is no longer used; Recent Updates now shows user notifications.

  Widget _buildNotificationCard(UserNotification notification, String userId) {
    final notificationProvider = Provider.of<UserNotificationProvider>(
      context,
      listen: false,
    );

    return NotificationCard(
      notification: notification,
      dense: true,
      onTap: () {
        if (!notification.isRead) {
          notificationProvider.markAsRead(notification.id, userId);
        }
      },
    );
  }

  // Notification helpers moved to shared widget `NotificationCard`.

  // Removed old EventUpdate-based card - home uses UserNotification cards now.

  Widget _buildEmptySection({required IconData icon, required String message}) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPlaceholder(String title) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F3D9C), Color(0xFF5B4FBF)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeText(Event event) {
    final dateFormat = DateFormat('d MMMM yyyy');
    final startDateStr = dateFormat.format(event.startDate);
    final endDateStr = dateFormat.format(event.endDate);

    if (event.startDate.day == event.endDate.day &&
        event.startDate.month == event.endDate.month &&
        event.startDate.year == event.endDate.year) {
      return startDateStr;
    } else {
      return '$startDateStr - $endDateStr';
    }
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final hasUnseen = _hasUnseenUpdates(eventProvider);
        return StudentBottomNavigation(
          currentIndex: 0, // Home screen index
          hasUnseenUpdates: hasUnseen,
        );
      },
    );
  }

  void _openEventDetails(Event event) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentEventDetailScreen(event: event),
      ),
    );
    if (result == true && mounted) {
      // Refresh events if something was updated
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.fetchAllEvents();
    }
  }
}
