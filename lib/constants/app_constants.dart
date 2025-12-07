import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // API Endpoints - All operations use the same endpoint
  static const String landmarksEndpoint = ''; // Using base URL directly

  // Default Bangladesh Coordinates (Dhaka)
  static const double defaultLatitude = 23.6850;
  static const double defaultLongitude = 90.3563;
  static const double defaultZoom = 6.0;
  static const double detailZoom = 15.0;

  // Image Configuration
  static const int imageMaxWidth = 800;
  static const int imageMaxHeight = 600;
  static const int imageQuality = 85;
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 225;

  // File Size Limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // App Colors - Light Theme
  static const Color primaryColor = Color(0xFF006A4E); // Bangladesh green
  static const Color accentColor = Color(0xFFF42A41); // Bangladesh red
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // App Colors - Dark Theme
  static const Color darkPrimaryColor = Color(0xFF004D38);
  static const Color darkAccentColor = Color(0xFFFF4458);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFFB0B0B0);

  // Map Configuration
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const double mapPadding = 50.0;
  static const double markerSize = 48.0;

  // Database Configuration
  static const String databaseName = 'landmarks.db';
  static const int databaseVersion = 1;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // SharedPreferences Keys
  static const String themeModeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync';
  static const String userLocationKey = 'user_location';
  static const String showTutorialKey = 'show_tutorial';

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String noDataMessage = 'No landmarks found.';
  static const String permissionDeniedMessage = 'Permission denied. Please enable in settings.';
  static const String imagePickErrorMessage = 'Failed to pick image.';
  static const String locationErrorMessage = 'Failed to get location.';

  // Success Messages
  static const String landmarkAddedMessage = 'Landmark added successfully!';
  static const String landmarkUpdatedMessage = 'Landmark updated successfully!';
  static const String landmarkDeletedMessage = 'Landmark deleted successfully!';

  // Validation
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int itemsPerPage = 20;
  static const int initialPage = 1;

  // Landmark Categories
  static const List<String> landmarkCategories = [
    'Historical',
    'Religious',
    'Natural',
    'Modern',
    'Cultural',
    'Educational',
    'Recreational',
    'Other',
  ];

  // Map Styles (for custom map styling)
  static const String mapStyleLight = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';

  static const String mapStyleDark = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    }
  ]
  ''';

  // App Info
  static const String appName = 'Bangladesh Landmarks';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Discover and explore landmarks across Bangladesh';

  // Utility Methods
  static String getApiBaseUrl() {
    // You can add logic here to determine which URL to use based on environment
    return apiBaseUrl;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? primaryColor
        : darkPrimaryColor;
  }

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? accentColor
        : darkAccentColor;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundColor
        : darkBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? cardColor
        : darkCardColor;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textPrimaryColor
        : darkTextPrimaryColor;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textSecondaryColor
        : darkTextSecondaryColor;
  }
}
