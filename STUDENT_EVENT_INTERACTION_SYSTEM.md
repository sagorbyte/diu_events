# Student-Event Interaction System

## Overview

The new Student-Event Interaction System replaces the previous approach of storing student registrations and interests directly in the Events collection. This new system uses a dedicated `student_event_interactions` Firestore collection to manage all relationships between students and events.

## Benefits

1. **Better Data Structure**: Separates event data from user interactions
2. **Improved Scalability**: Can handle large numbers of interactions without affecting event queries
3. **Enhanced Functionality**: Supports multiple interaction types (registered, following, completed, cancelled)
4. **Better Analytics**: Easy to query interaction statistics and user engagement
5. **Flexible Metadata**: Each interaction can store additional context information

## Architecture

### Core Components

#### 1. StudentEventInteraction Model
```dart
class StudentEventInteraction {
  final String id;
  final String studentId;
  final String eventId;
  final InteractionType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;
}
```

#### 2. InteractionType Enum
```dart
enum InteractionType {
  registered,   // Student registered for the event
  following,    // Student is following the event for updates
  completed,    // Student completed/attended the event
  cancelled,    // Student cancelled their registration
}
```

#### 3. StudentEventInteractionService
The service layer that handles all CRUD operations for interactions.

## Firestore Collection Structure

### Collection: `student_event_interactions`

Each document represents a single interaction between a student and an event:

```json
{
  "studentId": "user123",
  "eventId": "event456",
  "type": "registered",
  "createdAt": "2025-01-01T10:00:00Z",
  "updatedAt": "2025-01-01T10:00:00Z",
  "isActive": true,
  "metadata": {
    "registrationSource": "mobile_app",
    "followReason": "interested_in_topic"
  }
}
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Student Event Interactions collection
    match /student_event_interactions/{interactionId} {
      allow read: if request.auth != null && 
        (resource.data.studentId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && 
        (resource.data.studentId == request.auth.uid || 
         request.resource.data.studentId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

## Usage Examples

### 1. Register a Student for an Event

```dart
final interactionService = StudentEventInteractionService();

// Register student
await interactionService.registerStudentForEvent(
  studentId: 'user123',
  eventId: 'event456',
  metadata: {
    'registrationSource': 'mobile_app',
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

### 2. Check if Student is Registered

```dart
final isRegistered = await interactionService.isStudentRegistered(
  'user123',
  'event456',
);
```

### 3. Follow an Event

```dart
await interactionService.followEvent(
  studentId: 'user123',
  eventId: 'event456',
  metadata: {
    'followReason': 'interested_in_topic',
  },
);
```

### 4. Get Event Statistics

```dart
final stats = await interactionService.getEventStatistics('event456');
// Returns: { 'registered': 25, 'following': 40, 'completed': 15, 'cancelled': 3 }
```

### 5. Get Student's Events

```dart
// Get events student is registered for
final registeredEvents = await eventProvider.getRegisteredEvents('user123');

// Get events student is following
final followingEvents = await eventProvider.getFollowingEvents('user123');
```

## Provider Integration

The `EventProvider` has been updated to use the new interaction service:

```dart
// New methods in EventProvider
Future<bool> followEvent(String eventId, String userId)
Future<bool> unfollowEvent(String eventId, String userId)
Future<bool> isUserFollowing(String eventId, String userId)
Future<List<Event>> getRegisteredEvents(String userId)
Future<List<Event>> getFollowingEvents(String userId)
Future<Map<String, int>> getEventStatistics(String eventId)

// Backward compatibility methods (async now)
Future<bool> addInterestToEvent(String eventId, String userId)
Future<bool> removeInterestFromEvent(String eventId, String userId)
Future<bool> isUserInterested(String eventId, String userId)
```

## Migration from Old System

### Running the Migration

```dart
import '../utils/student_event_interaction_migration.dart';

// Run full migration
await StudentEventInteractionMigration.runFullMigration();

// Validate migration results
await StudentEventInteractionMigration.validateMigration();
```

### Migration Steps

1. **Backup your data** before running migration
2. Run the migration script to copy existing data
3. Validate that all data was migrated correctly
4. Update your app to use the new system
5. Test thoroughly in development
6. Deploy to production
7. (Optional) Clean up old fields after confirming everything works

## UI Updates Required

### 1. Async State Management

Since interaction checks are now async, UI components need to handle loading states:

```dart
class _StudentEventDetailScreenState extends State<StudentEventDetailScreen> {
  bool _isFollowing = false;
  bool _isLoadingFollowingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadFollowingStatus();
  }

  Future<void> _loadFollowingStatus() async {
    final isFollowing = await eventProvider.isUserInterested(
      widget.event.id,
      authProvider.user!.uid,
    );
    setState(() {
      _isFollowing = isFollowing;
      _isLoadingFollowingStatus = false;
    });
  }
}
```

### 2. Real-time Updates

Use streams for real-time interaction updates:

```dart
Stream<List<StudentEventInteraction>> stream = 
    interactionService.streamStudentInteractions(
      userId,
      type: InteractionType.registered,
    );
```

## Performance Considerations

### Indexing

Create these Firestore indexes for optimal performance:

1. **studentId + type + isActive** (for user's interactions by type)
2. **eventId + type + isActive** (for event statistics)
3. **studentId + isActive** (for all user interactions)
4. **eventId + isActive** (for all event interactions)

### Caching

Consider implementing local caching for frequently accessed interaction data:

```dart
// Cache user's registered events locally
final cache = <String, List<String>>{};

Future<List<String>> getCachedRegisteredEvents(String userId) async {
  if (cache.containsKey(userId)) {
    return cache[userId]!;
  }
  
  final events = await interactionService.getStudentRegisteredEventIds(userId);
  cache[userId] = events;
  return events;
}
```

## Best Practices

1. **Always check authentication** before creating interactions
2. **Use soft deletes** (isActive: false) instead of hard deletes
3. **Include meaningful metadata** for analytics and debugging
4. **Handle errors gracefully** with user-friendly messages
5. **Implement loading states** for async operations
6. **Use transactions** for operations that affect multiple documents
7. **Monitor performance** and create appropriate indexes

## Troubleshooting

### Common Issues

1. **"Interaction already exists" error**
   - The system prevents duplicate interactions
   - Check if the interaction already exists before creating

2. **Permission denied errors**
   - Verify Firestore security rules are correctly set up
   - Ensure user is authenticated and has proper role

3. **Slow queries**
   - Check if proper indexes are created
   - Consider using composite indexes for complex queries

4. **UI not updating**
   - Ensure async methods are properly awaited
   - Check that setState is called after async operations

### Debugging

Enable debug logging:

```dart
// In StudentEventInteractionService
print('Creating interaction: $interaction');
print('Query result: ${querySnapshot.docs.length} documents');
```

## Future Enhancements

1. **Notification System**: Send notifications based on interactions
2. **Analytics Dashboard**: Build admin analytics using interaction data
3. **Recommendation Engine**: Suggest events based on user interests
4. **Attendance Tracking**: Use QR codes to mark interactions as "completed"
5. **Certificate Management**: Link certificates to completed interactions
6. **Waitlist Management**: Implement waitlist functionality using interactions

## Support

If you encounter issues with the new system:

1. Check the troubleshooting section above
2. Verify your Firestore security rules
3. Ensure proper migration was completed
4. Check console logs for detailed error messages
5. Test with a clean user account to isolate issues

Remember: The old system is maintained for backward compatibility, but new features should use the interaction service exclusively.
