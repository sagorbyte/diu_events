# User Notification System with Firebase Cloud Messaging

## Overview

The DIU Events app now supports real-time push notifications via Firebase Cloud Messaging (FCM). Users will receive notifications on their devices for:

- Event registration cancellations
- Event updates (time, venue, description changes)
- Event status changes (published, cancelled)
- General announcements

## Architecture

### Components

1. **FCM Service** (`lib/services/fcm_service.dart`)
   - Handles FCM initialization
   - Manages device tokens
   - Processes incoming messages
   - Handles foreground and background notifications

2. **User Notification Service** (`lib/features/shared/services/user_notification_service.dart`)
   - Creates notification records in Firestore
   - Manages notification status (read/unread)
   - Retrieves user notifications

3. **Cloud Functions** (`functions/index.js`)
   - `sendPushNotificationOnCreate`: Automatically sends push notifications when a notification is created
   - `sendBulkPushNotification`: Sends notifications to multiple users
   - `cleanupInvalidTokens`: Scheduled cleanup of expired tokens

4. **Auth Provider** (`lib/features/auth/providers/auth_provider.dart`)
   - Saves FCM token on login
   - Removes FCM token on logout
   - Links tokens to user accounts

## How It Works

### Flow Diagram

```
Admin Action (e.g., Cancel Registration)
    ↓
Event Provider calls UserNotificationService.sendNotificationToUser()
    ↓
Notification document created in Firestore (/user_notifications)
    ↓
Cloud Function triggered (sendPushNotificationOnCreate)
    ↓
Function fetches user's FCM token from /users collection
    ↓
FCM sends push notification to user's device
    ↓
User receives notification on their phone
```

### Token Management

1. **On Login:**
   - App requests FCM token from device
   - Token is saved to Firestore in `/users/{userId}/fcmToken`
   - Timestamp is recorded in `fcmTokenUpdatedAt`

2. **On Token Refresh:**
   - FCM tokens can refresh automatically
   - New token is saved to Firestore
   - Old token is replaced

3. **On Logout:**
   - Token is removed from Firestore
   - Token is deleted from device

### Notification Types

The system supports various notification types:

- `registration_cancelled`: User's event registration was cancelled
- `event_updated`: Event details were modified
- `event_published`: Event status changed to published
- `event_cancelled`: Event was cancelled
- `general`: General announcements

## Implementation Details

### Database Structure

#### User Collection Update
```javascript
{
  uid: "user123",
  name: "John Doe",
  email: "john@example.com",
  role: "student",
  fcmToken: "fcm_device_token_here",  // NEW
  fcmTokenUpdatedAt: Timestamp,        // NEW
  // ... other fields
}
```

#### User Notifications Collection
```javascript
{
  id: "notification123",
  userId: "user123",
  title: "Registration Cancelled",
  message: "Your registration for 'Tech Fest 2024' has been cancelled...",
  type: "registration_cancelled",
  eventId: "event123",
  eventTitle: "Tech Fest 2024",
  isRead: false,
  createdAt: "2024-01-15T10:30:00Z",
  metadata: {
    adminId: "admin123",
    cancelledAt: "2024-01-15T10:30:00Z"
  }
}
```

### Notification Payload

When a push notification is sent, it includes:

