import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/event.dart';
import '../../auth/models/app_user.dart';
import '../../../utils/download_helper_web.dart'
    if (dart.library.io) '../../../utils/download_helper_io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import '../../shared/services/user_notification_service.dart';
import '../../../services/fcm_v1_service.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/services/student_event_interaction_service.dart';
import '../../shared/models/student_event_interaction.dart';
import 'ticket_scanner_screen.dart';

class ViewAttendeesScreen extends StatefulWidget {
  final Event event;

  const ViewAttendeesScreen({super.key, required this.event});

  @override
  State<ViewAttendeesScreen> createState() => _ViewAttendeesScreenState();
}

class _ViewAttendeesScreenState extends State<ViewAttendeesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppUser> _attendedUsers = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = false;
  int _totalAttendees = 0;

  @override
  void initState() {
    super.initState();
    _loadAttendedUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAttendedUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final interactionService = StudentEventInteractionService();

      // Get all completed interactions for this event (attendees)
      final completedInteractions = await interactionService
          .getEventInteractions(
            widget.event.id,
            type: InteractionType.completed,
          );

      _totalAttendees = completedInteractions.length;

      if (completedInteractions.isEmpty) {
        _attendedUsers = [];
        _filteredUsers = [];
      } else {
        // Get user details for each attendee
        List<AppUser> attendees = [];
        for (final interaction in completedInteractions) {
          try {
            // Get user data from firestore
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(interaction.studentId)
                .get();

            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              final user = AppUser(
                uid: interaction.studentId,
                name: userData['name'] ?? 'Unknown',
                email: userData['email'] ?? '',
                studentId: userData['studentId'] ?? '',
                department: userData['department'] ?? '',
                phone: userData['phone'] ?? '',
                profilePicture: userData['profilePicture'] ?? '',
                role: userData['role'] ?? 'student',
              );
              attendees.add(user);
            }
          } catch (e) {
            print('Error loading user ${interaction.studentId}: $e');
          }
        }

        _attendedUsers = attendees;
        _filteredUsers = List.from(_attendedUsers);
      }
    } catch (e) {
      print('Error loading attendees: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load attendees: $e',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _attendedUsers = [];
      _filteredUsers = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _attendedUsers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.department.toLowerCase().contains(query) ||
            user.studentId.toLowerCase().contains(query) ||
            user.phone.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Export attendees as CSV
  void _exportAttendeesCsv() async {
    try {
      if (_attendedUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No attendees to export',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
          ),
        );
        return;
      }

      final rows = <List<String>>[];
      rows.add(['uid', 'name', 'email', 'studentId', 'department', 'phone']);
      for (final u in _attendedUsers) {
        rows.add([u.uid, u.name, u.email, u.studentId, u.department, u.phone]);
      }

      final csv = rows
          .map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(','))
          .join('\n');

      final filename =
          '${widget.event.title.replaceAll(' ', '_')}_attendees.csv';

      if (kIsWeb) {
        await downloadFile(filename, csv);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CSV downloaded',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
          ),
        );
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsString(csv);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CSV saved to ${file.path}',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to export CSV: $e',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
        ),
      );
    }
  }

  // Show dialog to set certificate folder link for the event
  void _showSetCertificateFolderDialog() {
    final TextEditingController controller = TextEditingController(
      text: widget.event.certificateFolderUrl,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Certificates Folder Link',
          style: GoogleFonts.hindSiliguri(),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'https://drive.google.com/...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.hindSiliguri()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _setCertificateFolderLink(controller.text.trim());
            },
            child: Text('Save', style: GoogleFonts.hindSiliguri()),
          ),
        ],
      ),
    );
  }

  // Save folder link to event and notify attendees
  void _setCertificateFolderLink(String url) async {
    if (url.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Update event via provider
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final updatedEvent = widget.event.copyWith(
        certificateFolderUrl: url,
        updatedAt: DateTime.now(),
      );
      final success = await eventProvider.updateEvent(updatedEvent);
      if (!success) throw Exception('Failed to save event');

      // Notify attendees in-app and push
      final userIds = _attendedUsers.map((u) => u.uid).toList();
      final notificationService = UserNotificationService();
      final fcmService = FCMV1Service();

      // Create notification documents for all attendees
      for (final uid in userIds) {
        await notificationService.sendNotificationToUser(
          userId: uid,
          title: 'Certificates Published',
          message:
              'Certificates for "${widget.event.title}" are now available. Check the certificates folder.',
          type: 'certificate_published',
          eventId: widget.event.id,
          eventTitle: widget.event.title,
        );
      }

      // Also send push notifications in bulk (fire-and-forget)
      Future(
        () => fcmService.sendBulkPushNotification(
          userIds: userIds,
          title: 'Certificates Published',
          message:
              'Certificates for "${widget.event.title}" are now available.',
          type: 'certificate_published',
          eventId: widget.event.id,
          eventTitle: widget.event.title,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certificate folder link saved and attendees notified',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save folder link: $e',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Event Image and Overlapped Back Button
            Stack(
              children: [
                // Event Header Image Container
                Container(
                  width: double.infinity,
                  height: 220, // Exactly 220px for image
                  child: widget.event.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.event.imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildEventPlaceholder();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildEventPlaceholder();
                          },
                        )
                      : _buildEventPlaceholder(),
                ),
                // Overlapped Back Button (inside SafeArea)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
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
                        decoration: InputDecoration(
                          hintText:
                              'Search by name, ID, email, department, or phone',
                          hintStyle: GoogleFonts.hindSiliguri(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  // Attendance Statistics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildAttendanceStats(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _exportAttendeesCsv,
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Export Attendees CSV'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showSetCertificateFolderDialog,
                                icon: const Icon(Icons.folder_open),
                                label: const Text('Set Certificates Folder'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Attended Users List
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF3F3D9C),
                            ),
                          )
                        : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No attendees yet',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Attendees will appear here after their tickets are scanned',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Scan Ticket Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Builder(
          builder: (context) {
            final now = DateTime.now();
            final eventStartTime = widget.event.startDate;
            final isEventStarted =
                now.isAfter(eventStartTime) ||
                now.isAtSameMomentAs(eventStartTime);

            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isEventStarted
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketScannerScreen(eventId: widget.event.id),
                          ),
                        );
                      }
                    : null, // Disabled when event hasn't started
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEventStarted
                      ? const Color(0xFF3F3D9C)
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: isEventStarted ? 4 : 0,
                  shadowColor: isEventStarted
                      ? const Color(0xFF3F3D9C).withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isEventStarted
                      ? 'Scan Ticket'
                      : 'Scanning starts at ${widget.event.startTime}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventPlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
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
                widget.event.title,
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

  Widget _buildAttendanceStats() {
    final totalRegistered = widget.event.registeredParticipants.length;
    final attendanceRate = totalRegistered > 0
        ? ((_totalAttendees / totalRegistered) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Total Attendees
          Expanded(
            child: Column(
              children: [
                Text(
                  '$_totalAttendees',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3F3D9C),
                  ),
                ),
                Text(
                  'Attended',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          // Attendance Rate
          Expanded(
            child: Column(
              children: [
                Text(
                  '$attendanceRate%',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade600,
                  ),
                ),
                Text(
                  'Attendance Rate',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Avatar/Profile Photo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF3F3D9C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: user.profilePicture.isNotEmpty
                    ? Image.network(
                        user.profilePicture,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3F3D9C),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3F3D9C),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name
                  Text(
                    user.name,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Student ID
                  if (user.studentId.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.studentId,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  if (user.studentId.isNotEmpty) const SizedBox(height: 4),
                  // Department
                  if (user.department.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.department,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (user.department.isNotEmpty) const SizedBox(height: 4),
                  // Email
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.email,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Phone
                  if (user.phone.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.phone,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                // Attendance Status Icon
                _buildActionButton(
                  onTap: () {}, // No action needed, just visual indicator
                  color: Colors.green.shade50,
                  iconColor: Colors.green.shade600,
                  icon: Icons.check_circle,
                ),
                const SizedBox(height: 8),
                // (Upload Certificate button removed; certificate uploads are handled via the Set Certificates Folder flow)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  // Per-user certificate upload removed; certificates are published via a folder link.
}
