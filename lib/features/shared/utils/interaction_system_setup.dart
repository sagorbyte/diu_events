import 'package:flutter/foundation.dart';
import '../utils/student_event_interaction_migration.dart';

/// Simple setup script to initialize the new Student-Event Interaction System
class InteractionSystemSetup {
  
  /// Runs the complete setup process for the new interaction system
  static Future<void> initialize() async {
    if (kDebugMode) {
      print('🚀 Initializing Student-Event Interaction System...');
      
      try {
        // Step 1: Run migration from old system
        print('\n📦 Step 1: Migrating existing data...');
        await StudentEventInteractionMigration.runFullMigration();
        
        // Step 2: Validate migration
        print('\n✅ Step 2: Validating migration...');
        await StudentEventInteractionMigration.validateMigration();
        
        print('\n🎉 Setup completed successfully!');
        print('\n📚 Next steps:');
        print('1. Update your Firestore security rules (see FIREBASE_SETUP.md)');
        print('2. Test the new functionality in your app');
        print('3. Monitor for any issues');
        print('4. Consider running cleanup after confirming everything works');
        
      } catch (e) {
        print('\n❌ Setup failed: $e');
        print('\n🔧 Troubleshooting:');
        print('1. Check your internet connection');
        print('2. Verify Firebase permissions');
        print('3. Ensure Firestore is properly configured');
        print('4. Check console for detailed error messages');
        rethrow;
      }
    } else {
      print('Setup can only be run in debug mode for safety');
    }
  }

  /// Quick health check for the interaction system
  static Future<bool> healthCheck() async {
    try {
      print('🔍 Running health check...');
      
      // Try to validate the migration
      await StudentEventInteractionMigration.validateMigration();
      
      print('✅ Health check passed!');
      return true;
      
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  /// Display system information
  static void showInfo() {
    print('📋 Student-Event Interaction System Information');
    print('═' * 50);
    print('Version: 1.0.0');
    print('Collection: student_event_interactions');
    print('Features:');
    print('  • Event registration tracking');
    print('  • Event following/unfollowing');
    print('  • Completion status');
    print('  • Cancellation tracking');
    print('  • Real-time statistics');
    print('  • Flexible metadata storage');
    print('');
    print('For more information, see STUDENT_EVENT_INTERACTION_SYSTEM.md');
  }
}
