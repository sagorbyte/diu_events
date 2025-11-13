import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/profile_image_service.dart';
import '../../../core/constants/department_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();

  final ProfileImageService _profileImageService = ProfileImageService();

  bool _isLoading = false;
  bool _isImageUploading = false;
  String? _profileImageUrl;
  String? _selectedFaculty;
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
      _profileImageUrl = authProvider.user!.profilePicture;

      // Load existing data if any
      _studentIdController.text = authProvider.user!.studentId;
      _selectedDepartment = authProvider.user!.department.isNotEmpty
          ? authProvider.user!.department
          : null;
      if (_selectedDepartment != null) {
        _selectedFaculty = DepartmentConstants.getFacultyByDepartment(
          _selectedDepartment!,
        );
      }

      // Initialize phone with +880 prefix if not already present
      // Handle phone number initialization with +880 prefix
      String userPhone = authProvider.user!.phone;
      if (userPhone.isNotEmpty) {
        if (userPhone.startsWith('+880')) {
          _phoneController.text = userPhone.substring(
            4,
          ); // Remove +880 prefix for display
        } else if (userPhone.startsWith('880')) {
          _phoneController.text = userPhone.substring(
            3,
          ); // Remove 880 prefix for display
        } else {
          _phoneController.text = userPhone;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3F3D9C), Color(0xFF5B4FBF)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        const SizedBox(
                          width: 48,
                        ), // Balance for center alignment
                        Expanded(
                          child: Text(
                            'Complete Your Profile',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Info message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please complete your profile to access all features of the app.',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Image Section
                    _buildProfileImageSection(),
                  ],
                ),
              ),
            ),
          ),
          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildFormField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Student ID Field
                    _buildFormField(
                      controller: _studentIdController,
                      label: 'Student ID',
                      hint: 'Enter your student ID',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Student ID is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Faculty and Department Dropdowns
                    _buildFacultyDepartmentDropdowns(),
                    const SizedBox(height: 20),
                    // Phone Number Field
                    _buildPhoneNumberField(),
                    const SizedBox(height: 40),
                    // Complete Profile Button
                    _buildCompleteProfileButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            // Profile Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? Image.network(
                        _profileImageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF3F3D9C),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Upload Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isImageUploading ? null : _showImagePickerOptions,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3F3D9C),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isImageUploading
                      ? const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Color(0xFF3F3D9C),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Color(0xFF3F3D9C),
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Upload Profile Picture',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          'Optional - Square images work best',
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _completeProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F3D9C),
          disabledBackgroundColor: const Color(0xFF3F3D9C).withOpacity(0.6),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          elevation: 4,
          shadowColor: const Color(0xFF3F3D9C).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : Text(
                'Complete Profile',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          validator: validator,
          style: GoogleFonts.hindSiliguri(
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Select Image',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 24),
              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3F3D9C)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isImageUploading = true;
      });

      final XFile? pickedImage = await _profileImageService
          .pickAndValidateSquareImage(source: source);

      if (pickedImage != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.uid ?? '';

        final imageUrl = await _profileImageService.uploadProfileImage(
          pickedImage,
          userId,
        );

        setState(() {
          _profileImageUrl = imageUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile image uploaded successfully!',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
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
          _isImageUploading = false;
        });
      }
    }
  }

  Widget _buildFacultyDepartmentDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Faculty Dropdown
        Text(
          'Faculty',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFaculty,
              hint: Text(
                'Select Faculty',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                color: Colors.grey.shade900,
              ),
              items: DepartmentConstants.faculties.map((String faculty) {
                return DropdownMenuItem<String>(
                  value: faculty,
                  child: Text(
                    faculty,
                    style: GoogleFonts.hindSiliguri(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFaculty = newValue;
                  _selectedDepartment =
                      null; // Reset department when faculty changes
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Department Dropdown
        Text(
          'Department',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _selectedFaculty != null
                ? Colors.white
                : Colors.grey.shade100,
            border: Border.all(
              color: _selectedFaculty != null
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedDepartment,
              hint: Text(
                _selectedFaculty != null
                    ? 'Select Department'
                    : 'Select Faculty first',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                color: Colors.grey.shade900,
              ),
              selectedItemBuilder: (BuildContext context) {
                return _selectedFaculty != null
                    ? DepartmentConstants.getDepartmentsByFaculty(
                        _selectedFaculty!,
                      ).map<Widget>((String department) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            department,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              color: Colors.grey.shade900,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        );
                      }).toList()
                    : [];
              },
              items: _selectedFaculty != null
                  ? DepartmentConstants.getDepartmentsByFaculty(
                      _selectedFaculty!,
                    ).map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            department,
                            style: GoogleFonts.hindSiliguri(fontSize: 14),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      );
                    }).toList()
                  : null,
              onChanged: _selectedFaculty != null
                  ? (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                      });
                    }
                  : null,
            ),
          ),
        ),
        // Department validation error
        if (_selectedDepartment == null && _hasTriedSubmit)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Department is required',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Non-editable +880 prefix
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                '+880',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: GoogleFonts.hindSiliguri(
                    color: Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  // Validate Bangladesh phone number (should be 10 digits after +880)
                  if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _hasTriedSubmit = false;

  void _completeProfile() async {
    setState(() {
      _hasTriedSubmit = true;
    });

    if (!_formKey.currentState!.validate() || _selectedDepartment == null) {
      if (_selectedDepartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a department',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Update complete profile info including student-specific fields
      final success = await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        profilePicture: _profileImageUrl,
        studentId: _studentIdController.text.trim(),
        department: _selectedDepartment ?? '',
        phone: '+880${_phoneController.text.trim()}',
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile completed successfully! Welcome to DIU Events!',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // The AuthWrapper will automatically handle navigation based on profile completion
          // No need to manually navigate here
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Failed to complete profile',
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
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
}
