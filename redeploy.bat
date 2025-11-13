@echo off
REM Firebase Hosting Redeploy Script for Windows
REM This script rebuilds the web app and redeploys to Firebase Hosting

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  DIU Events - Firebase Hosting Redeploy                    ║
echo ║  Script will: Clean, Build Web, and Deploy                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Set project ID (can be overridden from command line)
set PROJECT_ID=diu-events-app-d1718
set HOSTING_TARGET=diueventsapp

if not "%1"=="" (
  set PROJECT_ID=%1
)
if not "%2"=="" (
  set HOSTING_TARGET=%2
)

echo Project: %PROJECT_ID%
echo Hosting Target: %HOSTING_TARGET%
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
  echo ❌ Error: Flutter is not installed or not in PATH
  echo Please install Flutter from https://flutter.dev
  pause
  exit /b 1
)

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if errorlevel 1 (
  echo ❌ Error: Firebase CLI is not installed or not in PATH
  echo Run: npm install -g firebase-tools
  pause
  exit /b 1
)

echo Step 1: Cleaning Flutter cache...
flutter clean
if errorlevel 1 (
  echo ❌ Error: flutter clean failed
  pause
  exit /b 1
)
echo ✅ Flutter cache cleaned

echo.
echo Step 2: Getting dependencies...
flutter pub get
if errorlevel 1 (
  echo ❌ Error: flutter pub get failed
  pause
  exit /b 1
)
echo ✅ Dependencies updated

echo.
echo Step 3: Building web app (release mode)...
flutter build web --release
if errorlevel 1 (
  echo ❌ Error: flutter build web failed
  pause
  exit /b 1
)
echo ✅ Web app built successfully

echo.
echo Step 4: Deploying to Firebase Hosting...
firebase deploy --only hosting:%HOSTING_TARGET% --project %PROJECT_ID%
if errorlevel 1 (
  echo ❌ Error: Firebase deployment failed
  pause
  exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  ✅ Deployment Complete!                                   ║
echo ║  Your app is live at:                                      ║
echo ║  https://%HOSTING_TARGET%.web.app                          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
pause
