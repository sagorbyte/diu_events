# Firebase Migration - Visual Step-by-Step Guide

## Overview

This project is being transferred to a new Firebase account. All code and functionality remain exactly the same - only the Firebase credentials need to be updated.

### Current Setup
- **Old Firebase Project ID:** `diu-events-app`
- **Old Sender ID:** `210442734122`
- **Files to Update:** 6 configuration files
- **Time Required:** ~15-20 minutes
- **Difficulty:** Easy (mostly copy-paste)

---

## Step 1: Create New Firebase Project

### In your new Google account:

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"** or **"Create a project"**

```
┌─────────────────────────────┐
│  Firebase Console           │
│                             │
│  [Add project]    [Search]  │
│                             │
│  Your Projects:             │
│  ┌─────────────────────────┐│
│  │ • my-project            ││
│  │ • another-project       ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

3. Enter project name (e.g., `diu-events-2025`)
4. Accept terms → **Continue**
5. Choose Google Analytics preference (optional)
6. **Create project** and wait for completion

---

## Step 2: Register Your Apps

### In Firebase Console → Project Settings:

1. Go to **Project Settings** (gear icon)
2. Click **"General"** tab
3. Under **"Your apps"** section:

```
┌─────────────────────────────────────┐
│ Your apps                           │
├─────────────────────────────────────┤
│ [+ Add app] [Android] [iOS] [Web]   │
│                                     │
│ Apps to register:                   │
│ • Android (com.example.diu_events)  │
│ • iOS (com.example.diuEvents)       │
│ • Web                               │
│ • Windows                           │
└─────────────────────────────────────┘
```

### Register Android App:
1. Click **"Add app"** → **"Android"**
2. Package name: `com.example.diu_events`
3. Download `google-services.json`
4. Keep this file - you'll need it later

### Register iOS App:
1. Click **"Add app"** → **"iOS"**
2. Bundle ID: `com.example.diuEvents`

### Register Web App:
1. Click **"Add app"** → **"Web"**
2. Follow the setup (copy the config)

### Register Windows App:
1. Use the same Web app for Windows

---

## Step 3: Collect Your New Credentials

### In Firebase Console → Project Settings → General:

You should see something like this:

```
┌────────────────────────────────────────────┐
│ Project Settings / General                 │
├────────────────────────────────────────────┤
│                                            │
│ Project ID: your-new-project-id            │
│ Project Number: 123456789000               │
│                                            │
│ Your apps:                                 │
│ ┌────────────────────────────────────────┐│
│ │ Android App                            ││
│ │ App ID: 1:123456789000:android:abcd... ││
│ │ API Key: AIzaSy[...long key...]        ││
│ │ Storage: your-project.firebasestorage ││
│ └────────────────────────────────────────┘│
│                                            │
│ ┌────────────────────────────────────────┐│
│ │ iOS App                                ││
│ │ App ID: 1:123456789000:ios:efgh...     ││
│ │ API Key: AIzaSy[...long key...]        ││
│ └────────────────────────────────────────┘│
│                                            │
│ ┌────────────────────────────────────────┐│
│ │ Web App                                ││
│ │ App ID: 1:123456789000:web:ijkl...     ││
│ │ API Key: AIzaSy[...long key...]        ││
│ │ Auth Domain: your-project.firebaseapp ││
│ │ Storage: your-project.firebasestorage ││
│ └────────────────────────────────────────┘│
└────────────────────────────────────────────┘
```

**Copy these values:**
- [ ] Project ID: `_______________________________`
- [ ] Sender ID (Project Number): `_______________________________`
- [ ] Web API Key: `_______________________________`
- [ ] Android API Key: `_______________________________`
- [ ] iOS API Key: `_______________________________`
- [ ] Web App ID: `_______________________________`
- [ ] Android App ID: `_______________________________`
- [ ] iOS App ID: `_______________________________`
- [ ] Auth Domain: `_______________________________`
- [ ] Storage Bucket: `_______________________________`

---

## Step 4: Update Project Files (Automated)

### Option A: Windows Users
```bash
cd c:\Users\USERAS\Desktop\diu_events
firebase-migrate.bat
```
Follow the prompts - it will do everything automatically!

### Option B: Mac/Linux Users
```bash
cd ~/Desktop/diu_events
bash firebase-migrate.sh
```

### Option C: Manual Update
Edit these files and replace the old values with new ones:

---

## File 1: `.firebaserc`

**Location:** Root directory

**OLD:**
```json
{
  "projects": {
    "default": "diu-events-app"
  }
}
```

**NEW:** Replace `diu-events-app` with your new Project ID
```json
{
  "projects": {
    "default": "your-new-project-id"
  }
}
```

---

## File 2: `firebase.json`

**Location:** Root directory

**Replace:**
```
diu-events-app → your-new-project-id
210442734122 → your-new-sender-id
```

**Find section like this:**
```json
"projectId": "diu-events-app",
"appId": "1:210442734122:android:...",
```

**Change to:**
```json
"projectId": "your-new-project-id",
"appId": "1:your-new-sender-id:android:...",
```

---

## File 3: `lib/services/fcm_v1_service.dart`

**Location:** `lib/services/fcm_v1_service.dart`
**Line:** 14

**OLD:**
```dart
static const String _projectId = 'diu-events-app';
```

**NEW:**
```dart
static const String _projectId = 'your-new-project-id';
```

---

## File 4: `lib/firebase_options.dart`

**Location:** `lib/firebase_options.dart`
**This is the main file - update all platforms**

**OLD (Web section):**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyBOaa1Qz_HSHWfRAr8F0FOX5sWSqqtU_MM',
  appId: '1:210442734122:web:99aaad9637a9343df39153',
  messagingSenderId: '210442734122',
  projectId: 'diu-events-app',
  authDomain: 'diu-events-app.firebaseapp.com',
  storageBucket: 'diu-events-app.firebasestorage.app',
);
```

