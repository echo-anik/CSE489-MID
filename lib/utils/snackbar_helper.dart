import 'package:flutter/material.dart';

/// Utility class for displaying snackbars
///
/// Provides methods for showing success, error, and info messages
class SnackbarHelper {
  /// Show a success snackbar
  ///
  /// [context] BuildContext for showing the snackbar
  /// [message] Success message to display
  /// [duration] Duration to show the snackbar (default: 3 seconds)
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Show an error snackbar
  ///
  /// [context] BuildContext for showing the snackbar
  /// [message] Error message to display
  /// [duration] Duration to show the snackbar (default: 4 seconds)
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Show an info snackbar
  ///
  /// [context] BuildContext for showing the snackbar
  /// [message] Info message to display
  /// [duration] Duration to show the snackbar (default: 3 seconds)
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Show a warning snackbar
  ///
  /// [context] BuildContext for showing the snackbar
  /// [message] Warning message to display
  /// [duration] Duration to show the snackbar (default: 3 seconds)
  static void showWarningSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.warning,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Show a custom snackbar
  ///
  /// [context] BuildContext for showing the snackbar
  /// [message] Message to display
  /// [icon] Icon to show (optional)
  /// [backgroundColor] Background color (default: grey)
  /// [duration] Duration to show the snackbar (default: 3 seconds)
  static void showCustomSnackbar(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor ?? Colors.grey[800]!,
      duration: duration,
    );
  }

  /// Internal method to show snackbar
  static void _showSnackbar(
    BuildContext context, {
    required String message,
    IconData? icon,
    required Color backgroundColor,
    required Duration duration,
  }) {
    // Hide any existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Hide current snackbar
  static void hideSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
