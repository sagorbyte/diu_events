import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/exceptions/app_exceptions.dart';

/// Centralized error handling utility
/// Converts raw exceptions into user-friendly AppException classes
class ErrorHandler {
  /// Handle Firebase Auth exceptions
  static AppException handleAuthException(dynamic exception, StackTrace? stackTrace) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
          return UserNotFoundException(
            message: 'No account found with this email',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'wrong-password':
          return InvalidCredentialsException(
            message: 'Incorrect password',
            details: 'Please check your password and try again',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'email-already-in-use':
          return EmailAlreadyInUseException(
            message: 'This email is already registered',
            details: 'Try logging in instead or use a different email',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'weak-password':
          return WeakPasswordException(
            message: 'Password is too weak',
            details: 'Use at least 6 characters with a mix of letters and numbers',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'invalid-email':
          return ValidationException(
            message: 'Invalid email address',
            details: 'Please enter a valid email address',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'operation-not-allowed':
          return AccessDeniedException(
            message: 'This operation is not allowed',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'user-disabled':
          return AccessDeniedException(
            message: 'This account has been disabled',
            details: 'Please contact support for assistance',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'requires-recent-login':
          return AuthenticationException(
            message: 'Please log out and log back in',
            details: 'For security reasons, this action requires a fresh login',
            originalException: exception,
            stackTrace: stackTrace,
          );
        default:
          return AuthenticationException(
            message: exception.message ?? 'Authentication failed',
            details: 'Error code: ${exception.code}',
            originalException: exception,
            stackTrace: stackTrace,
          );
      }
    } else if (exception is AppException) {
      return exception;
    } else {
      return AuthenticationException(
        message: 'Authentication failed',
        details: 'An unexpected error occurred',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle Firestore exceptions
  static AppException handleFirestoreException(dynamic exception, StackTrace? stackTrace) {
    if (exception is FirebaseException) {
      switch (exception.code) {
        case 'permission-denied':
          return AccessDeniedException(
            message: 'You do not have permission to access this resource',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'not-found':
          return ResourceNotFoundException(
            message: 'The requested resource was not found',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'already-exists':
          return DatabaseException(
            message: 'This resource already exists',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'unavailable':
          return NetworkException(
            message: 'Service temporarily unavailable',
            details: 'Please try again in a moment',
            originalException: exception,
            stackTrace: stackTrace,
          );
        case 'deadline-exceeded':
          return TimeoutException(
            message: 'Request took too long',
            details: 'Please check your connection and try again',
            originalException: exception,
            stackTrace: stackTrace,
          );
        default:
          return DatabaseException(
            message: exception.message ?? 'Database operation failed',
            details: 'Error code: ${exception.code}',
            originalException: exception,
            stackTrace: stackTrace,
          );
      }
    } else if (exception is AppException) {
      return exception;
    } else {
      return DatabaseException(
        message: 'Database operation failed',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle general exceptions
  static AppException handleException(dynamic exception, StackTrace? stackTrace, {String? defaultMessage}) {
    // If already an AppException, return it
    if (exception is AppException) {
      return exception;
    }

    // If it's a Firebase Auth exception, delegate to auth handler
    if (exception is FirebaseAuthException) {
      return handleAuthException(exception, stackTrace);
    }

    // If it's a Firebase exception, delegate to Firestore handler
    if (exception is FirebaseException) {
      return handleFirestoreException(exception, stackTrace);
    }

    // Handle timeout
    if (exception is TimeoutException) {
      return TimeoutException(
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    // Handle custom exceptions
    if (exception is Exception) {
      final message = exception.toString();
      
      // Check for common patterns in exception messages
      if (message.contains('Network') || message.contains('Connection')) {
        return NetworkException(
          originalException: exception,
          stackTrace: stackTrace,
        );
      }
      if (message.contains('Timeout')) {
        return TimeoutException(
          originalException: exception,
          stackTrace: stackTrace,
        );
      }
      if (message.contains('Permission') || message.contains('Access')) {
        return AccessDeniedException(
          message: message,
          originalException: exception,
          stackTrace: stackTrace,
        );
      }
      if (message.contains('Domain') || message.contains('email')) {
        return UnauthorizedDomainException(
          message: message,
          originalException: exception,
          stackTrace: stackTrace,
        );
      }
      if (message.contains('not found') || message.contains('Not found')) {
        return ResourceNotFoundException(
          message: message,
          originalException: exception,
          stackTrace: stackTrace,
        );
      }
      if (message.contains('cancelled') || message.contains('Cancelled')) {
        return SignInCancelledException(
          message: message,
          originalException: exception,
          stackTrace: stackTrace,
        );
      }

      return GenericException(
        message: defaultMessage ?? message,
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    // Fallback for unknown exception types
    return GenericException(
      message: defaultMessage ?? 'An unexpected error occurred',
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Log exception details for debugging
  static void logException(AppException exception) {
    // In production, you might want to send this to a logging service
    print('❌ ${exception.getLogMessage()}');
  }

  /// Log with stacktrace
  static void logWithStackTrace(AppException exception, StackTrace? stackTrace) {
    print('❌ ${exception.getLogMessage()}');
    if (stackTrace != null) {
      print('Stack trace:\n$stackTrace');
    }
  }
}

/// Extension on AppException for convenient error handling
extension ExceptionExtension on Exception {
  AppException toAppException({StackTrace? stackTrace}) {
    return ErrorHandler.handleException(this, stackTrace);
  }
}