**NEW (Web section):**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_NEW_WEB_API_KEY',
  appId: '1:YOUR_NEW_SENDER_ID:web:YOUR_NEW_WEB_APP_ID',
  messagingSenderId: 'YOUR_NEW_SENDER_ID',
  projectId: 'your-new-project-id',
  authDomain: 'your-new-project.firebaseapp.com',
  storageBucket: 'your-new-project.firebasestorage.app',
);
```

**Do the same for:**
- `android` section (lines ~53-59)
- `ios` section (lines ~61-69)
- `macos` section (lines ~71-79)
- `windows` section (lines ~81-88)

---

## File 5: `android/app/google-services.json`

**Location:** `android/app/google-services.json`

**Action:** REPLACE entire file

1. In Firebase Console → Your project
2. Project Settings → General
3. Click Android app
4. Click the download icon next to "google-services.json"
5. Replace the file in your project

**Before:**
```
android/
└── app/
    └── google-services.json  ← OLD FILE
```

**After:**
```
android/
└── app/
    └── google-services.json  ← NEW FILE
```

---

## File 6: `service-account.json`

**Location:** Root directory (`service-account.json`)

**Action:** REPLACE entire file

1. In Firebase Console → Your project
2. Project Settings → Service Accounts
3. Click "Generate New Private Key"
4. JSON file downloads automatically
5. Replace the file in your project root

```
diu_events/
├── service-account.json  ← OLD FILE
└── ...
```

becomes:

```
diu_events/
├── service-account.json  ← NEW FILE
└── ...
```

---

## Step 5: Update Your Project

### Clean Everything
```bash
flutter clean
flutter pub get
```

### For Android Development:
```bash
cd android
./gradlew clean
cd ..
```

---

## Step 6: Test Locally

### Test on Android:
```bash
flutter run -d android
```

**Check:**
- [ ] App starts without errors
- [ ] Login works
- [ ] Data loads from Firestore
- [ ] Notifications work

### Test on Web:
```bash
flutter run -d chrome
```

**Check:**
- [ ] Web app loads
- [ ] All features work
- [ ] Console has no Firebase errors

### Test on iOS (Mac only):
```bash
flutter run -d ios
```

---

## Step 7: Enable Firebase Services

In your **new Firebase project**, make sure these are enabled:

1. **Go to Build → Authentication**
   - [ ] Enable desired sign-in methods

2. **Go to Build → Firestore Database**
   - [ ] Create database (location: nam5 or your preference)
   - [ ] Add firestore.rules

3. **Go to Engage → Cloud Messaging**
   - [ ] This is auto-enabled

4. **Go to Build → Storage** (if using file uploads)
   - [ ] Create storage bucket

5. **Go to Build → Hosting** (for web)
   - [ ] Initialize hosting

---

## Step 8: Deploy Firestore Configuration

```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

---

## Step 9: Deploy to Production

### Android:
```bash
flutter build apk --release
flutter build appbundle --release
# Upload to Play Store
```

### iOS:
```bash
flutter build ios --release
# Upload to App Store (on Mac)
```

### Web:
```bash
flutter build web --release
firebase deploy --only hosting
```

---

## Verification Checklist

After migration, verify everything works:

- [ ] Users can sign in
- [ ] User data loads from Firestore
- [ ] Events display correctly
- [ ] Push notifications work
- [ ] Image uploads work
- [ ] App syncs with new Firebase
- [ ] No console errors

---

## Troubleshooting

### Issue: "Cannot access project"
**Solution:** Ensure you're logged in to correct Google account in gcloud:
```bash
firebase logout
firebase login
firebase use --add
```

### Issue: "API Key invalid"
**Solution:** Check you copied the exact API key. Try again:
1. Go to Firebase Console
2. Project Settings → General
3. Re-copy the API key

### Issue: "google-services.json not found"
**Solution:** Make sure file is in `android/app/google-services.json`

### Issue: "Service account not found"
**Solution:** Make sure `service-account.json` is in project root and loaded in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - service-account.json
```

### Issue: "Firestore access denied"
**Solution:** Check Firestore rules. Update if needed:
```
match /{document=**} {
  allow read, write: if request.auth != null;
}
```

---

## Backup Reminder

✅ **All your files are backed up** in the `backups/` folder

If something goes wrong, restore from backup:
```bash
cp backups/* .
```

---

## Summary

You've successfully migrated to a new Firebase account! 🎉

### What Changed:
- Firebase credentials (Project ID, API Keys, etc.)

### What Stayed The Same:
- All app code
- All functionality
- All features
- App structure
- Database schema
- Security rules

Everything works exactly as before, just with your new Firebase account!

---

## Need Help?

- [Full Migration Guide](FIREBASE_MIGRATION_GUIDE.md)
- [Detailed Checklist](FIREBASE_MIGRATION_CHECKLIST.md)
- [Firebase Docs](https://firebase.google.com/docs)
