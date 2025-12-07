import '../database/app_database.dart';
import '../models/landmark.dart';

/// Database service wrapper
///
/// This service provides a simplified interface to database operations
/// and is used by the LandmarkProvider to access the AppDatabase.
extension DatabaseServiceExtension on AppDatabase {
  /// Get all landmarks from database
  Future<List<Landmark>> getLandmarks() async {
    return await landmarkDao.getAllLandmarks();
  }

  /// Get a specific landmark by ID
  Future<Landmark?> getLandmarkById(String id) async {
    return await landmarkDao.getLandmarkById(id);
  }

  /// Insert a landmark into the database
  Future<void> insertLandmark(Landmark landmark) async {
    await landmarkDao.insertLandmark(landmark);
  }

  /// Update a landmark in the database
  Future<void> updateLandmark(Landmark landmark) async {
    await landmarkDao.updateLandmark(landmark);
  }

  /// Delete a landmark by ID
  Future<void> deleteLandmark(int id) async {
    await landmarkDao.deleteLandmarkById(id.toString());
  }

  /// Clear all landmarks from the database
  Future<void> clearLandmarks() async {
    await landmarkDao.deleteAllLandmarks();
  }

  /// Search landmarks
  Future<List<Landmark>> searchLandmarks(String query) async {
    return await landmarkDao.searchLandmarks('%$query%');
  }

  /// Get landmark count
  Future<int> getLandmarkCount() async {
    return await landmarkDao.getLandmarkCount() ?? 0;
  }
}
