# Firebase Migration - Complete Package

**Project:** DIU Events  
**Status:** Ready for Firebase Account Transfer  
**Date:** November 13, 2025  

---

## What's Included

This complete package contains everything needed to migrate the DIU Events project from the old Firebase account to a new one. **All app functionality remains exactly the same** - only Firebase credentials change.

### Documentation Files Created:

1. **FIREBASE_MIGRATION_VISUAL.md** ⭐ **START HERE**
   - Step-by-step visual guide with screenshots
   - Easy to follow
   - Best for first-time users
   - ~15 minute read

2. **FIREBASE_MIGRATION_GUIDE.md**
   - Comprehensive migration guide
   - Detailed explanations
   - All technical details
   - Reference document

3. **FIREBASE_MIGRATION_CHECKLIST.md**
   - Quick checklist format
   - All steps in one place
   - Quick reference
   - Verification list

### Automated Scripts:

4. **firebase-migrate.bat** (Windows)
   - Double-click to run on Windows
   - Automated file updates
   - Automatic backups
   - Fastest method

5. **firebase-migrate.sh** (Mac/Linux)
   - Run with `bash firebase-migrate.sh`
   - Automated file updates
   - Automatic backups
   - Fastest method

---

## Quick Start (5 minutes)

### For Windows Users:
```bash
# 1. Create new Firebase project (3 min)
#    Go to https://console.firebase.google.com

# 2. Collect new credentials (2 min)
#    From Firebase Console → Project Settings

# 3. Run automatic migration (1 min)
firebase-migrate.bat
```

### For Mac/Linux Users:
```bash
bash firebase-migrate.sh
```

---

## What Will Be Updated

### Files Modified:
✅ `.firebaserc` - Project ID  
✅ `firebase.json` - Project and App IDs  
✅ `lib/firebase_options.dart` - All platform configs  
✅ `lib/services/fcm_v1_service.dart` - Project ID  

### Files Replaced:
✅ `android/app/google-services.json` - New Android config  
✅ `service-account.json` - New service account  

### Code Files:
❌ No code changes (100% backward compatible)  
❌ No functionality changes  
❌ No app logic changes  

---

## Current Firebase Configuration (To Be Replaced)

```
Project ID:        diu-events-app
Sender ID:         210442734122
Platform:          Android, iOS, Web, macOS, Windows
Database:          Firestore
Notifications:     FCM V1 API
Authentication:    Google OAuth, Email/Password
Storage:           Firebase Storage
Hosting:           Firebase Hosting
```

---

## Migration Steps Summary

1. **Create new Firebase project** (5 min)
   - Go to Firebase Console
   - Create project in new account
   - Register your apps (Android, iOS, Web, Windows)

2. **Collect new credentials** (5 min)
   - Copy Project ID
   - Copy Sender ID
   - Copy API Keys for each platform

3. **Run migration script** (2 min)
   - Windows: `firebase-migrate.bat`
   - Mac/Linux: `bash firebase-migrate.sh`
   - Or manually update 6 configuration files

4. **Replace binary files** (5 min)
   - Download new `google-services.json` from Firebase
   - Download new `service-account.json` from Firebase
   - Replace files in project

5. **Test locally** (5 min)
   - Run `flutter clean`
   - Run `flutter pub get`
   - Test on Android/iOS/Web

6. **Enable Firebase services** (5 min)
   - Enable Authentication
   - Enable Firestore
   - Enable Cloud Messaging
   - Enable Storage (if needed)
   - Enable Hosting (if needed)

7. **Deploy** (varies)
   - Deploy Firestore rules
   - Deploy Cloud Functions (if any)
   - Deploy to production

---

## Backup Information

**All backups are automatic!**

Backups saved to: `backups/firebase-migration-YYYYMMDD-HHMMSS/`

Backed up files:
- `.firebaserc`
- `firebase.json`
- `lib/firebase_options.dart`
- `lib/services/fcm_v1_service.dart`
- `android/app/google-services.json`
- `service-account.json`

**To restore:** `cp backups/firebase-migration-*/` .

---

## File-by-File Changes

### 1. `.firebaserc`
```
Change: diu-events-app → YOUR_NEW_PROJECT_ID
Lines:  1
```

### 2. `firebase.json`
```
Change: diu-events-app → YOUR_NEW_PROJECT_ID
Change: 210442734122 → YOUR_NEW_SENDER_ID
Lines:  Multiple
```

### 3. `lib/firebase_options.dart`
```
Change: All API Keys, App IDs, Project IDs, Domains
Lines:  45-90 (all platform configurations)
```

### 4. `lib/services/fcm_v1_service.dart`
```
Change: diu-events-app → YOUR_NEW_PROJECT_ID
Lines:  14
```

