# Firebase Account Migration Guide

This guide will help you migrate the DIU Events project from the old Firebase account (`diu-events-app`) to a new Firebase account while keeping everything else exactly the same.

## Current Firebase Configuration

**Old Project ID:** `diu-events-app`
**Sender ID:** `210442734122`

Files that reference Firebase:
- `lib/firebase_options.dart` - Platform configurations
- `android/app/google-services.json` - Android config
- `firebase.json` - Firebase project config
- `.firebaserc` - Firebase CLI config
- `service-account.json` - Service account for FCM V1 API
- `lib/services/fcm_v1_service.dart` - FCM service with project ID
- `functions/` - Cloud functions configuration

---

## Step 1: Create New Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" or "Create a project"
3. Enter new project name (e.g., `diu-events-app-new`)
4. Accept the terms and click "Continue"
5. Choose if you want to enable Google Analytics (optional)
6. Create the project and wait for initialization

---

## Step 2: Get New Firebase Credentials

### For Web & All Platforms:

1. In Firebase Console → Project Settings → General
2. Under "Your apps" section, you'll see registered apps
3. If no apps exist, register them:
   - **Android App:** Click "Add app" → Android
     - Package name: `com.example.diu_events`
     - SHA-1 certificate hash: (get from your local setup or leave for now)
   - **iOS App:** Click "Add app" → iOS
     - Bundle ID: `com.example.diuEvents`
   - **Web App:** Click "Add app" → Web
   - **Windows App:** Click "Add app" → Web (use same web config)

4. Download configurations:
   - **Android:** Download `google-services.json`
   - **Web:** Copy the Firebase config (shows on console)

### Get Your New Credentials:

From Firebase Console → Project Settings → General, copy these values:

**For Web:**
- `apiKey`
- `appId` (Web)
- `messagingSenderId`
- `projectId` (NEW)
- `authDomain`
- `storageBucket`

**For Android:**
- `apiKey`
- `appId` (Android)
- `messagingSenderId`
- `projectId` (NEW)
- `storageBucket`

**For iOS/macOS:**
- `apiKey`
- `appId` (iOS)
- `messagingSenderId`
- `projectId` (NEW)
- `storageBucket`

---

## Step 3: Update Flutter Configuration Files

### Step 3a: Update `lib/firebase_options.dart`

Replace ALL instances of old values with new ones. The structure stays exactly the same, only the values change.

**Find and Replace:**
- Old Project ID: `diu-events-app` → New Project ID
- Old Sender ID: `210442734122` → New Sender ID
- Old API Keys → New API Keys
- Old App IDs → New App IDs
- Old Auth Domain → New Auth Domain
- Old Storage Bucket → New Storage Bucket

Example:
```dart
// OLD:
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyBOaa1Qz_HSHWfRAr8F0FOX5sWSqqtU_MM',
  appId: '1:210442734122:web:99aaad9637a9343df39153',
  messagingSenderId: '210442734122',
  projectId: 'diu-events-app',
  // ...
);

// NEW (with your new credentials):
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_NEW_WEB_API_KEY',
  appId: '1:YOUR_NEW_SENDER_ID:web:YOUR_NEW_APP_ID',
  messagingSenderId: 'YOUR_NEW_SENDER_ID',
  projectId: 'your-new-project-id',
  // ...
);
```

### Step 3b: Update `android/app/google-services.json`

Replace the entire file with the new `google-services.json` downloaded from Firebase Console.

---

## Step 4: Update Android Configuration

Replace `android/app/google-services.json` with the new file downloaded from Firebase Console.

---

## Step 5: Update Firebase Configuration Files

### Step 5a: Update `.firebaserc`

```json
{
  "projects": {
    "default": "YOUR_NEW_PROJECT_ID"
  }
}
```

### Step 5b: Update `firebase.json`

Replace project IDs with your new project ID:

```json
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "YOUR_NEW_PROJECT_ID",
          "appId": "1:YOUR_NEW_SENDER_ID:android:YOUR_NEW_APP_ID",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "YOUR_NEW_PROJECT_ID",
          "configurations": {
            "android": "1:YOUR_NEW_SENDER_ID:android:YOUR_NEW_APP_ID",
            "ios": "1:YOUR_NEW_SENDER_ID:ios:YOUR_NEW_APP_ID",
            "macos": "1:YOUR_NEW_SENDER_ID:ios:YOUR_NEW_APP_ID",
            "web": "1:YOUR_NEW_SENDER_ID:web:YOUR_NEW_APP_ID",
            "windows": "1:YOUR_NEW_SENDER_ID:web:YOUR_NEW_APP_ID"
          }
        }
      }
    }
  },
  "firestore": {
    "database": "(default)",
    "location": "nam5",
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

## Step 6: Update FCM V1 Service

### Update `lib/services/fcm_v1_service.dart`

Change the project ID on line 14:

```dart
// OLD:
static const String _projectId = 'diu-events-app';

