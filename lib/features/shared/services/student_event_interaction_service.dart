import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_event_interaction.dart';

class StudentEventInteractionService {
  static final StudentEventInteractionService _instance =
      StudentEventInteractionService._internal();
  factory StudentEventInteractionService() => _instance;
  StudentEventInteractionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'student_event_interactions';

  // Create a new interaction (register, follow, etc.)
  Future<String> createInteraction(StudentEventInteraction interaction) async {
    try {
      // Check if interaction already exists
      final existingInteraction = await getInteraction(
        interaction.studentId,
        interaction.eventId,
        interaction.type,
      );

      if (existingInteraction != null && existingInteraction.isActive) {
        throw Exception('Interaction already exists');
      }

      // If it exists but is inactive, update it
      if (existingInteraction != null && !existingInteraction.isActive) {
        await updateInteraction(
          existingInteraction.id,
          existingInteraction.copyWith(
            isActive: true,
            updatedAt: DateTime.now(),
          ),
        );
        return existingInteraction.id;
      }

      // Create new interaction
      final docRef = await _firestore.collection(_collection).add(
            interaction.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create interaction: $e');
    }
  }

  // Update an existing interaction
  Future<void> updateInteraction(
    String interactionId,
    StudentEventInteraction interaction,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(interactionId)
          .update(interaction.toFirestore());
    } catch (e) {
      throw Exception('Failed to update interaction: $e');
    }
  }

  // Remove an interaction (soft delete)
  Future<void> removeInteraction(
    String studentId,
    String eventId,
    InteractionType type,
  ) async {
    try {
      final interaction = await getInteraction(studentId, eventId, type);
      if (interaction != null) {
        await _firestore.collection(_collection).doc(interaction.id).update({
          'isActive': false,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove interaction: $e');
    }
  }

  // Get a specific interaction
  Future<StudentEventInteraction?> getInteraction(
    String studentId,
    String eventId,
    InteractionType type,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('eventId', isEqualTo: eventId)
          .where('type', isEqualTo: type.toString().split('.').last)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return StudentEventInteraction.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get interaction: $e');
    }
  }

  // Get all interactions for a student
  Future<List<StudentEventInteraction>> getStudentInteractions(
    String studentId, {
    InteractionType? type,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => StudentEventInteraction.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get student interactions: $e');
    }
  }

  // Get all interactions for an event
  Future<List<StudentEventInteraction>> getEventInteractions(
    String eventId, {
    InteractionType? type,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('eventId', isEqualTo: eventId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => StudentEventInteraction.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get event interactions: $e');
    }
  }

  // Get registered students for an event
  Future<List<String>> getRegisteredStudentIds(String eventId) async {
    try {
      final interactions = await getEventInteractions(
        eventId,
        type: InteractionType.registered,
      );
      return interactions.map((interaction) => interaction.studentId).toList();
    } catch (e) {
      throw Exception('Failed to get registered students: $e');
    }
  }

  // Get following students for an event
  Future<List<String>> getFollowingStudentIds(String eventId) async {
    try {
      final interactions = await getEventInteractions(
        eventId,
        type: InteractionType.following,
      );
      return interactions.map((interaction) => interaction.studentId).toList();
    } catch (e) {
      throw Exception('Failed to get following students: $e');
    }
  }

  // Get events a student is registered for
  Future<List<String>> getStudentRegisteredEventIds(String studentId) async {
    try {
      final interactions = await getStudentInteractions(
        studentId,
        type: InteractionType.registered,
      );
      return interactions.map((interaction) => interaction.eventId).toList();
    } catch (e) {
      throw Exception('Failed to get student registered events: $e');
    }
  }

  // Get events a student is following
  Future<List<String>> getStudentFollowingEventIds(String studentId) async {
    try {
      final interactions = await getStudentInteractions(
        studentId,
        type: InteractionType.following,
      );
      return interactions.map((interaction) => interaction.eventId).toList();
    } catch (e) {
      throw Exception('Failed to get student following events: $e');
    }
  }

  // Check if student is registered for event
  Future<bool> isStudentRegistered(String studentId, String eventId) async {
    try {
      final interaction = await getInteraction(
        studentId,
        eventId,
        InteractionType.registered,
      );
      return interaction != null && interaction.isActive;
    } catch (e) {
      return false;
    }
  }

  // Check if student is following event
  Future<bool> isStudentFollowing(String studentId, String eventId) async {
    try {
      final interaction = await getInteraction(
        studentId,
        eventId,
        InteractionType.following,
      );
      return interaction != null && interaction.isActive;
    } catch (e) {
      return false;
    }
  }

  // Register student for event
  // Returns the created interaction id.
  Future<String> registerStudentForEvent(
    String studentId,
    String eventId, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interaction = StudentEventInteraction(
        id: '', // Will be set by Firestore
        studentId: studentId,
        eventId: eventId,
        type: InteractionType.registered,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      final id = await createInteraction(interaction);
      return id;
    } catch (e) {
      throw Exception('Failed to register student for event: $e');
    }
  }

  // Unregister student from event
  Future<void> unregisterStudentFromEvent(
    String studentId,
    String eventId,
  ) async {
    try {
      await removeInteraction(studentId, eventId, InteractionType.registered);
    } catch (e) {
      throw Exception('Failed to unregister student from event: $e');
    }
  }

  // Follow event
  Future<void> followEvent(
    String studentId,
    String eventId, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interaction = StudentEventInteraction(
        id: '', // Will be set by Firestore
        studentId: studentId,
        eventId: eventId,
        type: InteractionType.following,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await createInteraction(interaction);
    } catch (e) {
      throw Exception('Failed to follow event: $e');
    }
  }

  // Unfollow event
  Future<void> unfollowEvent(String studentId, String eventId) async {
    try {
      await removeInteraction(studentId, eventId, InteractionType.following);
    } catch (e) {
      throw Exception('Failed to unfollow event: $e');
    }
  }

  // Mark event as completed for student
  Future<void> markEventCompleted(
    String studentId,
    String eventId, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interaction = StudentEventInteraction(
        id: '', // Will be set by Firestore
        studentId: studentId,
        eventId: eventId,
        type: InteractionType.completed,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await createInteraction(interaction);
    } catch (e) {
      throw Exception('Failed to mark event as completed: $e');
    }
  }

  // Get interaction statistics for an event
  Future<Map<String, int>> getEventStatistics(String eventId) async {
    try {
      final allInteractions = await getEventInteractions(eventId);
      
      final stats = {
        'registered': 0,
        'following': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final interaction in allInteractions) {
        switch (interaction.type) {
          case InteractionType.registered:
            stats['registered'] = stats['registered']! + 1;
            break;
          case InteractionType.following:
            stats['following'] = stats['following']! + 1;
            break;
          case InteractionType.completed:
            stats['completed'] = stats['completed']! + 1;
            break;
          case InteractionType.cancelled:
            stats['cancelled'] = stats['cancelled']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get event statistics: $e');
    }
  }

  // Stream interactions for real-time updates
  Stream<List<StudentEventInteraction>> streamStudentInteractions(
    String studentId, {
    InteractionType? type,
    bool activeOnly = true,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => StudentEventInteraction.fromFirestore(doc))
            .toList());
  }

  // Stream event interactions for real-time updates
  Stream<List<StudentEventInteraction>> streamEventInteractions(
    String eventId, {
    InteractionType? type,
    bool activeOnly = true,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => StudentEventInteraction.fromFirestore(doc))
            .toList());
  }
}
