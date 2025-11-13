import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_update.dart';

class EventUpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'event_updates';

  // Create event update
  Future<String> createEventUpdate(EventUpdate eventUpdate) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(eventUpdate.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event update: $e');
    }
  }

  // Get updates for a specific event
  Future<List<EventUpdate>> getEventUpdates(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('eventId', isEqualTo: eventId)
          .get();

      // Filter and sort locally to avoid composite index requirement
      final updates = querySnapshot.docs
          .map((doc) => EventUpdate.fromFirestore(doc))
          .where((update) => update.isActive)
          .toList();

      // Sort by creation date in descending order
      updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return updates;
    } catch (e) {
      throw Exception('Failed to get event updates: $e');
    }
  }

  // Get all updates for admin
  Future<List<EventUpdate>> getAllEventUpdates() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      // Filter and sort locally to avoid composite index requirement
      final updates = querySnapshot.docs
          .map((doc) => EventUpdate.fromFirestore(doc))
          .where((update) => update.isActive)
          .toList();

      // Sort by creation date in descending order
      updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return updates;
    } catch (e) {
      throw Exception('Failed to get all event updates: $e');
    }
  }

  // Delete event update
  Future<void> deleteEventUpdate(String updateId) async {
    try {
      await _firestore.collection(_collection).doc(updateId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete event update: $e');
    }
  }

  // Stream updates for real-time listening
  Stream<List<EventUpdate>> streamEventUpdates(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventUpdate.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream all updates for admin
  Stream<List<EventUpdate>> streamAllEventUpdates() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventUpdate.fromFirestore(doc))
              .toList(),
        );
  }
}
