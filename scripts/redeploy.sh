#!/bin/bash

# Firebase Hosting Redeploy Script for Mac/Linux
# This script rebuilds the web app and redeploys to Firebase Hosting

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  DIU Events - Firebase Hosting Redeploy                    ║"
echo "║  Script will: Clean, Build Web, and Deploy                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Set defaults
PROJECT_ID="${1:-diu-events-app-d1718}"
HOSTING_TARGET="${2:-diueventsapp}"

echo "Project: $PROJECT_ID"
echo "Hosting Target: $HOSTING_TARGET"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo "❌ Error: Flutter is not installed or not in PATH"
  echo "Please install Flutter from https://flutter.dev"
  exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
  echo "❌ Error: Firebase CLI is not installed or not in PATH"
  echo "Run: npm install -g firebase-tools"
  exit 1
fi

# Step 1: Clean Flutter cache
echo "Step 1: Cleaning Flutter cache..."
flutter clean
if [ $? -ne 0 ]; then
  echo "❌ Error: flutter clean failed"
  exit 1
fi
echo "✅ Flutter cache cleaned"

# Step 2: Get dependencies
echo ""
echo "Step 2: Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
  echo "❌ Error: flutter pub get failed"
  exit 1
fi
echo "✅ Dependencies updated"

# Step 3: Build web app
echo ""
echo "Step 3: Building web app (release mode)..."
flutter build web --release
if [ $? -ne 0 ]; then
  echo "❌ Error: flutter build web failed"
  exit 1
fi
echo "✅ Web app built successfully"

# Step 4: Deploy to Firebase
echo ""
echo "Step 4: Deploying to Firebase Hosting..."
firebase deploy --only hosting:"$HOSTING_TARGET" --project "$PROJECT_ID"
if [ $? -ne 0 ]; then
  echo "❌ Error: Firebase deployment failed"
  exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ Deployment Complete!                                   ║"
echo "║  Your app is live at:                                      ║"
echo "║  https://${HOSTING_TARGET}.web.app                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
