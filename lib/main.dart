import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/admin/screens/admin_management_screen.dart';
import 'features/shared/providers/event_provider.dart';
import 'features/shared/providers/user_notification_provider.dart';
import 'features/admin/screens/admin_home_screen.dart';
import 'features/student/screens/student_home_screen.dart';
import 'features/student/screens/profile_completion_screen.dart';
import 'services/fcm_service.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM service
  await FCMService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'DIU Events',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textTheme: GoogleFonts.hindSiliguriTextTheme(),
              primaryTextTheme: GoogleFonts.hindSiliguriTextTheme(),
            ),
            // Constrain max width on web to 492px and center the app.
            // Use MaterialApp.builder so it applies app-wide without changing layouts on mobile.
            builder: (BuildContext context, Widget? child) {
              if (kIsWeb) {
                // Full-screen black background with centered constrained content.
                return Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 492),
                      child: child,
                    ),
                  ),
                );
              }
              return child ?? const SizedBox.shrink();
            },
            // Force rebuild of entire app when auth state changes
            key: ValueKey<AuthStatus>(authProvider.status),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Print the current auth status for debugging
        print('Current auth status: ${authProvider.status}');

        switch (authProvider.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            if (authProvider.user == null) {
              // If status is authenticated but user is null, force to login screen
              print(
                'User is null but status is authenticated, forcing login screen',
              );
              return const LoginScreen();
            }

            // Check if the user is a superadmin
            if (authProvider.user?.isSuperAdmin ?? false) {
              return const AdminManagementScreen();
            }
            // Check if the user is an admin
            if (authProvider.user?.isAdmin ?? false) {
              return const AdminHomeScreen();
            }

            // For students, check if profile is complete
            if (authProvider.user?.isStudent ?? false) {
              // If any of the student-specific fields are empty, show the completion screen
              final user = authProvider.user!;
              if (user.studentId.isEmpty ||
                  user.department.isEmpty ||
                  user.phone.isEmpty) {
                print(
                  'Profile incomplete: studentId=${user.studentId}, department=${user.department}, phone=${user.phone}',
                );
                return const ProfileCompletionScreen();
              } else {
                print(
                  'Profile complete: studentId=${user.studentId}, department=${user.department}, phone=${user.phone}',
                );
              }
            }

            // Regular students go to StudentHomeScreen
            return const StudentHomeScreen();
          case AuthStatus.unauthenticated:
            // Force navigation to login screen with key to ensure rebuild
            return const LoginScreen(key: Key('login_screen_forced'));
        }
      },
    );
  }
}
