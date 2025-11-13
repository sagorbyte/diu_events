# Firebase Cloud Messaging - Quick Reference

## 🚀 Quick Start Checklist

- [ ] Dependencies installed (`flutter pub get` - ✅ DONE)
- [ ] Android configuration (AndroidManifest.xml)
- [ ] iOS configuration (Info.plist, AppDelegate)
- [ ] Cloud Functions deployed
- [ ] Firestore security rules updated
- [ ] Test notification sent successfully

## 📱 Platform Configuration

### Android - Quick Setup

**File:** `android/app/src/main/AndroidManifest.xml`

Add before `<application>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Add inside `<application>`:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="diu_events_notifications" />
```

### iOS - Quick Setup

**File:** `ios/Runner/Info.plist`
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

**Xcode:** Add capabilities:
- ✅ Push Notifications
- ✅ Background Modes → Remote notifications

## ⚡ Common Commands

### Deploy Cloud Functions
```bash
# Windows
deploy_functions.bat

# Linux/Mac
./deploy_functions.sh

# Manual
cd functions
npm install
firebase deploy --only functions
```

### Check if FCM is installed
```bash
flutter pub deps | grep firebase_messaging
```

### View Function Logs
```bash
firebase functions:log
```

### Test Notification from Console
1. Firebase Console → Cloud Messaging
2. Send test message
3. Paste FCM token from app logs

## 🔍 Debugging Quick Checks

### 1. Is token saved?
```
Firestore → users → {userId} → fcmToken
```

### 2. Are functions deployed?
```bash
firebase functions:list
```
Should show:
- sendPushNotificationOnCreate
- sendBulkPushNotification  
- cleanupInvalidTokens

### 3. Is notification created?
```
Firestore → user_notifications → {notificationId}
```

### 4. Check app logs
```
Console should show: "FCM Token: xxxxx"
```

## 💻 Code Snippets

### Send Notification (Already Implemented)
```dart
await _notificationService.sendNotificationToUser(
  userId: userId,
  title: 'Title Here',
  message: 'Message body here',
  type: 'event_updated',
  eventId: eventId,
  eventTitle: eventTitle,
);
```

### Get Current User's Token
```dart
final fcmService = FCMService();
final token = await fcmService.getToken();
print('My token: $token');
```

### Subscribe to Topic
```dart
await FCMService().subscribeToTopic('announcements');
```

## 🎯 Testing Workflow

1. **Login** to app → Check console for FCM token
2. **Trigger notification** (e.g., admin cancels registration)
3. **Check Firestore** → user_notifications collection
4. **Check device** → Should see notification
5. **If failed** → Check function logs

## 🔗 Important Files

| File | Purpose |
|------|---------|
| `lib/services/fcm_service.dart` | FCM token management |
| `lib/main.dart` | FCM initialization |
| `lib/features/auth/providers/auth_provider.dart` | Token save/remove |
| `functions/index.js` | Cloud Functions |
| `FCM_SETUP_GUIDE.md` | Detailed setup |
| `NOTIFICATION_SYSTEM.md` | Complete documentation |

## 🐛 Quick Fixes

### Notifications not showing on Android
```
Settings → Apps → DIU Events → Notifications → Enable
```

### iOS notifications not working
```
1. Test on physical device (not simulator)
2. Check notification permissions granted
3. Verify APNs certificate in Firebase Console
```

### Token null or undefined
```dart
// Wait for Firebase initialization
await Firebase.initializeApp();
await FCMService().initialize();
```

### Function not triggering
```bash
# Check deployment
firebase functions:list

# View logs
firebase functions:log --only sendPushNotificationOnCreate
```

## 📞 Where to Get Help

1. **Setup Issues:** See `FCM_SETUP_GUIDE.md`
2. **System Design:** See `NOTIFICATION_SYSTEM.md`
3. **Implementation:** See `NOTIFICATION_SYSTEM_IMPLEMENTATION.md`
4. **Firebase Docs:** https://firebase.google.com/docs/cloud-messaging
5. **FlutterFire Docs:** https://firebase.flutter.dev/docs/messaging/overview/

## ✅ Success Indicators

You'll know it's working when:
- ✅ Console shows "FCM Token: xxxxx" on login
- ✅ Token appears in Firestore users collection
- ✅ Notification document created in user_notifications
- ✅ Function log shows "Successfully sent notification"
- ✅ Device shows notification (even when app closed)

## 🎉 Quick Test

```dart
// 1. Login to app
// 2. Copy FCM token from console
// 3. Go to Firebase Console → Cloud Messaging
// 4. Click "Send test message"
// 5. Paste token and send
// 6. Should receive notification immediately
```

---

**Status:** ✅ Implementation complete - Ready for configuration and deployment
