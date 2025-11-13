# Running DIU Events App on localhost:5000

## Current Setup:
✅ App is launching on Chrome at localhost:5000
✅ Command used: `flutter run -d chrome --web-port 5000`

## Google OAuth Configuration Update Required:

### In Google Cloud Console:
1. Go to: https://console.cloud.google.com/
2. Navigate to: APIs & Services → Credentials
3. Find your OAuth 2.0 client ID: `1042782835170-69gn5pbsmfefkmfdvhevradkgop1u5r2.apps.googleusercontent.com`
4. Edit the client ID
5. Add to **Authorized JavaScript origins**:
   - `http://localhost:5000`
   - `http://localhost:3000` (backup)
   - `http://localhost:8080` (backup)

### Why This is Important:
- Google Sign-In will only work from authorized domains
- Without localhost:5000 in the authorized origins, Google Sign-In will fail with CORS errors

## Current Status:
🟢 App launching on localhost:5000
🟢 Firebase configuration ready
🟢 Google OAuth client ID configured
⚠️ Need to add localhost:5000 to Google Cloud Console authorized origins

## Commands for Development:

### Run on specific port:
```bash
flutter run -d chrome --web-port 5000
```

### Run with hot reload:
```bash
flutter run -d chrome --web-port 5000 --hot
```

### Build for production:
```bash
flutter build web
```

## Access URLs:
- **App**: http://localhost:5000
- **DevTools**: Will be shown in terminal once launched

## Next Steps:
1. ✅ App is launching
2. ⏳ Add localhost:5000 to Google OAuth authorized origins
3. ⏳ Test Google Sign-In functionality
4. ⏳ Test admin login functionality
