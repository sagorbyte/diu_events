@echo off
REM DIU Events - Release APK Builder
REM Builds a production-ready APK in release mode

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  DIU Events - Release APK Builder                          ║
echo ║  Builds production APK with optimizations                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    echo 📝 Please install Flutter: https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo 🔍 Flutter version:
flutter --version
echo.

REM Get build number if provided (default 1)
set BUILD_NUMBER=%1
if "%BUILD_NUMBER%"=="" set BUILD_NUMBER=1

REM Get build name if provided (default 1.0.0)
set BUILD_NAME=%2
if "%BUILD_NAME%"=="" set BUILD_NAME=1.0.0

echo 📦 Build Configuration:
echo   Build Number: %BUILD_NUMBER%
echo   Build Name: %BUILD_NAME%
echo.

REM Step 1: Clean
echo Step 1: Cleaning Flutter cache...
flutter clean
if errorlevel 1 (
    echo ❌ Failed to clean Flutter cache
    exit /b 1
)
echo ✅ Flutter cache cleaned
echo.

REM Step 2: Get dependencies
echo Step 2: Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo ❌ Failed to get dependencies
    exit /b 1
)
echo ✅ Dependencies updated
echo.

REM Step 3: Build APK
echo Step 3: Building release APK...
echo   This may take several minutes...
echo.

flutter build apk ^
  --release ^
  --split-per-abi ^
  --build-number=%BUILD_NUMBER% ^
  --build-name=%BUILD_NAME%

if errorlevel 1 (
    echo ❌ Failed to build APK
    exit /b 1
)

echo.
echo ✅ APK build completed!
echo.

REM Check if APK was created
if exist "build\app\outputs\flutter-apk" (
    echo 📁 APK Output Directory:
    dir /s /b "build\app\outputs\flutter-apk\*.apk"
    echo.
    echo 📍 APK Location and Sizes:
    for /r "build\app\outputs\flutter-apk" %%F in (*.apk) do (
        for /F "usebackq" %%A in ('%%~zF') do set /A SIZE=%%A/1024/1024
        echo   ✓ %%F (!SIZE! MB^)
    )
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║  ✅ Release APK Build Complete!                           ║
    echo ║  Ready for Google Play Store or direct distribution       ║
    echo ╚════════════════════════════════════════════════════════════╝
) else (
    echo ❌ APK output directory not found
    exit /b 1
)
