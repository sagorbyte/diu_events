# DIU Events App - Project Structure

## Overview
This document outlines the restructured project organization that separates admin and student functionality into distinct modules.

## New Directory Structure

```
lib/
├── core/                           # Core utilities and services
│   ├── services/
│   │   ├── imgbb_image_service.dart
│   │   └── profile_image_service.dart
│   └── ...
├── features/
│   ├── admin/                      # Admin-specific functionality
│   │   ├── screens/               # Admin UI screens
│   │   │   ├── admin_home_screen.dart
│   │   │   ├── admin_management_screen.dart
│   │   │   ├── create_event_screen.dart
│   │   │   ├── edit_event_screen.dart
│   │   │   ├── event_registrations_screen.dart
│   │   │   ├── event_updates_management_screen.dart
│   │   │   └── publish_update_screen.dart
│   │   ├── providers/             # Admin state management
│   │   │   └── admin_provider.dart
│   │   └── services/              # Admin business logic
│   │       └── admin_service.dart
│   ├── student/                   # Student-specific functionality
│   │   └── screens/              # Student UI screens
│   │       ├── student_home_screen.dart
│   │       ├── explore_screen.dart
│   │       ├── my_events_screen.dart
│   │       └── event_updates_screen.dart
│   ├── shared/                    # Shared functionality between admin and student
│   │   ├── models/               # Data models
│   │   │   ├── event.dart
│   │   │   └── event_update.dart
│   │   ├── providers/            # Shared state management
│   │   │   └── event_provider.dart
│   │   ├── services/             # Shared business logic
│   │   │   └── event_service.dart
│   │   └── screens/              # Shared UI components
│   │       └── event_detail_screen.dart
│   └── auth/                      # Authentication functionality
│       ├── models/
│       ├── providers/
│       ├── screens/
│       └── services/
├── firebase_options.dart
└── main.dart
```

## Module Responsibilities

### Admin Module (`lib/features/admin/`)
- **Purpose**: Handles all administrative functionality
- **Key Features**:
  - Event creation and management
  - Event registration management
  - Publishing event updates
  - Admin dashboard and analytics
  - Admin profile management

### Student Module (`lib/features/student/`)
- **Purpose**: Handles all student-facing functionality  
- **Key Features**:
  - Browsing and exploring events
  - Event registration and management
  - Viewing event updates
  - Personal event dashboard

### Shared Module (`lib/features/shared/`)
- **Purpose**: Contains common functionality used by both admin and student modules
- **Key Features**:
  - Event data models and DTOs
  - Event provider for state management
  - Event services for business logic
  - Shared UI components like event detail screens

### Auth Module (`lib/features/auth/`)
- **Purpose**: Handles authentication and user management
- **Key Features**:
  - User login/logout
  - User registration
  - Profile management
  - Role-based access control

## Benefits of This Structure

1. **Separation of Concerns**: Clear boundaries between admin and student functionality
2. **Maintainability**: Easier to locate and modify specific features
3. **Scalability**: New features can be added to appropriate modules without affecting others
4. **Code Reusability**: Shared components reduce duplication
5. **Team Development**: Different teams can work on different modules independently
6. **Testing**: Easier to write focused unit and integration tests

## Import Guidelines

### Within the same module:
```dart
import 'screen_name.dart';  // Relative import for screens in same directory
```

### Cross-module imports:
```dart
import '../../shared/models/event.dart';           // From admin to shared
import '../../shared/providers/event_provider.dart'; // From student to shared
import '../../admin/screens/edit_event_screen.dart'; // From shared to admin
```

### External packages:
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
```

## Migration Notes

- All existing imports have been updated to reflect the new structure
- No breaking changes to existing functionality
- All screens maintain their current behavior and UI
- Database and Firebase integrations remain unchanged

## Next Steps for Further Organization

1. **Create student providers/services directories** as the student module grows
2. **Add shared widgets directory** for reusable UI components
3. **Implement feature-specific routing** within each module
4. **Add module-specific testing directories**

This structure provides a solid foundation for the continued development and maintenance of the DIU Events application.
