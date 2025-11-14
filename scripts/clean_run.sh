#!/bin/bash
echo "Starting DIU Events App in Release Mode..."
cd "D:/Design Work/Extra Freelance Work/DIU Events/diu_events_app/diu_events"
flutter clean && flutter pub get && flutter run --release
