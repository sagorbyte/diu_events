# Error Handling Quick Reference

## TL;DR - Quick Start

### 1️⃣ Import
```dart
import '../../../utils/error_handler.dart';
import '../../../core/exceptions/app_exceptions.dart';
```

### 2️⃣ Handle Exceptions
```dart
try {
  await operation();
} catch (e) {
  throw ErrorHandler.handleException(e, StackTrace.current,
      defaultMessage: 'Operation failed');
}
```

### 3️⃣ Use in Provider
```dart
catch (e) {
  final appException = ErrorHandler.handleException(e, StackTrace.current);
  _setError(appException.getUserMessage());
  ErrorHandler.logException(appException);
}
```

### 4️⃣ Display in UI
```dart
// Option 1: Error message widget
ErrorMessage(exception: exception)

// Option 2: Snackbar
showErrorSnackbar(context, exception)

// Option 3: Dialog
showErrorDialog(context, exception, onRetry: retry)
```

---

## Exception Types at a Glance

| Use Case | Exception |
|----------|-----------|
| Auth fails | `AuthenticationException` |
| Wrong email domain | `UnauthorizedDomainException` |
| User cancels signin | `SignInCancelledException` |
| Wrong password | `InvalidCredentialsException` |
| Email taken | `EmailAlreadyInUseException` |
| Weak password | `WeakPasswordException` |
| No permission | `AccessDeniedException` |
| Event op fails | `EventException` |
| No internet | `NetworkException` |
| Server error | `ServerException` |
| DB error | `DatabaseException` |
| File upload fail | `FileUploadException` |
| Bad input | `ValidationException` |
| Too slow | `TimeoutException` |
| Not found | `ResourceNotFoundException` |
| Unknown | `GenericException` |

---

## Common Patterns

### ✅ Service (with Firebase auth error)
```dart
Future<void> signIn(String email, String password) async {
  try {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    throw ErrorHandler.handleAuthException(e, StackTrace.current);
  }
}
```

### ✅ Service (with Firestore error)
```dart
Future<void> updateUser(String uid, Map data) async {
  try {
    await _firestore.collection('users').doc(uid).update(data);
  } catch (e) {
    throw ErrorHandler.handleFirestoreException(e, StackTrace.current);
  }
}
```

### ✅ Service (with custom validation)
```dart
Future<void> createEvent(Event event) async {
  try {
    if (event.title.isEmpty) {
      throw ValidationException(
        message: 'Event title is required',
        details: 'Please enter an event title',
      );
    }
    await _firestore.collection('events').add(event.toJson());
  } catch (e) {
    throw ErrorHandler.handleFirestoreException(e, StackTrace.current);
  }
}
```

### ✅ Provider (fetch with error handling)
```dart
Future<void> loadEvents() async {
  try {
    _setLoading(true);
    clearError();
    _events = await _service.getEvents();
  } catch (e) {
    final appEx = ErrorHandler.handleException(e, StackTrace.current,
        defaultMessage: 'Failed to load events');
    _setError(appEx.getUserMessage());
    ErrorHandler.logException(appEx);
  } finally {
    _setLoading(false);
  }
}
```

### ✅ Provider (create/update with error)
```dart
Future<bool> createEvent(Event event) async {
  try {
    _setLoading(true);
    clearError();
    await _service.createEvent(event);
    return true;
  } catch (e) {
    final appEx = ErrorHandler.handleException(e, StackTrace.current);
    _setError(appEx.getUserMessage());
    return false;
  } finally {
    _setLoading(false);
  }
}
```

### ✅ Screen (display errors)
```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.errorMessage != null) {
      return ErrorMessage(
        exception: AppException(...),
        onDismiss: provider.clearError,
      );
    }
    return MyContent();
  },
)
```

---

## File Locations

```
lib/
├── core/exceptions/
│   └── app_exceptions.dart          ← Custom exceptions
├── utils/
│   └── error_handler.dart           ← Error conversion logic
└── features/shared/widgets/
    └── error_display.dart           ← UI components
```

---

## Do's and Don'ts

### ❌ DON'T
```dart
// Raw exception message
throw Exception('Sign in failed: ${e.toString()}');

// Unhandled Firebase exception
try { ... } catch(e) { print('Error: $e'); }

// User sees technical error
_setError('FirebaseAuthException: wrong-password');
```

