import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/student_hamburger_menu.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F3D9C), Color(0xFF5B59C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3F3D9C).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.event_available,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              'DIU Events',
              style: GoogleFonts.hindSiliguri(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3F3D9C),
              ),
            ),

            const SizedBox(height: 8),

            // App Version
            Text(
              'Version 1.0.0',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 8),

            // App Tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your Gateway to Campus Events',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // About the App Section
            _buildSection(
              icon: Icons.info_outline,
              title: 'About the App',
              content:
                  'DIU Events is a comprehensive event management platform designed specifically for Daffodil International University. '
                  'It connects students, faculty, and administrators, making it easier to discover, register for, and manage campus events. '
                  'From academic seminars to cultural festivals, DIU Events brings the entire campus community together.',
            ),

            const SizedBox(height: 24),

            // Features Section
            _buildFeaturesSection(),

            const SizedBox(height: 24),

            // Developer Section
            _buildDeveloperSection(context),

            const SizedBox(height: 24),

            // Institution Section
            _buildInstitutionSection(context),

            const SizedBox(height: 24),

            // Project Information
            _buildProjectInfoSection(),

            const SizedBox(height: 24),

            // Contact Section
            _buildContactSection(),

            const SizedBox(height: 24),

            // Legal Section
            _buildLegalSection(context),

            const SizedBox(height: 40),

            // Copyright Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '© 2025 Daffodil International University',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All rights reserved',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
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
            'About',
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3D9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF3F3D9C), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3D9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_outline,
                  color: Color(0xFF3F3D9C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Key Features',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('📅', 'Browse and explore campus events'),
          _buildFeatureItem('✅', 'Easy event registration and management'),
          _buildFeatureItem('🔔', 'Real-time push notifications'),
          _buildFeatureItem('🎟️', 'Digital event tickets'),
          _buildFeatureItem('👤', 'Personalized profile management'),
          _buildFeatureItem('🔄', 'Event updates and announcements'),
          _buildFeatureItem('📱', 'User-friendly mobile interface'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Icon(Icons.code, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'Developed by',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sagor Majumder',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
                    const SizedBox(height: 8),
          Text(
            'Student ID: 221-15-4907',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Department of CSE',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Daffodil International University',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3D9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: Color(0xFF3F3D9C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Institution',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Daffodil International University',
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3F3D9C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Daffodil International University (DIU) is one of the leading private universities in Bangladesh, committed to providing quality education and fostering innovation. '
            'With a strong focus on technology and research, DIU prepares students for global challenges.',
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _launchWebsite(),
            icon: const Icon(Icons.web, size: 20),
            label: Text(
              'Visit Website',
              style: GoogleFonts.hindSiliguri(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F3D9C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3D9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFF3F3D9C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Project Information',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Project Type', 'Final Year Design Project'),
          const SizedBox(height: 12),
          _buildInfoRow('Degree', 'BSc in Computer Science & Engineering'),
          const SizedBox(height: 12),
          _buildInfoRow('Department', 'Department of CSE'),
          const SizedBox(height: 12),
          _buildInfoRow('Year', '2025'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This application was developed as a Final Year Design Project for the Bachelor of Science in Computer Science & Engineering degree.',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3D9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.contact_mail,
                  color: Color(0xFF3F3D9C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email,
            'Email',
            'majumder15-4907@diu.edu.bd',
            () => _launchEmail(),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.phone,
            'Phone',
            '+8801725691441',
            () => _launchPhone(),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.web,
            'Website',
            'www.daffodilvarsity.edu.bd',
            () => _launchWebsite(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3F3D9C), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                  Text(
                    value,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3D9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Color(0xFF3F3D9C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Legal',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLegalItem(
            'Privacy Policy',
            () => _showPrivacyPolicyDialog(context),
          ),
          const SizedBox(height: 8),
          _buildLegalItem('Terms of Use', () => _showTermsOfUseDialog(context)),
          const SizedBox(height: 8),
          _buildLegalItem(
            'Open Source Licenses',
            () => _showLicensesDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                color: const Color(0xFF3F3D9C),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF3F3D9C), size: 20),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
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

  void _showTermsOfUseDialog(BuildContext context) {
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

  void _showLicensesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Open Source Licenses',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This application uses the following open source packages:',
                style: GoogleFonts.hindSiliguri(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildLicenseItem('Flutter', 'BSD 3-Clause License'),
              _buildLicenseItem('Firebase', 'Apache License 2.0'),
              _buildLicenseItem('Provider', 'MIT License'),
              _buildLicenseItem('Google Fonts', 'Apache License 2.0'),
              _buildLicenseItem('URL Launcher', 'BSD 3-Clause License'),
              _buildLicenseItem('Image Picker', 'Apache License 2.0'),
              _buildLicenseItem('And many more...', ''),
              const SizedBox(height: 12),
              Text(
                'We are grateful to the open source community for their contributions.',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
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

  Widget _buildLicenseItem(String package, String license) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                ),
                children: [
                  TextSpan(
                    text: package,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (license.isNotEmpty) ...[
                    const TextSpan(text: ' - '),
                    TextSpan(
                      text: license,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'majumder15-4907@diu.edu.bd',
      query: 'subject=DIU Events App',
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
}
