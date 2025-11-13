import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event_update.dart';
import '../../shared/services/student_event_interaction_service.dart';
import '../../shared/models/student_event_interaction.dart';
import 'widgets/student_bottom_navigation.dart';
import 'widgets/student_hamburger_menu.dart';
import 'student_edit_profile_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final StudentEventInteractionService _interactionService = StudentEventInteractionService();

  Future<Map<String, int>> _getStats(String userId) async {
    try {
      final attendedInteractions = await _interactionService.getStudentInteractions(
        userId,
        type: InteractionType.completed,
      );

      final registeredInteractions = await _interactionService.getStudentInteractions(
        userId,
        type: InteractionType.registered,
      );

      return {
        'attended': attendedInteractions.length,
        'registered': registeredInteractions.length,
      };
    } catch (e) {
      print('Error fetching stats: $e');
      return {'attended': 0, 'registered': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Purple header section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3F3D9C), Color(0xFF5B4FBF)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Text(
                          'DIU ',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Events',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => StudentHamburgerMenu.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Profile Image and Info
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final user = authProvider.user;
                        if (user == null) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Image
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: user.profilePicture.isNotEmpty
                                    ? Image.network(
                                        user.profilePicture,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.white,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: const Color(0xFF3F3D9C),
                                                strokeWidth: 2,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          print(
                                            'Error loading profile image: $error',
                                          );
                                          return Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.white,
                                            child: Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey.shade400,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.white,
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // User Name
                            Text(
                              user.name,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Student ID from user profile
                            if (user.studentId.isNotEmpty)
                              Text(
                                user.studentId,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            if (user.studentId.isNotEmpty)
                              const SizedBox(height: 4),
                            // Department from user profile
                            if (user.department.isNotEmpty)
                              Text(
                                user.department,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            if (user.department.isNotEmpty)
                              const SizedBox(height: 4),
                            // Email from Google account
                            Text(
                              user.email,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            // Phone Number from user profile
                            if (user.phone.isNotEmpty)
                              Text(
                                user.phone,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content Section (modernized)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  if (user == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return FutureBuilder<Map<String, int>>(
                    future: _getStats(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final stats = snapshot.data ?? {'attended': 0, 'registered': 0};

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Quick Stats
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Attended Events',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${stats['attended']}',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF3F3D9C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Registered Events',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${stats['registered']}',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF3F3D9C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Spacer pushes buttons to bottom
                          const Spacer(),

                          // Edit Profile button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const StudentEditProfileScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF3F3D9C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: Color(0xFF3F3D9C),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          final hasUnseen = _hasUnseenUpdates(eventProvider);
          return StudentBottomNavigation(
            currentIndex: 4, // Profile screen index
            hasUnseenUpdates: hasUnseen,
          );
        },
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
}
