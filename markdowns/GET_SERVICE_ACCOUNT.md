# Quick Start: Get Service Account JSON

## Step-by-Step Instructions

### 1. Open Google Cloud Console
🔗 https://console.cloud.google.com/

### 2. Select Your Project
- Click the project dropdown at the top
- Select: **diu-events-app**

### 3. Go to Service Accounts
- Click the ☰ menu (top left)
- Go to: **IAM & Admin** → **Service Accounts**
- OR directly: https://console.cloud.google.com/iam-admin/serviceaccounts

### 4. Find Firebase Admin SDK Account
Look for an account like:
```
firebase-adminsdk-xxxxx@diu-events-app.iam.gserviceaccount.com
```

### 5. Create a New Key
- Click the **three dots (⋮)** on the right side of that service account
- Click **"Manage keys"**
- Click **"ADD KEY"** button
- Click **"Create new key"**
- Select **"JSON"** format
- Click **"CREATE"**

The JSON file will automatically download!

### 6. Add to Your Project

1. **Rename** the downloaded file to: `service-account.json`
2. **Move** it to your project root:
   ```
   D:\Data\Design Work\Extra Freelance Work\DIU Events\diu_events_app\diu_events\
   ```
3. The file should be next to `pubspec.yaml`

### 7. Verify Location

Your project structure should look like:
```
diu_events/
├── android/
├── lib/
├── pubspec.yaml
└── service-account.json  ✅ HERE!
```

### 8. Run the App

```bash
flutter pub get
flutter run
```

## That's It!

Your push notifications are now ready to use! 🎉

Test by:
1. Running the app on Android
2. Login as admin
3. Cancel a student's registration
4. Student should receive a push notification!

---

**Security:** The file is already in `.gitignore` and won't be committed to Git.
