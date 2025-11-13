import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Make sure these import paths are correct for your project structure
import 'package:diu_events/features/auth/models/app_user.dart';
import 'package:diu_events/features/admin/providers/admin_provider.dart';
import 'package:diu_events/features/auth/providers/auth_provider.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.fetchAllUsers();
      // Add a listener to filter users when the tab changes
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          adminProvider.filterUsers(_tabController.index);
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin =
        Provider.of<AuthProvider>(context, listen: false).user?.role ==
        'superadmin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ## Combined Header with Tighter Spacing ##
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              // Use bottom: false to prevent SafeArea from adding padding below the tabs
              bottom: false,
              child: Column(
                children: [
                  // Header Title Row with reduced bottom padding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          'Admin ',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Management',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3F3D9C),
                          ),
                        ),
                        const Spacer(),
                        // Logout Button
                        IconButton(
                          icon: const Icon(
                            Icons.logout_outlined,
                            color: Color(0xFF3F3D9C),
                            size: 24,
                          ),
                          onPressed: () => Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).signOut(),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Color(0xFF3F3D9C),
                          width: 2,
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      labelColor: const Color(0xFF3F3D9C),
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'All Admins'),
                        Tab(text: 'Super Admin'),
                        Tab(text: 'Admin'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ## Content Area ##
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading && adminProvider.users.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3F3D9C)),
                  );
                }

                if (adminProvider.errorMessage != null) {
                  return Center(
                    child: Text('Error: ${adminProvider.errorMessage}'),
                  );
                }

                if (adminProvider.filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      'No admin users found.',
                      style: GoogleFonts.hindSiliguri(),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => adminProvider.fetchAllUsers(),
                  color: const Color(0xFF3F3D9C),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: adminProvider.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = adminProvider.filteredUsers[index];
                      return _buildUserCard(user, adminProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isSuperAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddAdminDialog(context),
              backgroundColor: const Color(0xFF3F3D9C),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildUserCard(AppUser user, AdminProvider adminProvider) {
    final isSuperAdmin =
        Provider.of<AuthProvider>(context, listen: false).user?.role ==
        'superadmin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getRoleColor(user.role).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade50,
                child: user.profilePicture.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.profilePicture,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey.shade400,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: _getRoleColor(user.role),
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 28, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRoleWidget(user, adminProvider),
                      const Spacer(),
                      if (isSuperAdmin && user.role != 'superadmin')
                        InkWell(
                          onTap: () => _showEditAdminDialog(
                            context,
                            user,
                            adminProvider,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleWidget(AppUser user, AdminProvider adminProvider) {
    final isSuperAdmin =
        Provider.of<AuthProvider>(context, listen: false).user?.role ==
        'superadmin';

    Widget roleChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getRoleColor(user.role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRoleColor(user.role).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        user.role.toUpperCase(),
        style: GoogleFonts.hindSiliguri(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: _getRoleColor(user.role),
          letterSpacing: 0.5,
        ),
      ),
    );

    if (isSuperAdmin && user.role != 'superadmin') {
      return InkWell(
        onTap: () => _showChangeRoleDialog(context, user, adminProvider),
        borderRadius: BorderRadius.circular(12),
        child: roleChip,
      );
    }

    return roleChip;
  }

  void _showChangeRoleDialog(
    BuildContext context,
    AppUser user,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Role for ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['student', 'admin'].map((role) {
              return RadioListTile<String>(
                title: Text(role[0].toUpperCase() + role.substring(1)),
                value: role,
                groupValue: user.role,
                activeColor: const Color(0xFF3F3D9C),
                onChanged: (newRole) async {
                  if (newRole != null) {
                    Navigator.of(context).pop();
                    final success = await adminProvider.updateUserRole(
                      user.uid,
                      newRole,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Role updated successfully.'
                                : 'Failed to update role.',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAdminDialog(
    BuildContext context,
    AppUser user,
    AdminProvider adminProvider,
  ) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Admin User',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration(
                        'Full Name',
                        Icons.person_outline,
                      ),
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        'Email Address',
                        Icons.email_outlined,
                      ),
                      validator: (v) => v!.isEmpty ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        'New Password (optional)',
                        Icons.lock_outline,
                      ),
                      validator: (v) => v!.isNotEmpty && v.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final success = await adminProvider
                                    .updateAdminUser(
                                      uid: user.uid,
                                      name: nameController.text,
                                      email: emailController.text,
                                      password:
                                          passwordController.text.isNotEmpty
                                          ? passwordController.text
                                          : null,
                                    );
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Admin updated successfully.'
                                            : 'Failed: ${adminProvider.errorMessage}',
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F3D9C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Update',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create New Admin',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration(
                        'Full Name',
                        Icons.person_outline,
                      ),
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        'Email Address',
                        Icons.email_outlined,
                      ),
                      validator: (v) => v!.isEmpty ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        'Password',
                        Icons.lock_outline,
                      ),
                      validator: (v) => v!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final adminProvider = Provider.of<AdminProvider>(
                              context,
                              listen: false,
                            );
                            final success = await adminProvider.addAdminUser(
                              name: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Admin created successfully.'
                                        : 'Failed: ${adminProvider.errorMessage}',
                                  ),
                                  backgroundColor: success
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F3D9C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create Admin',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade400),
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
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'superadmin':
        return const Color(0xFFDC2626); // Red
      case 'admin':
        return const Color(0xFFF59E0B); // Amber/Orange
      case 'student':
        return const Color(0xFF3B82F6); // Blue
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
