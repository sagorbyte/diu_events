@echo off
REM Firebase Migration Script for DIU Events (Windows)
REM This script helps automate the Firebase account migration
REM Usage: firebase-migrate.bat

setlocal enabledelayedexpansion

echo ================================
echo Firebase Migration Helper
echo ================================
echo.

REM Collect new Firebase credentials
echo Please provide your NEW Firebase project credentials:
echo.

set /p NEW_PROJECT_ID="Enter new Project ID: "
set /p NEW_SENDER_ID="Enter new Sender ID (Messaging Sender ID): "
set /p NEW_WEB_API_KEY="Enter new Web API Key: "
set /p NEW_ANDROID_API_KEY="Enter new Android API Key: "
set /p NEW_IOS_API_KEY="Enter new iOS API Key: "
set /p NEW_WEB_APP_ID="Enter new Web App ID: "
set /p NEW_ANDROID_APP_ID="Enter new Android App ID: "
set /p NEW_IOS_APP_ID="Enter new iOS App ID: "
set /p NEW_AUTH_DOMAIN="Enter new Auth Domain (e.g., YOUR-PROJECT.firebaseapp.com): "
set /p NEW_STORAGE_BUCKET="Enter new Storage Bucket: "

echo.
echo Old values to replace:
echo   OLD_PROJECT_ID: diu-events-app
echo   OLD_SENDER_ID: 210442734122
echo.
echo New values to use:
echo   NEW_PROJECT_ID: %NEW_PROJECT_ID%
echo   NEW_SENDER_ID: %NEW_SENDER_ID%
echo.

set /p confirm="Continue with migration? (y/n): "
if /i not "%confirm%"=="y" (
    echo Migration cancelled.
    exit /b 1
)

echo.
echo Starting migration...
echo.

REM Create backup
echo Creating backups...
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set BACKUP_DIR=backups\firebase-migration-%mydate%-%mytime%

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

copy .firebaserc "%BACKUP_DIR%\.firebaserc.bak" >nul
copy firebase.json "%BACKUP_DIR%\firebase.json.bak" >nul
copy lib\services\fcm_v1_service.dart "%BACKUP_DIR%\fcm_v1_service.dart.bak" >nul
copy lib\firebase_options.dart "%BACKUP_DIR%\firebase_options.dart.bak" >nul
copy android\app\google-services.json "%BACKUP_DIR%\google-services.json.bak" >nul

echo Backups created in: %BACKUP_DIR%
echo.

REM Create temporary PowerShell script for replacements
echo Creating update script...
(
echo $files = @(
echo   '.\.firebaserc',
echo   '.\firebase.json',
echo   '.\lib\services\fcm_v1_service.dart',
echo   '.\lib\firebase_options.dart'
echo )
echo.
echo foreach ($file in $files) {
echo   $content = Get-Content $file -Raw
echo   $content = $content -replace 'diu-events-app', '%NEW_PROJECT_ID%'
echo   $content = $content -replace '210442734122', '%NEW_SENDER_ID%'
echo   Set-Content $file $content
echo }
echo.
echo $firebaseOptions = Get-Content '.\lib\firebase_options.dart' -Raw
echo $firebaseOptions = $firebaseOptions -replace 'AIzaSyBOaa1Qz_HSHWfRAr8F0FOX5sWSqqtU_MM', '%NEW_WEB_API_KEY%'
echo $firebaseOptions = $firebaseOptions -replace 'AIzaSyDbb9AhJ969PUC9MTER9bibf2VqSRfgjLA', '%NEW_ANDROID_API_KEY%'
echo $firebaseOptions = $firebaseOptions -replace 'AIzaSyDXISylZL7gpyH-1ROd6VywJdEGtym18m8', '%NEW_IOS_API_KEY%'
echo $firebaseOptions = $firebaseOptions -replace 'diu-events-app\.firebaseapp\.com', '%NEW_AUTH_DOMAIN%'
echo $firebaseOptions = $firebaseOptions -replace 'diu-events-app\.firebasestorage\.app', '%NEW_STORAGE_BUCKET%'
echo Set-Content '.\lib\firebase_options.dart' $firebaseOptions
) > update_firebase.ps1

echo Updating .firebaserc...
powershell -ExecutionPolicy Bypass -File update_firebase.ps1
if errorlevel 1 (
    echo Error updating files. Reverting from backups...
    copy "%BACKUP_DIR%\.firebaserc.bak" .firebaserc
    copy "%BACKUP_DIR%\firebase.json.bak" firebase.json
    copy "%BACKUP_DIR%\fcm_v1_service.dart.bak" lib\services\fcm_v1_service.dart
    copy "%BACKUP_DIR%\firebase_options.dart.bak" lib\firebase_options.dart
    del update_firebase.ps1
    exit /b 1
)

echo Migration Complete
echo.
echo Remaining manual steps:
echo 1. Replace android\app\google-services.json with new file from Firebase
echo 2. Replace service-account.json with new service account from Firebase
echo 3. Run: flutter clean
echo 4. Run: flutter pub get
echo 5. Test on all platforms
echo.
echo Backups saved to: %BACKUP_DIR%
echo.
echo To revert changes, run:
echo   copy "%BACKUP_DIR%\*" .
echo.

del update_firebase.ps1
endlocal
pause
