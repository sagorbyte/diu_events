# Firebase Migration - Quick Reference Card

## Files That Need Updating (6 Total)

### 1. `.firebaserc`
```json
{
  "projects": {
    "default": "YOUR_NEW_PROJECT_ID"
  }
}
```

### 2. `firebase.json`
Replace:
- `diu-events-app` → `YOUR_NEW_PROJECT_ID`
- `210442734122` → `YOUR_NEW_SENDER_ID`

### 3. `lib/firebase_options.dart`
Replace for ALL platforms (web, android, ios, macos, windows):
- `diu-events-app` → `YOUR_NEW_PROJECT_ID`
- `210442734122` → `YOUR_NEW_SENDER_ID`
- API Keys → Your new API Keys
- App IDs → Your new App IDs
- Auth Domain → Your new Auth Domain
- Storage Bucket → Your new Storage Bucket

### 4. `lib/services/fcm_v1_service.dart` (Line 14)
```dart
static const String _projectId = 'YOUR_NEW_PROJECT_ID';
```

### 5. `android/app/google-services.json`
Replace entire file with new one from Firebase Console

### 6. `service-account.json`
Replace entire file with new one from Firebase Console

---

## Where to Get New Values

### Firebase Console → Project Settings → General

```
WEB APP:
├── API Key: (copy this)
├── App ID: (copy this)
├── Auth Domain: (copy this)
└── Storage Bucket: (copy this)

ANDROID APP:
├── API Key: (copy this)
├── App ID: (copy this)
└── Storage Bucket: (same as web)

iOS APP:
├── API Key: (copy this)
├── App ID: (copy this)
└── Storage Bucket: (same as web)

PROJECT INFO:
├── Project ID: (copy this)
└── Project Number (Sender ID): (copy this)
```

---

## Values to Replace

### Old → New Mapping

```
OLD VALUES (Find These):
- diu-events-app
- 210442734122
- AIzaSyBOaa1Qz_HSHWfRAr8F0FOX5sWSqqtU_MM (Web API Key)
- AIzaSyDbb9AhJ969PUC9MTER9bibf2VqSRfgjLA (Android API Key)
- AIzaSyDXISylZL7gpyH-1ROd6VywJdEGtym18m8 (iOS API Key)
- 1:210442734122:web:99aaad9637a9343df39153 (Web App ID)
- 1:210442734122:android:6c32c51591e986a7f39153 (Android App ID)
- 1:210442734122:ios:5eeda1a815877c1df39153 (iOS App ID)
- diu-events-app.firebaseapp.com (Auth Domain)
- diu-events-app.firebasestorage.app (Storage Bucket)

NEW VALUES (Replace With These):
- YOUR_NEW_PROJECT_ID
- YOUR_NEW_SENDER_ID
- YOUR_NEW_WEB_API_KEY
- YOUR_NEW_ANDROID_API_KEY
- YOUR_NEW_IOS_API_KEY
- YOUR_NEW_WEB_APP_ID
- YOUR_NEW_ANDROID_APP_ID
- YOUR_NEW_IOS_APP_ID
- YOUR_NEW_AUTH_DOMAIN
- YOUR_NEW_STORAGE_BUCKET
```

---

## Quick Migration (Windows)

```bash
# 1. Create Firebase project (3 min)
#    https://console.firebase.google.com

# 2. Download google-services.json
#    From Firebase Console → Android app

# 3. Generate service-account.json
#    From Firebase Console → Service Accounts

# 4. Run automatic script (1 min)
firebase-migrate.bat

# 5. Replace binary files (1 min)
#    - android/app/google-services.json
#    - service-account.json

# 6. Clean and test (5 min)
flutter clean
flutter pub get
flutter run -d android
```

---

## Quick Migration (Mac/Linux)

```bash
# 1. Create Firebase project (3 min)
#    https://console.firebase.google.com

# 2. Download google-services.json
#    From Firebase Console → Android app

# 3. Generate service-account.json
#    From Firebase Console → Service Accounts

# 4. Run automatic script (1 min)
bash firebase-migrate.sh

# 5. Replace binary files (1 min)
#    - android/app/google-services.json
#    - service-account.json

# 6. Clean and test (5 min)
flutter clean
flutter pub get
flutter run -d ios
```

---

## Credentials Collection Form

### Firebase Console → Project Settings → General

Copy these:

```
Project ID:
_________________________________________________

Sender ID (Project Number):
_________________________________________________

Web App:
  API Key:
  _________________________________________________
  
  App ID:
  _________________________________________________
  
  Auth Domain:
  _________________________________________________
  
  Storage Bucket:
  _________________________________________________

Android App:
  API Key:
  _________________________________________________
  
  App ID:
  _________________________________________________

iOS App:
  API Key:
  _________________________________________________
  
  App ID:
  _________________________________________________
```

