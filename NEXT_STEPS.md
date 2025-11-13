# Firebase Setup for DIU Events App - Step by Step

## Current Status
✅ FlutterFire CLI is installed
✅ Assets (Google icon, logo) are copied
✅ Login screen is updated with SVG logo support
✅ All dependencies are installed

## Next Steps - Firebase Configuration

### Option 1: Use Existing Project (Recommended: diulnf)
```bash
cd "D:/Design Work/Extra Freelance Work/DIU Events/diu_events_app/diu_events"
dart pub global run flutterfire_cli:flutterfire configure --project=diulnf
```

### Option 2: Create New Project
```bash
cd "D:/Design Work/Extra Freelance Work/DIU Events/diu_events_app/diu_events"
dart pub global run flutterfire_cli:flutterfire configure
# Then select "create a new project" and name it "diu-events-app-2025"
```

## After Firebase Configuration

### 1. Enable Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Google** provider
3. Enable **Email/Password** provider
4. For Google Sign-in, make sure to add your domain

### 2. Set up Firestore Database
1. Go to Firebase Console → Firestore Database
2. Create database in **production mode**
3. Add these security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 3. Create Admin Account
After setup, you can create admin accounts either:
- Through the app's admin signup (temporarily enable it)
- Manually in Firestore with role: 'admin'

### 4. Test the App
```bash
flutter run -d chrome
```

## Domain Restriction for Google Sign-In
The app automatically restricts Google Sign-In to:
- @diu.edu.bd
- @daffodilvarsity.edu.bd

This is implemented in the `AuthService` class.

## What's Ready:
✅ Complete authentication system
✅ Domain-restricted Google Sign-In
✅ Admin email/password login
✅ User role management
✅ Firestore integration
✅ Professional UI with your logo
✅ Error handling and loading states

## Next Development Phase:
After Firebase is configured, we can proceed to:
1. Build the main app screens (Home, Profile, Events, etc.)
2. Implement event management features
3. Add admin panel functionality
4. Create event cards and registration system

Just run the FlutterFire configure command and select your preferred option!
