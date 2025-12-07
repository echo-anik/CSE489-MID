import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling app permissions
///
/// Provides methods for requesting and checking various permissions
class PermissionsHelper {
  /// Request location permission
  ///
  /// Returns true if permission granted, false otherwise
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Open app settings if permission permanently denied
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  ///
  /// Returns true if granted, false otherwise
  static Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  /// Request camera permission
  ///
  /// Returns true if permission granted, false otherwise
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Check if camera permission is granted
  ///
  /// Returns true if granted, false otherwise
  static Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  /// Request storage permission
  ///
  /// Returns true if permission granted, false otherwise
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check if storage permission is granted
  ///
  /// Returns true if granted, false otherwise
  static Future<bool> checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }

  /// Request photos permission (for Android 13+)
  ///
  /// Returns true if permission granted, false otherwise
  static Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        return true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      print('Error requesting photos permission: $e');
      return false;
    }
  }

  /// Check if photos permission is granted
  ///
  /// Returns true if granted, false otherwise
  static Future<bool> checkPhotosPermission() async {
    try {
      final status = await Permission.photos.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      print('Error checking photos permission: $e');
      return false;
    }
  }

  /// Request all necessary permissions for the app
  ///
  /// Returns a map of permission results
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    try {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ].request();

      return statuses;
    } catch (e) {
      print('Error requesting all permissions: $e');
      return {};
    }
  }

  /// Check if all necessary permissions are granted
  ///
  /// Returns true if all granted, false otherwise
  static Future<bool> checkAllPermissions() async {
    try {
      final location = await checkLocationPermission();
      final camera = await checkCameraPermission();
      final storage = await checkStoragePermission();

      return location && camera && storage;
    } catch (e) {
      print('Error checking all permissions: $e');
      return false;
    }
  }

  /// Open app settings for manual permission management
  static Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  /// Get permission status message for UI display
  ///
  /// [permission] The permission to check
  ///
  /// Returns a user-friendly message
  static Future<String> getPermissionStatusMessage(Permission permission) async {
    try {
      final status = await permission.status;

      if (status.isGranted) {
        return 'Permission granted';
      } else if (status.isDenied) {
        return 'Permission denied. Please grant permission to continue.';
      } else if (status.isPermanentlyDenied) {
        return 'Permission permanently denied. Please enable it in app settings.';
      } else if (status.isRestricted) {
        return 'Permission restricted by system.';
      } else if (status.isLimited) {
        return 'Limited permission granted.';
      }

      return 'Permission status unknown';
    } catch (e) {
      print('Error getting permission status message: $e');
      return 'Error checking permission';
    }
  }

  /// Request permission with custom handling
  ///
  /// [permission] The permission to request
  /// [onGranted] Callback when permission is granted
  /// [onDenied] Callback when permission is denied
  /// [onPermanentlyDenied] Callback when permission is permanently denied
  static Future<void> requestPermissionWithHandler(
    Permission permission, {
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    try {
      final status = await permission.request();

      if (status.isGranted) {
        onGranted?.call();
      } else if (status.isPermanentlyDenied) {
        onPermanentlyDenied?.call();
      } else {
        onDenied?.call();
      }
    } catch (e) {
      print('Error requesting permission with handler: $e');
      onDenied?.call();
    }
  }
}