### 5. `android/app/google-services.json`
```
Action: Replace entire file with new file from Firebase
```

### 6. `service-account.json`
```
Action: Replace entire file with new file from Firebase
```

---

## Firebase Services Breakdown

### ✅ Authentication (Google OAuth, Email/Password)
- Users can sign in
- User data persists
- Session management works

### ✅ Firestore Database
- Event data stored
- User profiles stored
- Real-time sync works

### ✅ Cloud Messaging (FCM V1 API)
- Push notifications sent
- Notification tokens stored
- Messaging works free (no external API costs)

### ✅ Firebase Storage
- Images uploaded/downloaded
- Posters stored
- Links generated

### ✅ Firebase Hosting (Web)
- Web app deployed
- Automatic SSL/HTTPS
- CDN distribution

### ✅ Cloud Functions (Node.js)
- Backend logic runs
- Event processing works
- Scheduled tasks work

---

## Verification After Migration

### Test Authentication:
- [ ] User registration works
- [ ] User login works
- [ ] User logout works
- [ ] Password reset works

### Test Firestore:
- [ ] Events load
- [ ] User data loads
- [ ] Interactions save
- [ ] Real-time updates work

### Test Storage:
- [ ] Image upload works
- [ ] Image download works
- [ ] Images display correctly

### Test Notifications:
- [ ] Notification permission works
- [ ] Notifications received
- [ ] Notification clicks tracked

### Test Web (if deployed):
- [ ] Web app loads
- [ ] All features work
- [ ] Performance acceptable

---

## Common Questions

**Q: Will the app code change?**  
A: No. Only Firebase credentials change. All code remains the same.

**Q: Will user data transfer?**  
A: No. New Firebase project starts fresh. You can export old data if needed.

**Q: Will existing users have issues?**  
A: They'll need to sign up/login again with new Firebase account.

**Q: Is the migration reversible?**  
A: Yes! Backups are automatic. You can restore anytime.

**Q: How long does it take?**  
A: Total: ~45 minutes (10 min Firebase setup + 10 min migration + 25 min testing)

**Q: What if something breaks?**  
A: Restore from backups: `cp backups/* .`

**Q: Do I need to change package names?**  
A: No. Keep them the same: `com.example.diu_events`

**Q: Will I need new signing certificates?**  
A: Android SHA-1 stays the same. Get from old setup or local keystore.

---

## Pre-Migration Checklist

- [ ] Create new Firebase project
- [ ] Register Android app (get google-services.json)
- [ ] Register iOS app
- [ ] Register Web app
- [ ] Register Windows app
- [ ] Generate new service account
- [ ] Collect all credentials
- [ ] Create backup (automatic with scripts)
- [ ] Close all running Flutter apps

---

## Support Resources

### Documentation:
- 📖 [FIREBASE_MIGRATION_VISUAL.md](FIREBASE_MIGRATION_VISUAL.md) - Visual guide
- 📖 [FIREBASE_MIGRATION_GUIDE.md](FIREBASE_MIGRATION_GUIDE.md) - Full guide
- 📖 [FIREBASE_MIGRATION_CHECKLIST.md](FIREBASE_MIGRATION_CHECKLIST.md) - Quick checklist

### External Resources:
- 🌐 [Firebase Console](https://console.firebase.google.com)
- 📚 [Firebase Docs](https://firebase.google.com/docs)
- 📚 [Flutter Firebase](https://firebase.flutter.dev)
- 💬 [Firebase Support](https://firebase.google.com/support)

---

## Next Steps

1. **Read** FIREBASE_MIGRATION_VISUAL.md for overview
2. **Create** new Firebase project
3. **Run** firebase-migrate.bat (Windows) or firebase-migrate.sh (Mac/Linux)
4. **Replace** google-services.json and service-account.json
5. **Test** the app locally
6. **Deploy** to production

---

## Important Reminders

⚠️ **Keep service-account.json secure!**
- Don't commit to public repositories
- Add to `.gitignore`
- Only share with trusted team members

✅ **Test thoroughly before deploying**
- Test on all platforms
- Test all features
- Test on real devices
- Test push notifications

✅ **Inform your users**
- They'll need to create new accounts
- Or import data if available
- Explain why migration happened

---

**Status:** ✅ Ready for Migration  
**Last Updated:** November 13, 2025  
**All Files:** Complete and Ready

---

## Contact & Support

For issues or questions:
1. Check the appropriate documentation file
2. Review the troubleshooting section
3. Check Firebase documentation
4. Contact Firebase support

---

**Good luck with your migration! 🚀**

The app will work exactly the same, just with your new Firebase account.
