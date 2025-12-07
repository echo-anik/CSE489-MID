# Bangladesh Landmark Management App

A comprehensive Flutter application for managing and exploring landmarks across Bangladesh with interactive map visualization, real-time data synchronization, and offline capabilities.

## Overview

This mobile application allows users to discover, add, edit, and manage landmarks throughout Bangladesh. Built with Flutter, it provides a seamless cross-platform experience with an intuitive interface featuring interactive maps, detailed listings, and easy landmark management.

## Features

### Core Features

- **Interactive Map View**
  - Google Maps or OpenStreetMap integration
  - Custom markers for each landmark
  - Real-time location updates
  - Tap-to-view landmark details in bottom sheets
  - Custom map themes and styling
  - Zoom and pan controls

- **Comprehensive List View**
  - Scrollable list of all landmarks
  - Swipe-to-delete functionality
  - Quick edit access
  - Search and filter capabilities
  - Pull-to-refresh for data synchronization

- **Landmark Management**
  - Add new landmarks with detailed information
  - Edit existing landmark details
  - Delete landmarks with confirmation
  - Image upload and management
  - GPS auto-detection for location capture

- **Bottom Navigation**
  - Overview Tab: Interactive map view
  - Records Tab: Comprehensive list view
  - New Entry Tab: Quick landmark addition form

- **Image Handling**
  - Camera and gallery integration
  - Automatic image resizing (800x600)
  - Base64 encoding for API transmission
  - Image preview and validation

- **Error Handling**
  - User-friendly snackbar notifications
  - Confirmation dialogs for destructive actions
  - Network error handling
  - Input validation and feedback

### Bonus Features

- **Offline Caching**
  - Local database storage using SQLite
  - Automatic data synchronization
  - Offline mode support
  - Cache management and updates

- **User Authentication**
  - Secure login system
  - User registration
  - Session management
  - Protected API endpoints

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile framework (SDK 3.0+)
- **Dart**: Programming language (2.19+)

### Backend & API
- **REST API**: https://labs.anontech.info/cse489/t3/api.php
- **HTTP Package**: Network requests and API communication

### Maps & Location
- **Google Maps Flutter**: Interactive map integration
- **OpenStreetMap**: Alternative map provider
- **Geolocator**: GPS and location services

### Data Management
- **SQLite**: Local database storage
- **Sqflite**: Flutter SQLite plugin
- **Shared Preferences**: App settings and cache

### Additional Packages
- **image_picker**: Camera and gallery access
- **image**: Image processing and resizing
- **provider**: State management
- **cached_network_image**: Efficient image loading

## Prerequisites

Before running this application, ensure you have the following installed:

