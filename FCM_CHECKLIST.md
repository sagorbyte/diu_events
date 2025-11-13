# FCM Implementation Checklist

Use this checklist to ensure Firebase Cloud Messaging is properly configured and working.

## ✅ Pre-Deployment Checklist

### 1. Dependencies
- [x] `firebase_messaging` added to pubspec.yaml (v15.0.4)
- [x] `flutter pub get` executed successfully
- [x] No dependency conflicts

### 2. Code Implementation
- [x] FCM Service created (`lib/services/fcm_service.dart`)
- [x] Main.dart updated with FCM initialization
- [x] Auth Provider updated to save/remove tokens
- [x] Background message handler configured
- [x] Cloud Functions created (`functions/index.js`)

### 3. Android Configuration
- [ ] **AndroidManifest.xml** updated with permissions
  ```xml
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
  ```
- [ ] **AndroidManifest.xml** updated with FCM metadata
  ```xml
  <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="diu_events_notifications" />
  ```
- [ ] **Optional:** Notification channel created in MainActivity.kt
- [ ] **google-services.json** exists in `android/app/`

### 4. iOS Configuration
- [ ] **Info.plist** updated with FirebaseAppDelegateProxyEnabled
- [ ] **AppDelegate.swift** updated for FCM
- [ ] **Xcode:** Push Notifications capability added
- [ ] **Xcode:** Background Modes capability added
  - [ ] Remote notifications
  - [ ] Background fetch
- [ ] **GoogleService-Info.plist** exists in `ios/Runner/`
- [ ] **APNs Certificate/Key** uploaded to Firebase Console

### 5. Firebase Console Setup
- [ ] Firebase project exists
- [ ] Android app registered in Firebase
- [ ] iOS app registered in Firebase
- [ ] **Cloud Messaging** section accessible
- [ ] **APNs Authentication Key** uploaded (iOS)
- [ ] Billing enabled (required for Cloud Functions)

### 6. Cloud Functions
- [ ] Node.js installed (version 18+)
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Logged into Firebase CLI (`firebase login`)
- [ ] Functions initialized (`firebase init functions` - if needed)
- [ ] `functions/package.json` created
- [ ] `functions/index.js` created
- [ ] Dependencies installed (`cd functions && npm install`)
- [ ] Functions deployed (`firebase deploy --only functions`)

### 7. Firestore Security Rules
- [ ] Rules updated to allow FCM token updates
  ```javascript
  match /users/{userId} {
    allow update: if request.auth.uid == userId &&
                     request.resource.data.diff(resource.data).affectedKeys()
                     .hasOnly(['fcmToken', 'fcmTokenUpdatedAt']);
  }
  ```
- [ ] Rules deployed (`firebase deploy --only firestore:rules`)

## 🧪 Testing Checklist

### Phase 1: Basic Setup Verification
- [ ] App builds successfully for Android
  ```bash
  flutter build apk
  ```
- [ ] App builds successfully for iOS
  ```bash
  flutter build ios
  ```
- [ ] No compilation errors
- [ ] No runtime errors on app launch

### Phase 2: FCM Token Verification
- [ ] Run app in debug mode
- [ ] Login with test user account
- [ ] Check console logs for: `FCM Token: xxxxx`
- [ ] Verify token is saved in Firestore:
  - Open Firebase Console
  - Go to Firestore Database
  - Navigate to `users` collection
  - Find your user document
  - Verify `fcmToken` field exists
  - Verify `fcmTokenUpdatedAt` field exists

### Phase 3: Cloud Functions Verification
- [ ] Verify functions are deployed
  ```bash
  firebase functions:list
  ```
  Should show:
  - `sendPushNotificationOnCreate`
  - `sendBulkPushNotification`
  - `cleanupInvalidTokens`
- [ ] Check function logs
  ```bash
  firebase functions:log
  ```
- [ ] No deployment errors

### Phase 4: Notification Creation Test
- [ ] Trigger a notification from the app
  - Option 1: Admin cancels a user registration
  - Option 2: Admin updates event details
  - Option 3: Create test notification manually in Firestore
- [ ] Check Firestore for notification document:
  - Collection: `user_notifications`
  - Document should have all required fields
- [ ] Check Cloud Function logs:
  ```bash
  firebase functions:log --only sendPushNotificationOnCreate
  ```
  Should show: `Successfully sent notification to {userId}`

### Phase 5: Push Notification Delivery Test

#### Android Testing
- [ ] App in **foreground**:
  - [ ] Trigger notification
  - [ ] Check console logs for notification data
  - [ ] Verify in-app handling (if implemented)
  
- [ ] App in **background**:
  - [ ] Press home button (app still running)
  - [ ] Trigger notification
  - [ ] Notification appears in system tray
  - [ ] Sound/vibration works
  
- [ ] App **closed**:
  - [ ] Force close app
  - [ ] Trigger notification
  - [ ] Notification appears in system tray
  - [ ] Tap notification → app opens

#### iOS Testing (Physical Device Required)
- [ ] App in **foreground**:
  - [ ] Trigger notification
  - [ ] Banner notification appears
  
