# Error Handling in UI Screens - Complete Examples

This document shows how to properly display errors in your screens using the new error handling system.

## 1. Login Screen with Error Display

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/error_display.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo/Title
                  Text(
                    'DIU Events',
                    style: GoogleFonts.hindSiliguriTextTheme(
                      TextTheme(
                        headlineLarge: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F3D9C),
                        ),
                      ),
                    ).headlineLarge,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // ERROR DISPLAY - Shows only if there's an error
                  if (authProvider.errorMessage != null)
                    Column(
                      children: [
                        ErrorMessage(
                          exception: _parseError(authProvider.errorMessage!),
                          onDismiss: authProvider.clearError,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  
                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleLogin(context, authProvider),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, AuthProvider authProvider) async {
    final success = await authProvider.signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (!success && mounted) {
      // Error will be shown via ErrorMessage widget above
      // No need to show dialog - it updates via Consumer
    }
  }

  // Helper to convert error string to AppException
  AppException _parseError(String errorMessage) {
    // For now, create a generic exception with the message
    // In a more advanced setup, you could parse the type
    return GenericException(
      message: errorMessage,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## 2. Form Screen with Inline Errors

```dart
class EventCreateScreen extends StatefulWidget {
  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ERROR MESSAGE - Inline display
                if (eventProvider.errorMessage != null) ...[
                  ErrorMessage(
                    exception: _parseError(eventProvider.errorMessage!),
                    onDismiss: eventProvider.clearError,
                  ),
                  const SizedBox(height: 16),
                ],

                // Title Field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    errorText: _validateTitle(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: eventProvider.isLoading
                        ? null
                        : () => _handleCreateEvent(context, eventProvider),
                    child: eventProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Event'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _validateTitle() {
    if (_titleController.text.isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  Future<void> _handleCreateEvent(
    BuildContext context,
    EventProvider eventProvider,
  ) async {
    if (_titleController.text.isEmpty) {
      eventProvider._setError('Please enter an event title');
      return;
    }

    final event = Event(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      // ... other fields
    );

    final success = await eventProvider.createEvent(event);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.of(context).pop();
    }
    // Error is shown via ErrorMessage widget
  }

  AppException _parseError(String errorMessage) {
    return GenericException(message: errorMessage);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

## 3. List Screen with Error and Retry

```dart
class EventsListScreen extends StatefulWidget {
  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          // Show error state
          if (eventProvider.errorMessage != null &&
              eventProvider.filteredEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ErrorDisplay(
                    exception: _parseError(eventProvider.errorMessage!),
                    onRetry: () => eventProvider.fetchAllEvents(),
                    onDismiss: eventProvider.clearError,
                  ),
                ],
              ),
            );
          }

          // Show loading state
          if (eventProvider.isLoading &&
              eventProvider.filteredEvents.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show list with error banner if there's an error but we have data
          return Column(
            children: [
              if (eventProvider.errorMessage != null)
                ErrorMessage(
                  exception: _parseError(eventProvider.errorMessage!),
                  onDismiss: eventProvider.clearError,
                ),
              Expanded(
                child: eventProvider.filteredEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No events found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: eventProvider.filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = eventProvider.filteredEvents[index];
                          return EventCard(event: event);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppException _parseError(String errorMessage) {
    return GenericException(message: errorMessage);
  }
}
```

## 4. Dialog with Error and Retry

```dart
void showErrorWithRetry(
  BuildContext context,
  String errorMessage,
  VoidCallback onRetry,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

## 5. Advanced: Custom Error Handler in Screen

```dart
class ComplexFeatureScreen extends StatefulWidget {
  @override
  State<ComplexFeatureScreen> createState() => _ComplexFeatureScreenState();
}

class _ComplexFeatureScreenState extends State<ComplexFeatureScreen> {
  String? _localError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Local error display
            if (_localError != null)
              ErrorMessage(
                exception: GenericException(message: _localError!),
                onDismiss: () => setState(() => _localError = null),
              ),

            // Consumer for provider errors
            Consumer<SomeProvider>(
              builder: (context, provider, _) {
                if (provider.errorMessage != null) {
                  return Column(
                    children: [
                      ErrorMessage(
                        exception: GenericException(
                          message: provider.errorMessage!,
                        ),
                        onDismiss: provider.clearError,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Main content
            _buildMainContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Complex form or content
        ],
      ),
    );
  }

  Future<void> _handleComplexOperation() async {
    try {
      setState(() => _localError = null);
      
      // Do something
      
    } catch (e) {
      final appException = ErrorHandler.handleException(
        e,
        StackTrace.current,
        defaultMessage: 'Operation failed',
      );
      setState(() => _localError = appException.getUserMessage());
      ErrorHandler.logException(appException);
    }
  }
}
```

## Best Practices for Screens

### ✅ Do's

1. **Clear errors before operations**
   ```dart
   eventProvider.clearError();
   await eventProvider.loadData();
   ```

2. **Show errors inline for forms**
   ```dart
   if (provider.errorMessage != null)
     ErrorMessage(exception: _parseError(...))
   ```

3. **Provide retry on failure**
   ```dart
   ErrorDisplay(exception: ex, onRetry: () => retry())
   ```

4. **Use Consumer for provider errors**
   ```dart
   Consumer<MyProvider>(
     builder: (context, provider, _) {
       if (provider.errorMessage != null) {
         return ErrorMessage(...);
       }
     },
   )
   ```

5. **Handle both error and success states**
   ```dart
   if (isError) showError();
   if (isSuccess) showSuccess();
   ```

### ❌ Don'ts

1. **Don't ignore errors**
   ```dart
   // BAD
   try { await op(); } catch (e) { }
   ```

2. **Don't show raw exceptions**
   ```dart
   // BAD
   showDialog(context, 'Error: $e');
   ```

3. **Don't forget to dispose**
   ```dart
   // BAD - memory leak
   class MyScreen extends StatefulWidget { }
   ```

4. **Don't mix error sources**
   ```dart
   // BAD
   if (localError != null && providerError != null)
     // confusing
   ```

5. **Don't block UI indefinitely**
   ```dart
   // BAD
   while (loading) { } // freezes UI
   ```

## Error Handling Patterns by Screen Type

### Form/Input Screen
```dart
Column(
  children: [
    // Error at top
    if (error != null) ErrorMessage(),
    // Form fields
    TextField(...),
    // Submit
    ElevatedButton(
      onPressed: () => _submit(),
      child: Text('Submit'),
    ),
  ],
)
```

### List/Data Screen
```dart
Column(
  children: [
    // Error as banner
    if (error != null && data.isNotEmpty)
      ErrorMessage(),
    // Content
    Expanded(
      child: ListView(...),
    ),
  ],
)
```

### Detail/View Screen
```dart
SingleChildScrollView(
  child: Column(
    children: [
      // Error dialog or dialog
      if (error != null)
        showErrorDialog(context, error, onRetry: retry),
      // Content
      DetailWidget(...),
    ],
  ),
)
```

---

## Testing Error Display

```dart
testWidgets('shows error message on failure', (tester) async {
  final errorMessage = 'Something went wrong';
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ErrorMessage(
          exception: GenericException(message: errorMessage),
        ),
      ),
    ),
  );

  expect(find.text(errorMessage), findsOneWidget);
  expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
});

testWidgets('dismisses error on close', (tester) async {
  bool dismissed = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ErrorMessage(
          exception: GenericException(message: 'Error'),
          onDismiss: () => dismissed = true,
        ),
      ),
    ),
  );

  await tester.tap(find.byIcon(Icons.close));
  expect(dismissed, isTrue);
});
```

---

For more details, see:
- `ERROR_HANDLING_GUIDE.md` - Complete reference
- `ERROR_HANDLING_QUICK_REFERENCE.md` - Quick patterns
