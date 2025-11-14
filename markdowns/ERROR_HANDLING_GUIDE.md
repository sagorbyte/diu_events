# Clean & Readable Error Handling System

## Overview

This document describes the centralized error handling system that provides clean, user-friendly error messages throughout the DIU Events application.

## Architecture

The error handling system consists of four main components:

### 1. **Custom Exception Classes** (`lib/core/exceptions/app_exceptions.dart`)

All custom exceptions extend the `AppException` abstract class, which provides:
- User-friendly messages for display in the UI
- Detailed technical information for logging and debugging
- Stack traces for error tracking
- Original exception reference

#### Available Exception Types:

| Exception | Usage | User Message |
|-----------|-------|-------------|
| `AuthenticationException` | General auth failures | "Authentication failed" |
| `UnauthorizedDomainException` | Invalid email domain | "Your email domain is not authorized" |
| `SignInCancelledException` | User cancels sign-in | "Sign in was cancelled" |
| `InvalidCredentialsException` | Wrong password | "Invalid email or password" |
| `EmailAlreadyInUseException` | Email registered | "This email is already registered" |
| `WeakPasswordException` | Password too weak | "Password is too weak" |
| `AccessDeniedException` | Permission denied | "Access denied" |
| `EventException` | Event operations fail | "Event operation failed" |
| `NetworkException` | Connection issues | "Network connection failed" |
| `ServerException` | Server errors | "Server error" |
| `DatabaseException` | Firestore errors | "Database operation failed" |
| `FileUploadException` | File upload fails | "File upload failed" |
| `ValidationException` | Input validation fails | "Validation failed" |
| `TimeoutException` | Operation times out | "Operation timed out" |
| `UserNotFoundException` | User not found | "User not found" |
| `ResourceNotFoundException` | Resource not found | "Resource not found" |
| `GenericException` | Fallback for unknown errors | "An error occurred" |

### 2. **Error Handler Utility** (`lib/utils/error_handler.dart`)

Centralized error handling logic with methods:

#### `handleAuthException(exception, stackTrace)`
Converts Firebase Auth exceptions to user-friendly `AppException` objects.

```dart
try {
  await _firebaseAuth.signInWithEmailAndPassword(...);
} catch (e) {
  throw ErrorHandler.handleAuthException(e, StackTrace.current);
}
```

#### `handleFirestoreException(exception, stackTrace)`
Converts Firestore exceptions to user-friendly `AppException` objects.

```dart
try {
  await _firestore.collection('users').doc(uid).update(data);
} catch (e) {
  throw ErrorHandler.handleFirestoreException(e, StackTrace.current);
}
```

#### `handleException(exception, stackTrace, defaultMessage)`
General-purpose exception converter that intelligently routes to specific handlers.

```dart
try {
  // Any operation
} catch (e) {
  throw ErrorHandler.handleException(e, StackTrace.current,
      defaultMessage: 'Operation failed');
}
```

#### `logException(appException)`
Logs exception details for debugging.

```dart
try {
  // operation
} catch (e) {
  final appException = ErrorHandler.handleException(e, StackTrace.current);
  ErrorHandler.logException(appException);
}
```

### 3. **Error Display Widgets** (`lib/features/shared/widgets/error_display.dart`)

Reusable UI widgets for displaying errors:

#### `ErrorDisplay`
Full-featured error container with retry option:

```dart
ErrorDisplay(
  exception: myException,
  onRetry: () => retryOperation(),
  onDismiss: () => Navigator.pop(context),
)
```

#### `ErrorMessage`
Compact inline error message:

```dart
ErrorMessage(
  exception: myException,
  onDismiss: () => setState(() => clearError()),
)
```

#### `showErrorSnackbar(context, exception)`
Display error as a snackbar:

```dart
showErrorSnackbar(context, myException);
```

#### `showErrorDialog(context, exception, onRetry)`
Display error in a dialog:

```dart
showErrorDialog(
  context,
  myException,
  onRetry: () => retryOperation(),
);
```

## Usage Examples

### In Services

```dart
import '../../../utils/error_handler.dart';
import '../../../core/exceptions/app_exceptions.dart';

class UserService {
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw ErrorHandler.handleFirestoreException(e, StackTrace.current);
    }
  }
}
```

### In Providers

```dart
import '../../../utils/error_handler.dart';
import '../../../core/exceptions/app_exceptions.dart';

class MyProvider with ChangeNotifier {
  String? _errorMessage;

  Future<void> loadData() async {
    try {
      _setLoading(true);
      clearError();
      // operation
      _applyFilters();
    } catch (e) {
      final appException = ErrorHandler.handleException(
        e,
        StackTrace.current,
        defaultMessage: 'Failed to load data',
      );
      _setError(appException.getUserMessage());
      ErrorHandler.logException(appException);
    } finally {
      _setLoading(false);
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

### In Screens/UI

```dart
import '../../shared/widgets/error_display.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null) {
          // Option 1: Show error container
          return Column(
            children: [
              ErrorMessage(
                exception: provider.errorMessage!,
                onDismiss: () => provider.clearError(),
              ),
              // ... rest of content
            ],
          );
        }

        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: provider.filteredItems.map((item) {
            return ItemCard(item: item);
          }).toList(),
        );
      },
    );
  }
}
```

### Error Handling in Screens (with retry)

```dart
void _showErrorAndRetry(AppException exception) {
  showErrorDialog(
    context,
    exception,
    onRetry: () {
      Provider.of<MyProvider>(context, listen: false).loadData();
    },
  );
}
```

## Best Practices

### 1. **Always Convert Unknown Exceptions**
Never let raw exceptions bubble up to the UI. Always convert them using `ErrorHandler`:

```dart
// ❌ Bad
throw Exception('Operation failed: $e');

