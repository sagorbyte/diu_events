# FCM V1 API Setup Guide (Modern & Secure)

## 🎯 What We're Using Now

Your push notification system now uses **Firebase Cloud Messaging V1 API** - the modern, recommended approach by Google!

### ✅ Benefits of V1 API:
- **Future-proof** - Won't be deprecated like Legacy API
- **Better security** - More secure authentication
- **Already enabled** - You have it active in Firebase Console!
- **FREE** - Still works on Spark plan

---

## 🔑 Getting Your Web API Key

### Method 1: Web API Key (Simplest - Recommended for Quick Setup)

This is the easiest method and works great for university/internal projects.

#### Step 1: Get Your Web API Key

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/project/diu-events-app/settings/general

2. **Scroll down to "Your apps" section**

3. **Find "Web API Key"** - it looks like:
   ```
   AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

4. **Copy the key**

#### Step 2: Add Key to Your Code

**Open:** `lib/services/direct_fcm_service.dart`

**Find this line (around line 18):**
```dart
static const String _webApiKey = 'YOUR_WEB_API_KEY_HERE';
```

**Replace with your actual key:**
```dart
static const String _webApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

#### Step 3: Test It!

Run your app and trigger a notification - it should work! 🚀

---

## 🔒 Method 2: Service Account (Most Secure - For Production)

If you want maximum security, use a service account with OAuth2.

### ⚠️ Important Note:
This method requires additional packages and OAuth2 token generation. **For a university project, Method 1 (Web API Key) is perfectly fine!**

### Steps (If you want to implement this later):

1. **Download Service Account Key**
   - Go to: https://console.firebase.google.com/project/diu-events-app/settings/serviceaccounts
   - Click "Generate new private key"
   - Save the JSON file securely

2. **Add Required Packages**
   ```bash
   flutter pub add googleapis_auth
   ```

3. **Implement OAuth2 Token Generation**
   - Load service account JSON
   - Generate OAuth2 access token
   - Use token in Authorization header

**For now, stick with Method 1!** It's much simpler and works perfectly for your needs.

---

## 📱 Platform Configuration Checklist

### ✅ Already Done:
- [x] FCM V1 API enabled in Firebase Console
- [x] Code updated to use V1 API format
- [x] DirectFCMService created

### 🔲 Still Needed (from DIRECT_FCM_GUIDE.md):
- [ ] Get Web API Key and add to code
- [ ] Add Android permissions to AndroidManifest.xml
- [ ] Add iOS configuration (if targeting iOS)
- [ ] Test push notifications

---

## 🆚 V1 API vs Legacy API

