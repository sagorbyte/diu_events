import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../shared/models/event.dart';
import '../../shared/providers/event_provider.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../utils/download_helper_web.dart'
    if (dart.library.io) '../../../utils/download_helper_io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';

class EventRegistrationsScreen extends StatefulWidget {
  final Event event;

  const EventRegistrationsScreen({super.key, required this.event});

  @override
  State<EventRegistrationsScreen> createState() =>
      _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppUser> _registeredUsers = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRegisteredUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRegisteredUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      _registeredUsers = await eventProvider.getRegisteredUsers(
        widget.event.id,
      );
      _filteredUsers = List.from(_registeredUsers);
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load registered users: $e',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // Fallback to empty list on error
      _registeredUsers = [];
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
      _filteredUsers = _registeredUsers.where((user) {
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
      if (_registeredUsers.isEmpty) {
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
      for (final u in _registeredUsers) {
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
                  // Participant Statistics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildParticipantStats(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _exportAttendeesCsv,
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Export Registree CSV'),
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
                  // Registered Users List
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
                                  'No registrations found',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
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
            const Icon(Icons.event, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.event.title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
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
                // Cancel Registration Button
                _buildActionButton(
                  onTap: () => _showCancelRegistrationDialog(user),
                  color: Colors.red.shade50,
                  iconColor: Colors.red.shade600,
                  icon: Icons.cancel,
                ),
                // only Cancel Registration button remains
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

  void _showCancelRegistrationDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Registration',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to cancel ${user.name}\'s registration for this event?',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelUserRegistration(user);
            },
            child: Text(
              'Confirm',
              style: GoogleFonts.hindSiliguri(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelUserRegistration(AppUser user) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Cancel Registration',
            style: GoogleFonts.hindSiliguri(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          content: Text(
            'Are you sure you want to cancel ${user.name}\'s registration for this event? They will be notified of the cancellation.',
            style: GoogleFonts.hindSiliguri(color: const Color(0xFF4A5568)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: GoogleFonts.hindSiliguri(color: const Color(0xFF718096)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Yes, Cancel',
                style: GoogleFonts.hindSiliguri(
                  color: const Color(0xFFE53E3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Cancel the registration using the admin method
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      final success = await Provider.of<EventProvider>(context, listen: false)
          .cancelUserRegistration(
            widget.event.id,
            user.uid,
            adminId: currentUser?.uid,
            userDisplayName: user.name,
          );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Remove user from local list
        setState(() {
          _registeredUsers.removeWhere((u) => u.uid == user.uid);
          _filterUsers();
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration cancelled for ${user.name}',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF48BB78),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Show error message
        final errorMessage =
            Provider.of<EventProvider>(context, listen: false).errorMessage ??
            'Failed to cancel registration';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFE53E3E),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE53E3E),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildParticipantStats() {
    final totalRegistered = _registeredUsers.length;
    final maxParticipants = widget.event.maxParticipants;
    final availableSpots = maxParticipants > 0
        ? maxParticipants - totalRegistered
        : -1;

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
          // Total Registered
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalRegistered',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3F3D9C),
                  ),
                ),
                Text(
                  'Registered',
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
          // Available Spots / Limit
          Expanded(
            child: Column(
              children: [
                Text(
                  maxParticipants > 0 ? '$availableSpots' : '∞',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: availableSpots == 0 ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  maxParticipants > 0 ? 'Spots Left' : 'Unlimited',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (maxParticipants > 0) ...[
            // Divider
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            // Max Participants
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$maxParticipants',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Max Limit',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Certificate upload handled on View Attendees screen only
}
