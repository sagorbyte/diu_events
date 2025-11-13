# Firebase Cloud Messaging (FCM) Setup Guide

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in the DIU Events app.

## Prerequisites

1. Firebase project already created
2. Firebase CLI installed
3. Android and iOS apps configured in Firebase

## Step 1: Install Dependencies

Run the following command to install the required packages:

```bash
flutter pub get
```

This will install `firebase_messaging: ^15.0.4` that we added to pubspec.yaml.

## Step 2: Android Configuration

### 2.1 Update AndroidManifest.xml

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<!-- FCM Notification Icon (optional, for custom icon) -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />

<!-- FCM Notification Color (optional) -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/colorPrimary" />

<!-- FCM Default Channel ID -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="diu_events_notifications" />
```

### 2.2 Add Permissions

Add these permissions before the `<application>` tag in AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 2.3 Create Notification Channel (Optional)

For better notification control, create a notification channel in your MainActivity. 

Add this to `android/app/src/main/kotlin/com/example/diu_events/MainActivity.kt`:

```kotlin
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "diu_events_notifications",
                "DIU Events Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for event updates and announcements"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}
```

## Step 3: iOS Configuration

### 3.1 Update Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### 3.2 Update AppDelegate.swift

Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

### 3.3 Add Capabilities

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and check:
   - Remote notifications
   - Background fetch

## Step 4: Deploy Firebase Cloud Functions

### 4.1 Install Node Dependencies

```bash
cd functions
npm install
```

### 4.2 Deploy Functions

```bash
firebase deploy --only functions
```

This will deploy three functions:
- `sendPushNotificationOnCreate`: Automatically sends push notification when a user_notification is created
- `sendBulkPushNotification`: Callable function for sending bulk notifications
- `cleanupInvalidTokens`: Scheduled function to clean up old tokens

## Step 5: Test Push Notifications

### 5.1 Test on Android

1. Build and run the app: `flutter run`
2. Login to the app
3. Check logs for FCM token: `FCM Token: <your_token>`
4. From another account (admin), trigger an event that sends notifications
5. You should receive a push notification

### 5.2 Test on iOS

1. Build and run on a physical device (simulator doesn't support push notifications)
2. Grant notification permissions when prompted
3. Check logs for FCM token
4. Test notifications as with Android

### 5.3 Test from Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter the FCM token from your device logs
4. Send the message

## Step 6: Testing Notifications

You can test notifications in several ways:

### Option 1: Trigger from App Actions
- Admin cancels user registration
- Event details are updated
- New event announcement

### Option 2: Firebase Console
- Go to Cloud Messaging in Firebase Console
- Send a test notification to a specific token

### Option 3: Using Cloud Functions Testing
Test the callable function using Firebase CLI:

```bash
firebase functions:shell
```

Then call:
```javascript
sendBulkPushNotification({
  userIds: ['user_id_1', 'user_id_2'],
  title: 'Test Notification',
  message: 'This is a test message',
  type: 'general'
})
```

## Troubleshooting

### Android Issues

1. **Notifications not showing**
   - Check if notifications are enabled in device settings
   - Verify google-services.json is in android/app/
   - Check logcat for FCM logs: `adb logcat | grep FCM`

2. **Token null**
   - Ensure internet connection
   - Verify Firebase is properly initialized
   - Check google-services.json configuration

### iOS Issues

1. **Notifications not showing**
   - Ensure testing on physical device
   - Check notification permissions
   - Verify APNs certificate in Firebase Console
   - Check Xcode console for errors

2. **APNs token error**
   - Verify Push Notifications capability is enabled
   - Check provisioning profile includes push notifications
   - Ensure app is signed correctly

### General Issues

1. **Token not saved to Firestore**
   - Check Firestore security rules allow token updates
   - Verify user is authenticated
   - Check network connectivity

2. **Cloud Function not triggering**
   - Check Firebase Console → Functions for errors
   - Verify functions are deployed: `firebase functions:list`
   - Check function logs: `firebase functions:log`

## Security Rules Update

Update your Firestore security rules to allow FCM token updates:

```javascript
match /users/{userId} {
  allow read: if request.auth != null;
  allow update: if request.auth != null && 
                   request.auth.uid == userId &&
                   (request.resource.data.diff(resource.data).affectedKeys()
                    .hasOnly(['fcmToken', 'fcmTokenUpdatedAt']));
}
```

## Important Notes

1. **APNs Certificates (iOS)**: Ensure you have valid APNs certificates uploaded to Firebase Console
2. **Notification Permissions**: Always request permissions properly on iOS
3. **Background Notifications**: Test both foreground and background notification scenarios
4. **Token Refresh**: Tokens can refresh; the app handles this automatically
5. **Web Platform**: FCM for web requires additional configuration (not covered in this guide)

## Next Steps

1. Customize notification icon and color for Android
2. Add notification sound customization
3. Implement notification click actions to navigate to specific screens
4. Add notification categories for grouping
5. Implement notification scheduling for specific times

## Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging Plugin](https://firebase.flutter.dev/docs/messaging/overview/)
- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)
