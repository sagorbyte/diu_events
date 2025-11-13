import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_event_interaction.dart';
import '../services/student_event_interaction_service.dart';

/// Utility class to migrate existing event registrations to the new interaction system
class StudentEventInteractionMigration {
  static final StudentEventInteractionService _interactionService = 
      StudentEventInteractionService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrates existing registrations from events collection to student_event_interactions
  static Future<void> migrateExistingRegistrations() async {
    try {
      print('Starting migration of existing registrations...');
      
      // Get all events
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      int migratedCount = 0;
      int totalProcessed = 0;

      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final eventId = eventDoc.id;
        final registeredParticipants = List<String>.from(
          eventData['registeredParticipants'] ?? [],
        );

        print('Processing event: ${eventData['title']} (${registeredParticipants.length} registrations)');

        for (final studentId in registeredParticipants) {
          try {
            // Check if interaction already exists
            final existingInteraction = await _interactionService.getInteraction(
              studentId,
              eventId,
              InteractionType.registered,
            );

            if (existingInteraction == null) {
              // Create new interaction
              final interaction = StudentEventInteraction(
                id: '',
                studentId: studentId,
                eventId: eventId,
                type: InteractionType.registered,
                createdAt: (eventData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                metadata: {
                  'migratedFromEvent': true,
                  'migrationDate': Timestamp.fromDate(DateTime.now()),
                },
              );

              await _interactionService.createInteraction(interaction);
              migratedCount++;
              print('  ✓ Migrated registration for student: $studentId');
            } else {
              print('  - Registration already exists for student: $studentId');
            }
            
            totalProcessed++;
          } catch (e) {
            print('  ✗ Failed to migrate registration for student $studentId: $e');
          }
        }
      }

      print('Migration completed!');
      print('Total processed: $totalProcessed');
      print('Successfully migrated: $migratedCount');
      print('Already existed: ${totalProcessed - migratedCount}');
      
    } catch (e) {
      print('Migration failed: $e');
      throw Exception('Failed to migrate existing registrations: $e');
    }
  }

  /// Migrates existing interested users to following interactions
  static Future<void> migrateExistingInterests() async {
    try {
      print('Starting migration of existing interests...');
      
      // Get all events that have interestedUsers field
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      int migratedCount = 0;
      int totalProcessed = 0;

      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final eventId = eventDoc.id;
        final interestedUsers = List<String>.from(
          eventData['interestedUsers'] ?? [],
        );

        if (interestedUsers.isNotEmpty) {
          print('Processing event: ${eventData['title']} (${interestedUsers.length} interests)');

          for (final studentId in interestedUsers) {
            try {
              // Check if interaction already exists
              final existingInteraction = await _interactionService.getInteraction(
                studentId,
                eventId,
                InteractionType.following,
              );

              if (existingInteraction == null) {
                // Create new interaction
                final interaction = StudentEventInteraction(
                  id: '',
                  studentId: studentId,
                  eventId: eventId,
                  type: InteractionType.following,
                  createdAt: (eventData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  metadata: {
                    'migratedFromEvent': true,
                    'migrationDate': Timestamp.fromDate(DateTime.now()),
                  },
                );

                await _interactionService.createInteraction(interaction);
                migratedCount++;
                print('  ✓ Migrated interest for student: $studentId');
              } else {
                print('  - Interest already exists for student: $studentId');
              }
              
              totalProcessed++;
            } catch (e) {
              print('  ✗ Failed to migrate interest for student $studentId: $e');
            }
          }
        }
      }

      print('Interest migration completed!');
      print('Total processed: $totalProcessed');
      print('Successfully migrated: $migratedCount');
      print('Already existed: ${totalProcessed - migratedCount}');
      
    } catch (e) {
      print('Interest migration failed: $e');
      throw Exception('Failed to migrate existing interests: $e');
    }
  }

  /// Full migration - runs both registration and interest migrations
  static Future<void> runFullMigration() async {
    print('=== Starting Full Migration ===');
    
    try {
      await migrateExistingRegistrations();
      await migrateExistingInterests();
      
      print('\n=== Migration Completed Successfully ===');
      print('You can now safely remove registeredParticipants and interestedUsers fields from events');
      print('The new student_event_interactions collection is now active');
      
    } catch (e) {
      print('\n=== Migration Failed ===');
      print('Error: $e');
      rethrow;
    }
  }

  /// Validates that the migration was successful by comparing counts
  static Future<void> validateMigration() async {
    try {
      print('Validating migration...');
      
      // Get all events
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      int totalEventRegistrations = 0;
      int totalEventInterests = 0;
      
      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final registeredParticipants = List<String>.from(
          eventData['registeredParticipants'] ?? [],
        );
        final interestedUsers = List<String>.from(
          eventData['interestedUsers'] ?? [],
        );
        
        totalEventRegistrations += registeredParticipants.length;
        totalEventInterests += interestedUsers.length;
      }

      // Get interactions count
      final registrationInteractions = await _firestore
          .collection('student_event_interactions')
          .where('type', isEqualTo: 'registered')
          .where('isActive', isEqualTo: true)
          .get();

      final followingInteractions = await _firestore
          .collection('student_event_interactions')
          .where('type', isEqualTo: 'following')
          .where('isActive', isEqualTo: true)
          .get();

      print('Validation Results:');
      print('Event registrations: $totalEventRegistrations');
      print('Interaction registrations: ${registrationInteractions.docs.length}');
      print('Event interests: $totalEventInterests');
      print('Interaction following: ${followingInteractions.docs.length}');
      
      final registrationMatch = totalEventRegistrations <= registrationInteractions.docs.length;
      final interestMatch = totalEventInterests <= followingInteractions.docs.length;
      
      if (registrationMatch && interestMatch) {
        print('✓ Migration validation successful!');
      } else {
        print('✗ Migration validation failed!');
        if (!registrationMatch) {
          print('  Registration count mismatch');
        }
        if (!interestMatch) {
          print('  Interest count mismatch');
        }
      }
      
    } catch (e) {
      print('Validation failed: $e');
    }
  }

  /// Clean up old fields from events after successful migration (use with caution!)
  static Future<void> cleanupOldFields() async {
    try {
      print('WARNING: This will remove registeredParticipants and interestedUsers fields from all events!');
      print('Make sure migration is successful before running this.');
      
      // Uncomment the following lines only after confirming migration is successful
      /*
      final eventsSnapshot = await _firestore
          .collection('events')
          .get();

      for (final eventDoc in eventsSnapshot.docs) {
        await eventDoc.reference.update({
          'registeredParticipants': FieldValue.delete(),
          'interestedUsers': FieldValue.delete(),
        });
      }
      
      print('Cleanup completed!');
      */
      
      print('Cleanup is commented out for safety. Uncomment after confirming migration success.');
      
    } catch (e) {
      print('Cleanup failed: $e');
    }
  }
}
