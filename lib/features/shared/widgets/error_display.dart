import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Reusable error display widget for showing user-friendly error messages
class ErrorDisplay extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDisplay({
    super.key,
    required this.exception,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFEEBEE), // Light red background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFFE53935), // Red border
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with error icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error',
                  style: GoogleFonts.hindSiliguriTextTheme(
                    TextTheme(
                      titleMedium: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).titleMedium,
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Main error message
          Text(
            exception.getUserMessage(),
            style: GoogleFonts.hindSiliguriTextTheme(
              TextTheme(
                bodyMedium: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).bodyMedium,
          ),
          // Additional details if available
          if (exception.details != null) ...[
            const SizedBox(height: 8),
            Text(
              exception.details!,
              style: GoogleFonts.hindSiliguriTextTheme(
                TextTheme(
                  bodySmall: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ).bodySmall,
            ),
          ],
          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline error message widget (more compact than ErrorDisplay)
class ErrorMessage extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onDismiss;

  const ErrorMessage({
    super.key,
    required this.exception,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFEEBEE),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: Color(0xFFE53935),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE53935),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exception.getUserMessage(),
              style: GoogleFonts.hindSiliguriTextTheme(
                TextTheme(
                  bodySmall: TextStyle(
                    color: Color(0xFFE53935),
                  ),
                ),
              ).bodySmall,
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: Color(0xFFE53935),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar error display
void showErrorSnackbar(BuildContext context, AppException exception) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        exception.getUserMessage(),
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Dialog error display
void showErrorDialog(
  BuildContext context,
  AppException exception, {
  VoidCallback? onRetry,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Color(0xFFE53935),
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Error',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exception.getUserMessage()),
          if (exception.details != null) ...[
            const SizedBox(height: 8),
            Text(
              exception.details!,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: Text(
              'Retry',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Dismiss',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    ),
  );
}
