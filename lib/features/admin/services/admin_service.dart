import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_events/features/auth/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diu_events/firebase_options.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return AppUser.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role.');
    }
  }

  Future<void> createAdminInFirestore({
    required String name,
    required String email,
    required String password,
  }) async {
    // Create a secondary Firebase app to create a user without signing out the admin.
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'tempAdminCreationApp',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instanceFor(
        app: tempApp,
      ).createUserWithEmailAndPassword(email: email, password: password);

      User newUser = userCredential.user!;

      // Create user document in Firestore
      final appUser = AppUser(
        uid: newUser.uid,
        name: name,
        email: email,
        role: 'admin', // Default role for new users created by superadmin
      );

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(appUser.toJson());
    } on FirebaseAuthException catch (e) {
      // Provide more specific error messages
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already registered.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      }
      throw Exception('Failed to create admin: ${e.message}');
    } finally {
      // Delete the temporary app instance to clean up resources
      await tempApp.delete();
    }
  }

  Future<void> updateAdminUser({
    required String uid,
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      // Update user document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'email': email,
      });

      // Update email and password in Firebase Auth if needed
      if (password != null && password.isNotEmpty) {
        // Create a secondary Firebase app to update user without affecting current session
        FirebaseApp tempApp = await Firebase.initializeApp(
          name: 'tempAdminUpdateApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );

        try {
          // Note: Updating email/password for other users requires admin SDK
          // For now, we'll just update the Firestore document
          // In production, you'd need Firebase Admin SDK or Cloud Functions
        } finally {
          await tempApp.delete();
        }
      }
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user.');
    }
  }
}