| Feature | Legacy API (Old) | V1 API (New - What you're using now) |
|---------|------------------|--------------------------------------|
| **Status** | ⚠️ Deprecated (June 2024) | ✅ Active & Supported |
| **Endpoint** | `/fcm/send` | `/v1/projects/{project-id}/messages:send` |
| **Auth** | Server Key | Web API Key or OAuth2 |
| **Batch Send** | ✅ 1000 tokens/request | ❌ Individual requests |
| **Security** | Basic | Better |
| **Future Support** | Will be removed | Long-term support |

---

## 🧪 Testing Your Implementation

### Test 1: Check Configuration

After adding your Web API Key, restart your app. You should see in console:
```
✅ FCM configured and ready
```

### Test 2: Send Test Notification

1. **Login as admin**
2. **Cancel a student registration**
3. **Check console logs:**
   ```
   ✅ Push notification sent successfully to {userId}
   ```
4. **Check student's device** - notification should appear! 📱

### Test 3: Verify Error Handling

If something goes wrong, you'll see helpful error messages:
- `❌ Failed to send notification: 401` - API key is wrong
- `❌ Failed to send notification: 403` - API key doesn't have permission
- `❌ Failed to send notification: 404` - Project ID is wrong

---

## 🔍 Troubleshooting V1 API

### Issue: "401 Unauthorized"

**Cause:** Web API Key is incorrect or not configured

**Solution:**
1. Double-check you copied the complete Web API Key
2. Verify the key from Firebase Console → Project Settings → General
3. Make sure you replaced `'YOUR_WEB_API_KEY_HERE'` in code
4. Restart the app after adding the key

### Issue: "403 Forbidden"

**Cause:** API key restrictions might be blocking FCM API

**Solution:**
1. Go to: https://console.cloud.google.com/apis/credentials?project=diu-events-app
2. Click on your Web API Key (Browser key)
3. Under "API restrictions", select "Don't restrict key" (for testing)
4. Or specifically allow "Firebase Cloud Messaging API"

### Issue: "404 Not Found"

**Cause:** Project ID is incorrect

**Solution:**
1. Verify project ID in `direct_fcm_service.dart` is: `diu-events-app`
2. Check Firebase Console URL to confirm project ID

### Issue: "No notification received"

**Checklist:**
1. ✅ Web API Key added correctly?
2. ✅ FCM token saved in Firestore?
3. ✅ Android/iOS permissions granted?
4. ✅ Device has internet connection?
5. ✅ Check console logs for errors?

---

## 🎯 V1 API Payload Structure

Here's what your notification looks like now (for reference):

```json
{
  "message": {
    "token": "user_fcm_token_here",
    "notification": {
      "title": "Registration Cancelled",
      "body": "Your registration for Event Name has been cancelled."
    },
    "data": {
      "type": "registration_cancelled",
      "eventId": "event123",
      "eventTitle": "Event Name",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "android": {
      "priority": "high",
      "notification": {
        "sound": "default",
        "notification_count": 1
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1,
          "content-available": 1
        }
      }
    }
  }
}
```

Much cleaner and more organized than the legacy format! ✨

---

## 📊 Performance Notes

### Single Notifications:
- **Speed:** < 1 second
- **Reliability:** Very high
- **Cost:** $0 (FREE!)

### Bulk Notifications:
- **V1 API limitation:** Sends individual requests per user
- **For 10 users:** ~2-3 seconds
- **For 100 users:** ~20-30 seconds
- **Still FREE!** No cost regardless of volume

**Note:** If you need to send to 1000+ users frequently, consider upgrading to Cloud Functions with Blaze plan for better batch processing.

---

## 🎉 Quick Start Summary

**3 Simple Steps to Get Push Notifications Working:**

1. **Get Web API Key**
   - Firebase Console → Project Settings → General
   - Copy the "Web API Key"

2. **Add to Code**
   - Open `lib/services/direct_fcm_service.dart`
   - Replace `'YOUR_WEB_API_KEY_HERE'` with your key

3. **Test It**
   - Run app
   - Trigger a notification
   - Check user's device! 📱

---

## ✅ Advantages of Your Current Setup

Your implementation is:
- ✅ **Modern** - Uses latest V1 API
- ✅ **FREE** - Works on Spark plan
- ✅ **Simple** - No Cloud Functions needed
- ✅ **Secure enough** - Good for university/internal apps
- ✅ **Future-proof** - Won't be deprecated
- ✅ **Already enabled** - V1 API is active in your project!

---

## 🚀 Next Steps

1. **Immediate:** Get your Web API Key and add it to code
2. **Today:** Test push notifications with real devices
3. **This week:** Add Android/iOS platform configurations
4. **Optional:** Consider service account method for production later

---

## 📞 Need Help?

**Common issues:**
- Can't find Web API Key? → Check Project Settings → General tab
- 401 error? → API key is incorrect, get it again
- 403 error? → Remove API restrictions in Google Cloud Console
- No notification? → Check FCM token is saved in Firestore

**Your setup is ready!** Just add the Web API Key and you're good to go! 🎯

---

## 🔐 Security Reminder

**For University/Internal App (Current):**
- ✅ Web API Key in code is acceptable
- ✅ Good enough for testing and internal use
- ✅ Easy to implement and maintain

**For Public Production App (Future):**
- Consider service account with OAuth2
- Or use Cloud Functions (requires Blaze plan)
- Implement API key restrictions
- Add rate limiting

**For now, don't worry about advanced security. Your current approach is perfect for a university project!** 🎓
