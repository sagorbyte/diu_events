# Firebase Migration Quick Checklist

## Before You Start

- [ ] Create a new Firebase project in your new account
- [ ] Have access to the new Firebase Console
- [ ] Gather all new Firebase credentials

---

## Collect New Firebase Credentials

Go to your new Firebase project → **Project Settings** → **General** tab

Copy these values from your apps:

### Web App Credentials:
```
Web API Key: ___________________________________
Web App ID: ____________________________________
Auth Domain: ___________________________________
Storage Bucket: ________________________________
Messaging Sender ID: ____________________________
Project ID: _____________________________________
```

### Android App Credentials:
```
Android API Key: ________________________________
Android App ID: _________________________________
Storage Bucket: ________________________________
Messaging Sender ID: ____________________________
Project ID: _____________________________________
```

### iOS App Credentials:
```
iOS API Key: ____________________________________
iOS App ID: _____________________________________
Storage Bucket: ________________________________
Messaging Sender ID: ____________________________
Project ID: _____________________________________
```

---

## Step-by-Step Migration

### 1. Backup (IMPORTANT!)
```bash
# Create a backup of your Firebase configuration
mkdir backups
cp .firebaserc backups/
cp firebase.json backups/
cp lib/firebase_options.dart backups/
cp lib/services/fcm_v1_service.dart backups/
cp android/app/google-services.json backups/
cp service-account.json backups/
```

### 2. Update Configuration Files

**Windows Users:** Run the automated script
```bash
firebase-migrate.bat
```

**Mac/Linux Users:** Run the automated script
```bash
bash firebase-migrate.sh
```

**Manual Update (if scripts don't work):**

#### Update `.firebaserc`
```json
{
  "projects": {
    "default": "YOUR_NEW_PROJECT_ID"
  }
}
```

#### Update `firebase.json` - Replace:
- `"projectId": "diu-events-app"` → `"projectId": "YOUR_NEW_PROJECT_ID"`
- `"appId": "1:210442734122:..."` → `"appId": "1:YOUR_NEW_SENDER_ID:..."`

#### Update `lib/services/fcm_v1_service.dart` - Line 14:
```dart
// OLD:
static const String _projectId = 'diu-events-app';

// NEW:
static const String _projectId = 'YOUR_NEW_PROJECT_ID';
```

#### Update `lib/firebase_options.dart` - Replace all:
```
diu-events-app → YOUR_NEW_PROJECT_ID
210442734122 → YOUR_NEW_SENDER_ID
AIzaSyBOaa1Qz_HSHWfRAr8F0FOX5sWSqqtU_MM → YOUR_NEW_WEB_API_KEY
AIzaSyDbb9AhJ969PUC9MTER9bibf2VqSRfgjLA → YOUR_NEW_ANDROID_API_KEY
AIzaSyDXISylZL7gpyH-1ROd6VywJdEGtym18m8 → YOUR_NEW_IOS_API_KEY
1:210442734122:web:99aaad9637a9343df39153 → YOUR_NEW_WEB_APP_ID
1:210442734122:android:6c32c51591e986a7f39153 → YOUR_NEW_ANDROID_APP_ID
1:210442734122:ios:5eeda1a815877c1df39153 → YOUR_NEW_IOS_APP_ID
diu-events-app.firebaseapp.com → YOUR_NEW_AUTH_DOMAIN
diu-events-app.firebasestorage.app → YOUR_NEW_STORAGE_BUCKET
```

### 3. Replace Binary Configuration Files

#### Replace `android/app/google-services.json`
1. Go to Firebase Console → Your new project
2. Go to Project Settings → General
3. Under "Your apps", click the Android app
4. Download `google-services.json`
5. Replace the file in `android/app/google-services.json`

#### Replace `service-account.json`
1. Go to Firebase Console → Your new project
2. Go to Project Settings → Service Accounts
3. Click "Generate New Private Key"
4. Replace `service-account.json` in project root

### 4. Clean and Rebuild

```bash
# Clean Flutter cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild native files
cd android
./gradlew clean
cd ..
```

### 5. Test the App

```bash
# Test on Android
flutter run -d android

# Test on Web
flutter run -d chrome

# Test on iOS (Mac only)
flutter run -d ios
```

**Verify in Firebase Console:**
- [ ] Data appearing in Firestore
- [ ] Authentication working
- [ ] Push notifications working
- [ ] File storage working

### 6. Enable Firebase Services in New Project

In Firebase Console, make sure these are enabled:

- [ ] Authentication (Build → Authentication)
- [ ] Firestore Database (Build → Firestore Database)
- [ ] Cloud Messaging (Engage → Cloud Messaging)
- [ ] Hosting (Build → Hosting)
- [ ] Storage (Build → Storage)

### 7. Deploy Firestore Configuration

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy Cloud Functions (if applicable)
firebase deploy --only functions
```

### 8. Deploy to Production

```bash
# Build production Android APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build for iOS (Mac only)
flutter build ios --release

# Build for Web
flutter build web --release

# Deploy web to Firebase Hosting
firebase deploy --only hosting
```

---

## Verification Checklist

### Authentication
- [ ] User can sign up
- [ ] User can sign in
- [ ] User can sign out
- [ ] Password reset works

### Firestore Database
- [ ] Can read data
- [ ] Can write data
- [ ] Can update data
- [ ] Can delete data

### Cloud Storage
- [ ] Can upload files
- [ ] Can download files
- [ ] Can view files in console

### Push Notifications
- [ ] Can send test notifications
- [ ] Notifications appear on device
- [ ] Click tracking works

### Hosting (Web)
- [ ] Web app loads
- [ ] All pages accessible
- [ ] Links work properly

---

## If Something Goes Wrong

### Revert Changes
```bash
# Restore from backup
cp backups/.firebaserc .
cp backups/firebase.json .
cp backups/firebase_options.dart lib/
cp backups/fcm_v1_service.dart lib/services/
cp backups/google-services.json android/app/

# Clean and rebuild
flutter clean
flutter pub get
```

### Common Issues

**"Permission denied" when pushing:**
- Check Firebase Console permissions
- Verify service account has correct roles

**"Authentication failed":**
- Verify api keys are correct
- Check Firebase Console → Authentication → Settings

**"Push notifications not working":**
- Verify Cloud Messaging is enabled
- Check service-account.json is valid
- Verify project ID in fcm_v1_service.dart

**"Firestore not accessible":**
- Check Firestore rules allow access
- Verify Firestore Database is created
- Check authentication is working

---

## Important Notes

1. **Everything Stays the Same:**
   - App code doesn't change
   - App functionality is identical
   - Only Firebase account changes

2. **Data:**
   - Old data stays in old Firebase project
   - New project starts fresh
   - Use Firebase Export/Import to migrate data if needed

3. **Users:**
   - Users won't automatically transfer
   - They'll need to create new accounts
   - Or import user data if needed

4. **Security:**
   - Keep service-account.json private
   - Don't commit to public repositories
   - Add to .gitignore if not already there

---

## Support

- [Firebase Migration Guide](FIREBASE_MIGRATION_GUIDE.md)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase](https://firebase.flutter.dev)
