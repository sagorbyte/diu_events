import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../../../services/fcm_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FCMService _fcmService = FCMService();

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // Clear all user data and set status to unauthenticated
      _user = null;
      _status = AuthStatus.unauthenticated;

      // Force UI update immediately
      notifyListeners();

      // Add a small delay and notify again to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();
      return;
    }

    // Set unknown status first to ensure we don't show incorrect screens
    _status = AuthStatus.unknown;
    notifyListeners();

    // Fetch complete user data from Firestore with retry mechanism
    await _loadUserData(firebaseUser);

    // Now set the authenticated status after user data is loaded
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  // Separate method to load user data with retry mechanism
  Future<void> _loadUserData(User firebaseUser) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final userData = await _authService.getUserData(firebaseUser.uid);
        print('Fetched user data from Firestore: $userData'); // Debug print

        // Check if we got valid data
        if (userData.isEmpty) {
          print(
            'Warning: Empty user data returned from Firestore, retrying...',
          );
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          continue;
        }

        // Extract the student-specific fields explicitly, with detailed logging
        final studentId = userData['studentId'] as String? ?? '';
        final department = userData['department'] as String? ?? '';
        final phone = userData['phone'] as String? ?? '';

        print(
          'Profile data from Firestore: studentId=$studentId, department=$department, phone=$phone',
        );

        _user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: userData['name'] ?? firebaseUser.displayName ?? 'Unknown User',
          role: userData['role'] ?? 'student',
          profilePicture:
              userData['profilePicture'] ?? firebaseUser.photoURL ?? '',
          createdAt: userData['createdAt']?.toDate(),
          lastLogin: userData['lastLogin']?.toDate(),
          // Include student-specific fields with empty string fallbacks instead of null
          studentId: studentId,
          department: department,
          phone: phone,
        );

        print(
          'Created AppUser: studentId=${_user!.studentId}, department=${_user!.department}, phone=${_user!.phone}',
        );
        print('Profile complete? ${_user!.isProfileComplete}');

        // Save FCM token after successful user load
        await _saveFCMToken(firebaseUser.uid);

        // Note: lastLogin is already updated by the sign-in process in auth_service
        // No need to update it again here to avoid potential conflicts

        notifyListeners();
        return; // Success, exit the retry loop
      } catch (e) {
        print('Error fetching user data (attempt ${retryCount + 1}): $e');
        retryCount++;

        if (retryCount >= maxRetries) {
          // Final fallback to Firebase Auth data if all Firestore fetches fail
          _user = AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'Unknown User',
            role: await _authService.getUserRole() ?? 'student',
            profilePicture: firebaseUser.photoURL ?? '',
            // Use empty strings instead of null for student fields
            studentId: '',
            department: '',
            phone: '',
          );
          notifyListeners();
        } else {
          // Wait before retrying with exponential backoff
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }
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

  // Save FCM token for the user
  Future<void> _saveFCMToken(String userId) async {
    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _fcmService.saveTokenToFirestore(userId, token);
        print('FCM token saved for user: $userId');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      // Don't throw error, just log it
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Sign-In (Admin)
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signInWithEmailPassword(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Sign-Up (Admin)
  Future<bool> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signUpWithEmailPassword(email, password, name);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      // Remove FCM token from Firestore before signing out
      if (_user != null) {
        await _fcmService.removeTokenFromFirestore(_user!.uid);
        await _fcmService.deleteToken();
      }

      // First, clear the user data and set status to unauthenticated
      // This ensures the UI will respond to the change
      _user = null;
      _status = AuthStatus.unauthenticated;

      // Force immediate UI update before Firebase signout
      notifyListeners();

      // Then sign out from Firebase (which might take time)
      await _authService.signOut();

      // Force another UI update after Firebase signout
      notifyListeners();

      // Add a small delay and notify again to ensure UI has fully processed the change
      await Future.delayed(const Duration(milliseconds: 300));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error message
  void clearError() {
    _setError(null);
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? profilePicture,
    String? studentId,
    String? department,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_user == null) {
        throw Exception('No user logged in');
      }

      await _authService.updateUserProfile(
        uid: _user!.uid,
        name: name,
        profilePicture: profilePicture,
        studentId: studentId,
        department: department,
        phone: phone,
      );

      // Update local user object
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        profilePicture: profilePicture ?? _user!.profilePicture,
        studentId: studentId ?? _user!.studentId,
        department: department ?? _user!.department,
        phone: phone ?? _user!.phone,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update last seen update time for notifications
  Future<bool> updateLastSeenUpdateTime() async {
    try {
      if (_user == null) return false;

      final now = DateTime.now();

      await _authService.updateUserProfile(
        uid: _user!.uid,
        lastSeenUpdateTime: now,
      );

      // Update local user object
      _user = _user!.copyWith(lastSeenUpdateTime: now);

      notifyListeners();
      return true;
    } catch (e) {
      // Don't show error for this background operation
      print('Failed to update last seen update time: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
