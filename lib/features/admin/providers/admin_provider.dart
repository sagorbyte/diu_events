import 'package:flutter/foundation.dart';
import 'package:diu_events/features/auth/models/app_user.dart';
import 'package:diu_events/features/admin/services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppUser> get users => _users;
  List<AppUser> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllUsers() async {
    try {
      _setLoading(true);
      _users = await _adminService.getAllUsers();
      // Initially, show only admin and superadmin users
      _filteredUsers = _users
          .where((user) => user.role == 'admin' || user.role == 'superadmin')
          .toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void filterUsers(int tabIndex) {
    switch (tabIndex) {
      case 1: // Super Admin
        _filteredUsers = _users
            .where((user) => user.role == 'superadmin')
            .toList();
        break;
      case 2: // Admin
        _filteredUsers = _users.where((user) => user.role == 'admin').toList();
        break;
      default: // All Admins
        _filteredUsers = _users
            .where((user) => user.role == 'admin' || user.role == 'superadmin')
            .toList();
    }
    notifyListeners();
  }

  Future<bool> updateUserRole(String uid, String newRole) async {
    try {
      _setLoading(true);
      await _adminService.updateUserRole(uid, newRole);
      await fetchAllUsers();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAdminUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      await _adminService.createAdminInFirestore(
        name: name,
        email: email,
        password: password,
      );
      await fetchAllUsers();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAdminUser({
    required String uid,
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      _setLoading(true);
      await _adminService.updateAdminUser(
        uid: uid,
        name: name,
        email: email,
        password: password,
      );
      await fetchAllUsers();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}
