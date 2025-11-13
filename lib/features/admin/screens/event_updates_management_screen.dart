import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../shared/models/event.dart';
import '../../shared/models/event_update.dart';
import '../../shared/providers/event_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EventUpdatesManagementScreen extends StatefulWidget {
  final Event event;

  const EventUpdatesManagementScreen({super.key, required this.event});

  @override
  State<EventUpdatesManagementScreen> createState() =>
      _EventUpdatesManagementScreenState();
}

class _EventUpdatesManagementScreenState
    extends State<EventUpdatesManagementScreen> {
  final _updateController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventUpdates();
    });
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  Future<void> _loadEventUpdates() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.fetchEventUpdates(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Event Image and Back Button
            Stack(
              children: [
                // Event Header Image Container
                AspectRatio(
                  aspectRatio: 2 / 1, // 2:1 aspect ratio (width:height)
                  child: Container(
                    width: double.infinity,
                    child: widget.event.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.event.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain, // Changed from cover to contain to avoid cropping
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
                ),
                // Overlapped Back Button
                Padding(
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
              ],
            ),

            // Content Section
            Expanded(
              child: Column(
                children: [
                  // Updates List
                Expanded(
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      final updates = eventProvider.getUpdatesForEvent(
                        widget.event.id,
                      );

                      if (_isLoading && updates.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3F3D9C),
                          ),
                        );
                      }

                      if (updates.isEmpty) {
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
                                'No updates published yet',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first update below',
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
                        onRefresh: _loadEventUpdates,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          itemCount: updates.length,
                          itemBuilder: (context, index) {
                            final update = updates[index];
                            return _buildUpdateCard(update);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    // Floating Action Button for Create Update
    floatingActionButton: Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () => _showCreateUpdateDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F3D9C),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF3F3D9C).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Publish New Update',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}

  Widget _buildUpdateCard(EventUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with delete button and date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    update.timeAgo,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Update Button
                InkWell(
                  onTap: () => _showDeleteUpdateDialog(update),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Update message
            Text(
              update.message,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
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
            const Icon(Icons.event, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.event.title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
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

  void _showCreateUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Publish New Update',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _updateController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter update message...',
              hintStyle: GoogleFonts.hindSiliguri(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3F3D9C),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateController.clear();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _publishUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F3D9C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Publish',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publishUpdate() async {
    if (_updateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter update details',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      final message = _updateController.text.trim();

      final success = await eventProvider.publishEventUpdate(
        eventId: widget.event.id,
        message: message,
        organizerId: authProvider.user!.uid,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Update published successfully!',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear the text field
        _updateController.clear();

        // Reload updates
        await _loadEventUpdates();
      } else if (mounted) {
        final errorMessage =
            eventProvider.errorMessage ?? 'Failed to publish update';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to publish update: $e',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteUpdateDialog(EventUpdate update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Update',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this update? This action cannot be undone.',
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
              _deleteUpdate(update.id);
            },
            child: Text(
              'Delete',
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

  Future<void> _deleteUpdate(String updateId) async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteEventUpdate(updateId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Update deleted successfully',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Reload updates
        await _loadEventUpdates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete update: $e',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
