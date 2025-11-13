import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event.dart';
import '../../shared/models/event_update.dart';
import 'student_event_detail_screen.dart';
import 'widgets/student_bottom_navigation.dart';
import 'widgets/student_hamburger_menu.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Fetch ALL events from ALL organizers
      eventProvider.fetchAllEvents();

      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          final eventProvider = Provider.of<EventProvider>(
            context,
            listen: false,
          );
          switch (_tabController.index) {
            case 0:
              eventProvider.setFilter(EventFilter.all);
              break;
            case 1:
              eventProvider.setFilter(EventFilter.current);
              break;
            case 2:
              eventProvider.setFilter(EventFilter.upcoming);
              break;
            case 3:
              eventProvider.setFilter(EventFilter.past);
              break;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
                  Tab(text: 'All Events'),
                  Tab(text: 'Current'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past Events'),
                ],
              ),
            ),
          ),
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<EventProvider>(
                  context,
                  listen: false,
                ).searchEvents(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by event name',
                hintStyle: GoogleFonts.hindSiliguri(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<EventProvider>(
                            context,
                            listen: false,
                          ).clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          // Events List
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                if (eventProvider.isLoading && eventProvider.events.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
                  );
                }

                if (eventProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading events',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eventProvider.errorMessage!,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            eventProvider.fetchAllEvents();
                          },
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

                if (eventProvider.filteredEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eventProvider.searchQuery.isNotEmpty
                              ? 'Try adjusting your search query'
                              : 'No events available at the moment',
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
                  onRefresh: () async {
                    await eventProvider.fetchAllEvents();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount: eventProvider.filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = eventProvider.filteredEvents[index];
                      return _buildEventCard(event);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentEventDetailScreen(event: event),
          ),
        );
        if (result == true && mounted) {
          // Refresh events if something was updated
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
                          fit: BoxFit
                              .cover, // Keep cover to fill the container properly
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
                  // Location
                  Row(
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
                  const SizedBox(height: 8),
                  // Date Range
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
                      Expanded(
                        child: Text(
                          _getDateRangeText(event),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F3D9C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          size: 16,
                          color: const Color(0xFF3F3D9C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.startTime} - ${event.endTime}',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Organizer
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F3D9C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.business,
                          size: 16,
                          color: const Color(0xFF3F3D9C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.organizerName,
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
                  const SizedBox(height: 8),
                  // Participants
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
                    const SizedBox(height: 8),
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
                ],
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
          currentIndex: 2, // Explore screen index
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
    final registeredEvents = eventProvider.events
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
