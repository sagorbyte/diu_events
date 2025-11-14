#!/bin/bash

# Firebase Cloud Functions Deployment Script
# This script installs dependencies and deploys Cloud Functions

echo "================================================"
echo "  Firebase Cloud Functions Deployment"
echo "================================================"
echo ""

# Navigate to functions directory
cd functions

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found in functions directory"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"
echo ""

# Deploy functions
echo "🚀 Deploying Cloud Functions..."
firebase deploy --only functions

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to deploy functions"
    exit 1
fi

echo ""
echo "================================================"
echo "  ✅ Deployment Complete!"
echo "================================================"
echo ""
echo "Deployed functions:"
echo "  • sendPushNotificationOnCreate"
echo "  • sendBulkPushNotification"
echo "  • cleanupInvalidTokens"
echo ""
echo "Next steps:"
echo "1. Test notifications by triggering app actions"
echo "2. Check Firebase Console → Functions for logs"
echo "3. Monitor Firestore → user_notifications collection"
echo ""
