import 'package:flutter/material.dart';

/// Reusable loading indicator widget
///
/// Displays a centered circular progress indicator with customizable color and size
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.color,
    this.size,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Show a loading overlay dialog
  static void showDialog(BuildContext context, {String? message}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Material(
            color: Colors.transparent,
            child: LoadingIndicator(
              color: Colors.white,
              size: 50,
              message: message,
            ),
          ),
        );
      },
    );
  }

  /// Hide the loading overlay dialog
  static void hideDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
