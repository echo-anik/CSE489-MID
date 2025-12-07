import 'package:geolocator/geolocator.dart';

/// Service for handling location and GPS operations
///
/// This service manages location permissions, retrieves the current position,
/// and provides utilities for working with geolocation data.
class LocationService {
  // Singleton pattern implementation
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  LocationService._internal();

  /// Default location settings for high accuracy
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Minimum distance (meters) before update
  );

  /// Gets the current device position
  ///
  /// This method handles permission requests and returns the current GPS position.
  /// Returns null if permission is denied or location services are disabled.
  ///
  /// Example:
  /// ```dart
  /// final position = await LocationService().getCurrentPosition();
  /// if (position != null) {
  ///   print('Lat: ${position.latitude}, Lon: ${position.longitude}');
  /// }
  /// ```
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        throw LocationServiceException(
          'Location services are disabled. Please enable them in your device settings.',
        );
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          throw LocationServiceException(
            'Location permission denied. Please grant location access to use this feature.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        print('Location permission denied forever');
        throw LocationServiceException(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } on LocationServiceException {
      rethrow;
    } catch (e) {
      print('Error getting current position: $e');
      throw LocationServiceException('Failed to get location: $e');
    }
  }

  /// Checks if location services are enabled on the device
  ///
  /// Returns true if enabled, false otherwise.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  /// Checks the current location permission status
  ///
  /// Returns the current [LocationPermission] status.
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      print('Error checking permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Requests location permission from the user
  ///
  /// Returns the permission status after the request.
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      print('Error requesting permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Opens the device's location settings
  ///
  /// Returns true if the settings were opened successfully.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
      return false;
    }
  }

  /// Opens the app's settings page
  ///
  /// Returns true if the settings were opened successfully.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      return false;
    }
  }

  /// Gets the last known position (cached)
  ///
  /// This is faster than [getCurrentPosition] but may return stale data.
  /// Returns null if no cached position is available.
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  /// Calculates the distance between two positions in meters
  ///
  /// Parameters:
  /// - [startLatitude]: Starting position latitude
  /// - [startLongitude]: Starting position longitude
  /// - [endLatitude]: Ending position latitude
  /// - [endLongitude]: Ending position longitude
  ///
  /// Returns distance in meters.
  ///
  /// Example:
  /// ```dart
  /// final distance = LocationService().getDistanceBetween(
  ///   23.8103, 90.4125,  // Dhaka
  ///   23.7104, 90.4074,  // Another location
  /// );
  /// print('Distance: ${distance.toStringAsFixed(2)} meters');
  /// ```
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculates the bearing between two positions in degrees
  ///
  /// The bearing is the direction from the start point to the end point.
  /// Returns a value between 0 and 360 degrees.
  double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Streams position updates
  ///
  /// Returns a stream that emits position updates as the device moves.
  ///
  /// Example:
  /// ```dart
  /// final positionStream = LocationService().getPositionStream();
  /// positionStream.listen((position) {
  ///   print('New position: ${position.latitude}, ${position.longitude}');
  /// });
  /// ```
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings ?? _locationSettings,
    );
  }

  /// Gets position with timeout and error handling
  ///
  /// Parameters:
  /// - [timeout]: Maximum time to wait for position (default: 10 seconds)
  ///
  /// Returns the position or null if timeout occurs.
  Future<Position?> getPositionWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await getCurrentPosition().timeout(
        timeout,
        onTimeout: () {
          throw LocationServiceException(
            'Location request timed out. Please ensure GPS is enabled.',
          );
        },
      );
    } on LocationServiceException {
      rethrow;
    } catch (e) {
      print('Error getting position with timeout: $e');
      return null;
    }
  }

  /// Validates if coordinates are within valid ranges
  ///
  /// Returns true if valid, false otherwise.
  bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Formats coordinates as a readable string
  ///
  /// Example: "23.8103° N, 90.4125° E"
  String formatCoordinates(double latitude, double longitude) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lonDirection = longitude >= 0 ? 'E' : 'W';

    return '${latitude.abs().toStringAsFixed(4)}° $latDirection, '
        '${longitude.abs().toStringAsFixed(4)}° $lonDirection';
  }

  /// Formats distance in a human-readable way
  ///
  /// Returns distance with appropriate unit (m or km).
  ///
  /// Example:
  /// ```dart
  /// print(LocationService().formatDistance(500));    // "500 m"
  /// print(LocationService().formatDistance(1500));   // "1.5 km"
  /// print(LocationService().formatDistance(50000));  // "50.0 km"
  /// ```
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Gets position or returns a default location if unavailable
  ///
  /// Parameters:
  /// - [defaultLatitude]: Fallback latitude (default: Dhaka, Bangladesh)
  /// - [defaultLongitude]: Fallback longitude (default: Dhaka, Bangladesh)
  ///
  /// This is useful for initializing maps when location is unavailable.
  Future<Position> getPositionOrDefault({
    double defaultLatitude = 23.8103,
    double defaultLongitude = 90.4125,
  }) async {
    try {
      final position = await getCurrentPosition();
      if (position != null) {
        return position;
      }
    } catch (e) {
      print('Could not get current position, using default: $e');
    }

    // Return default position (Dhaka, Bangladesh)
    return Position(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  /// Checks if location permission is granted
  ///
  /// Returns true if permission is granted (whileInUse or always).
  Future<bool> hasLocationPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Gets a user-friendly message for the current permission status
  Future<String> getPermissionStatusMessage() async {
    final permission = await checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission is denied. Please grant permission to use this feature.';
      case LocationPermission.deniedForever:
        return 'Location permission is permanently denied. Please enable it in app settings.';
      case LocationPermission.whileInUse:
        return 'Location permission granted while app is in use.';
      case LocationPermission.always:
        return 'Location permission granted always.';
      default:
        return 'Location permission status unknown.';
    }
  }
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
