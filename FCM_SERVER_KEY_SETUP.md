# FCM Server Key Setup Guide

To send push notifications directly from the Flutter app (without Cloud Functions), you need the FCM Server Key.

## Option 1: Legacy Server Key (Easier, but deprecated)

### Get Legacy Server Key:

1. Go to [Firebase Console](https://console.firebase.google.com/project/diu-events-app/settings/cloudmessaging)
2. Navigate to: **Project Settings** → **Cloud Messaging** tab
3. Scroll down to **"Cloud Messaging API (Legacy)"**
4. You'll see **"Server key"** - Copy this key
5. If you don't see it, you may need to enable "Cloud Messaging API (Legacy)"

**Note:** This is deprecated but still works and is simpler.

---

## Option 2: Service Account (Recommended, more secure)

### Get Service Account JSON:

1. Go to [Firebase Console](https://console.firebase.google.com/project/diu-events-app/settings/serviceaccounts)
2. Navigate to: **Project Settings** → **Service Accounts** tab
3. Click **"Generate new private key"**
4. Download the JSON file
5. **IMPORTANT:** Keep this file secure! Don't commit it to Git!

### Save the JSON file:
- Save as: `service-account.json` in your project root
- Add to `.gitignore` to prevent committing

---

## Which Option to Use?

### For Quick Setup (Development):
- Use **Option 1** (Legacy Server Key)
- Faster to implement
- Good for testing

### For Production (Recommended):
- Use **Option 2** (Service Account)
- More secure
- Better for long-term

---

## Next Steps After Getting the Key:

1. Update `.env` file with your server key
2. Add the key to your app (we'll do this securely)
3. Test sending notifications

**Important:** Never commit API keys to your repository!
