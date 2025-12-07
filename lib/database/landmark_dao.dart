import 'package:floor/floor.dart';
import '../models/landmark.dart';

@dao
abstract class LandmarkDao {
  @Query('SELECT * FROM Landmark ORDER BY createdAt DESC')
  Future<List<Landmark>> getAllLandmarks();

  @Query('SELECT * FROM Landmark WHERE id = :id')
  Future<Landmark?> getLandmarkById(String id);

  @Query('SELECT * FROM Landmark WHERE name LIKE :query OR description LIKE :query ORDER BY createdAt DESC')
  Future<List<Landmark>> searchLandmarks(String query);

  @Query('SELECT * FROM Landmark WHERE category = :category ORDER BY createdAt DESC')
  Future<List<Landmark>> getLandmarksByCategory(String category);

  @insert
  Future<void> insertLandmark(Landmark landmark);

  @insert
  Future<void> insertLandmarks(List<Landmark> landmarks);

  @update
  Future<void> updateLandmark(Landmark landmark);

  @delete
  Future<void> deleteLandmark(Landmark landmark);

  @Query('DELETE FROM Landmark WHERE id = :id')
  Future<void> deleteLandmarkById(String id);

  @Query('DELETE FROM Landmark')
  Future<void> deleteAllLandmarks();

  @Query('SELECT COUNT(*) FROM Landmark')
  Future<int?> getLandmarkCount();
}