- [ ] App in **background**:
  - [ ] Swipe up to background
  - [ ] Trigger notification
  - [ ] Notification appears in notification center
  - [ ] Sound works
  - [ ] Badge count increases
  
- [ ] App **closed**:
  - [ ] Force close app
  - [ ] Trigger notification
  - [ ] Notification appears
  - [ ] Tap notification → app opens

### Phase 6: Firebase Console Test
- [ ] Go to Firebase Console → Cloud Messaging
- [ ] Click "Send test message"
- [ ] Paste FCM token from app logs
- [ ] Enter notification title and body
- [ ] Send message
- [ ] Verify notification received on device

### Phase 7: Edge Cases
- [ ] Test with no internet connection
  - [ ] Notification should queue
  - [ ] Should deliver when connection restored
  
- [ ] Test token refresh
  - [ ] Clear app data
  - [ ] Login again
  - [ ] Verify new token is saved
  
- [ ] Test after logout
  - [ ] Logout from app
  - [ ] Verify token removed from Firestore
  - [ ] Try sending notification (should fail/not deliver)
  
- [ ] Test multiple devices
  - [ ] Login on Device A
  - [ ] Login on Device B with same account
  - [ ] Both should have different tokens
  - [ ] Both should receive notifications

## 🚨 Troubleshooting Checklist

If notifications aren't working, check:

### Token Issues
- [ ] Token appears in console logs?
- [ ] Token saved in Firestore?
- [ ] Token not null or empty?
- [ ] Token refreshes on app reinstall?

### Permission Issues
- [ ] Notification permissions granted?
  - Android: Settings → Apps → DIU Events → Notifications
  - iOS: Settings → DIU Events → Notifications
- [ ] Foreground permission requested?
- [ ] Background permission granted?

### Function Issues
- [ ] Functions deployed successfully?
- [ ] Function logs show errors?
- [ ] Function triggered on notification create?
- [ ] Function has internet access?
- [ ] Firebase billing enabled?

### Platform Issues
- [ ] Android:
  - [ ] google-services.json exists?
  - [ ] Notification channel created?
  - [ ] App has POST_NOTIFICATIONS permission?
  
- [ ] iOS:
  - [ ] Testing on physical device?
  - [ ] APNs certificate uploaded?
  - [ ] Capabilities added in Xcode?
  - [ ] GoogleService-Info.plist exists?

### Network Issues
- [ ] Device has internet connection?
- [ ] Firewall blocking FCM?
- [ ] Proxy settings correct?
- [ ] Firebase services accessible?

## 📊 Success Criteria

You can consider FCM successfully implemented when:

1. ✅ **Token Management**
   - Tokens are saved on login
   - Tokens are removed on logout
   - Tokens refresh automatically

2. ✅ **Notification Delivery**
   - Notifications received when app is foreground
   - Notifications received when app is background
   - Notifications received when app is closed
   - Notifications work on both Android and iOS

3. ✅ **Cloud Functions**
   - Functions deploy without errors
   - Functions trigger on notification create
   - Functions log successful sends
   - No runtime errors in function logs

4. ✅ **User Experience**
   - Notifications are timely (< 5 seconds)
   - Notifications show correct title/message
   - Tapping notification opens relevant screen
   - Notifications respect user preferences

5. ✅ **Error Handling**
   - App doesn't crash on permission denial
   - Graceful handling of missing tokens
   - Failed sends are logged
   - Invalid tokens are cleaned up

## 📝 Post-Deployment Monitoring

After deployment, monitor:

- [ ] **Daily** (First Week)
  - [ ] Check function logs for errors
  - [ ] Monitor notification delivery rate
  - [ ] Check user feedback/complaints
  
- [ ] **Weekly**
  - [ ] Review token cleanup logs
  - [ ] Check for invalid tokens
  - [ ] Monitor function execution count
  
- [ ] **Monthly**
  - [ ] Review FCM analytics in Firebase Console
  - [ ] Check notification engagement metrics
  - [ ] Optimize based on user behavior

## 📚 Documentation Review

Ensure you've read:
- [ ] `FCM_SETUP_GUIDE.md` - Platform-specific configuration
- [ ] `NOTIFICATION_SYSTEM.md` - Complete system documentation
- [ ] `NOTIFICATION_SYSTEM_IMPLEMENTATION.md` - Implementation summary
- [ ] `FCM_QUICK_REFERENCE.md` - Quick command reference
- [ ] `FCM_ARCHITECTURE.md` - System architecture diagrams

## 🎉 Final Sign-Off

- [ ] All items in this checklist completed
- [ ] Tested on at least 2 devices (Android + iOS)
- [ ] No critical errors in logs
- [ ] Notifications delivering successfully
- [ ] Team trained on notification system
- [ ] Documentation updated
- [ ] Ready for production ✅

---

**Date Completed:** _______________

**Tested By:** _______________

**Approved By:** _______________

**Notes:**
_________________________________________________
_________________________________________________
_________________________________________________
