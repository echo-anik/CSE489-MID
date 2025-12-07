import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

/// Provider class for managing landmark state
///
/// Implements offline-first architecture:
/// - Loads data from local database first
/// - Syncs with remote API in background
/// - Handles CRUD operations with proper error handling
class LandmarkProvider with ChangeNotifier {
  final ApiService _apiService;
  final AppDatabase _database;

  List<Landmark> _landmarks = [];
  bool _isLoading = false;
  String? _error;

  List<Landmark> get landmarks => _landmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LandmarkProvider({
    required ApiService apiService,
    required AppDatabase database,
  })  : _apiService = apiService,
        _database = database;

  /// Fetch landmarks with offline-first approach
  ///
  /// 1. Load from local database immediately
  /// 2. Sync with API in background
  /// 3. Update UI if API returns new data
  Future<void> fetchLandmarks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Step 1: Load from local database first (instant feedback)
      await _loadFromDatabase();

      // Step 2: Try to sync with API
      try {
        final apiLandmarks = await _apiService.getLandmarks();

        // Update database with API data
        await _database.clearLandmarks();
        for (final landmark in apiLandmarks) {
          await _database.insertLandmark(landmark);
        }

        // Update state if API data is different
        if (!_compareLandmarkLists(_landmarks, apiLandmarks)) {
          _landmarks = apiLandmarks;
          notifyListeners();
        }
      } catch (apiError) {
        print('API sync failed, using cached data: $apiError');
        // Continue with cached data, don't show error to user
        // unless there's no cached data
        if (_landmarks.isEmpty) {
          _error = 'Unable to load landmarks. Please check your connection.';
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load landmarks: ${e.toString()}';
      notifyListeners();
      print('Error fetching landmarks: $e');
    }
  }

  /// Load landmarks from local database
  Future<void> _loadFromDatabase() async {
    try {
      _landmarks = await _database.getLandmarks();
      notifyListeners();
    } catch (e) {
      print('Error loading from database: $e');
    }
  }

  /// Add a new landmark
  ///
  /// [title] Landmark title
  /// [latitude] Latitude coordinate
  /// [longitude] Longitude coordinate
  /// [imageFile] Image file (optional)
  Future<bool> addLandmark({
    required String title,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create landmark via API
      final newLandmark = await _apiService.createLandmark(
        title: title,
        latitude: latitude,
        longitude: longitude,
        imageFile: imageFile,
      );

      // Save to local database
      await _database.insertLandmark(newLandmark);

      // Update state
      _landmarks.add(newLandmark);
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add landmark: ${e.toString()}';
      notifyListeners();
      print('Error adding landmark: $e');
      return false;
    }
  }

  /// Update an existing landmark
  ///
  /// [id] Landmark ID
  /// [title] Updated title
  /// [latitude] Updated latitude
  /// [longitude] Updated longitude
  /// [imageFile] Updated image file (optional)
  Future<bool> updateLandmark({
    required int id,
    required String title,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update landmark via API
      final updatedLandmark = await _apiService.updateLandmark(
        id: id,
        title: title,
        latitude: latitude,
        longitude: longitude,
        imageFile: imageFile,
      );

      // Update local database
      await _database.updateLandmark(updatedLandmark);

      // Update state
      final index = _landmarks.indexWhere((l) => l.id == id);
      if (index != -1) {
        _landmarks[index] = updatedLandmark;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update landmark: ${e.toString()}';
      notifyListeners();
      print('Error updating landmark: $e');
      return false;
    }
  }

  /// Delete a landmark
  ///
  /// [id] Landmark ID to delete
  Future<bool> deleteLandmark(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Delete from API
      await _apiService.deleteLandmark(id);

      // Delete from local database
      await _database.deleteLandmark(id);

      // Update state
      _landmarks.removeWhere((l) => l.id == id);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete landmark: ${e.toString()}';
      notifyListeners();
      print('Error deleting landmark: $e');
      return false;
    }
  }

  /// Sync local database with API
  ///
  /// Useful for manual refresh or background sync
  Future<void> syncWithLocal() async {
    try {
      // Get data from API
      final apiLandmarks = await _apiService.getLandmarks();

      // Clear and update database
      await _database.clearLandmarks();
      for (final landmark in apiLandmarks) {
        await _database.insertLandmark(landmark);
      }

      // Update state
      _landmarks = apiLandmarks;
      _error = null;
      notifyListeners();
    } catch (e) {
      print('Error syncing with local: $e');
      _error = 'Sync failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get a single landmark by ID
  Landmark? getLandmarkById(int id) {
    try {
      return _landmarks.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search landmarks by title
  List<Landmark> searchLandmarks(String query) {
    if (query.isEmpty) return _landmarks;

    final lowerQuery = query.toLowerCase();
    return _landmarks.where((landmark) {
      return landmark.title.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter landmarks by distance from a point
  ///
  /// [latitude] Reference latitude
  /// [longitude] Reference longitude
  /// [radiusKm] Search radius in kilometers
  List<Landmark> filterByDistance({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return _landmarks.where((landmark) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        landmark.latitude,
        landmark.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _degreesToRadians(lat1).cos() *
            _degreesToRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final c = 2 * a.sqrt().asin();
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }

  /// Compare two landmark lists for equality
  bool _compareLandmarkLists(List<Landmark> list1, List<Landmark> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].title != list2[i].title ||
          list1[i].latitude != list2[i].latitude ||
          list1[i].longitude != list2[i].longitude) {
        return false;
      }
    }

    return true;
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh landmarks (force reload)
  Future<void> refresh() async {
    await fetchLandmarks();
  }
}
