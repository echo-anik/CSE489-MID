# Project Structure Documentation

This document provides a comprehensive overview of the Flutter project organization, file structure, and architectural patterns used in the Bangladesh Landmark Management App.

## Table of Contents

1. [Root Directory Structure](#root-directory-structure)
2. [Library Organization (lib/)](#library-organization-lib)
3. [Asset Management](#asset-management)
4. [Configuration Files](#configuration-files)
5. [Platform-Specific Directories](#platform-specific-directories)
6. [Testing Structure](#testing-structure)
7. [Key Files and Their Purposes](#key-files-and-their-purposes)
8. [Architectural Patterns](#architectural-patterns)
9. [Naming Conventions](#naming-conventions)

---

## Root Directory Structure

```
cse489-lab-mid/
├── android/                      # Android-specific configuration and code
├── ios/                          # iOS-specific configuration and code
├── lib/                          # Main Dart source code
├── assets/                       # Static assets (images, fonts, etc.)
├── test/                         # Unit and widget tests
├── integration_test/             # Integration tests
├── web/                          # Web-specific files (if web support enabled)
├── linux/                        # Linux desktop files (if enabled)
├── macos/                        # macOS files (if enabled)
├── windows/                      # Windows desktop files (if enabled)
├── .dart_tool/                   # Dart tooling files (generated)
├── .idea/                        # IDE configuration (Android Studio/IntelliJ)
├── .vscode/                      # VS Code configuration
├── build/                        # Build outputs (generated)
├── .gitignore                    # Git ignore rules
├── .metadata                     # Flutter project metadata
├── analysis_options.yaml         # Dart analyzer configuration
├── pubspec.yaml                  # Project dependencies and metadata
├── pubspec.lock                  # Locked dependency versions
├── README.md                     # Main documentation (this project overview)
├── FEATURES.md                   # Detailed feature descriptions
└── PROJECT_STRUCTURE.md          # This file
```

---

## Library Organization (lib/)

The `lib/` directory contains all Dart source code organized by feature and responsibility.

### Complete lib/ Structure

```
lib/
├── main.dart                     # Application entry point
│
├── app.dart                      # Root app widget with theme and routing
│
├── screens/                      # UI screens (pages)
│   ├── home_screen.dart          # Main screen with bottom navigation
│   ├── map_screen.dart           # Map view (Overview tab)
│   ├── list_screen.dart          # List view (Records tab)
│   ├── add_edit_screen.dart      # Add/Edit form (New Entry tab)
│   ├── landmark_detail_screen.dart # Full landmark details
│   ├── splash_screen.dart        # App launch screen
│   ├── settings_screen.dart      # App settings
│   └── auth/                     # Authentication screens
│       ├── login_screen.dart     # User login
│       ├── register_screen.dart  # User registration
│       └── forgot_password_screen.dart
│
├── models/                       # Data models and entities
│   ├── landmark.dart             # Landmark data model
│   ├── user.dart                 # User data model (bonus)
│   ├── api_response.dart         # Generic API response wrapper
│   ├── pending_action.dart       # Offline queue item (bonus)
│   └── map_theme.dart            # Map theme configuration
│
├── services/                     # Business logic and data services
│   ├── api_service.dart          # REST API communication
│   ├── database_service.dart     # Local SQLite database (bonus)
│   ├── location_service.dart     # GPS and location services
│   ├── image_service.dart        # Image handling and processing
│   ├── auth_service.dart         # Authentication (bonus)
│   ├── network_service.dart      # Network connectivity (bonus)
│   └── sync_service.dart         # Data synchronization (bonus)
│
├── providers/                    # State management (Provider pattern)
│   ├── landmark_provider.dart    # Landmark state management
│   ├── auth_provider.dart        # Authentication state (bonus)
│   ├── map_provider.dart         # Map state and camera control
│   └── theme_provider.dart       # App theme management
│
├── widgets/                      # Reusable UI components
│   ├── landmark_card.dart        # List item for landmarks
│   ├── landmark_bottom_sheet.dart # Map marker detail sheet
│   ├── custom_map_marker.dart    # Custom marker widget
│   ├── image_picker_widget.dart  # Image selection component
│   ├── loading_indicator.dart    # Loading spinner
│   ├── empty_state.dart          # Empty state placeholder
│   ├── error_widget.dart         # Error display component
│   ├── custom_text_field.dart    # Styled text input
│   ├── custom_button.dart        # Styled button
│   └── offline_banner.dart       # Offline mode indicator (bonus)
│
├── utils/                        # Utilities and helpers
│   ├── constants.dart            # App-wide constants
│   ├── validators.dart           # Input validation functions
│   ├── helpers.dart              # Helper functions
│   ├── extensions.dart           # Dart extensions
│   ├── image_utils.dart          # Image processing utilities
│   ├── date_utils.dart           # Date formatting utilities
│   └── map_styles.dart           # Map theme definitions
│
├── config/                       # Configuration
│   ├── app_config.dart           # App configuration
│   ├── api_config.dart           # API endpoints
│   ├── database_config.dart      # Database schema (bonus)
│   └── route_config.dart         # Navigation routes
│
└── core/                         # Core functionality
    ├── error/                    # Error handling
    │   ├── exceptions.dart       # Custom exceptions
    │   └── failures.dart         # Failure types
    ├── network/                  # Network layer
    │   └── http_client.dart      # HTTP client wrapper
    └── permissions/              # Permission handling
        └── permission_handler.dart
```

### Directory Purposes

#### screens/
Contains all full-page UI screens. Each screen is a StatefulWidget or StatelessWidget that represents a complete page in the app.

**Key Screens**:
- `home_screen.dart`: Container for bottom navigation and tab switching
- `map_screen.dart`: Google Maps/OpenStreetMap integration
- `list_screen.dart`: Scrollable landmark list with search
- `add_edit_screen.dart`: Form for creating/editing landmarks

#### models/
Data models representing business entities. These are plain Dart classes with:
- Properties matching API/database structure
- JSON serialization methods (toJson/fromJson)
- Equality and hashCode overrides
- Constructors and factory methods

**Example Structure** (`landmark.dart`):
```dart
class Landmark {
  final String id;
  final String title;
  final double lat;
  final double lon;
  final String image; // Base64 encoded

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.image,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'],
      title: json['title'],
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': image,
    };
  }
}
```

#### services/
Business logic and data access layer. Services handle:
- API communication
- Database operations
- Location services
- Image processing
- Authentication

**Service Responsibilities**:
- `api_service.dart`: HTTP requests to REST API
- `database_service.dart`: SQLite CRUD operations
- `location_service.dart`: GPS access and permissions
- `image_service.dart`: Image picking, resizing, encoding

#### providers/
State management using Provider pattern. Providers:
- Manage app state
- Notify listeners of changes
- Provide state to widgets
- Handle async operations

**Example Provider** (`landmark_provider.dart`):
```dart
class LandmarkProvider extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  List<Landmark> _landmarks = [];
  bool _isLoading = false;

  List<Landmark> get landmarks => _landmarks;
  bool get isLoading => _isLoading;

  Future<void> fetchLandmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _landmarks = await _apiService.getAllLandmarks();
      await _databaseService.saveAll(_landmarks);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addLandmark(Landmark landmark) async {
    await _apiService.createLandmark(landmark);
    _landmarks.add(landmark);
    notifyListeners();
  }
}
```

#### widgets/
Reusable UI components used across multiple screens. Keep widgets:
- Small and focused
- Configurable via parameters
- Stateless when possible
- Well-documented

#### utils/
Utility functions and constants. Includes:
- Validation functions
- Helper methods
- Extension methods
- Constants

**Example** (`validators.dart`):
```dart
class Validators {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Latitude is required';
    }
    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) {
      return 'Enter valid latitude (-90 to 90)';
    }
    return null;
  }
}
```

#### config/
Configuration files for app-wide settings:
- API endpoints
- Database schemas
- Route definitions
- App constants

---

## Asset Management

### assets/ Directory Structure

```
assets/
├── images/                       # Image assets
│   ├── logo.png                  # App logo
│   ├── placeholder.png           # Image placeholder
│   ├── empty_state.png           # Empty state illustration
│   └── markers/                  # Custom map markers
│       ├── default_marker.png
│       ├── selected_marker.png
│       └── cluster_marker.png
│
├── icons/                        # Custom icons
│   ├── app_icon.png              # Launcher icon
│   └── tab_icons/                # Bottom nav icons
│       ├── map_icon.png
│       ├── list_icon.png
│       └── add_icon.png
│
├── fonts/                        # Custom fonts (if any)
│   └── CustomFont-Regular.ttf
│
└── map_styles/                   # Map theme JSON files
    ├── standard.json
    ├── silver.json
    ├── night.json
    ├── retro.json
    └── minimal.json
```

### Asset Declaration in pubspec.yaml

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/images/markers/
    - assets/icons/
    - assets/map_styles/

  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

### Asset Usage in Code

```dart
// Image asset
Image.asset('assets/images/logo.png')

// Load map style
final style = await rootBundle.loadString('assets/map_styles/night.json');

// Custom font (automatically applied via theme)
Text('Hello', style: TextStyle(fontFamily: 'CustomFont'))
```

---

## Configuration Files

### pubspec.yaml

Main project configuration file defining dependencies, assets, and metadata.

```yaml
name: landmark_management_app
description: Bangladesh Landmark Management Application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=2.19.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.5

  # HTTP & Network
  http: ^1.1.0
  connectivity_plus: ^5.0.2

  # Maps & Location
  google_maps_flutter: ^2.5.0
  flutter_map: ^6.1.0  # OpenStreetMap alternative
  geolocator: ^10.1.0
  geocoding: ^2.1.1

  # Local Database (Bonus)
  sqflite: ^2.3.0
  path_provider: ^2.1.1

  # Image Handling
  image_picker: ^1.0.4
  image: ^4.1.3
  cached_network_image: ^3.3.0

  # Storage & Preferences
  shared_preferences: ^2.2.2

  # UI Components
  cupertino_icons: ^1.0.6
  flutter_spinkit: ^5.2.0

  # Utilities
  intl: ^0.18.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.6

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/map_styles/
```

### analysis_options.yaml

Dart analyzer configuration for code quality and linting.

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - unnecessary_this
    - avoid_print
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
    - prefer_const_declarations
    - unnecessary_null_in_if_null_operators

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
```

### .gitignore

```
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# VS Code related
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Android related
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Exceptions to above rules.
!**/ios/**/default.mode1v3
!**/ios/**/default.mode2v3
!**/ios/**/default.pbxuser
!**/ios/**/default.perspectivev3
```

---

## Platform-Specific Directories

### android/

Android platform configuration and native code.

```
android/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── AndroidManifest.xml    # App permissions and config
│   │   │   ├── kotlin/                # Native Kotlin code
│   │   │   └── res/                   # Android resources
│   │   │       ├── drawable/          # App icons
│   │   │       ├── mipmap-*/          # Launcher icons
│   │   │       └── values/            # Strings, colors
│   │   └── debug/                     # Debug configuration
│   └── build.gradle                   # App-level build config
├── gradle/                            # Gradle wrapper
├── build.gradle                       # Project-level build config
└── local.properties                   # Local SDK paths
```

**Key Files**:

`android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>

    <application
        android:label="Landmark Manager"
        android:icon="@mipmap/ic_launcher">

        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>

        <activity android:name=".MainActivity">
            <!-- Activity configuration -->
        </activity>
    </application>
</manifest>
```

`android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.landmark_app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
}
```

### ios/

iOS platform configuration and native code.

```
ios/
├── Runner/
│   ├── AppDelegate.swift             # App lifecycle
│   ├── Info.plist                    # App configuration
│   ├── Assets.xcassets/              # App icons and images
│   └── Runner-Bridging-Header.h      # Objective-C bridge
├── Runner.xcodeproj/                 # Xcode project
├── Runner.xcworkspace/               # Xcode workspace
├── Podfile                           # CocoaPods dependencies
└── Podfile.lock                      # Locked pod versions
```

**Key Files**:

`ios/Runner/Info.plist`:
```xml
<dict>
    <key>CFBundleName</key>
    <string>Landmark Manager</string>

    <!-- Privacy Descriptions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to show nearby landmarks</string>

    <key>NSCameraUsageDescription</key>
    <string>We need camera access to take landmark photos</string>

    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access to select images</string>
</dict>
```

`ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
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

---

## Testing Structure

### test/ Directory

```
test/
├── models/
│   ├── landmark_test.dart
│   └── user_test.dart
├── services/
│   ├── api_service_test.dart
│   ├── database_service_test.dart
│   └── location_service_test.dart
├── providers/
│   └── landmark_provider_test.dart
├── widgets/
│   ├── landmark_card_test.dart
│   └── bottom_sheet_test.dart
├── utils/
│   └── validators_test.dart
└── mocks/
    ├── mock_api_service.dart
    └── mock_database_service.dart
```

**Example Test** (`test/models/landmark_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:landmark_app/models/landmark.dart';

void main() {
  group('Landmark Model', () {
    test('should create landmark from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Landmark',
        'lat': 23.8103,
        'lon': 90.4125,
        'image': 'base64string',
      };

      final landmark = Landmark.fromJson(json);

      expect(landmark.id, '1');
      expect(landmark.title, 'Test Landmark');
      expect(landmark.lat, 23.8103);
    });

    test('should convert landmark to JSON', () {
      final landmark = Landmark(
        id: '1',
        title: 'Test',
        lat: 23.8103,
        lon: 90.4125,
        image: 'base64',
      );

      final json = landmark.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test');
    });
  });
}
```

---

## Key Files and Their Purposes

### main.dart

Application entry point. Sets up:
- Material App
- Theme configuration
- State management providers
- Initial route

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/landmark_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandmarkProvider()),
        // Add other providers
      ],
      child: MaterialApp(
        title: 'Landmark Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

### constants.dart

App-wide constants.

```dart
class AppConstants {
  // API
  static const String apiBaseUrl = 'https://labs.anontech.info/cse489/t3/api.php';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Images
  static const int imageWidth = 800;
  static const int imageHeight = 600;
  static const int imageQuality = 85;

  // Database
  static const String databaseName = 'landmarks.db';
  static const int databaseVersion = 1;

  // Map
  static const double defaultZoom = 12.0;
  static const double defaultLatitude = 23.8103; // Dhaka
  static const double defaultLongitude = 90.4125;

  // Validation
  static const int titleMaxLength = 100;
  static const int passwordMinLength = 8;
}
```

---

## Architectural Patterns

### 1. Clean Architecture Layers

```
Presentation Layer (UI)
    ↓
Business Logic Layer (Providers)
    ↓
Data Layer (Services)
    ↓
External Layer (API/Database)
```

### 2. State Management

**Provider Pattern**:
- ChangeNotifier for state
- Consumer widgets for listening
- Provider for dependency injection

### 3. Dependency Injection

Services injected via Provider:
```dart
final apiService = Provider.of<ApiService>(context, listen: false);
```

### 4. Repository Pattern

Abstraction for data sources:
```dart
abstract class LandmarkRepository {
  Future<List<Landmark>> getAll();
  Future<Landmark> getById(String id);
  Future<void> create(Landmark landmark);
  Future<void> update(Landmark landmark);
  Future<void> delete(String id);
}
```

---

## Naming Conventions

### Files
- **Screens**: `*_screen.dart` (e.g., `home_screen.dart`)
- **Widgets**: `*_widget.dart` or descriptive name (e.g., `landmark_card.dart`)
- **Services**: `*_service.dart` (e.g., `api_service.dart`)
- **Models**: Singular noun (e.g., `landmark.dart`)
- **Providers**: `*_provider.dart` (e.g., `landmark_provider.dart`)
- **Utils**: Descriptive (e.g., `validators.dart`, `helpers.dart`)

### Classes
- **PascalCase**: `LandmarkCard`, `ApiService`
- **Descriptive**: Name reflects purpose

### Variables
- **camelCase**: `landmarkList`, `isLoading`
- **Private**: `_privateVariable` (underscore prefix)

### Constants
- **lowerCamelCase**: `apiBaseUrl`, `defaultZoom`
- **Static const**: For compile-time constants

### Functions
- **camelCase**: `fetchLandmarks()`, `showDialog()`
- **Verbs**: Action-oriented names

---

## Best Practices

### File Organization
1. Group related files in directories
2. Keep files small and focused (< 300 lines ideal)
3. Use barrel files (index.dart) for clean imports
4. Separate UI from logic

### Code Organization
1. Imports at top (dart: → package: → relative)
2. Constants before class
3. Constructor first
4. Public methods before private
5. Build method last in widgets

### Import Organization
```dart
// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Relative imports
import '../models/landmark.dart';
import '../services/api_service.dart';
```

---

## Development Workflow

### Adding a New Feature

1. **Create Model** (if needed): `lib/models/feature.dart`
2. **Create Service**: `lib/services/feature_service.dart`
3. **Create Provider**: `lib/providers/feature_provider.dart`
4. **Create Screen**: `lib/screens/feature_screen.dart`
5. **Create Widgets**: `lib/widgets/feature_widget.dart`
6. **Add Tests**: `test/feature_test.dart`
7. **Update Routes**: `lib/config/route_config.dart`

### Code Review Checklist

- [ ] Follows naming conventions
- [ ] Proper file organization
- [ ] No hardcoded values (use constants)
- [ ] Error handling implemented
- [ ] Comments for complex logic
- [ ] No unused imports
- [ ] Widgets properly disposed
- [ ] Tests written
- [ ] Documentation updated

---

## Troubleshooting

### Common Issues

**Issue**: "Cannot find file" errors
- **Solution**: Check import paths, use absolute imports from lib/

**Issue**: Provider not found
- **Solution**: Ensure provider is declared in main.dart above consumer

**Issue**: Asset not found
- **Solution**: Verify asset path in pubspec.yaml and run `flutter pub get`

**Issue**: Build errors after adding dependency
- **Solution**: Run `flutter clean && flutter pub get`

---

**Last Updated**: December 2025

**Project Version**: 1.0.0

**Flutter Version**: 3.0+

**Maintainer**: CSE489 Development Team