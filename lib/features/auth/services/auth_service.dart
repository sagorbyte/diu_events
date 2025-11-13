import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Configure Google Sign-In differently for web vs mobile
    if (kIsWeb) {
      // For web, use minimal configuration to avoid People API calls
      _googleSignIn = GoogleSignIn(
        clientId:
            '210442734122-g8rqhhmn1t048oe0nqfkb5vls7gv86rk.apps.googleusercontent.com',
        scopes: ['email', 'profile'], // Only request minimal scopes
      );
    } else {
      // For mobile, use default configuration
      _googleSignIn = GoogleSignIn(
        scopes: [], // Empty scopes to avoid unnecessary API calls
      );
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Allowed domains for Google Sign-In
  static const List<String> allowedDomains = [
    'diu.edu.bd',
    'daffodilvarsity.edu.bd',
  ];

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Google Sign-In with domain restriction
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        // Web-specific implementation to avoid People API issues
        // Use Firebase's built-in Google auth provider for web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Add custom parameters for Google sign-in on web - DOMAIN RESTRICTION ENABLED
        googleProvider.setCustomParameters({
          'login_hint': '@diu.edu.bd',
          'hd': 'diu.edu.bd', // Forces Google account picker to show only diu.edu.bd accounts
        });

        // Trigger popup sign-in flow directly with Firebase
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);

        // Check domain restriction
        final String? email = userCredential.user?.email;
        if (email != null) {
          final String domain = email.split('@')[1];
          if (!allowedDomains.contains(domain)) {
            await signOut();
            throw Exception(
              'Only @diu.edu.bd and @daffodilvarsity.edu.bd email addresses are allowed',
            );
          }
        }

        // Store user data directly from Firebase User
        if (userCredential.user != null) {
          await _storeBasicUserData(userCredential.user!);
        }
      } else {
        // Mobile implementation (standard flow)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled');
        }

        // Check if the email domain is allowed
        final String email = googleUser.email;
        final String domain = email.split('@')[1];

        if (!allowedDomains.contains(domain)) {
          await _googleSignIn.signOut();
          throw Exception(
            'Only @diu.edu.bd and @daffodilvarsity.edu.bd email addresses are allowed',
          );
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credentials
        userCredential = await _firebaseAuth.signInWithCredential(credential);

        // Store user data in Firestore using GoogleSignInAccount data
        await _storeGoogleUserData(userCredential.user!, googleUser);
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');

      // Additional error handling for People API errors that might still occur
      if (e.toString().contains('People API') ||
          e.toString().contains('PERMISSION_DENIED')) {
        print('People API error detected, attempting recovery...');

        // Check if user is already authenticated
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null) {
          print('User is authenticated in Firebase despite People API error');
          await _storeBasicUserData(currentUser);
          return null; // User is authenticated despite error
        }
      }

      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  // Email and Password Sign-In (for admin)
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if user is admin or superadmin
      final userData = await _getUserData(userCredential.user!.uid);
      if (userData['role'] != 'admin' && userData['role'] != 'superadmin') {
        await signOut();
        throw Exception('Access denied. Admin credentials required.');
      }

      return userCredential;
    } catch (e) {
      print('Email Sign-In Error: $e');
      throw Exception('Email Sign-In failed: ${e.toString()}');
    }
  }

  // Email and Password Sign-Up (for creating admin accounts)
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Store admin user data in Firestore
      await _storeUserData(userCredential.user!, 'admin', name: name);

      return userCredential;
    } catch (e) {
      print('Email Sign-Up Error: $e');
      throw Exception('Email Sign-Up failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // First clear any cached user data
      FirebaseAuth.instance.authStateChanges().drain();

      // Force sign out from Firebase Auth
      await _firebaseAuth.signOut();

      // Force sign out from Google Sign In
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print('Google disconnect error (non-critical): $e');
      }

      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Google signOut error (non-critical): $e');
      }

      // Clear any persistent auth state
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Sign Out Error: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Store user data in Firestore
  Future<void> _storeUserData(User user, String role, {String? name}) async {
    try {
      // First check if user already exists to avoid overwriting profile data
      final existingUserDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (existingUserDoc.exists) {
        // User exists, only update login timestamp and basic auth fields
        final updateData = {
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email,
          'profilePicture': user.photoURL ?? '',
        };

        // Only update name if it's provided and different, or if current name is empty
        final existingData = existingUserDoc.data() as Map<String, dynamic>;
        if (name != null ||
            existingData['name'] == null ||
            existingData['name'].toString().isEmpty) {
          updateData['name'] = name ?? user.displayName ?? '';
        }

        await _firestore.collection('users').doc(user.uid).update(updateData);

        print('Updated existing user login timestamp and basic fields');
      } else {
        // New user, create full document
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'name': name ?? user.displayName ?? '',
          'role': role,
          'profilePicture': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);

        print('Created new user document');
      }
    } catch (e) {
      print('Store User Data Error: $e');
      throw Exception('Failed to store user data: ${e.toString()}');
    }
  }

  // Store user data from Google Sign-In (minimal approach)
  Future<void> _storeGoogleUserData(
    User firebaseUser,
    GoogleSignInAccount googleUser,
  ) async {
    try {
      // First check if user already exists to avoid overwriting profile data
      final existingUserDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (existingUserDoc.exists) {
        // User exists, only update login timestamp and basic auth fields
        final updateData = {
          'lastLogin': FieldValue.serverTimestamp(),
          // Only update these if they've changed or are empty
          'email': googleUser.email,
          'profilePicture': googleUser.photoUrl ?? firebaseUser.photoURL ?? '',
        };

        // Only update name if it's empty in existing document
        final existingData = existingUserDoc.data() as Map<String, dynamic>;
        if (existingData['name'] == null ||
            existingData['name'].toString().isEmpty) {
          updateData['name'] =
              googleUser.displayName ?? firebaseUser.displayName ?? '';
        }

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .update(updateData);

        print('Updated existing user login timestamp and basic fields');
      } else {
        // New user, create full document
        final userData = {
          'uid': firebaseUser.uid,
          'email': googleUser.email,
          'name': googleUser.displayName ?? firebaseUser.displayName ?? '',
          'role': 'student',
          'profilePicture': googleUser.photoUrl ?? firebaseUser.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userData);

        print('Created new user document');
      }
    } catch (e) {
      print('Store User Data Error: $e');
      throw Exception('Failed to store user data: ${e.toString()}');
    }
  }

  // Store basic user data when People API fails (fallback method)
  Future<void> _storeBasicUserData(User firebaseUser) async {
    try {
      // First check if user already exists to avoid overwriting profile data
      final existingUserDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (existingUserDoc.exists) {
        // User exists, only update login timestamp and basic auth fields
        final updateData = {
          'lastLogin': FieldValue.serverTimestamp(),
          // Only update these if they've changed or are empty
          'email': firebaseUser.email ?? '',
          'profilePicture': firebaseUser.photoURL ?? '',
        };

        // Only update name if it's empty in existing document
        final existingData = existingUserDoc.data() as Map<String, dynamic>;
        if (existingData['name'] == null ||
            existingData['name'].toString().isEmpty) {
          updateData['name'] = firebaseUser.displayName ?? 'Unknown User';
        }

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .update(updateData);

        print(
          'Updated existing user login timestamp and basic fields (fallback)',
        );
      } else {
        // New user, create full document
        final userData = {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'name': firebaseUser.displayName ?? 'Unknown User',
          'role': 'student',
          'profilePicture': firebaseUser.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userData);

        print('Created new user document (fallback)');
      }

      print('Basic user data stored successfully despite People API error');
    } catch (e) {
      print('Store Basic User Data Error: $e');
      throw Exception('Failed to store basic user data: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Get User Data Error: $e');
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) return null;

      final userData = await _getUserData(currentUser!.uid);
      return userData['role'] as String?;
    } catch (e) {
      print('Get User Role Error: $e');
      return null;
    }
  }

  // Check if user is admin or superadmin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin' || role == 'superadmin';
  }

  // Check if user is student
  Future<bool> isStudent() async {
    final role = await getUserRole();
    return role == 'student';
  }

  // Get user data from Firestore (public method)
  Future<Map<String, dynamic>> getUserData(String uid) async {
    return await _getUserData(uid);
  }

  // Update user profile (name, profile picture, and student-specific fields)
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? profilePicture,
    String? studentId,
    String? department,
    String? phone,
    DateTime? lastSeenUpdateTime,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
        // Also update Firebase Auth display name
        if (currentUser?.uid == uid) {
          await currentUser?.updateDisplayName(name);
        }
      }

      if (profilePicture != null) {
        updateData['profilePicture'] = profilePicture;
        // Also update Firebase Auth photo URL
        if (currentUser?.uid == uid) {
          await currentUser?.updatePhotoURL(profilePicture);
        }
      }

      // Student-specific fields
      if (studentId != null) {
        updateData['studentId'] = studentId;
      }

      if (department != null) {
        updateData['department'] = department;
      }

      if (phone != null) {
        updateData['phone'] = phone;
      }

      if (lastSeenUpdateTime != null) {
        updateData['lastSeenUpdateTime'] = Timestamp.fromDate(
          lastSeenUpdateTime,
        );
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(uid).update(updateData);
      }
    } catch (e) {
      print('Update User Profile Error: $e');
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset Password Error: $e');
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Change password (requires current password for security)
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('Password changed successfully');
    } catch (e) {
      print('Change Password Error: $e');
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw Exception('Current password is incorrect');
          case 'weak-password':
            throw Exception('New password is too weak');
          case 'requires-recent-login':
            throw Exception(
              'Please log out and log back in before changing your password',
            );
          default:
            throw Exception('Failed to change password: ${e.message}');
        }
      }
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }
}
