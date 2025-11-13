import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkify/linkify.dart' as lf;
import 'package:flutter/services.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../../admin/screens/edit_event_screen.dart';
import '../../admin/screens/event_updates_management_screen.dart';
import '../../admin/screens/event_registrations_screen.dart';
import '../../admin/screens/view_attendees_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isDeleting = false;
  final ScrollController _scrollController = ScrollController();

  // Custom linkifier: matches tokens containing a dot like `xxx.xxx` and treats them as URLs
  final lf.Linkifier _dotLinkifier = _DotLinkifier();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Image header
                SliverToBoxAdapter(
                  child: AspectRatio(
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
                ),
                // Content section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Title
                        Text(
                          widget.event.title,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Event Details Cards
                        _buildEventInfoCard(),
                        const SizedBox(height: 16),

                        // Description Section
                        _buildDescriptionSection(),
                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating back button
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
      ),
    );
  }  Widget _buildEventPlaceholder() {
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

  Widget _buildEventInfoCard() {
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
      child: Column(
        children: [
          // Location
          _buildInfoRow(icon: Icons.location_on, title: widget.event.location),
          const SizedBox(height: 16),
          // Date
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: DateFormat('d MMMM yyyy').format(widget.event.startDate),
          ),
          const SizedBox(height: 16),
          // Time
          _buildInfoRow(
            icon: Icons.access_time,
            title: '${widget.event.startTime} - ${widget.event.endTime}',
          ),
          const SizedBox(height: 16),
          // Organizer
          _buildInfoRow(
            icon: Icons.business,
            title: widget.event.organizerName,
          ),
          const SizedBox(height: 16),
          // Participants
          _buildInfoRow(icon: Icons.people, title: _getParticipantText()),
          // Registration Deadline (if exists)
          if (widget.event.registrationDeadline != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.hourglass_bottom,
              title: '${widget.event.getRegistrationDeadlineText()}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3F3D9C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF3F3D9C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Description',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy full description',
                    icon: Icon(Icons.copy, size: 20, color: const Color(0xFF3F3D9C)),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: widget.event.description));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Full description copied to clipboard', style: GoogleFonts.hindSiliguri()),
                            backgroundColor: const Color(0xFF3F3D9C),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableLinkify(
                text: widget.event.description,
                linkifiers: [_dotLinkifier, lf.UrlLinkifier()],
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                linkStyle: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  color: const Color(0xFF3F3D9C),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
                onOpen: (link) async {
                  try {
                    final uri = Uri.parse(link.url);
                    
                    if (link.url.startsWith('mailto:')) {
                      // Handle email links
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No email app found to open: ${link.url.replaceFirst('mailto:', '')}', 
                                style: GoogleFonts.hindSiliguri()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      // Handle web URLs
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        // Try adding https:// if missing
                        final httpsUri = Uri.parse('https://${link.url}');
                        if (await canLaunchUrl(httpsUri)) {
                          await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
                        }
                      }
                    }
                  } catch (e) {
                    // If parsing fails, try as a direct URL
                    try {
                      final directUri = Uri.parse(link.url.startsWith('http') ? link.url : 'https://${link.url}');
                      if (await canLaunchUrl(directUri)) {
                        await launchUrl(directUri, mode: LaunchMode.externalApplication);
                      }
                    } catch (e2) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open link: ${link.url}', style: GoogleFonts.hindSiliguri()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Edit Event Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(event: widget.event),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.of(
                  context,
                ).pop(true); // Return to previous screen and refresh
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3F3D9C),
              elevation: 0,
              side: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Edit Event',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Event Updates Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EventUpdatesManagementScreen(event: widget.event),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3F3D9C),
              elevation: 0,
              side: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Event Updates',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // View Registrations Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EventRegistrationsScreen(event: widget.event),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3F3D9C),
              elevation: 0,
              side: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'View Registrations',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // View Attendees Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ViewAttendeesScreen(event: widget.event),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3F3D9C),
              elevation: 0,
              side: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'View Attendees',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Delete Event Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isDeleting ? null : _showDeleteEventDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isDeleting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Delete Event',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showDeleteEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Event',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.event.title}"? This will also delete all updates and registrations. This action cannot be undone.',
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
              _deleteEvent();
            },
            child: Text(
              'Delete Event',
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

  Future<void> _deleteEvent() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final success = await eventProvider.deleteEvent(widget.event.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event deleted successfully',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to the previous screen
        Navigator.of(context).pop(true); // Pass true to indicate deletion
      } else if (mounted) {
        final errorMessage =
            eventProvider.errorMessage ?? 'Failed to delete event';
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
              'Failed to delete event: $e',
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
          _isDeleting = false;
        });
      }
    }
  }

  String _getParticipantText() {
    final registeredCount = widget.event.registeredParticipants.length;
    final maxParticipants = widget.event.maxParticipants;

    if (maxParticipants == 0) {
      return '$registeredCount registered • Unlimited spots';
    } else {
      final availableSpots = maxParticipants - registeredCount;
      return '$registeredCount/$maxParticipants registered • $availableSpots spots left';
    }
  }
}

// Custom linkifier: matches tokens containing a dot like `xxx.xxx` and treats them as URLs
class _DotLinkifier extends lf.Linkifier {
  static final RegExp _urlRegex = RegExp(
    r'\b(?:https?://)?(?:www\.)?[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*(?:\.[a-zA-Z]{2,})(?:/[^\s]*)?\b',
    caseSensitive: false,
  );
  
  static final RegExp _emailRegex = RegExp(
    r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}\b',
    caseSensitive: false,
  );

  @override
  List<lf.LinkifyElement> parse(List<lf.LinkifyElement> elements, lf.LinkifyOptions options) {
    final result = <lf.LinkifyElement>[];
    for (final element in elements) {
      if (element is lf.TextElement) {
                result.addAll(_parseText(element.text));
      } else {
        result.add(element);
      }
    }
    return result;
  }

  List<lf.LinkifyElement> _parseText(String text) {
    final elements = <lf.LinkifyElement>[];
    
    // First, find all email matches (more specific)
    final emailMatches = _emailRegex.allMatches(text).toList();
    
    // Then find URL matches that don't overlap with emails
    final urlMatches = <Match>[];
    for (final urlMatch in _urlRegex.allMatches(text)) {
      bool overlapsWithEmail = false;
      for (final emailMatch in emailMatches) {
        if (urlMatch.start < emailMatch.end && urlMatch.end > emailMatch.start) {
          overlapsWithEmail = true;
          break;
        }
      }
      if (!overlapsWithEmail) {
        urlMatches.add(urlMatch);
      }
    }
    
    // Combine and sort all matches
    final allMatches = <Match>[];
    allMatches.addAll(emailMatches);
    allMatches.addAll(urlMatches);
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    
    int start = 0;
    for (final match in allMatches) {
      if (match.start > start) {
        elements.add(lf.TextElement(text.substring(start, match.start)));
      }
      
      final matched = match.group(0)!;
      
      // Check if it's an email or URL
      if (_emailRegex.hasMatch(matched)) {
        // It's an email
        final emailLink = matched.startsWith('mailto:') ? matched : 'mailto:$matched';
        elements.add(lf.LinkableElement(matched, emailLink));
      } else {
        // It's a URL
        final link = matched.startsWith(RegExp(r'https?://', caseSensitive: false))
            ? matched
            : 'https://$matched';
        elements.add(lf.LinkableElement(matched, link));
      }
      
      start = match.end;
    }
    
    if (start < text.length) {
      elements.add(lf.TextElement(text.substring(start)));
    }
    return elements;
  }
}
