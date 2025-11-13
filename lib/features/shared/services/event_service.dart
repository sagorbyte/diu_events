import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../../../core/services/imgbb_image_service.dart';
import 'package:image_picker/image_picker.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';
  final ImgBBImageService _imageUploadService = ImgBBImageService();

  // Get all events
  Future<List<Event>> getAllEvents() async {
    try {
      print('Fetching all events'); // Debug log
      // Query all events without compound filters to avoid index issues
      final querySnapshot = await _firestore
          .collection(_collection)
          .get();

      // Filter active events and sort locally
      final events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .where((event) => event.isActive) // Filter active events locally
          .toList();

  // Sort locally by start date (latest first)
  events.sort((a, b) => b.startDate.compareTo(a.startDate));

      print('Found ${events.length} active events'); // Debug log
      return events;
    } catch (e) {
      print('Error fetching events: $e'); // Debug log
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Get events by organizer (admin)
  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    try {
      print('Fetching events for organizer: $organizerId'); // Debug log
      // First query: get events by organizer only, then filter and sort locally
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('organizerId', isEqualTo: organizerId)
          .get();

      final events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .where((event) => event.isActive) // Filter active events locally
          .toList();

  // Sort locally by start date (latest first)
  events.sort((a, b) => b.startDate.compareTo(a.startDate));

      print(
        'Found ${events.length} events for organizer: $organizerId',
      ); // Debug log
      return events;
    } catch (e) {
      print('Error fetching organizer events: $e'); // Debug log
      throw Exception('Failed to fetch organizer events: $e');
    }
  }

  // Get upcoming events
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      print('Fetching upcoming events'); // Debug log
      
      // Query all events to avoid compound index issues
      final querySnapshot = await _firestore
          .collection(_collection)
          .get();

      // Filter upcoming and active events locally
      final events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .where((event) => event.isActive && event.startDate.isAfter(now))
          .toList();

  // Sort locally by start date (latest first)
  events.sort((a, b) => b.startDate.compareTo(a.startDate));

      print('Found ${events.length} upcoming events'); // Debug log
      return events;
    } catch (e) {
      print('Error fetching upcoming events: $e'); // Debug log
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  // Get past events
  Future<List<Event>> getPastEvents() async {
    try {
      final now = DateTime.now();
      print('Fetching past events'); // Debug log
      
      // Query all events to avoid compound index issues
      final querySnapshot = await _firestore
          .collection(_collection)
          .get();

      // Filter past and active events locally
      final events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .where((event) => event.isActive && event.endDate.isBefore(now))
          .toList();

  // Sort locally by start date (latest first)
  events.sort((a, b) => b.startDate.compareTo(a.startDate));

      print('Found ${events.length} past events'); // Debug log
      return events;
    } catch (e) {
      print('Error fetching past events: $e'); // Debug log
      throw Exception('Failed to fetch past events: $e');
    }
  }

  // Search events
  Future<List<Event>> searchEvents(String query) async {
    try {
      // For simplicity, we'll get all events and filter client-side
      // In a production app, you might want to use Algolia or similar for better search
      final events = await getAllEvents();
      final lowercaseQuery = query.toLowerCase();

      return events.where((event) {
        return event.title.toLowerCase().contains(lowercaseQuery) ||
            event.description.toLowerCase().contains(lowercaseQuery) ||
            event.organizerName.toLowerCase().contains(lowercaseQuery) ||
            event.location.toLowerCase().contains(lowercaseQuery) ||
            event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  // Create event with image upload
  Future<String> createEventWithImage(Event event, {XFile? imageFile}) async {
    try {
      print(
        'Creating event: ${event.title} for organizer: ${event.organizerId}',
      ); // Debug log
      
      String imageUrl = event.imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        // Create a temporary event ID for image upload
        final tempEventId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _imageUploadService.uploadEventImage(imageFile, tempEventId);
        print('Image uploaded: $imageUrl'); // Debug log
      }
      
      // Create event with image URL
      final eventWithImage = event.copyWith(imageUrl: imageUrl);
      final docRef = await _firestore
          .collection(_collection)
          .add(eventWithImage.toFirestore());
      
      print('Event created with ID: ${docRef.id}'); // Debug log
      return docRef.id;
    } catch (e) {
      print('Error creating event: $e'); // Debug log
      throw Exception('Failed to create event: $e');
    }
  }

  // Update event with optional image upload
  Future<void> updateEventWithImage(Event event, {XFile? imageFile}) async {
    try {
      String imageUrl = event.imageUrl;
      
      // Upload new image if provided
      if (imageFile != null) {
        // Delete old image if it exists and is from ImgBB
        if (event.imageUrl.isNotEmpty && 
            _imageUploadService.isImgBBUrl(event.imageUrl)) {
          await _imageUploadService.deleteImage(event.imageUrl);
        }
        
        // Upload new image
        imageUrl = await _imageUploadService.uploadEventImage(imageFile, event.id);
      }
      
      // Update event with new image URL
      final updatedEvent = event.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(_collection)
          .doc(event.id)
          .update(updatedEvent.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete event and its image
  Future<void> deleteEventWithImage(String eventId) async {
    try {
      // Get event data first to delete image
      final event = await getEventById(eventId);
      
      if (event != null && 
          event.imageUrl.isNotEmpty && 
          _imageUploadService.isImgBBUrl(event.imageUrl)) {
        await _imageUploadService.deleteImage(event.imageUrl);
      }
      
      // Soft delete the event
      await _firestore.collection(_collection).doc(eventId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete event (soft delete)
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Register for event
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'registeredParticipants': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  // Unregister from event
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'registeredParticipants': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to unregister from event: $e');
    }
  }

  // Follow event (add to interested users)
  Future<void> addInterestToEvent(String eventId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'interestedUsers': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to follow event: $e');
    }
  }

  // Unfollow event (remove from interested users)
  Future<void> removeInterestFromEvent(String eventId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'interestedUsers': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to unfollow event: $e');
    }
  }

  // Convenience methods with follow terminology
  Future<void> followEvent(String eventId, String userId) async {
    return await addInterestToEvent(eventId, userId);
  }

  Future<void> unfollowEvent(String eventId, String userId) async {
    return await removeInterestFromEvent(eventId, userId);
  }

  // Get event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();

      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  // Stream events for real-time updates
  Stream<List<Event>> eventsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          // Filter and sort locally to avoid index issues
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.isActive)
              .toList();
          
          // Sort by start date (latest first)
          events.sort((a, b) => b.startDate.compareTo(a.startDate));
          
          return events;
        });
  }

  // Stream events by organizer
  Stream<List<Event>> organizerEventsStream(String organizerId) {
    return _firestore
        .collection(_collection)
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) {
          // Filter and sort locally to avoid compound index issues
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.isActive)
              .toList();
          
          // Sort by start date (latest first)
          events.sort((a, b) => b.startDate.compareTo(a.startDate));
          
          return events;
        });
  }
}