// NEW:
static const String _projectId = 'YOUR_NEW_PROJECT_ID';
```

---

## Step 7: Get Service Account JSON for FCM

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. A JSON file will download
4. Replace `service-account.json` in your project root with the new one
5. Also copy it to `assets/service-account.json` if you have an assets folder

**Important:** Keep `service-account.json` secure and don't commit it to public repositories!

---

## Step 8: Update Cloud Functions (if applicable)

If you have Cloud Functions:

1. In `functions/` directory, update any hardcoded project IDs
2. Cloud Functions typically use environment variables or automatic configuration
3. Run `firebase deploy --only functions` to deploy with the new project

---

## Step 9: Enable Required Firebase Services

In the new Firebase project, enable:

1. **Authentication** (if used)
   - Go to Build → Authentication
   - Enable desired sign-in methods

2. **Firestore Database** (if used)
   - Go to Build → Firestore Database
   - Create database in preferred location

3. **Cloud Messaging** (for push notifications)
   - Go to Engage → Cloud Messaging
   - This is enabled by default

4. **Hosting** (if using web)
   - Go to Build → Hosting
   - Initialize hosting

5. **Storage** (if using file upload)
   - Go to Build → Storage
   - Create storage bucket

---

## Step 10: Configure Firestore Rules & Indexes

1. Copy your `firestore.rules` to the new project:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. Copy your `firestore.indexes.json`:
   ```bash
   firebase deploy --only firestore:indexes
   ```

---

## Step 11: Test the Migration

1. **Clean Flutter cache:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Test on Android:**
   ```bash
   flutter run -d android
   ```

3. **Test on Web:**
   ```bash
   flutter run -d chrome
   ```

4. **Test on iOS:**
   ```bash
   flutter run -d ios
   ```

5. **Verify:**
   - Check Firebase Console for new data
   - Test authentication if applicable
   - Test push notifications
   - Test Firestore read/write operations

---

## Step 12: Deploy to Production

1. **Build release APK/AAB:**
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

2. **Deploy to Play Store** (if applicable)

3. **Deploy to App Store** (if applicable)

4. **Deploy web hosting:**
   ```bash
   firebase deploy --only hosting
   ```

---

## Checklist: Files to Update

- [ ] `lib/firebase_options.dart` - Update all platform configs
- [ ] `android/app/google-services.json` - Replace with new file
- [ ] `.firebaserc` - Update default project ID
- [ ] `firebase.json` - Update all project IDs and app IDs
- [ ] `lib/services/fcm_v1_service.dart` - Update _projectId
- [ ] `service-account.json` - Download and replace
- [ ] `firestore.rules` - Deploy to new project
- [ ] `firestore.indexes.json` - Deploy to new project
- [ ] Enable all required Firebase services in new project

---

## Important Notes

1. **Everything Stays the Same:**
   - App structure and code logic remain unchanged
   - Only Firebase credentials change
   - All features work exactly as before with new Firebase account

2. **Data Migration:**
   - Your old data is still in the old Firebase project
   - You can use Firebase Export/Import if needed
   - Or rebuild data in new project if acceptable

3. **Authentication:**
   - Old user accounts won't automatically transfer
   - Users will need to sign up/authenticate again
   - Or use Firebase's data export/import tools

4. **Security:**
   - Keep `service-account.json` private
   - Don't commit to public repositories
   - Add to `.gitignore` if not already

5. **Testing:**
   - Test thoroughly on all platforms before releasing
   - Verify all Firebase features (Auth, Firestore, Storage, Messaging)
   - Test push notifications with new FCM setup

---

## Troubleshooting

### "Permission denied" errors:
- Ensure service-account.json is loaded correctly
- Check Firebase Console → Service Accounts → permissions

### Push notifications not working:
- Verify Cloud Messaging is enabled
- Check service account has correct permissions
- Verify project ID in fcm_v1_service.dart

### App won't build:
- Run `flutter clean && flutter pub get`
- Check google-services.json is in correct location
- Verify android/app/build.gradle.kts is properly configured

### Firestore/Authentication not working:
- Verify services are enabled in Firebase Console
- Check Firestore rules allow desired access
- Verify authentication providers are configured

---

## Support

For more help:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)
