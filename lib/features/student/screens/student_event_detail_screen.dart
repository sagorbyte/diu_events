import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkify/linkify.dart' as lf;
import 'package:flutter/services.dart';
import '../../shared/models/event.dart';
import '../../shared/providers/event_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'event_public_updates_screen.dart';
import 'ticket_screen.dart';

class StudentEventDetailScreen extends StatefulWidget {
  final Event event;

  const StudentEventDetailScreen({super.key, required this.event});

  @override
  State<StudentEventDetailScreen> createState() =>
      _StudentEventDetailScreenState();
}

class _StudentEventDetailScreenState extends State<StudentEventDetailScreen> {
  bool _isRegistering = false;
  bool _isUnregistering = false;
  bool _isToggleFollow = false;
  bool _isFollowing = false;
  bool _isLoadingFollowingStatus = true;
  final ScrollController _scrollController = ScrollController();

  // Custom linkifier: matches tokens containing a dot like `xxx.xxx` and treats them as URLs
  final lf.Linkifier _dotLinkifier = _DotLinkifier();

  @override
  void initState() {
    super.initState();
    _loadFollowingStatus();
  }

  Future<void> _loadFollowingStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (authProvider.user != null) {
      try {
        final isFollowing = await eventProvider.isUserFollowing(
          widget.event.id,
          authProvider.user!.uid,
        );
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
            _isLoadingFollowingStatus = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingFollowingStatus = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingFollowingStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _viewCertificate() async {
    final raw = widget.event.certificateFolderUrl.trim();
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
        if (!launched) throw Exception('launchUrl returned false');
        return;
      }

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
                              fit: BoxFit
                                  .contain, // Changed from cover to contain to avoid cropping
                              errorBuilder: (context, error, stackTrace) {
                                return _buildEventPlaceholder();
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildEventPlaceholder();
                                  },
                            )
                          : _buildEventPlaceholder(),
                    ),
                  ),
                ),
                // Event details content
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
          // Registration Status
          _buildInfoRow(icon: Icons.group, title: _getRegistrationStatusText()),
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
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getRegistrationStatusText() {
    final registeredCount = widget.event.registeredParticipants.length;
    final maxParticipants = widget.event.maxParticipants;

    if (maxParticipants == 0) {
      return '$registeredCount registered • Unlimited spots';
    } else {
      final availableSpots = maxParticipants - registeredCount;
      return '$registeredCount/$maxParticipants registered • $availableSpots spots left';
    }
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
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: const Color(0xFF3F3D9C),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.event.description),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Full description copied to clipboard',
                              style: GoogleFonts.hindSiliguri(),
                            ),
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
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No email app found to open: ${link.url.replaceFirst('mailto:', '')}',
                                style: GoogleFonts.hindSiliguri(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      // Handle web URLs
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Try adding https:// if missing
                        final httpsUri = Uri.parse('https://${link.url}');
                        if (await canLaunchUrl(httpsUri)) {
                          await launchUrl(
                            httpsUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    }
                  } catch (e) {
                    // If parsing fails, try as a direct URL
                    try {
                      final directUri = Uri.parse(
                        link.url.startsWith('http')
                            ? link.url
                            : 'https://${link.url}',
                      );
                      if (await canLaunchUrl(directUri)) {
                        await launchUrl(
                          directUri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    } catch (e2) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not open link: ${link.url}',
                              style: GoogleFonts.hindSiliguri(),
                            ),
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
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        if (authProvider.user == null) {
          return _buildLoginPrompt();
        }

        final userId = authProvider.user!.uid;
        final isRegistered = eventProvider.isUserRegistered(
          widget.event.id,
          userId,
        );
        final hasAvailableSpots = widget.event.hasAvailableSpots;
        final isPastEvent = widget.event.isPastEvent;
        final isRegistrationOpen = widget.event.isRegistrationOpen;

        return Column(
          children: [
            if (isPastEvent) ...[
              // Event is over
              _buildDisabledButton('Event has ended', Icons.schedule),
              const SizedBox(height: 16),
              // Allow viewing public updates even if event is past only for registered/following
              if (isRegistered || _isFollowing)
                _buildActionButton(
                  label: 'Updates',
                  icon: Icons.info_outline,
                  color: const Color(0xFF3F3D9C),
                  textColor: Colors.black,
                  iconColor: const Color(0xFF3F3D9C),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventPublicUpdatesScreen(
                        eventId: widget.event.id,
                        eventTitle: widget.event.title,
                      ),
                    ),
                  ),
                  isOutlined: true,
                ),
              // If user was registered, show View Certificate button
              if (isRegistered) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final hasCertificate = widget.event.certificateFolderUrl
                        .trim()
                        .isNotEmpty;
                    return Opacity(
                      opacity: hasCertificate ? 1.0 : 0.5,
                      child: AbsorbPointer(
                        absorbing: !hasCertificate,
                        child: _buildActionButton(
                          label: 'View Certificate',
                          icon: Icons.workspace_premium,
                          color: Colors.amber.shade50,
                          textColor: Colors.amber.shade700,
                          iconColor: Colors.amber.shade700,
                          onTap: _viewCertificate,
                          isOutlined: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ] else if (isRegistered) ...[
              // User is registered - stacked full width buttons to match admin layout
              if (isRegistrationOpen) ...[
                _buildActionButton(
                  label: 'Unregister',
                  icon: Icons.close,
                  color: Colors.red.shade600,
                  textColor: Colors.red.shade600,
                  iconColor: Colors.red.shade600,
                  isLoading: _isUnregistering,
                  onTap: _showUnregisterDialog,
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
              ],
              _buildActionButton(
                label: 'View Ticket',
                icon: Icons.confirmation_number,
                color: const Color(0xFF3F3D9C),
                textColor: const Color(0xFF3F3D9C),
                iconColor: const Color(0xFF3F3D9C),
                onTap: _viewTicket,
                isOutlined: true,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Updates',
                icon: Icons.info_outline,
                color: const Color(0xFF3F3D9C),
                textColor: Colors.black,
                iconColor: const Color(0xFF3F3D9C),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventPublicUpdatesScreen(
                      eventId: widget.event.id,
                      eventTitle: widget.event.title,
                    ),
                  ),
                ),
                isOutlined: true,
              ),
            ] else if (!isRegistrationOpen) ...[
              // Registration closed
              _buildDisabledButton('Registration closed', Icons.block),
              const SizedBox(height: 16),
              _buildFollowButton(),
              const SizedBox(height: 16),
              if (_isFollowing)
                _buildActionButton(
                  label: 'Updates',
                  icon: Icons.info_outline,
                  color: const Color(0xFF3F3D9C),
                  textColor: Colors.black,
                  iconColor: const Color(0xFF3F3D9C),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventPublicUpdatesScreen(
                        eventId: widget.event.id,
                        eventTitle: widget.event.title,
                      ),
                    ),
                  ),
                  isOutlined: true,
                ),
            ] else if (!hasAvailableSpots) ...[
              // No available spots
              _buildDisabledButton('Event is full', Icons.group),
              const SizedBox(height: 16),
              _buildFollowButton(),
              const SizedBox(height: 16),
              if (_isFollowing)
                _buildActionButton(
                  label: 'Updates',
                  icon: Icons.info_outline,
                  color: Colors.white,
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventPublicUpdatesScreen(
                        eventId: widget.event.id,
                        eventTitle: widget.event.title,
                      ),
                    ),
                  ),
                  isOutlined: true,
                ),
            ] else ...[
              // User can register - stacked follow + register
              _buildFollowButton(),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Register',
                icon: Icons.app_registration,
                color: const Color(0xFF3F3D9C),
                textColor: Colors.white,
                iconColor: Colors.white,
                isLoading: _isRegistering,
                onTap: _showRegistrationDialog,
                isOutlined: true,
              ),
            ],

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  void _viewTicket() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TicketScreen(
          userId: authProvider.user!.uid,
          eventId: widget.event.id,
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
    bool isLoading = false,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          foregroundColor: isOutlined ? color : textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: isOutlined ? color : textColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: isOutlined ? color : iconColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isOutlined ? color : textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.user;

        if (currentUser == null) return const SizedBox.shrink();

        // If user is registered, don't show follow button
        final isRegistered = eventProvider.isUserRegistered(
          widget.event.id,
          currentUser.uid,
        );
        if (isRegistered) return const SizedBox.shrink();

        if (_isLoadingFollowingStatus) {
          return _buildActionButton(
            label: 'Loading...',
            icon: Icons.favorite_border,
            color: Colors.grey.shade300,
            textColor: Colors.grey.shade600,
            iconColor: Colors.grey.shade600,
            onTap: () {},
            isLoading: true,
            isOutlined: true,
          );
        }

        return _buildActionButton(
          label: _isFollowing ? 'Unfollow' : 'Follow Event',
          icon: _isFollowing ? Icons.favorite : Icons.favorite_border,
          color: _isFollowing ? Colors.red.shade600 : Colors.orange.shade600,
          textColor: _isFollowing
              ? Colors.red.shade600
              : Colors.orange.shade600,
          iconColor: _isFollowing
              ? Colors.red.shade600
              : Colors.orange.shade600,
          onTap: () =>
              _toggleFollow(_isFollowing, currentUser.uid, eventProvider),
          isLoading: _isToggleFollow,
          isOutlined: true,
        );
      },
    );
  }

  Widget _buildDisabledButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.login, size: 48, color: Colors.blue.shade600),
          const SizedBox(height: 12),
          Text(
            'Login Required',
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please log in to register for events or follow them',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Register for Event',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'You are about to register for "${widget.event.title}". \n\nPlease note: You might also need to register manually if the organizers require additional information. Check the event description for details.',
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
              _registerForEvent();
            },
            child: Text(
              'Register',
              style: GoogleFonts.hindSiliguri(
                color: const Color(0xFF3F3D9C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnregisterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unregister from Event',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to unregister from "${widget.event.title}"?',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep Registration',
              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _unregisterFromEvent();
            },
            child: Text(
              'Unregister',
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

  Future<void> _registerForEvent() async {
    setState(() {
      _isRegistering = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      if (authProvider.user != null) {
        final success = await eventProvider.registerForEvent(
          widget.event.id,
          authProvider.user!.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Successfully registered for "${widget.event.title}"'
                    : 'Failed to register for event',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );

          if (success) {
            // Return to previous screen to refresh the data
            Navigator.of(context).pop(true);
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _unregisterFromEvent() async {
    setState(() {
      _isUnregistering = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      if (authProvider.user != null) {
        final success = await eventProvider.unregisterFromEvent(
          widget.event.id,
          authProvider.user!.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Successfully unregistered from "${widget.event.title}"'
                    : 'Failed to unregister from event',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );

          if (success) {
            // Return to previous screen to refresh the data
            Navigator.of(context).pop(true);
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnregistering = false;
        });
      }
    }
  }

  Future<void> _toggleFollow(
    bool isCurrentlyFollowing,
    String userId,
    EventProvider eventProvider,
  ) async {
    setState(() {
      _isToggleFollow = true;
    });

    try {
      bool success;
      if (isCurrentlyFollowing) {
        success = await eventProvider.unfollowEvent(widget.event.id, userId);
      } else {
        success = await eventProvider.followEvent(widget.event.id, userId);
      }

      if (success) {
        // Update local state
        setState(() {
          _isFollowing = !isCurrentlyFollowing;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFollowing
                  ? 'Unfollowed "${widget.event.title}"'
                  : 'Now following "${widget.event.title}"',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: isCurrentlyFollowing
                ? Colors.grey.shade600
                : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update follow status. Please try again.',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please try again.',
            style: GoogleFonts.hindSiliguri(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isToggleFollow = false;
      });
    }
  }

  // _viewTicket is implemented above to navigate to TicketScreen
}

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
  List<lf.LinkifyElement> parse(
    List<lf.LinkifyElement> elements,
    lf.LinkifyOptions options,
  ) {
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
        if (urlMatch.start < emailMatch.end &&
            urlMatch.end > emailMatch.start) {
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
        final emailLink = matched.startsWith('mailto:')
            ? matched
            : 'mailto:$matched';
        elements.add(lf.LinkableElement(matched, emailLink));
      } else {
        // It's a URL
        final link =
            matched.startsWith(RegExp(r'https?://', caseSensitive: false))
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
