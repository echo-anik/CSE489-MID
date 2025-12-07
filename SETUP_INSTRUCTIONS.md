# Bangladesh Landmarks - Setup Instructions

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (API level 21 or higher)
- **Git** for version control
- **Java JDK** 8 or higher

## Step-by-Step Setup Guide

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd "CSE489 LAB MID"
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will download all the packages specified in `pubspec.yaml`.

### 3. Generate Floor Database Code

The app uses Floor for local database (offline caching). You need to generate the database code:

```bash
flutter packages pub run build_runner build
```

This command generates the following files:
- `lib/database/app_database.g.dart` (Floor database implementation)

If you encounter any issues or want to rebuild from scratch:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Note:** Every time you modify the database entities, DAOs, or the AppDatabase class, you must run this command again.

### 4. Configure Google Maps API Key

#### For Android:

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Geocoding API (optional, for address lookup)

3. Add your API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

Replace `YOUR_ACTUAL_API_KEY_HERE` with your actual Google Maps API key.

**Alternative: Use OpenStreetMap**

If you prefer not to use Google Maps, you can switch to OpenStreetMap by:
1. Removing `google_maps_flutter` dependency from `pubspec.yaml`
2. Adding `flutter_map` package instead
3. Modifying the MapScreen to use FlutterMap widget

### 5. Run the App

#### On Android Emulator:

```bash
flutter run
```

#### On Physical Device:

1. Enable Developer Options and USB Debugging on your Android device
2. Connect via USB
3. Run: `flutter run`

#### Check for Connected Devices:

```bash
flutter devices
```

### 6. Build APK for Testing

To create an APK file for testing:

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### 7. Build App Bundle for Production

For production release on Google Play Store:

```bash
flutter build appbundle --release
```

## Project Configuration

### API Configuration

The app connects to the REST API at:
```
https://labs.anontech.info/cse489/t3/api.php
```

This is configured in `lib/constants/app_constants.dart`. No additional configuration needed.

### Database Configuration

- **Database Name:** `landmarks.db`
- **Location:** App's local storage directory
- **Tables:** Landmarks (for offline caching)

The database is automatically created on first run.

## Development Workflow

### Running in Debug Mode

```bash
flutter run
```

Press `r` to hot reload, `R` to hot restart, `q` to quit.

### Checking for Issues

```bash
flutter doctor
```

This command checks your environment and displays a report of the status.

### Code Analysis

```bash
flutter analyze
```

This runs the Dart analyzer to check for issues.

### Running Tests

```bash
flutter test
```

## Common Issues and Solutions

### Issue 1: Build Runner Fails

**Error:** "Conflicting outputs"

**Solution:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Issue 2: Google Maps Not Showing

**Causes:**
- API key not configured
- API key not enabled for Maps SDK for Android
- Wrong API key restrictions

**Solution:**
1. Verify API key in AndroidManifest.xml
2. Check Google Cloud Console for API restrictions
3. Ensure "Maps SDK for Android" is enabled

### Issue 3: Permission Denied for Location/Camera

**Solution:**
- Go to Android Settings > Apps > Bangladesh Landmarks > Permissions
- Enable Location and Camera permissions
- Or uninstall and reinstall the app to trigger permission requests

### Issue 4: Internet Connection Issues

**Solution:**
- Ensure device/emulator has internet connection
- For Android emulator, check that it can access the internet
- Check if API endpoint is accessible: `https://labs.anontech.info/cse489/t3/api.php`

### Issue 5: Image Upload Fails

**Possible causes:**
- Image too large (limit: 5MB)
- Network timeout
- Server error

**Solution:**
- Images are automatically resized to 800x600
- Check network connection
- Verify API endpoint is working using Postman

## Development Features

### Hot Reload

While running in debug mode, press `r` to hot reload changes without losing app state.

### Debug Console

Use `print()` or `debugPrint()` statements for logging. View output in your IDE's debug console.

### Flutter DevTools

For advanced debugging:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then run your app and click on the URL provided.

## Project Structure Reference

```
lib/
├── constants/          # App constants and configuration
├── database/          # Floor database setup
│   ├── entities/      # Database entities
│   └── daos/         # Data Access Objects
├── models/           # Data models
├── providers/        # State management (Provider)
├── screens/          # UI screens
├── services/         # API and business logic services
├── utils/            # Utility functions
└── widgets/          # Reusable UI components
```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Floor Package Documentation](https://pub.dev/packages/floor)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Provider State Management](https://pub.dev/packages/provider)

## Support

For issues or questions:
1. Check the documentation files in this project
2. Review CHALLENGES_SOLUTIONS.md for common problems
3. Consult the Flutter community: [flutter.dev/community](https://flutter.dev/community)

---

**Last Updated:** December 2025
