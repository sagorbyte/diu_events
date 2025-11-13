import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event_update.dart';
import '../../shared/models/event.dart';

class EventPublicUpdatesScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const EventPublicUpdatesScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  State<EventPublicUpdatesScreen> createState() => _EventPublicUpdatesScreenState();
}

class _EventPublicUpdatesScreenState extends State<EventPublicUpdatesScreen> {
  bool _isLoading = true;
  Event? _event;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    final provider = Provider.of<EventProvider>(context, listen: false);
    await provider.fetchEventUpdates(widget.eventId);
    // Also fetch event details for header
    final evt = await provider.getEventById(widget.eventId);
    if (mounted) {
      setState(() {
        _event = evt;
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
            // Header similar to admin screen
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 1, // 2:1 aspect ratio (width:height)
                  child: Container(
                    width: double.infinity,
                    child: _event != null && _event!.imageUrl.isNotEmpty
                        ? Image.network(
                            _event!.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain, // Changed from cover to contain to avoid cropping
                            errorBuilder: (context, error, stackTrace) => _buildEventPlaceholder(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildEventPlaceholder();
                            },
                          )
                        : _buildEventPlaceholder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Consumer<EventProvider>(
                builder: (context, provider, child) {
                  if (_isLoading) return const Center(child: CircularProgressIndicator());

                  final updates = provider.getUpdatesForEvent(widget.eventId);

                  if (updates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No updates published yet', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Text('Updates published by the event organizer will appear here.', style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadUpdates,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: updates.length,
                    itemBuilder: (context, index) => _buildUpdateCard(updates[index]),
                  ),
                );
              },
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
        child: Text(widget.eventTitle, style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildUpdateCard(EventUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with timestamp
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  update.timeAgo,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Message content
            Text(
              update.message,
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