// ✅ Good
throw ErrorHandler.handleException(e, StackTrace.current,
    defaultMessage: 'Operation failed');
```

### 2. **Use Specific Exception Types**
Use the most specific exception type for your error:

```dart
// ❌ Generic
throw GenericException(message: 'Password incorrect');

// ✅ Specific
throw InvalidCredentialsException();
```

### 3. **Provide Context in Details**
Include helpful details that explain why the error occurred:

```dart
throw TimeoutException(
  message: 'Request took too long',
  details: 'The server is not responding. Please try again in a moment.',
);
```

### 4. **Log Before Throwing**
Log errors for debugging but show user-friendly messages:

```dart
try {
  await operation();
} catch (e) {
  final appException = ErrorHandler.handleException(e, StackTrace.current);
  ErrorHandler.logException(appException); // Technical details logged
  throw appException; // User-friendly message thrown
}
```

### 5. **Clear Errors When Retrying**
Always clear the error message before retrying an operation:

```dart
Future<void> retryOperation() async {
  clearError();
  try {
    await performOperation();
  } catch (e) {
    _setError(ErrorHandler.handleException(e, StackTrace.current).getUserMessage());
  }
}
```

## Error Message Guidelines

### ✅ Good Error Messages
- **Clear**: User understands what went wrong
- **Actionable**: User knows what to do next
- **Brief**: Not overwhelming with information
- **Polite**: Friendly tone, no technical jargon

### Examples:
| Bad | Good |
|-----|------|
| "FirebaseAuthException: wrong-password" | "Incorrect password" |
| "Network error: timeout" | "Check your connection and try again" |
| "Firestore Permission Denied Exception" | "You don't have permission to access this resource" |
| "Failed to upload file to ImgBB API" | "Image upload failed. Please try again." |

## File Structure

```
lib/
├── core/
│   └── exceptions/
│       └── app_exceptions.dart        # Custom exception classes
├── utils/
│   └── error_handler.dart             # Error handling logic
└── features/
    └── shared/
        └── widgets/
            └── error_display.dart      # Error UI widgets
```

## Migration Guide

If you have existing code using raw exceptions:

### Before:
```dart
try {
  await _firebaseAuth.signInWithEmailAndPassword(...);
} catch (e) {
  print('Error: $e');
  throw Exception('Sign-in failed: ${e.toString()}');
}
```

### After:
```dart
try {
  await _firebaseAuth.signInWithEmailAndPassword(...);
} catch (e) {
  throw ErrorHandler.handleAuthException(e, StackTrace.current);
}
```

## Testing Error Handling

### Unit Test Example:
```dart
test('handles weak password exception', () {
  final exception = WeakPasswordException();
  expect(exception.getUserMessage(), 'Password is too weak');
  expect(exception.details, isNotNull);
});
```

### Widget Test Example:
```dart
testWidgets('displays error message', (WidgetTester tester) async {
  final exception = WeakPasswordException();
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ErrorDisplay(exception: exception),
      ),
    ),
  );

  expect(find.text('Password is too weak'), findsOneWidget);
});
```

## Common Patterns

### Pattern 1: Fetch with Retry
```dart
Future<void> fetchData() async {
  try {
    _setLoading(true);
    clearError();
    _data = await _service.fetchData();
  } catch (e) {
    final appException = ErrorHandler.handleException(
      e,
      StackTrace.current,
      defaultMessage: 'Failed to load data',
    );
    _setError(appException.getUserMessage());
    ErrorHandler.logException(appException);
  } finally {
    _setLoading(false);
  }
}
```

### Pattern 2: Create/Update with Validation
```dart
Future<bool> createEvent(Event event) async {
  try {
    _setLoading(true);
    clearError();
    
    if (!_isValidEvent(event)) {
      throw ValidationException(
        message: 'Event information incomplete',
        details: 'Please fill in all required fields',
      );
    }
    
    await _service.createEvent(event);
    return true;
  } catch (e) {
    final appException = ErrorHandler.handleException(
      e,
      StackTrace.current,
      defaultMessage: 'Failed to create event',
    );
    _setError(appException.getUserMessage());
    return false;
  } finally {
    _setLoading(false);
  }
}
```

### Pattern 3: Authentication with Domain Check
```dart
Future<UserCredential?> signInWithGoogle() async {
  try {
    final userCredential = await _googleSignIn.authenticate();
    
    if (userCredential == null) {
      throw SignInCancelledException();
    }
    
    final domain = userCredential.email.split('@')[1];
    if (!isAllowedDomain(domain)) {
      throw UnauthorizedDomainException();
    }
    
    return userCredential;
  } catch (e) {
    throw ErrorHandler.handleAuthException(e, StackTrace.current);
  }
}
```

## Troubleshooting

### Issue: Exception not being caught properly
**Solution**: Ensure you're awaiting async functions and using proper error handling in the right scope.

### Issue: User sees technical error messages
**Solution**: Verify exceptions are passed through `ErrorHandler` before throwing to UI layer.

### Issue: Stack traces not appearing in logs
**Solution**: Pass `StackTrace.current` to exception handlers.

## Future Enhancements

1. **Remote Error Logging**: Send error logs to Firebase Crashlytics
2. **Error Analytics**: Track error frequency and types
3. **Localization**: Support multiple languages for error messages
4. **Error Recovery**: Implement automatic retry logic with exponential backoff
5. **User Preferences**: Allow users to control error notification styles

## Support

For issues or questions about error handling, please refer to the inline code documentation or contact the development team.
