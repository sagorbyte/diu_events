@echo off
REM Firebase Cloud Functions Deployment Script for Windows
REM This script installs dependencies and deploys Cloud Functions

echo ================================================
echo   Firebase Cloud Functions Deployment
echo ================================================
echo.

REM Navigate to functions directory
cd functions

REM Check if package.json exists
if not exist "package.json" (
    echo Error: package.json not found in functions directory
    exit /b 1
)

REM Install dependencies
echo Installing dependencies...
call npm install

if %ERRORLEVEL% neq 0 (
    echo Error: Failed to install dependencies
    exit /b 1
)

echo Dependencies installed successfully
echo.

REM Deploy functions
echo Deploying Cloud Functions...
call firebase deploy --only functions

if %ERRORLEVEL% neq 0 (
    echo Error: Failed to deploy functions
    exit /b 1
)

echo.
echo ================================================
echo   Deployment Complete!
echo ================================================
echo.
echo Deployed functions:
echo   - sendPushNotificationOnCreate
echo   - sendBulkPushNotification
echo   - cleanupInvalidTokens
echo.
echo Next steps:
echo 1. Test notifications by triggering app actions
echo 2. Check Firebase Console - Functions for logs
echo 3. Monitor Firestore - user_notifications collection
echo.

pause
