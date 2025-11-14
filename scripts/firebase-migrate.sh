#!/bin/bash

# Firebase Migration Script for DIU Events
# This script helps automate the Firebase account migration
# Usage: ./firebase-migrate.sh

echo "================================"
echo "Firebase Migration Helper"
echo "================================"
echo ""

# Function to prompt for input
prompt_for_value() {
    local prompt_text=$1
    local variable_name=$2
    
    read -p "$prompt_text: " value
    eval "$variable_name='$value'"
}

# Collect new Firebase credentials
echo "Please provide your NEW Firebase project credentials:"
echo ""

prompt_for_value "Enter new Project ID" NEW_PROJECT_ID
prompt_for_value "Enter new Sender ID (Messaging Sender ID)" NEW_SENDER_ID
prompt_for_value "Enter new Web API Key" NEW_WEB_API_KEY
prompt_for_value "Enter new Android API Key" NEW_ANDROID_API_KEY
prompt_for_value "Enter new iOS API Key" NEW_IOS_API_KEY
prompt_for_value "Enter new Web App ID" NEW_WEB_APP_ID
prompt_for_value "Enter new Android App ID" NEW_ANDROID_APP_ID
prompt_for_value "Enter new iOS App ID" NEW_IOS_APP_ID
prompt_for_value "Enter new Auth Domain (e.g., YOUR-PROJECT.firebaseapp.com)" NEW_AUTH_DOMAIN
prompt_for_value "Enter new Storage Bucket" NEW_STORAGE_BUCKET

echo ""
echo "Old values to replace:"
echo "  OLD_PROJECT_ID: diu-events-app"
echo "  OLD_SENDER_ID: 210442734122"
echo ""
echo "New values to use:"
echo "  NEW_PROJECT_ID: $NEW_PROJECT_ID"
echo "  NEW_SENDER_ID: $NEW_SENDER_ID"
echo ""

# Ask for confirmation
read -p "Continue with migration? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 1
fi

echo ""
echo "Starting migration..."
echo ""

# Function to show what would be replaced
show_replacements() {
    echo "File: $1"
    echo "Replacements to be made:"
    echo "  diu-events-app → $NEW_PROJECT_ID"
    echo "  210442734122 → $NEW_SENDER_ID"
    echo ""
}

# Show what will be done
echo "=== Summary of Changes ==="
echo ""
show_replacements ".firebaserc"
show_replacements "firebase.json"
show_replacements "lib/services/fcm_v1_service.dart"
echo "File: lib/firebase_options.dart"
echo "Replacements to be made:"
echo "  All API Keys updated"
echo "  All App IDs updated"
echo "  Project ID: diu-events-app → $NEW_PROJECT_ID"
echo "  Sender ID: 210442734122 → $NEW_SENDER_ID"
echo "  Auth Domain and Storage Bucket updated"
echo ""
echo "File: android/app/google-services.json"
echo "  Should be replaced with new file from Firebase Console"
echo ""

# Create backup
echo "Creating backups..."
BACKUP_DIR="backups/firebase-migration-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp .firebaserc "$BACKUP_DIR/.firebaserc.bak"
cp firebase.json "$BACKUP_DIR/firebase.json.bak"
cp lib/services/fcm_v1_service.dart "$BACKUP_DIR/fcm_v1_service.dart.bak"
cp lib/firebase_options.dart "$BACKUP_DIR/firebase_options.dart.bak"
cp android/app/google-services.json "$BACKUP_DIR/google-services.json.bak"

echo "✓ Backups created in: $BACKUP_DIR"
echo ""

# Update .firebaserc
echo "Updating .firebaserc..."
sed -i "s/diu-events-app/$NEW_PROJECT_ID/g" .firebaserc
echo "✓ Updated .firebaserc"

# Update firebase.json
echo "Updating firebase.json..."
sed -i "s/diu-events-app/$NEW_PROJECT_ID/g" firebase.json
sed -i "s/210442734122/$NEW_SENDER_ID/g" firebase.json
echo "✓ Updated firebase.json"

# Update fcm_v1_service.dart
echo "Updating lib/services/fcm_v1_service.dart..."
sed -i "s/_projectId = 'diu-events-app'/_projectId = '$NEW_PROJECT_ID'/g" lib/services/fcm_v1_service.dart
echo "✓ Updated fcm_v1_service.dart"

# Update firebase_options.dart
echo "Updating lib/firebase_options.dart..."
sed -i "s/210442734122/$NEW_SENDER_ID/g" lib/firebase_options.dart
sed -i "s/diu-events-app/$NEW_PROJECT_ID/g" lib/firebase_options.dart
sed -i "s|AIzaSyBOaa1Qz_HSHWfRAr8F0FOX5sWSqqtU_MM|$NEW_WEB_API_KEY|g" lib/firebase_options.dart
sed -i "s|AIzaSyDbb9AhJ969PUC9MTER9bibf2VqSRfgjLA|$NEW_ANDROID_API_KEY|g" lib/firebase_options.dart
sed -i "s|AIzaSyDXISylZL7gpyH-1ROd6VywJdEGtym18m8|$NEW_IOS_API_KEY|g" lib/firebase_options.dart
sed -i "s|diu-events-app.firebaseapp.com|$NEW_AUTH_DOMAIN|g" lib/firebase_options.dart
sed -i "s|diu-events-app.firebasestorage.app|$NEW_STORAGE_BUCKET|g" lib/firebase_options.dart
echo "✓ Updated firebase_options.dart"

echo ""
echo "=== Migration Complete ==="
echo ""
echo "Remaining manual steps:"
echo "1. Replace android/app/google-services.json with new file from Firebase"
echo "2. Replace service-account.json with new service account from Firebase"
echo "3. Run: flutter clean"
echo "4. Run: flutter pub get"
echo "5. Test on all platforms"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
echo "To revert changes, run:"
echo "  cp $BACKUP_DIR/* ."
echo ""
