import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../student_home_screen.dart';
import '../my_events_screen.dart';
import '../explore_screen.dart';
import '../event_updates_screen.dart';
import '../student_profile_screen.dart';

class StudentBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final bool hasUnseenUpdates;

  const StudentBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.hasUnseenUpdates = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3F3D9C),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
  selectedLabelStyle: GoogleFonts.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
  unselectedLabelStyle: GoogleFonts.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        onTap: onTap ?? (index) => _handleNavigation(context, index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.event), label: 'My Events'),
          const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (hasUnseenUpdates)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Updates',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Don't navigate if already on the same screen
    if (index == currentIndex) return;

    Widget? targetScreen;

    switch (index) {
      case 0:
        targetScreen = const StudentHomeScreen();
        break;
      case 1:
        targetScreen = const MyEventsScreen();
        break;
      case 2:
        targetScreen = const ExploreScreen();
        break;
      case 3:
        targetScreen = const EventUpdatesScreen();
        break;
      case 4:
        // Profile
        targetScreen = const StudentProfileScreen();
        break;
    }

    if (targetScreen != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              targetScreen!,
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }
}
