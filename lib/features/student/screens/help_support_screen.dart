import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/student_hamburger_menu.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header Banner
            _buildHeaderBanner(),

            const SizedBox(height: 24),

            // Quick Help Section
            _buildSectionTitle('Quick Help'),
            _buildHelpCard(
              context: context,
              children: [
                _buildHelpTile(
                  context: context,
                  icon: Icons.question_answer,
                  title: 'FAQs',
                  subtitle: 'Find answers to common questions',
                  onTap: () => _showFAQDialog(context),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.book_outlined,
                  title: 'User Guide',
                  subtitle: 'Learn how to use the app',
                  onTap: () => _showUserGuideDialog(context),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Tips & Tricks',
                  subtitle: 'Get the most out of DIU Events',
                  onTap: () => _showTipsDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Contact Support Section
            _buildSectionTitle('Contact Support'),
            _buildHelpCard(
              context: context,
              children: [
                _buildHelpTile(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'majumder15-4907@diu.edu.bd',
                  onTap: () => _launchEmail(),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.phone_outlined,
                  title: 'Phone Support',
                  subtitle: '+8801725691441',
                  onTap: () => _launchPhone(),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.web_outlined,
                  title: 'Visit Website',
                  subtitle: 'www.daffodilvarsity.edu.bd',
                  onTap: () => _launchWebsite(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Report Issues Section
            _buildSectionTitle('Report Issues'),
            _buildHelpCard(
              context: context,
              children: [
                _buildHelpTile(
                  context: context,
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  onTap: () => _showReportBugDialog(context),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts with us',
                  onTap: () => _showFeedbackDialog(context),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.security_outlined,
                  title: 'Report Security Issue',
                  subtitle: 'Report security concerns',
                  onTap: () => _showSecurityReportDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Community Section
            _buildSectionTitle('Community'),
            _buildHelpCard(
              context: context,
              children: [
                _buildHelpTile(
                  context: context,
                  icon: Icons.facebook,
                  title: 'Facebook Page',
                  subtitle: 'Follow us on Facebook',
                  onTap: () => _launchFacebook(),
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context: context,
                  icon: Icons.groups_outlined,
                  title: 'DIU Community',
                  subtitle: 'Join the student community',
                  onTap: () => _showCommunityInfo(context),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF3F3D9C)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Help & Support',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
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

  Widget _buildHeaderBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F3D9C), Color(0xFF5B59C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F3D9C).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.headset_mic, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'How can we help you?',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re here to assist you with any questions or issues',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(children: children),
    );
  }

  Widget _buildHelpTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF3F3D9C).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3F3D9C), size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.hindSiliguri(
          fontSize: 14,
          color: Colors.grey.shade600,
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

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Frequently Asked Questions',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem(
                'How do I register for an event?',
                'Browse events in the Explore tab, tap on an event you\'re interested in, and click the "Register" button.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'Can I cancel my registration?',
                'Yes, go to My Events tab, select the event, and tap "Unregister" button.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'How do I get event updates?',
                'Follow events to receive updates. You\'ll get notifications about any changes or announcements.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'Where can I find my event tickets?',
                'Go to My Events tab and select a registered event to view your ticket.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'How do I update my profile?',
                'Go to Profile tab and tap the "Edit Profile" button to update your information.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.hindSiliguri(color: const Color(0xFF3F3D9C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _showUserGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.book, color: Color(0xFF3F3D9C)),
            const SizedBox(width: 12),
            Text(
              'User Guide',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideSection('Getting Started', [
                'Complete your profile with student ID and department',
                'Browse events in the Explore tab',
                'Register for events that interest you',
              ]),
              const SizedBox(height: 16),
              _buildGuideSection('Managing Events', [
                'View all your events in My Events tab',
                'Follow events to get updates',
                'Check event details and location',
                'View your event tickets',
              ]),
              const SizedBox(height: 16),
              _buildGuideSection('Notifications', [
                'Enable push notifications in Settings',
                'Get updates about registered events',
                'Receive reminders before events start',
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: GoogleFonts.hindSiliguri(color: const Color(0xFF3F3D9C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.hindSiliguri(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: const Color(0xFF3F3D9C),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFFFFA726)),
            const SizedBox(width: 12),
            Text(
              'Tips & Tricks',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTipItem(
                '💡',
                'Follow events to stay updated without registering',
              ),
              _buildTipItem(
                '🔔',
                'Enable notifications to never miss an event',
              ),
              _buildTipItem(
                '📅',
                'Check registration deadlines before they expire',
              ),
              _buildTipItem(
                '🎟️',
                'Save event tickets offline by taking screenshots',
              ),
              _buildTipItem(
                '👥',
                'Complete your profile to enhance networking',
              ),
              _buildTipItem('🔍', 'Use filters to find events by category'),
              _buildTipItem('📱', 'Share interesting events with friends'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Thanks!',
              style: GoogleFonts.hindSiliguri(color: const Color(0xFF3F3D9C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bug_report, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Report a Bug',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please describe the issue you encountered:',
              style: GoogleFonts.hindSiliguri(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the bug...',
                hintStyle: GoogleFonts.hindSiliguri(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final bugDescription = controller.text.trim();
              if (bugDescription.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please describe the bug before submitting',
                      style: GoogleFonts.hindSiliguri(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              _sendBugReport(context, bugDescription);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F3D9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.feedback, color: Color(0xFF3F3D9C)),
            const SizedBox(width: 12),
            Text(
              'Send Feedback',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'d love to hear your thoughts:',
              style: GoogleFonts.hindSiliguri(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your feedback...',
                hintStyle: GoogleFonts.hindSiliguri(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final feedback = controller.text.trim();
              if (feedback.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter your feedback before submitting',
                      style: GoogleFonts.hindSiliguri(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              _sendFeedback(context, feedback);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F3D9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Security Issue',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'For security concerns, please contact us immediately at:\n\n'
          'Email: security@diu.edu.bd\n'
          'Phone: +8801725691441\n\n'
          'Your report will be handled with highest priority and confidentiality.',
          style: GoogleFonts.hindSiliguri(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchEmail();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Email Now',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommunityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.groups, color: Color(0xFF3F3D9C)),
            const SizedBox(width: 12),
            Text(
              'DIU Community',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Join the vibrant DIU student community!\n\n'
          '• Connect with fellow students\n'
          '• Participate in events and activities\n'
          '• Share experiences and knowledge\n'
          '• Build your professional network\n\n'
          'Visit the DIU website or follow our social media pages to stay connected.',
          style: GoogleFonts.hindSiliguri(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.hindSiliguri(color: const Color(0xFF3F3D9C)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendBugReport(
    BuildContext context,
    String bugDescription,
  ) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'majumder15-4907@diu.edu.bd',
      queryParameters: {
        'subject': 'DIU Events App - Bug Report',
        'body':
            'Bug Description:\n$bugDescription\n\n---\nPlease do not modify the text above this line.\nApp: DIU Events v1.0.0\nReported via: Help & Support',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Opening email app to send bug report...',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF3F3D9C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not open email app. Please email your bug report to majumder15-4907@diu.edu.bd',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Could not send bug report. Please try again.',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendFeedback(BuildContext context, String feedback) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'majumder15-4907@diu.edu.bd',
      queryParameters: {
        'subject': 'DIU Events App - User Feedback',
        'body':
            'Feedback:\n$feedback\n\n---\nPlease do not modify the text above this line.\nApp: DIU Events v1.0.0\nSent via: Help & Support',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Opening email app to send feedback...',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF3F3D9C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not open email app. Please email your feedback to majumder15-4907@diu.edu.bd',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Could not send feedback. Please try again.',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'majumder15-4907@diu.edu.bd',
      query: 'subject=DIU Events App Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+8801725691441');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.daffodilvarsity.edu.bd');

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchFacebook() async {
    final Uri facebookUri = Uri.parse(
      'https://www.facebook.com/daffodilvarsity.edu.bd',
    );

    if (await canLaunchUrl(facebookUri)) {
      await launchUrl(facebookUri, mode: LaunchMode.externalApplication);
    }
  }
}
