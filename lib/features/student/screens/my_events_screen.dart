import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event.dart';
import '../../shared/models/event_update.dart';
import '../../shared/services/student_event_interaction_service.dart';
import '../../shared/models/student_event_interaction.dart';
import 'student_event_detail_screen.dart';
import 'event_public_updates_screen.dart';
import 'widgets/student_bottom_navigation.dart';
import 'widgets/student_hamburger_menu.dart';
import 'ticket_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.fetchAllEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Tab Bar Section
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Color(0xFF3F3D9C), width: 2),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                labelColor: const Color(0xFF3F3D9C),
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Registered'),
                  Tab(text: 'Following'),
                  Tab(text: 'Attended'),
                  Tab(text: 'Ended'),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRegisteredEventsTab(),
                _buildFollowingEventsTab(),
                _buildAttendedEventsTab(),
                _buildEndedEventsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildRegisteredEventsTab() {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        if (authProvider.user == null) {
          return _buildEmptyState(
            icon: Icons.person_off,
            title: 'Not logged in',
            message: 'Please log in to view your registered events',
          );
        }

        return FutureBuilder<List<Event>>(
          future: eventProvider.getRegisteredEvents(authProvider.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
              );
            }

            if (snapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.error_outline,
                title: 'Error loading events',
                message: 'Please try again later',
              );
            }

            final registeredEvents = snapshot.data ?? [];

            if (registeredEvents.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_note,
                title: 'No registered events',
                message: 'You haven\'t registered for any events yet',
              );
            }

            return _buildEventsList(registeredEvents, isRegistered: true);
          },
        );
      },
    );
  }

  Widget _buildFollowingEventsTab() {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        if (authProvider.user == null) {
          return _buildEmptyState(
            icon: Icons.person_off,
            title: 'Not logged in',
            message: 'Please log in to view your following events',
          );
        }

        return FutureBuilder<List<Event>>(
          future: eventProvider.getFollowingEvents(authProvider.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
              );
            }

            if (snapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.error_outline,
                title: 'Error loading events',
                message: 'Please try again later',
              );
            }

            final followingEvents = snapshot.data ?? [];

            if (followingEvents.isEmpty) {
              return _buildEmptyState(
                icon: Icons.favorite_border,
                title: 'No following events',
                message: 'Start following events to see them here',
              );
            }

            return _buildEventsList(followingEvents, isFollowing: true);
          },
        );
      },
    );
  }

  Widget _buildAttendedEventsTab() {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        if (authProvider.user == null) {
          return _buildEmptyState(
            icon: Icons.person_off,
            title: 'Not logged in',
            message: 'Please log in to view your attended events',
          );
        }

        return FutureBuilder<List<Event>>(
          future: _getAttendedEvents(authProvider.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
              );
            }

            if (snapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.error_outline,
                title: 'Error loading attended events',
                message: 'Please try again later',
              );
            }

            final attendedEvents = snapshot.data ?? [];

            if (attendedEvents.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_available,
                title: 'No attended events',
                message:
                    'Events you\'ve attended will appear here after ticket scanning',
              );
            }

            return _buildEventsList(attendedEvents, isAttended: true);
          },
        );
      },
    );
  }

  Widget _buildEndedEventsTab() {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        if (authProvider.user == null) {
          return _buildEmptyState(
            icon: Icons.person_off,
            title: 'Not logged in',
            message: 'Please log in to view your ended events',
          );
        }

        final endedEvents = _getEndedEvents(
          eventProvider.events,
          authProvider.user!.uid,
        );

        if (endedEvents.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No ended events',
            message:
                'Events you registered for that have ended will appear here',
          );
        }

        return _buildEventsList(endedEvents, isCompleted: true);
      },
    );
  }

  Widget _buildEventsList(
    List<Event> events, {
    bool isRegistered = false,
    bool isFollowing = false,
    bool isCompleted = false,
    bool isAttended = false,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        final eventProvider = Provider.of<EventProvider>(
          context,
          listen: false,
        );
        await eventProvider.fetchAllEvents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildMyEventCard(
            event,
            isRegistered: isRegistered,
            isFollowing: isFollowing,
            isCompleted: isCompleted,
            isAttended: isAttended,
          );
        },
      ),
    );
  }

  Widget _buildMyEventCard(
    Event event, {
    bool isRegistered = false,
    bool isFollowing = false,
    bool isCompleted = false,
    bool isAttended = false,
  }) {
    final bool hasCertificate = event.certificateFolderUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentEventDetailScreen(event: event),
          ),
        );
        if (result == true && mounted) {
          final eventProvider = Provider.of<EventProvider>(
            context,
            listen: false,
          );
          await eventProvider.fetchAllEvents();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            AspectRatio(
              aspectRatio: 2.0, // 440:220 = 2:1 aspect ratio
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: event.imageUrl.isNotEmpty
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3F3D9C), Color(0xFF5B4FBF)],
                        ),
                ),
                child: event.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          event.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildEventPlaceholder(event.title);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildEventPlaceholder(event.title);
                          },
                        ),
                      )
                    : _buildEventPlaceholder(event.title),
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Event Details Row
                  Row(
                    children: [
                      // Location
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F3D9C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 16,
                                color: const Color(0xFF3F3D9C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F3D9C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: const Color(0xFF3F3D9C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getDateRangeText(event),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Participants information
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F3D9C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.people,
                          size: 16,
                          color: const Color(0xFF3F3D9C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getParticipantText(event),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Registration Deadline (if exists)
                  if (event.registrationDeadline != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.hourglass_bottom,
                            size: 16,
                            color: const Color(0xFF3F3D9C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${event.getRegistrationDeadlineText()}',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Action Buttons Row
                  Row(
                    children: [
                      if (isRegistered) ...[
                        // Updates Button (replaces Cancel Registration)
                        Expanded(
                          child: _buildActionButton(
                            label: 'Updates',
                            icon: Icons.info_outline,
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            textColor: const Color(0xFF3F3D9C),
                            iconColor: const Color(0xFF3F3D9C),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EventPublicUpdatesScreen(
                                  eventId: event.id,
                                  eventTitle: event.title,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // View Ticket Button
                        Expanded(
                          child: _buildActionButton(
                            label: 'View Ticket',
                            icon: Icons.confirmation_number,
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            textColor: const Color(0xFF3F3D9C),
                            iconColor: const Color(0xFF3F3D9C),
                            onTap: () => _viewTicket(event),
                          ),
                        ),
                      ] else if (isFollowing) ...[
                        // Updates Button (replaces Unfollow)
                        Expanded(
                          child: _buildActionButton(
                            label: 'Updates',
                            icon: Icons.info_outline,
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            textColor: const Color(0xFF3F3D9C),
                            iconColor: const Color(0xFF3F3D9C),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EventPublicUpdatesScreen(
                                  eventId: event.id,
                                  eventTitle: event.title,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Register Button
                        Expanded(
                          child: _buildActionButton(
                            label: 'Register Now',
                            icon: Icons.app_registration,
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            textColor: const Color(0xFF3F3D9C),
                            iconColor: const Color(0xFF3F3D9C),
                            onTap: () => _registerForEvent(event),
                          ),
                        ),
                      ] else if (isCompleted) ...[
                        // View Certificate Button
                        Expanded(
                          child: Opacity(
                            opacity: hasCertificate ? 1.0 : 0.5,
                            child: AbsorbPointer(
                              absorbing: !hasCertificate,
                              child: _buildActionButton(
                                label: 'View Certificate',
                                icon: Icons.workspace_premium,
                                color: Colors.amber.shade50,
                                textColor: Colors.amber.shade700,
                                iconColor: Colors.amber.shade700,
                                onTap: () => _viewCertificate(event),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // View Ticket Button
                        Expanded(
                          child: _buildActionButton(
                            label: 'View Ticket',
                            icon: Icons.confirmation_number,
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            textColor: const Color(0xFF3F3D9C),
                            iconColor: const Color(0xFF3F3D9C),
                            onTap: () => _viewTicket(event),
                          ),
                        ),
                      ] else if (isAttended) ...[
                        // View Certificate Button
                        Expanded(
                          child: Opacity(
                            opacity: hasCertificate ? 1.0 : 0.5,
                            child: AbsorbPointer(
                              absorbing: !hasCertificate,
                              child: _buildActionButton(
                                label: 'View Certificate',
                                icon: Icons.workspace_premium,
                                color: Colors.amber.shade50,
                                textColor: Colors.amber.shade700,
                                iconColor: Colors.amber.shade700,
                                onTap: () => _viewCertificate(event),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // View Ticket Button
                        Expanded(
                          child: _buildActionButton(
                            label: 'View Ticket',
                            icon: Icons.confirmation_number,
                            color: const Color(0xFF3F3D9C).withOpacity(0.1),
                            textColor: const Color(0xFF3F3D9C),
                            iconColor: const Color(0xFF3F3D9C),
                            onTap: () => _viewTicket(event),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPlaceholder(String title) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F3D9C), Color(0xFF5B4FBF)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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

  // Helper methods to filter events
  List<Event> _getEndedEvents(List<Event> events, String userId) {
    final now = DateTime.now();
    return events
        .where(
          (event) =>
              event.registeredParticipants.contains(userId) &&
              event.endDate.isBefore(now),
        )
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate)); // Latest first
  }

  Future<List<Event>> _getAttendedEvents(String userId) async {
    try {
      final interactionService = StudentEventInteractionService();
      final completedInteractions = await interactionService
          .getStudentInteractions(userId, type: InteractionType.completed);

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final allEvents = eventProvider.events;

      // Get events that the user has completed interactions for
      final attendedEvents = <Event>[];
      for (final interaction in completedInteractions) {
        final event = allEvents.firstWhere(
          (event) => event.id == interaction.eventId,
          orElse: () => throw Exception('Event not found'),
        );
        attendedEvents.add(event);
      }

      // Sort by latest first
      attendedEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
      return attendedEvents;
    } catch (e) {
      print('Error loading attended events: $e');
      return [];
    }
  }

  String _getDateRangeText(Event event) {
    final dateFormat = DateFormat('MMM dd');
    final startDateStr = dateFormat.format(event.startDate);
    final endDateStr = dateFormat.format(event.endDate);

    if (event.startDate.day == event.endDate.day &&
        event.startDate.month == event.endDate.month &&
        event.startDate.year == event.endDate.year) {
      return DateFormat('MMM dd, yyyy').format(event.startDate);
    } else {
      return '$startDateStr - $endDateStr';
    }
  }

  // Action methods
  // Cancel registration removed from card UI; use detail screen or admin controls to cancel registrations.

  void _viewTicket(Event event) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TicketScreen(userId: authProvider.user!.uid, eventId: event.id),
      ),
    );
  }

  // Unfollow removed from card UI; use detail screen to manage following.

  void _registerForEvent(Event event) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (authProvider.user != null) {
      final success = await eventProvider.registerForEvent(
        event.id,
        authProvider.user!.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Successfully registered for "${event.title}"'
                  : 'Failed to register for event',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _viewCertificate(Event event) async {
    final raw = event.certificateFolderUrl.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certificate viewing feature coming soon!',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
          backgroundColor: Colors.amber.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Normalize URL: if scheme missing, assume https
    String candidate = raw;
    Uri? uri = Uri.tryParse(candidate);
    if (uri == null || uri.scheme.isEmpty) {
      candidate = 'https://$candidate';
      uri = Uri.tryParse(candidate);
    }

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid certificate link.',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final can = await canLaunchUrl(uri);
      if (can) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          // Could not launch even though canLaunchUrl returned true
          throw Exception('launchUrl returned false');
        }
        return;
      }

      // As a last attempt, try to launch anyway and if it fails copy to clipboard
      final attempted = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!attempted) {
        await Clipboard.setData(ClipboardData(text: candidate));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open link. The link has been copied to clipboard.',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: candidate));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open link. The link has been copied to clipboard.',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
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

  Widget _buildBottomNavigationBar() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final hasUnseen = _hasUnseenUpdates(eventProvider);
        return StudentBottomNavigation(
          currentIndex: 1, // My Events screen index
          hasUnseenUpdates: hasUnseen,
        );
      },
    );
  }

  bool _hasUnseenUpdates(EventProvider eventProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) return false;

    final lastSeenTime =
        authProvider.user!.lastSeenUpdateTime ?? DateTime(2020);

    // Get all user updates
    final registeredEvents =
        eventProvider.events
            .where(
              (event) =>
                  event.registeredParticipants.contains(authProvider.user!.uid),
            )
            .toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final List<EventUpdate> userUpdates = <EventUpdate>[];
    for (final event in registeredEvents) {
      final updates = eventProvider.getUpdatesForEvent(event.id);
      userUpdates.addAll(updates);
    }

    // Check if any update is newer than last seen time
    return userUpdates.any((update) => update.createdAt.isAfter(lastSeenTime));
  }

  String _getParticipantText(Event event) {
    final registeredCount = event.registeredParticipants.length;
    final maxParticipants = event.maxParticipants;

    if (maxParticipants == 0) {
      return '$registeredCount registered • Unlimited spots';
    } else {
      final availableSpots = maxParticipants - registeredCount;
      return '$registeredCount/$maxParticipants registered • $availableSpots spots left';
    }
  }
}
