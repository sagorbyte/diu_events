# FCM V1 API Setup Guide

Since Google has deprecated the Legacy FCM API and Cloud Functions require Blaze plan, we're using the modern FCM V1 API with service account authentication.

## Step 1: Download Service Account JSON

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: **diu-events-app**
3. Go to **IAM & Admin** → **Service Accounts**
4. Find the Firebase Admin SDK service account:
   - Usually named: `firebase-adminsdk-xxxxx@diu-events-app.iam.gserviceaccount.com`
5. Click the **three dots menu** (⋮) → **Manage keys**
6. Click **Add Key** → **Create new key**
7. Select **JSON** format
8. Click **Create** - the JSON file will download

## Step 2: Add to Project

1. Save the downloaded JSON file as: `service-account.json`
2. Place it in the project root directory: `diu_events/`
3. **IMPORTANT**: This file contains sensitive credentials!

## Step 3: Add to .gitignore

Make sure `service-account.json` is in your `.gitignore` file:
```
service-account.json
```

## Step 4: Get Your Project ID

Open the `service-account.json` file and copy the `project_id` value.
It should be: `diu-events-app`

## Step 5: Update the Code

Open `lib/services/fcm_v1_service.dart` and update line 14:
```dart
static const String _projectId = 'diu-events-app'; // Your Firebase project ID
```

## Done!

The app will now automatically:
1. Load the service account credentials
2. Generate OAuth2 tokens
3. Send push notifications using FCM V1 API

## Security Notes

- ✅ Service account works on **FREE Spark plan**
- ✅ No external API calls - only Firebase services
- ⚠️ **NEVER** commit `service-account.json` to git
- ⚠️ Keep your service account credentials secure
