import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/student_hamburger_menu.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _eventReminders = true;
  bool _eventUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications on your device',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                    _showSavedSnackbar();
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.email,
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                    _showSavedSnackbar();
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.event_note,
                  title: 'Event Reminders',
                  subtitle: 'Get reminded about upcoming events',
                  value: _eventReminders,
                  onChanged: (value) {
                    setState(() {
                      _eventReminders = value;
                    });
                    _showSavedSnackbar();
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.update,
                  title: 'Event Updates',
                  subtitle: 'Notifications for changes in registered events',
                  value: _eventUpdates,
                  onChanged: (value) {
                    setState(() {
                      _eventUpdates = value;
                    });
                    _showSavedSnackbar();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy & Security Section
            _buildSectionTitle('Privacy & Security'),
            _buildSettingsCard(
              children: [
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  onTap: () {
                    _showPrivacyPolicyDialog();
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Use',
                  subtitle: 'Read terms and conditions',
                  onTap: () {
                    _showTermsOfUseDialog();
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.shield_outlined,
                  title: 'Data Security',
                  subtitle: 'Learn how we protect your data',
                  onTap: () {
                    _showDataSecurityDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSectionTitle('Account'),
            _buildSettingsCard(
              children: [
                _buildListTile(
                  icon: Icons.person_outline,
                  title: 'Account Information',
                  subtitle: 'View your account details',
                  onTap: () {
                    _showAccountInfoDialog();
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.storage_outlined,
                  title: 'Data & Storage',
                  subtitle: 'Manage your data',
                  onTap: () {
                    _showDataStorageDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Information Section
            _buildSectionTitle('About App'),
            _buildSettingsCard(
              children: [
                _buildListTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: 'Version 1.0.0',
                  trailing: const SizedBox.shrink(),
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.code,
                  title: 'Developer',
                  subtitle: 'Sagor Majumder',
                  trailing: const SizedBox.shrink(),
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.school_outlined,
                  title: 'Institution',
                  subtitle: 'Daffodil International University',
                  trailing: const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
            'Settings',
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

  Widget _buildSettingsCard({required List<Widget> children}) {
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF3F3D9C),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
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
      trailing:
          trailing ??
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved',
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F3D9C),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us.\n\n'
            '1. Information We Collect: We collect your name, DIU email, and student/faculty ID for registration and identification purposes.\n\n'
            '2. How We Use Information: Your information is used to manage your event participation, send notifications, and verify your identity.\n\n'
            '3. Data Sharing: We do not share your personal information with third parties without your consent, except as required by the laws of Bangladesh.\n\n'
            '4. Data Security: We take reasonable measures to protect your data from unauthorized access.\n\n'
            '5. Your Rights: You have the right to access and update your information through your profile.\n\n'
            'By using the app, you consent to our data practices.',
            style: GoogleFonts.hindSiliguri(fontSize: 14),
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

  void _showTermsOfUseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Terms of Use',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Welcome to DIU Events!\n\n'
            'By using this app, you agree to the following terms:\n\n'
            '1. Account Responsibility: You are responsible for all activities under your DIU account.\n\n'
            '2. Appropriate Conduct: You must not use this app for any unlawful purpose. Harassment, abuse, or spamming is strictly prohibited.\n\n'
            '3. Event Registration: All event registrations are subject to approval by the event organizers. We reserve the right to cancel any registration.\n\n'
            '4. Data Usage: Your data will be used in accordance with the Digital Security Act, 2018 of Bangladesh.\n\n'
            '5. Content Ownership: All content posted by the university and organizers is the property of Daffodil International University.\n\n'
            'These terms are subject to change without notice.',
            style: GoogleFonts.hindSiliguri(fontSize: 14),
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

  void _showDataSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield, color: Color(0xFF3F3D9C)),
            const SizedBox(width: 12),
            Text(
              'Data Security',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'We take your data security seriously:\n\n'
            '• Encrypted Data Storage: All your personal data is encrypted and stored securely on Firebase Cloud Firestore.\n\n'
            '• Secure Authentication: We use Google Sign-In and Firebase Authentication for secure access.\n\n'
            '• Access Control: Only authorized administrators can access event management features.\n\n'
            '• Regular Updates: We regularly update our security measures to protect against new threats.\n\n'
            '• Compliance: We comply with the Digital Security Act, 2018 of Bangladesh and international data protection standards.\n\n'
            '• No Third-Party Sharing: Your data is never shared with third parties without your explicit consent.',
            style: GoogleFonts.hindSiliguri(fontSize: 14),
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

  void _showAccountInfoDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.account_circle, color: Color(0xFF3F3D9C)),
            const SizedBox(width: 12),
            Text(
              'Account Information',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Name', user?.name ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Email', user?.email ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Student ID', user?.studentId ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Department', user?.department ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Phone', user?.phone ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Role', user?.role ?? 'Student'),
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

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  void _showDataStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.storage, color: Color(0xFF3F3D9C)),
            const SizedBox(width: 12),
            Text(
              'Data & Storage',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your data is stored securely in the cloud:',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 16),
              _buildStorageItem('Profile Data', 'Stored securely'),
              _buildStorageItem('Event Registrations', 'Synced'),
              _buildStorageItem('Notifications', 'Active'),
              _buildStorageItem('Cache', 'Minimal'),
              const SizedBox(height: 16),
              Text(
                'All data is backed up regularly and protected with industry-standard encryption.',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
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

  Widget _buildStorageItem(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3F3D9C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3F3D9C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
