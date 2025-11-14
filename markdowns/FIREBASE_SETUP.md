# Firebase Setup Instructions for DIU Events App

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com/
2. Enable Authentication and Firestore Database

## Step 1: Configure Firebase Authentication

### Enable Authentication Providers:
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Google** sign-in provider
3. Enable **Email/Password** sign-in provider

### For Google Sign-In Domain Restriction:
1. In Google Sign-in settings, add authorized domains if needed
2. The app will automatically restrict to @diu.edu.bd and @daffodilvarsity.edu.bd domains

## Step 2: Configure Firestore Database

1. Go to Firebase Console → Firestore Database
2. Create database in production mode
3. Set up the following security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events collection - students can read, admins can write
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Student Event Interactions collection - users can manage their own interactions
    match /student_event_interactions/{interactionId} {
      allow read: if request.auth != null && 
        (resource.data.studentId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && 
        (resource.data.studentId == request.auth.uid || 
         request.resource.data.studentId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Event Updates collection - admins can write, all authenticated users can read
    match /event_updates/{updateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Admin verification
    match /admins/{adminId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Step 3: Get Firebase Configuration

1. Go to Project Settings → General → Your apps
2. Click on the web app icon to add a web app
3. Copy the configuration values
4. Update `lib/firebase_options.dart` with your actual values:

### Replace the placeholder values in firebase_options.dart:
- `your-web-api-key` → Your actual API key
- `your-project-id` → Your Firebase project ID
- `your-sender-id` → Your messaging sender ID
- `your-web-app-id` → Your web app ID
- `your-measurement-id` → Your measurement ID (for analytics)

### For Android (if you plan to build for Android):
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Update the Android configuration in firebase_options.dart

### For iOS (if you plan to build for iOS):
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory
3. Update the iOS configuration in firebase_options.dart

## Step 4: Create Admin Account

After setting up Firebase, you can create an admin account by:

1. Running the app
2. Using the admin sign-up functionality (you might need to temporarily enable this)
3. Or manually creating an admin user in Firestore with role: 'admin'

## Step 5: Google Sign-In Setup

### For Web:
1. Go to Google Cloud Console → APIs & Services → Credentials
2. Create OAuth 2.0 client ID for web application
3. Add your domain to authorized JavaScript origins

### For Android:
1. Get SHA-1 fingerprint of your app
2. Add it to Firebase project settings
3. Download updated google-services.json

## Domain Restriction Implementation

The app automatically restricts Google Sign-In to these domains:
- @diu.edu.bd
- @daffodilvarsity.edu.bd

This is handled in `lib/features/auth/services/auth_service.dart` in the `signInWithGoogle()` method.

## Testing

1. Test Google Sign-In with a valid university email
2. Test admin login with email/password
3. Verify domain restrictions work correctly
4. Check that user data is stored in Firestore

## Next Steps

After Firebase is configured:
1. Add the Google logo image to `assets/images/google_logo.png`
2. Test the authentication flow
3. Build out the rest of the app features