### ✅ DO
```dart
// Use error handler
throw ErrorHandler.handleAuthException(e, StackTrace.current);

// Convert and log
final appEx = ErrorHandler.handleException(e, StackTrace.current);
ErrorHandler.logException(appEx);

// User-friendly message
_setError(appEx.getUserMessage());
```

---

## Testing

### Test Exception Message
```dart
test('weak password shows friendly message', () {
  final ex = WeakPasswordException();
  expect(ex.getUserMessage(), 'Password is too weak');
});
```

### Test Widget Display
```dart
testWidgets('error widget shows message', (tester) async {
  final ex = TimeoutException();
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: ErrorMessage(exception: ex)),
  ));
  expect(find.text('Operation timed out'), findsOneWidget);
});
```

---

## Error Handler Methods

### `handleAuthException(exception, stackTrace)`
For Firebase Auth errors → AppException

### `handleFirestoreException(exception, stackTrace)`
For Firestore/Firebase errors → AppException

### `handleException(exception, stackTrace, defaultMessage)`
For any exception → AppException (smart routing)

### `logException(appException)`
Print error details for debugging

---

## User-Friendly Messages Examples

| Scenario | Message |
|----------|---------|
| Wrong password | "Incorrect password" |
| Email taken | "This email is already registered" |
| Weak password | "Use at least 6 characters with letters and numbers" |
| No internet | "Check your internet connection" |
| Timeout | "Request took too long. Please try again" |
| Permission denied | "You don't have permission for this action" |
| Not authorized | "Your email domain is not authorized" |
| User not found | "No account found with this email" |

---

## Logging

```dart
// Log error for debugging
ErrorHandler.logException(appException);

// Log with stack trace
ErrorHandler.logWithStackTrace(appException, stackTrace);
```

Output:
```
❌ Exception: WeakPasswordException
Message: Password is too weak
Details: Use at least 6 characters with a mix of letters and numbers
Original: ...
Stack trace: ...
```

---

## Pro Tips

1. **Always pass `StackTrace.current`** to capture the error location
2. **Provide a default message** in `handleException()` for generic catches
3. **Clear errors before retrying** with `clearError()`
4. **Log before throwing** if you need technical details
5. **Use specific exceptions** instead of `GenericException` when possible
6. **Add details** to help users understand what went wrong
7. **Make messages polite** - avoid blame or technical jargon
8. **Suggest action** - tell users what to do next

---

## Common Mistakes & Fixes

### ❌ Mistake: Swallowing errors silently
```dart
try {
  await operation();
} catch (e) {
  // silent fail - BAD!
}
```

### ✅ Fix: Log and show to user
```dart
try {
  await operation();
} catch (e) {
  final appEx = ErrorHandler.handleException(e, StackTrace.current);
  _setError(appEx.getUserMessage());
  ErrorHandler.logException(appEx);
}
```

### ❌ Mistake: Raw exception to UI
```dart
catch (e) {
  showDialog(context, 'Error: $e'); // Technical mess!
}
```

### ✅ Fix: Convert first
```dart
catch (e) {
  final appEx = ErrorHandler.handleException(e, StackTrace.current);
  showErrorDialog(context, appEx);
}
```

### ❌ Mistake: Lost stack trace
```dart
catch (e) {
  rethrow; // where did error come from?
}
```

### ✅ Fix: Preserve context
```dart
catch (e, st) {
  throw ErrorHandler.handleException(e, st);
}
```

---

## When to Use Each Display Method

| Method | When |
|--------|------|
| `ErrorMessage` | Inline errors in form/screen |
| `showErrorSnackbar()` | Quick notification |
| `showErrorDialog()` | Important errors needing action |
| `ErrorDisplay` | Full error container with retry |

---

## Troubleshooting

**Q: Users still see technical errors?**  
A: Check that all exceptions go through `ErrorHandler` before reaching UI

**Q: Stack trace not showing?**  
A: Pass `StackTrace.current` to exception handlers

**Q: Error not being caught?**  
A: Make sure to `await` the async function

**Q: Multiple error messages?**  
A: Call `clearError()` before new operations

---

## Need Help?

See `ERROR_HANDLING_GUIDE.md` for detailed documentation and examples.