```javascript
{
  notification: {
    title: "Registration Cancelled",
    body: "Your registration for 'Tech Fest 2024' has been cancelled..."
  },
  data: {
    notificationId: "notification123",
    type: "registration_cancelled",
    eventId: "event123",
    eventTitle: "Tech Fest 2024",
    clickAction: "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Platform-Specific Features

### Android
- High priority notifications
- Custom notification channel (`diu_events_notifications`)
- Default notification sound
- Notification icon and color customization
- Background and foreground handling

### iOS
- APNs integration
- Badge count updates
- Notification permissions request
- Background fetch capability
- Foreground notifications with banner

## Testing

### 1. Test Notification Creation

Trigger an action that creates a notification:
```dart
// Example: Cancel a registration
await eventProvider.cancelRegistration(
  eventId: 'event123',
  userId: 'user123',
  adminId: 'admin456',
  userDisplayName: 'John Doe'
);
```

### 2. Check Firestore

Verify notification document is created:
- Collection: `user_notifications`
- Document should have proper fields

### 3. Check Cloud Function Logs

```bash
firebase functions:log --only sendPushNotificationOnCreate
```

### 4. Verify Device Receives Notification

- App in foreground: Check console logs
- App in background: Should see system notification
- App terminated: Should see system notification

## Common Use Cases

### 1. Admin Cancels User Registration

```dart
// In EventProvider
await _notificationService.sendNotificationToUser(
  userId: userId,
  title: 'Registration Cancelled',
  message: 'Your registration for "${event.title}" has been cancelled...',
  type: 'registration_cancelled',
  eventId: eventId,
  eventTitle: event.title,
  metadata: {
    'adminId': adminId,
    'cancelledAt': DateTime.now().toIso8601String(),
  },
);
```

### 2. Event Details Updated

```dart
await _notificationService.sendNotificationToUser(
  userId: registeredUserId,
  title: 'Event Updated',
  message: 'The event "${event.title}" has been updated...',
  type: 'event_updated',
  eventId: event.id,
  eventTitle: event.title,
  metadata: {
    'updatedFields': ['startTime', 'venue'],
    'updatedAt': DateTime.now().toIso8601String(),
  },
);
```

### 3. Bulk Notifications (Future Enhancement)

```dart
// Call Cloud Function from admin panel
final result = await FirebaseFunctions.instance
  .httpsCallable('sendBulkPushNotification')
  .call({
    'userIds': ['user1', 'user2', 'user3'],
    'title': 'Important Announcement',
    'message': 'All events have been rescheduled...',
    'type': 'general',
  });
```

## Error Handling

The system handles various error scenarios:

1. **No FCM Token**: Notification is stored in Firestore but no push notification is sent
2. **Invalid Token**: Token is marked for cleanup in daily scheduled function
3. **Network Error**: Cloud Function retries automatically
4. **User Offline**: Notification is delivered when user comes online

## Security

### Firestore Security Rules

```javascript
// Users can update their own FCM token
match /users/{userId} {
  allow update: if request.auth.uid == userId &&
                   request.resource.data.diff(resource.data).affectedKeys()
                   .hasOnly(['fcmToken', 'fcmTokenUpdatedAt']);
}

// Users can read their own notifications
match /user_notifications/{notificationId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow update: if request.auth.uid == resource.data.userId &&
                   request.resource.data.diff(resource.data).affectedKeys()
                   .hasOnly(['isRead']);
}
```

## Monitoring & Analytics

### Key Metrics to Track

1. **Token Management**
   - Number of active tokens
   - Token refresh rate
   - Failed token saves

2. **Notification Delivery**
   - Notifications sent vs delivered
   - Delivery success rate
   - Average delivery time

3. **User Engagement**
   - Notification open rate
   - Click-through rate
   - Dismissed notifications

### Firebase Console Monitoring

1. Cloud Messaging → Campaign analytics
2. Functions → Execution logs
3. Firestore → Collection metrics

## Best Practices

1. **Always Store Notifications**: Create Firestore document even if push notification fails
2. **Handle Permissions Gracefully**: Don't force users to enable notifications
3. **Provide Clear Messages**: Notification text should be actionable and clear
4. **Test Both States**: Test with app in foreground and background
5. **Monitor Token Validity**: Use scheduled cleanup function
6. **Rate Limiting**: Avoid sending too many notifications in short time

## Future Enhancements

1. **Rich Notifications**: Add images and action buttons
2. **Notification Categories**: Group notifications by type
3. **User Preferences**: Allow users to choose notification types
4. **Scheduled Notifications**: Send notifications at specific times
5. **In-App Notification Center**: Show notification history with filtering
6. **Read Receipts**: Track when users read notifications
7. **Notification Sound**: Custom notification sounds per type
8. **Localization**: Multi-language notification support

## Troubleshooting

### Issue: Notifications not received on Android
**Solution:** Check notification channel is created and enabled in device settings

### Issue: iOS not showing notifications
**Solution:** Verify APNs certificates are uploaded to Firebase Console and app has notification permissions

### Issue: Token not saved to Firestore
**Solution:** Check Firestore security rules and user authentication status

### Issue: Cloud Function not triggering
**Solution:** Verify functions are deployed and check function logs for errors

## Resources

- [FCM Setup Guide](./FCM_SETUP_GUIDE.md) - Detailed setup instructions
- [Firebase Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview/)

## Support

For issues or questions:
1. Check the FCM_SETUP_GUIDE.md
2. Review Cloud Function logs
3. Check Firestore console for notification documents
4. Verify device token in Firestore user document