---

## What Stays The Same ✅

```
✅ App code (100% unchanged)
✅ App features (all work identically)
✅ Database schema (same structure)
✅ App UI (looks same)
✅ Package names (com.example.diu_events)
✅ App logic (all same)
✅ Security rules (can reuse)
✅ Cloud functions (code same)
✅ Storage structure (same)
```

---

## What Changes 🔄

```
🔄 Firebase Project ID
🔄 Firebase Sender ID  
🔄 API Keys (all platforms)
🔄 App IDs (all platforms)
🔄 Auth Domain
🔄 Storage Bucket
🔄 Service Account
🔄 google-services.json file
🔄 service-account.json file
```

---

## Testing Checklist

After migration, verify:

```
Auth & Login:
□ User signup works
□ User login works
□ User logout works
□ Saved sessions work

Data & Firestore:
□ Events load
□ Data saves
□ Real-time updates work
□ Queries work

Notifications:
□ Permissions granted
□ Notifications received
□ Notification tracking works

Storage:
□ Image upload works
□ Image display works
□ Downloads work

Web (if deployed):
□ Web app loads
□ All features work
□ Performance acceptable
```

---

## Rollback Commands

If something goes wrong:

```bash
# Restore from backup
cp backups/firebase-migration-*/[filename] .

# Clean everything
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..

# Re-test
flutter run
```

---

## Firebase Console Tasks

### Before Running Migration Script

1. ✅ Create new Firebase project
2. ✅ Register Android app → Download google-services.json
3. ✅ Register iOS app
4. ✅ Register Web app
5. ✅ Generate new Service Account → Download JSON
6. ✅ Copy Project ID
7. ✅ Copy Sender ID (Project Number)
8. ✅ Copy API Keys for each platform

### After Running Migration Script

1. ✅ Enable Authentication
2. ✅ Create Firestore Database
3. ✅ Enable Cloud Messaging
4. ✅ Create Storage Bucket (if needed)
5. ✅ Setup Hosting (if web deployment)
6. ✅ Deploy Firestore Rules
7. ✅ Deploy Firestore Indexes

---

## Platform-Specific Notes

### Android
- Package: `com.example.diu_events`
- SHA-1: (same as before)
- Config: `android/app/google-services.json`

### iOS
- Bundle ID: `com.example.diuEvents`
- Config: Auto-configured via GoogleService-Info.plist

### Web
- Same as Android (same App ID)
- No additional config needed

### Windows
- Uses Web app config
- No additional setup

### macOS
- Uses iOS app config
- No additional setup

---

## Document Guide

| Document | Best For | Read Time |
|----------|----------|-----------|
| **FIREBASE_MIGRATION_VISUAL.md** | First-time users | 15 min |
| **FIREBASE_MIGRATION_GUIDE.md** | Complete reference | 20 min |
| **FIREBASE_MIGRATION_CHECKLIST.md** | Step-by-step | 10 min |
| **FIREBASE_MIGRATION_README.md** | Overview | 5 min |
| **This file** | Quick ref | 2 min |

---

## Troubleshooting Quick Links

### Problem: "Permission denied"
→ Check Firebase Console permissions

### Problem: "API Key invalid"
→ Recopy from Firebase Console

### Problem: "google-services.json not found"
→ File should be in `android/app/`

### Problem: "Service account error"
→ Regenerate in Firebase Console

### Problem: "Firestore access denied"
→ Check Firestore security rules

### Problem: "Authentication not working"
→ Enable auth in Firebase Console

---

## Time Estimate

```
Create Firebase Project:        5 min
Collect Credentials:            5 min
Run Migration Script:           2 min
Replace Binary Files:           2 min
Flutter Clean & Rebuild:        10 min
Test Locally:                   10 min
Enable Firebase Services:       5 min
Deploy to Production:           5-30 min (varies)
────────────────────────────────────
Total:                          44-59 min
```

---

## Important Security Notes

⚠️ **service-account.json**
- Keep private
- Don't commit to public repo
- Add to .gitignore
- Only share with trusted devs

✅ **API Keys**
- Can be in code (public)
- Used for web/mobile
- Firebase secures access with rules

---

## Start Here

1. Read: **FIREBASE_MIGRATION_VISUAL.md**
2. Follow: **FIREBASE_MIGRATION_CHECKLIST.md**
3. Use: **firebase-migrate.bat** (Windows) or **firebase-migrate.sh** (Mac)
4. Test: On all platforms
5. Deploy: To production

---

**You've got this! 🚀**