### Required Software
1. **Flutter SDK** (version 3.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install

2. **Dart SDK** (version 2.19 or higher)
   - Included with Flutter SDK

3. **IDE** (Choose one)
   - Android Studio (recommended)
   - Visual Studio Code with Flutter extensions
   - IntelliJ IDEA

4. **Platform-Specific Requirements**
   - **For Android:**
     - Android Studio
     - Android SDK (API level 21 or higher)
     - Android Emulator or physical device

   - **For iOS:**
     - Xcode (macOS only)
     - iOS Simulator or physical device
     - CocoaPods

### Optional Tools
- Git (for version control)
- Chrome/Edge (for web debugging)
- Flutter DevTools

## Installation and Setup

### 1. Clone or Download the Project

```bash
# If using Git
git clone <repository-url>
cd cse489-lab-mid

# Or download and extract the ZIP file
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure API Endpoint

The API endpoint is pre-configured in the project. If you need to modify it, update the API base URL in:

```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';
```

### 4. Configure Google Maps (if using Google Maps)

#### Android Configuration
1. Open `android/app/src/main/AndroidManifest.xml`
2. Add your Google Maps API key:

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
    </application>
</manifest>
```

#### iOS Configuration
1. Open `ios/Runner/AppDelegate.swift`
2. Add your Google Maps API key:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 5. Build and Run

#### Check Flutter Installation
```bash
flutter doctor
```

#### Run on Connected Device/Emulator
```bash
# List available devices
flutter devices

# Run the app
flutter run

# Run in release mode (optimized)
flutter run --release
```

#### Build APK (Android)
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by architecture (smaller size)
flutter build apk --split-per-abi
```

#### Build App Bundle (Android - for Play Store)
```bash
flutter build appbundle
```

#### Build iOS App
```bash
flutter build ios
```

## Project Structure

```
cse489-lab-mid/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Main screen with bottom navigation
│   │   ├── map_screen.dart       # Map view (Overview tab)
│   │   ├── list_screen.dart      # List view (Records tab)
│   │   ├── add_edit_screen.dart  # Add/Edit form (New Entry tab)
│   │   └── auth/                 # Authentication screens
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── models/                   # Data models
│   │   ├── landmark.dart         # Landmark model
│   │   └── user.dart             # User model (bonus)
│   ├── services/                 # Business logic
│   │   ├── api_service.dart      # REST API communication
│   │   ├── database_service.dart # Local database (SQLite)
│   │   ├── location_service.dart # GPS and location
│   │   ├── image_service.dart    # Image handling
│   │   └── auth_service.dart     # Authentication (bonus)
│   ├── widgets/                  # Reusable UI components
│   │   ├── landmark_card.dart    # List item widget
│   │   ├── map_marker.dart       # Custom map marker
│   │   ├── bottom_sheet.dart     # Landmark detail sheet
│   │   └── loading_indicator.dart
│   ├── utils/                    # Utilities and helpers
│   │   ├── constants.dart        # App constants
│   │   ├── validators.dart       # Input validation
│   │   └── helpers.dart          # Helper functions
│   └── providers/                # State management
│       ├── landmark_provider.dart
│       └── auth_provider.dart
├── assets/                       # Static assets
│   ├── images/                   # App images
│   ├── icons/                    # Custom icons
│   └── map_styles/               # Custom map themes (JSON)
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
├── test/                         # Unit and widget tests
├── pubspec.yaml                  # Dependencies and assets
└── README.md                     # This file
```

## API Configuration

### Base URL
```
https://labs.anontech.info/cse489/t3/api.php
```

### Landmark Data Model
Each landmark contains the following fields:

| Field   | Type   | Description                           |
|---------|--------|---------------------------------------|
| id      | String | Unique identifier (auto-generated)    |
| title   | String | Landmark name/title                   |
| lat     | Double | Latitude coordinate                   |
| lon     | Double | Longitude coordinate                  |
| image   | String | Base64-encoded image (800x600)        |

### API Endpoints (Examples)

- **GET**: Fetch all landmarks
- **POST**: Create new landmark
- **PUT**: Update existing landmark
- **DELETE**: Remove landmark

*Note: Refer to API documentation for specific endpoint parameters and request formats.*

## Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/landmark_test.dart
```

## Known Limitations

1. **Image Size**: Images are automatically resized to 800x600 pixels to optimize storage and transmission
2. **Network Dependency**: Core features require internet connectivity (offline mode available with bonus feature)
3. **API Rate Limits**: The REST API may have rate limiting (check API documentation)
4. **Platform Differences**: Some UI elements may appear differently on Android vs iOS
5. **Location Permissions**: Users must grant location permissions for GPS features
6. **Map Provider**: Google Maps requires API key and has usage quotas

## Troubleshooting

### Common Issues

**Issue**: Flutter command not found
```bash
# Solution: Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

**Issue**: Dependencies not installing
```bash
# Solution: Clean and reinstall
flutter clean
flutter pub get
```

**Issue**: Build errors on Android
```bash
# Solution: Clean Android build
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

**Issue**: iOS build errors
```bash
# Solution: Update CocoaPods
cd ios
pod install --repo-update
cd ..
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## License

This project is developed as part of the CSE489 course assignment. All rights reserved.

## Credits

### Development Team
- Developed for CSE489 Lab Mid Assignment
- Institution: [Your University Name]
- Semester: [Current Semester]

### Third-Party Services
- **API Provider**: AnonTech Labs (https://labs.anontech.info)
- **Map Services**: Google Maps Platform / OpenStreetMap
- **Flutter Framework**: Google LLC

### Dependencies
This project uses various open-source packages. See `pubspec.yaml` for a complete list.

## Contact

For questions, issues, or feedback:
- Course: CSE489
- Assignment: Lab Mid - Flutter Landmark Management App
- Instructor: [Instructor Name]

---

**Last Updated**: December 2025

**Version**: 1.0.0

**Flutter SDK**: 3.0+

**Dart SDK**: 2.19+
