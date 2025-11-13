import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isAdminLogin = false;
  bool _termsAccepted = true;

  // Recognizers for tappable links in the terms text
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTermsOfUseDialog;
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = _showPrivacyPolicyDialog;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Set system UI styles for this screen ---
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Make the Android navigation bar background purple
        systemNavigationBarColor: Color(0xFF3F3D9C),
        // Make the navigation bar icons (like the gesture handle) light
        systemNavigationBarIconBrightness: Brightness.light,
        // Make the status bar transparent
        statusBarColor: Colors.transparent,
        // Make the status bar icons dark
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top white section with logo
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DIU ',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Events',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3F3D9C),
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C17C),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with solid purple background
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3F3D9C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Conditionally display User or Admin login widgets directly
                        if (_isAdminLogin)
                          _buildAdminLoginForm(authProvider)
                        else
                          _buildUserLoginButtons(authProvider),

                        // Adjust spacing based on the current view
                        if (!_isAdminLogin) const SizedBox(height: 24),
                        if (_isAdminLogin) const SizedBox(height: 8),
                        _buildTermsAndConditions(),
                      ],
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

  /// Builds the initial view with Google Sign-In and Admin login options.
  Widget _buildUserLoginButtons(AuthProvider authProvider) {
    return Column(
      key: const ValueKey('userLogin'),
      children: [
        // Google Sign-in Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: (!_termsAccepted || authProvider.isLoading)
                ? null
                : () async {
                    final success = await authProvider.signInWithGoogle();
                    if (!success && authProvider.errorMessage != null) {
                      _showErrorSnackBar(authProvider.errorMessage!);
                    }
                  },
            icon: authProvider.isLoading && !_isAdminLogin
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF3F3D9C),
                    ),
                  )
                : Image.asset(
                    'assets/images/google-icon.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.login),
                  ),
            label: Text(
              authProvider.isLoading && !_isAdminLogin
                  ? 'Signing in...'
                  : 'Sign in with DIU Email Account',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withOpacity(0.8),
              foregroundColor: Colors.black87,
              disabledForegroundColor: Colors.black.withOpacity(0.5),
              elevation: 6,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Admin Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: !_termsAccepted
                ? null
                : () => setState(() => _isAdminLogin = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4FBF),
              disabledBackgroundColor: const Color(0xFF5B4FBF).withOpacity(0.6),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Login as an Admin',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the Admin login form with email, password, and action buttons.
  Widget _buildAdminLoginForm(AuthProvider authProvider) {
    return Column(
      key: const ValueKey('adminLogin'),
      children: [
        // Header with Back Button and Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => _isAdminLogin = false),
            ),
            // Title
            Text(
              'Admin Login',
              style: GoogleFonts.hindSiliguri(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Spacer to keep the title perfectly centered
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Username/email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter username or email',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.hindSiliguri(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter email'
                    : null,
              ),
              const SizedBox(height: 12),
              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.hindSiliguri(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter password'
                    : null,
              ),
              const SizedBox(height: 24),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (!_termsAccepted || authProvider.isLoading)
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider
                                .signInWithEmailPassword(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                            if (!success && authProvider.errorMessage != null) {
                              _showErrorSnackBar(authProvider.errorMessage!);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4FBF),
                    disabledBackgroundColor: const Color(
                      0xFF5B4FBF,
                    ).withOpacity(0.6),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: authProvider.isLoading && _isAdminLogin
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Login',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              // Forgot Password
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the terms and conditions checkbox and text.
  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => setState(() => _termsAccepted = !_termsAccepted),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: _termsAccepted ? Colors.white : Colors.transparent,
            ),
            child: _termsAccepted
                ? const Icon(Icons.check, size: 16, color: Color(0xFF3F3D9C))
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.hindSiliguri(
                color: Colors.white,
                fontSize: 12,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'I confirm that I have read and agree to DIU Event\'s ',
                ),
                TextSpan(
                  text: 'Terms of Use',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _termsRecognizer,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _privacyRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a dialog with the Terms of Use.
  void _showTermsOfUseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Use'),
        content: const SingleChildScrollView(
          child: Text(
            'Welcome to DIU Events!\n\n'
            'By using this app, you agree to the following terms:\n\n'
            '1. Account Responsibility: You are responsible for all activities under your DIU account.\n'
            '2. Appropriate Conduct: You must not use this app for any unlawful purpose. Harassment, abuse, or spamming is strictly prohibited.\n'
            '3. Event Registration: All event registrations are subject to approval by the event organizers. We reserve the right to cancel any registration.\n'
            '4. Data Usage: Your data will be used in accordance with the Digital Security Act, 2018 of Bangladesh.\n'
            '5. Content Ownership: All content posted by the university and organizers is the property of Daffodil International University.\n\n'
            'These terms are subject to change without notice.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog with the Privacy Policy.
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us.\n\n'
            '1. Information We Collect: We collect your name, DIU email, and student/faculty ID for registration and identification purposes.\n'
            '2. How We Use Information: Your information is used to manage your event participation, send notifications, and verify your identity.\n'
            '3. Data Sharing: We do not share your personal information with third parties without your consent, except as required by the laws of Bangladesh.\n'
            '4. Data Security: We take reasonable measures to protect your data from unauthorized access.\n'
            '5. Your Rights: You have the right to access and update your information through your profile.\n\n'
            'By using the app, you consent to our data practices.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog for password recovery instructions.
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password?'),
        content: const Text(
          'To reset your admin password, please contact the DIU IT Department or the system administrator directly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
