import 'package:floor/floor.dart';
import '../../models/landmark.dart';

/// Floor entity for Landmark table
///
/// This entity represents the database schema for landmarks with Floor ORM.
/// It includes proper annotations for primary keys, column names, and indexes.
@Entity(
  tableName: 'landmarks',
  indices: [
    Index(value: ['title']),
    Index(value: ['is_synced']),
    Index(value: ['updated_at']),
    Index(value: ['latitude', 'longitude']),
  ],
)
class LandmarkEntity {
  /// Unique identifier (auto-increment primary key)
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Landmark title/name
  final String title;

  /// Latitude coordinate (-90 to 90)
  final double latitude;

  /// Longitude coordinate (-180 to 180)
  final double longitude;

  /// Remote URL for the landmark image
  @ColumnInfo(name: 'image_url')
  final String? imageUrl;

  /// Local file path to cached image
  @ColumnInfo(name: 'image_path')
  final String? imagePath;

  /// Sync status: 1 = synced, 0 = not synced
  @ColumnInfo(name: 'is_synced', defaultValue: '1')
  final int isSynced;

  /// Creation timestamp (milliseconds since epoch)
  @ColumnInfo(name: 'created_at')
  final int createdAt;

  /// Last update timestamp (milliseconds since epoch)
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  /// Creates a new LandmarkEntity instance
  LandmarkEntity({
    this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.imagePath,
    this.isSynced = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a LandmarkEntity from a Landmark model
  factory LandmarkEntity.fromModel(Landmark landmark) {
    return LandmarkEntity(
      id: landmark.id,
      title: landmark.title,
      latitude: landmark.latitude,
      longitude: landmark.longitude,
      imageUrl: landmark.imageUrl,
      imagePath: landmark.imagePath,
      isSynced: landmark.isSynced ? 1 : 0,
      createdAt: landmark.createdAt,
      updatedAt: landmark.updatedAt,
    );
  }

  /// Converts this entity to a Landmark model
  Landmark toModel() {
    return Landmark(
      id: id,
      title: title,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      imagePath: imagePath,
      isSynced: isSynced == 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a copy of this entity with updated fields
  LandmarkEntity copyWith({
    int? id,
    String? title,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? imagePath,
    int? isSynced,
    int? createdAt,
    int? updatedAt,
  }) {
    return LandmarkEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LandmarkEntity &&
        other.id == id &&
        other.title == title &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.imageUrl == imageUrl &&
        other.imagePath == imagePath &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        imageUrl.hashCode ^
        imagePath.hashCode ^
        isSynced.hashCode;
  }

  @override
  String toString() {
    return 'LandmarkEntity(id: $id, title: $title, lat: $latitude, lon: $longitude, synced: $isSynced)';
  }
}
