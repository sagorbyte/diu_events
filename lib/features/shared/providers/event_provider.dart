import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/event_update.dart';
import '../services/event_service.dart';
import '../services/event_update_service.dart';
import '../services/student_event_interaction_service.dart';
import '../models/student_event_interaction.dart';
import '../services/user_notification_service.dart';
import '../services/ticket_service.dart';
import '../../auth/models/app_user.dart';

enum EventFilter { all, upcoming, current, past }

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();
  final EventUpdateService _eventUpdateService = EventUpdateService();
  final StudentEventInteractionService _interactionService =
      StudentEventInteractionService();
  final UserNotificationService _notificationService =
      UserNotificationService();
  final TicketService _ticketService = TicketService();

  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  List<EventUpdate> _eventUpdates = [];
  bool _isLoading = false;
  String? _errorMessage;
  EventFilter _currentFilter = EventFilter.all;
  String _searchQuery = '';

  List<Event> get events => _events;
  List<Event> get filteredEvents => _filteredEvents;
  List<EventUpdate> get eventUpdates => _eventUpdates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EventFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  // Get all events for students
  Future<void> fetchAllEvents() async {
    try {
      _setLoading(true);
      _events = await _eventService.getAllEvents();
      // Ensure provider's master list is sorted by start date (latest first)
      _events.sort((a, b) => b.startDate.compareTo(a.startDate));
      _applyFilter();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get events for a specific organizer (admin)
  Future<void> fetchOrganizerEvents(String organizerId) async {
    try {
      _setLoading(true);
      print(
        'EventProvider: Fetching events for organizer: $organizerId',
      ); // Debug log
      _events = await _eventService.getEventsByOrganizer(organizerId);
      print('EventProvider: Fetched ${_events.length} events'); // Debug log
      _applyFilter();
    } catch (e) {
      print('EventProvider: Error fetching organizer events: $e'); // Debug log
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Apply filter (All, Upcoming, Past)
  void setFilter(EventFilter filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  // Search events
  void searchEvents(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<Event> eventsToFilter = List.from(_events);

    // Apply date filter
    switch (_currentFilter) {
      case EventFilter.upcoming:
        eventsToFilter = eventsToFilter
            .where((event) => event.isUpcomingEvent)
            .toList();
        break;
      case EventFilter.current:
        eventsToFilter = eventsToFilter
            .where((event) => event.isOngoingEvent)
            .toList();
        break;
      case EventFilter.past:
        eventsToFilter = eventsToFilter
            .where((event) => event.isPastEvent)
            .toList();
        break;
      case EventFilter.all:
        // No filter, show all events
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      eventsToFilter = eventsToFilter.where((event) {
        return event.title.toLowerCase().contains(lowercaseQuery) ||
            event.description.toLowerCase().contains(lowercaseQuery) ||
            event.organizerName.toLowerCase().contains(lowercaseQuery) ||
            event.location.toLowerCase().contains(lowercaseQuery) ||
            event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    }

    // Sort events by start date (latest to oldest)
    eventsToFilter.sort((a, b) => b.startDate.compareTo(a.startDate));

    _filteredEvents = eventsToFilter;
    // Notify listeners after filter is applied so callers don't need to remember
    // to call notifyListeners() after every local change that uses _applyFilter().
    notifyListeners();
  }

  // Create new event (admin only)
  Future<bool> createEvent(Event event) async {
    try {
      _setLoading(true);
      print('EventProvider: Creating event: ${event.title}'); // Debug log
      final eventId = await _eventService.createEventWithImage(event);
      print('EventProvider: Event created with ID: $eventId'); // Debug log

      // Add the created event to the local list with the generated ID
      final createdEvent = event.copyWith(id: eventId);
      _events.add(createdEvent);
      _applyFilter();
      print(
        'EventProvider: Added event to local list. Total events: ${_events.length}',
      ); // Debug log

      return true;
    } catch (e) {
      print('EventProvider: Error creating event: $e'); // Debug log
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create new event with image upload (admin only)
  Future<bool> createEventWithImage(Event event, {XFile? imageFile}) async {
    try {
      _setLoading(true);
      print(
        'EventProvider: Creating event with image: ${event.title}',
      ); // Debug log
      final eventId = await _eventService.createEventWithImage(
        event,
        imageFile: imageFile,
      );
      print('EventProvider: Event created with ID: $eventId'); // Debug log

      // Add the created event to the local list with the generated ID
      final createdEvent = event.copyWith(id: eventId);
      _events.add(createdEvent);
      _applyFilter();
      print(
        'EventProvider: Added event to local list. Total events: ${_events.length}',
      ); // Debug log

      return true;
    } catch (e) {
      print('EventProvider: Error creating event with image: $e'); // Debug log
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update event (admin only)
  Future<bool> updateEvent(Event event) async {
    try {
      _setLoading(true);
      await _eventService.updateEvent(event);

      // Update the local list
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
        _applyFilter();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update event with image upload (admin only)
  Future<bool> updateEventWithImage(Event event, {XFile? imageFile}) async {
    try {
      _setLoading(true);
      print(
        'EventProvider: Updating event with image: ${event.title}',
      ); // Debug log
      await _eventService.updateEventWithImage(event, imageFile: imageFile);
      print('EventProvider: Event updated with ID: ${event.id}'); // Debug log

      // Update the local list
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
        _applyFilter();
      }
      print(
        'EventProvider: Updated event in local list. Total events: ${_events.length}',
      ); // Debug log

      return true;
    } catch (e) {
      print('EventProvider: Error updating event with image: $e'); // Debug log
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete event (admin only)
  Future<bool> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      await _eventService.deleteEvent(eventId);

      // Remove from local list
      _events.removeWhere((event) => event.id == eventId);
      _applyFilter();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register for event (student only)
  Future<bool> registerForEvent(String eventId, String userId) async {
    try {
      // Check if registration is open
      final event = _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );

      // Check if registration is still open
      if (!event.isRegistrationOpen) {
        _setError('Registration for this event is closed');
        return false;
      }

      // Check if there are available spots
      if (!event.hasAvailableSpots) {
        _setError('No available spots left for this event');
        return false;
      }

      // Check if user is already registered
      if (event.registeredParticipants.contains(userId)) {
        _setError('You are already registered for this event');
        return false;
      }

      // Register the user in the interaction service and capture interaction id
      final interactionId = await _interactionService.registerStudentForEvent(
        userId,
        eventId,
      );

      // If the user is following the event, unfollow it
      final isFollowing = await isUserFollowing(eventId, userId);
      if (isFollowing) {
        await _interactionService.unfollowEvent(userId, eventId);
      }

      // Update the local event
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final updatedParticipants = List<String>.from(
          event.registeredParticipants,
        );
        if (!updatedParticipants.contains(userId)) {
          updatedParticipants.add(userId);

          // Also remove from interested users if present
          final updatedInterestedUsers = List<String>.from(
            event.interestedUsers,
          );
          updatedInterestedUsers.remove(userId);

          // Update local state
          _events[index] = event.copyWith(
            registeredParticipants: updatedParticipants,
            interestedUsers: updatedInterestedUsers,
          );

          // Update event in Firestore
          await _eventService.updateEvent(_events[index]);

          _applyFilter();

          // Create a ticket for the user and persist the ticketId on the interaction
          try {
            final eventTitle = _events[index].title;
            final ticketId = await _ticketService.createTicket(
              userId: userId,
              eventId: eventId,
              eventTitle: eventTitle,
            );

            // If we have the interaction id, update the interaction metadata to include the ticketId
            if (interactionId.isNotEmpty) {
              try {
                final existingInteraction = await _interactionService
                    .getInteraction(
                      userId,
                      eventId,
                      InteractionType.registered,
                    );
                if (existingInteraction != null) {
                  final mergedMetadata = {
                    ...existingInteraction.metadata,
                    'ticketId': ticketId,
                  };
                  await _interactionService.updateInteraction(
                    existingInteraction.id,
                    existingInteraction.copyWith(metadata: mergedMetadata),
                  );
                }
              } catch (_) {
                // ignore metadata update failures
              }
            }

            print('Ticket created: $ticketId for $userId / $eventId');
          } catch (e) {
            print('Failed to create ticket: $e');
          }

          // Send historical updates for this user so they immediately see
          // all past updates for the event (deduped by metadata).
          // Fire-and-forget the work so follow/register doesn't block.
          Future(() => _sendExistingUpdatesToUser(eventId, userId));
        }
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Unregister from event (student only)
  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    try {
      // Check if registration is open
      final event = _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );

      // Check if registration is still open
      if (!event.isRegistrationOpen) {
        _setError('Registration changes for this event are closed');
        return false;
      }

      // Unregister the user
      await _interactionService.unregisterStudentFromEvent(userId, eventId);

      // Update the local event
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final updatedParticipants = List<String>.from(
          event.registeredParticipants,
        );
        updatedParticipants.remove(userId);

        _events[index] = event.copyWith(
          registeredParticipants: updatedParticipants,
        );

        // Update event in Firestore
        await _eventService.updateEvent(_events[index]);

        _applyFilter();

        // Remove ticket if exists: prefer ticketId stored on the interaction, fallback to query
        try {
          final interaction = await _interactionService.getInteraction(
            userId,
            eventId,
            InteractionType.registered,
          );
          String? ticketId;
          if (interaction != null && interaction.metadata['ticketId'] != null) {
            ticketId = interaction.metadata['ticketId'].toString();
          }

          if (ticketId != null && ticketId.isNotEmpty) {
            await _ticketService.deleteTicket(ticketId);
            print(
              'Deleted ticket $ticketId for $userId / $eventId (via interaction metadata)',
            );
          } else {
            final ticket = await _ticketService.getTicketByUserAndEvent(
              userId,
              eventId,
            );
            if (ticket != null && ticket.id.isNotEmpty) {
              await _ticketService.deleteTicket(ticket.id);
              print(
                'Deleted ticket ${ticket.id} for $userId / $eventId (via query)',
              );
            }
          }
        } catch (e) {
          print('Failed to delete ticket for $userId / $eventId: $e');
        }
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Cancel user registration from event (admin only - bypasses deadline check)
  Future<bool> cancelUserRegistration(
    String eventId,
    String userId, {
    String? adminId,
    String? userDisplayName,
  }) async {
    try {
      // Find the event
      final event = _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );

      // Check if user is actually registered
      if (!event.registeredParticipants.contains(userId)) {
        _setError('User is not registered for this event');
        return false;
      }

      // Cancel the user's registration (bypass deadline check)
      await _interactionService.unregisterStudentFromEvent(userId, eventId);

      // Update the local event
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final updatedParticipants = List<String>.from(
          event.registeredParticipants,
        );
        updatedParticipants.remove(userId);

        _events[index] = event.copyWith(
          registeredParticipants: updatedParticipants,
        );

        // Update event in Firestore
        await _eventService.updateEvent(_events[index]);

        _applyFilter();
      }

      // Send private notification to affected user if admin details are provided
      if (adminId != null && userDisplayName != null) {
        print(
          '🎯🎯🎯 ADMIN CANCELLED REGISTRATION - SENDING NOTIFICATION 🎯🎯🎯',
        );
        print('   Event: ${event.title}');
        print('   User ID: $userId');
        print('   Admin ID: $adminId');
        print('   User Name: $userDisplayName');

        try {
          print('   Calling _notificationService.sendNotificationToUser...');
          await _notificationService.sendNotificationToUser(
            userId: userId,
            title: 'Registration Cancelled',
            message:
                'Your registration for "${event.title}" has been cancelled by the admin. If you have any questions, please contact the event organizers.',
            type: 'registration_cancelled',
            eventId: eventId,
            eventTitle: event.title,
            metadata: {
              'adminId': adminId,
              'cancelledAt': DateTime.now().toIso8601String(),
            },
          );
          print('   ✅ Notification service call completed');
        } catch (e) {
          // Don't fail the cancellation if notification fails
          print('❌ Failed to send cancellation notification: $e');
        }
      } else {
        print('⚠️ Notification NOT sent - adminId or userDisplayName is null');
        print('   adminId: $adminId');
        print('   userDisplayName: $userDisplayName');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      return await _eventService.getEventById(eventId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Check if user is registered for event
  bool isUserRegistered(String eventId, String userId) {
    final event = _filteredEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => Event(
          id: '',
          title: '',
          description: '',
          location: '',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          startTime: '',
          endTime: '',
          organizerName: '',
          organizerId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    );

    return event.id.isNotEmpty && event.registeredParticipants.contains(userId);
  }

  // Follow event (student only)
  Future<bool> followEvent(String eventId, String userId) async {
    try {
      await _interactionService.followEvent(userId, eventId);

      // Update local state
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final event = _events[index];
        final updatedInterestedUsers = List<String>.from(event.interestedUsers);
        if (!updatedInterestedUsers.contains(userId)) {
          updatedInterestedUsers.add(userId);

          // Update local state
          _events[index] = event.copyWith(
            interestedUsers: updatedInterestedUsers,
          );

          // Update event in Firestore
          await _eventService.updateEvent(_events[index]);

          _applyFilter();

          // Send existing updates to this follower so they see past updates
          // immediately. Fire-and-forget to avoid blocking the follow call.
          Future(() => _sendExistingUpdatesToUser(eventId, userId));
        }
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Unfollow event (student only)
  Future<bool> unfollowEvent(String eventId, String userId) async {
    try {
      await _interactionService.unfollowEvent(userId, eventId);

      // Update local state
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final event = _events[index];
        final updatedInterestedUsers = List<String>.from(event.interestedUsers);
        updatedInterestedUsers.remove(userId);

        // Update local state
        _events[index] = event.copyWith(
          interestedUsers: updatedInterestedUsers,
        );

        // Update event in Firestore
        await _eventService.updateEvent(_events[index]);

        _applyFilter();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check if user is following event
  Future<bool> isUserFollowing(String eventId, String userId) async {
    try {
      return await _interactionService.isStudentFollowing(userId, eventId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check if user is registered for event (using new service)
  Future<bool> isUserRegisteredAsync(String eventId, String userId) async {
    try {
      return await _interactionService.isStudentRegistered(userId, eventId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get events user is registered for
  Future<List<Event>> getRegisteredEvents(String userId) async {
    try {
      final registeredEventIds = await _interactionService
          .getStudentRegisteredEventIds(userId);

      return _events
          .where((event) => registeredEventIds.contains(event.id))
          .toList();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get events user is following
  Future<List<Event>> getFollowingEvents(String userId) async {
    try {
      final followingEventIds = await _interactionService
          .getStudentFollowingEventIds(userId);

      return _events
          .where((event) => followingEventIds.contains(event.id))
          .toList();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get event statistics
  Future<Map<String, int>> getEventStatistics(String eventId) async {
    try {
      return await _interactionService.getEventStatistics(eventId);
    } catch (e) {
      _setError(e.toString());
      return {'registered': 0, 'following': 0, 'completed': 0, 'cancelled': 0};
    }
  }

  // Get registered users for an event
  Future<List<AppUser>> getRegisteredUsers(String eventId) async {
    try {
      final event = _filteredEvents.firstWhere(
        (e) => e.id == eventId,
        orElse: () => _events.firstWhere(
          (e) => e.id == eventId,
          orElse: () => Event(
            id: '',
            title: '',
            description: '',
            location: '',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            startTime: '',
            endTime: '',
            organizerName: '',
            organizerId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );

      if (event.id.isEmpty || event.registeredParticipants.isEmpty) {
        return [];
      }

      // Fetch user data for each registered participant
      final List<AppUser> registeredUsers = [];
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      for (String userId in event.registeredParticipants) {
        try {
          final userDoc = await firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            userData['uid'] = userDoc.id;
            registeredUsers.add(AppUser.fromJson(userData));
          }
        } catch (e) {
          print('Error fetching user $userId: $e');
          // Continue with next user if one fails
        }
      }

      return registeredUsers;
    } catch (e) {
      print('Error getting registered users: $e');
      _setError('Failed to fetch registered users: $e');
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  // Backward compatibility methods
  Future<bool> addInterestToEvent(String eventId, String userId) async {
    return await followEvent(eventId, userId);
  }

  Future<bool> removeInterestFromEvent(String eventId, String userId) async {
    return await unfollowEvent(eventId, userId);
  }

  Future<bool> isUserInterested(String eventId, String userId) async {
    return await isUserFollowing(eventId, userId);
  }

  // Event Update Methods

  // Publish event update (admin only)
  Future<bool> publishEventUpdate({
    required String eventId,
    required String message,
    required String organizerId,
  }) async {
    try {
      _setLoading(true);

      final eventUpdate = EventUpdate(
        id: '', // Will be set by Firestore
        eventId: eventId,
        message: message,
        organizerId: organizerId,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Create the update and capture the generated ID
      final updateId = await _eventUpdateService.createEventUpdate(eventUpdate);

      // Refresh event updates
      await fetchEventUpdates(eventId);

      // Notify all students who are registered OR following this event so
      // the update appears in their notifications/Updates page.
      try {
        // Get registered and following student ids from interaction service
        final registeredIds = await _interactionService.getRegisteredStudentIds(
          eventId,
        );
        final followingIds = await _interactionService.getFollowingStudentIds(
          eventId,
        );

        // Merge and dedupe
        final Set<String> recipients = {...registeredIds, ...followingIds};

        // Resolve event title for nicer notification text
        String? eventTitle;
        try {
          final event = _events.firstWhere(
            (e) => e.id == eventId,
            orElse: () => Event(
              id: '',
              title: '',
              description: '',
              location: '',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              startTime: '',
              endTime: '',
              organizerName: '',
              organizerId: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          if (event.id.isNotEmpty) eventTitle = event.title;
        } catch (_) {
          // ignore - fallback to null
        }

        // Send notifications (best-effort, continue on individual failures)
        final futures = <Future>[];
        for (final userId in recipients) {
          // Skip notifying the organizer if they are in the list
          if (userId == organizerId) continue;

          // Invoke an async closure so we get a Future we can await
          futures.add(() async {
            try {
              await _notificationService.sendNotificationToUser(
                userId: userId,
                title: 'Event Update',
                message: message,
                type: 'event_update',
                eventId: eventId,
                eventTitle: eventTitle,
                metadata: {'updateId': updateId},
              );
            } catch (e) {
              print('Failed to notify $userId: $e');
            }
          }());
        }

        // Await all sends but don't fail publish if notifications fail
        if (futures.isNotEmpty) await Future.wait(futures);
      } catch (e) {
        // Log but don't fail publishing
        print('publishEventUpdate: failed to send notifications: $e');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch event updates for a specific event
  Future<void> fetchEventUpdates(String eventId) async {
    try {
      _eventUpdates = await _eventUpdateService.getEventUpdates(eventId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Send all existing event updates to a single user (deduplicated by metadata)
  Future<void> _sendExistingUpdatesToUser(String eventId, String userId) async {
    try {
      // Load all active updates for the event
      final updates = await _eventUpdateService.getEventUpdates(eventId);

      if (updates.isEmpty) return;

      // Load user's existing notifications to avoid duplicates
      final userNotifications = await _notificationService.getUserNotifications(
        userId,
      );
      final Set<String> existingUpdateIds = {};
      for (final n in userNotifications) {
        if (n.metadata != null && n.metadata!['updateId'] != null) {
          try {
            existingUpdateIds.add(n.metadata!['updateId'].toString());
          } catch (_) {}
        }
      }

      // Resolve event title if available
      String? eventTitle;
      try {
        final event = _events.firstWhere(
          (e) => e.id == eventId,
          orElse: () => Event(
            id: '',
            title: '',
            description: '',
            location: '',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            startTime: '',
            endTime: '',
            organizerName: '',
            organizerId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        if (event.id.isNotEmpty) eventTitle = event.title;
      } catch (_) {}

      final futures = <Future>[];
      for (final update in updates) {
        if (existingUpdateIds.contains(update.id)) continue;

        futures.add(() async {
          try {
            await _notificationService.sendNotificationToUser(
              userId: userId,
              title: 'Event Update',
              message: update.message,
              type: 'event_update',
              eventId: eventId,
              eventTitle: eventTitle,
              metadata: {'updateId': update.id},
            );
          } catch (e) {
            print('Failed to send historical update $eventId -> $userId: $e');
          }
        }());
      }

      if (futures.isNotEmpty) await Future.wait(futures);
    } catch (e) {
      print('Error sending existing updates to $userId for event $eventId: $e');
    }
  }

  // Fetch all event updates (admin only)
  Future<void> fetchAllEventUpdates() async {
    try {
      _eventUpdates = await _eventUpdateService.getAllEventUpdates();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get updates for a specific event
  List<EventUpdate> getUpdatesForEvent(String eventId) {
    return _eventUpdates.where((update) => update.eventId == eventId).toList();
  }

  // Delete event update (admin only)
  Future<void> deleteEventUpdate(String updateId) async {
    try {
      await _eventUpdateService.deleteEventUpdate(updateId);

      // Remove from local list
      _eventUpdates.removeWhere((update) => update.id == updateId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Get events count by type
  int get upcomingEventsCount => _events.where((e) => e.isUpcomingEvent).length;
  int get pastEventsCount => _events.where((e) => e.isPastEvent).length;
  int get ongoingEventsCount => _events.where((e) => e.isOngoingEvent).length;

  // Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.startDate.year == date.year &&
          event.startDate.month == date.month &&
          event.startDate.day == date.day &&
          event.isActive;
    }).toList();
  }

  // Get today's events
  List<Event> get todaysEvents {
    final list = getEventsForDate(DateTime.now());
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  // Get recent events (last 5 created)
  List<Event> get recentEvents {
    final activeEvents = _events.where((event) => event.isActive).toList();
    activeEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
    return activeEvents.take(5).toList();
  }
}
