import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/screens/login_screen.dart';
import '../student_profile_screen.dart';
import '../event_updates_screen.dart';
import '../my_events_screen.dart';
import '../settings_screen.dart';
import '../help_support_screen.dart';
import '../about_screen.dart';

class StudentHamburgerMenu {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with user info
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Profile image or avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              authProvider.user?.profilePicture != null &&
                                  authProvider.user!.profilePicture.isNotEmpty
                              ? Image.network(
                                  authProvider.user!.profilePicture,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildAvatarFallback(authProvider);
                                  },
                                )
                              : _buildAvatarFallback(authProvider),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.name ?? 'Student',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.email ?? '',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (authProvider.user?.studentId != null &&
                                authProvider.user!.studentId.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                authProvider.user!.studentId,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            // Menu items
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.person_outline,
                    'My Profile',
                    () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const StudentProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.event_note_outlined,
                    'My Events',
                    () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MyEventsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications_outlined,
                    'Updates',
                    () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const EventUpdatesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline,
                    'Help & Support',
                    () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(context, Icons.info_outline, 'About', () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  }),
                  const Divider(),
                  _buildMenuItem(context, Icons.logout, 'Logout', () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context);
                  }, isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAvatarFallback(AuthProvider authProvider) {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFF3F3D9C),
      child: Center(
        child: Text(
          authProvider.user?.name != null && authProvider.user!.name.isNotEmpty
              ? authProvider.user!.name.substring(0, 1).toUpperCase()
              : 'U',
          style: GoogleFonts.hindSiliguri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF3F3D9C),
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  static void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
                  ),
                );

                // Perform logout
                try {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();

                  // Close loading dialog and force navigation to login screen
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loading dialog

                    // Force navigation to login screen by clearing the entire navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to logout: ${e.toString()}',
                          style: GoogleFonts.hindSiliguri(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
