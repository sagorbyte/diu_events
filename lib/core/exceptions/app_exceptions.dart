/// Custom exception classes for the DIU Events application
/// Provides clean, user-friendly error messages for different error scenarios

abstract class AppException implements Exception {
  final String message;
  final String? details;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.details,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;

  /// Get the user-friendly message to display in the UI
  String getUserMessage() => message;

  /// Get the technical details for logging
  String getLogMessage() {
    final buffer = StringBuffer();
    buffer.writeln('Exception: ${runtimeType.toString()}');
    buffer.writeln('Message: $message');
    if (details != null) buffer.writeln('Details: $details');
    if (originalException != null) {
      buffer.writeln('Original: $originalException');
    }
    return buffer.toString();
  }
}

/// Thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException({
    String message = 'Authentication failed',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when user email domain is not allowed
class UnauthorizedDomainException extends AppException {
  UnauthorizedDomainException({
    String message = 'Your email domain is not authorized',
    String? details = 'Please use a @diu.edu.bd or @daffodilvarsity.edu.bd email address',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when sign-in is cancelled
class SignInCancelledException extends AppException {
  SignInCancelledException({
    String message = 'Sign in was cancelled',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when credentials are invalid
class InvalidCredentialsException extends AppException {
  InvalidCredentialsException({
    String message = 'Invalid email or password',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when email is already in use
class EmailAlreadyInUseException extends AppException {
  EmailAlreadyInUseException({
    String message = 'This email is already registered',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when password is too weak
class WeakPasswordException extends AppException {
  WeakPasswordException({
    String message = 'Password is too weak',
    String? details = 'Use at least 6 characters with a mix of letters and numbers',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when access is denied
class AccessDeniedException extends AppException {
  AccessDeniedException({
    String message = 'Access denied',
    String? details = 'You do not have permission to perform this action',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when event operations fail
class EventException extends AppException {
  EventException({
    String message = 'Event operation failed',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when network request fails
class NetworkException extends AppException {
  NetworkException({
    String message = 'Network connection failed',
    String? details = 'Please check your internet connection and try again',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when server returns an error
class ServerException extends AppException {
  ServerException({
    String message = 'Server error',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when database operation fails
class DatabaseException extends AppException {
  DatabaseException({
    String message = 'Database operation failed',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when file upload fails
class FileUploadException extends AppException {
  FileUploadException({
    String message = 'File upload failed',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when validation fails
class ValidationException extends AppException {
  ValidationException({
    String message = 'Validation failed',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when an operation times out
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Operation timed out',
    String? details = 'The operation took too long. Please try again',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when user is not found
class UserNotFoundException extends AppException {
  UserNotFoundException({
    String message = 'User not found',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Thrown when resource is not found
class ResourceNotFoundException extends AppException {
  ResourceNotFoundException({
    String message = 'Resource not found',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Generic application exception
class GenericException extends AppException {
  GenericException({
    String message = 'An error occurred',
    String? details,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    details: details,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}
