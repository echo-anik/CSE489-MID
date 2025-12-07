import 'package:floor/floor.dart';

/// Landmark data model representing a geographical landmark
///
/// This model represents a landmark with its location coordinates,
/// title, and associated image data. It works in conjunction with
/// LandmarkEntity for Floor database operations.
@entity
class Landmark {
  /// Unique identifier for the landmark (synced with server)
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Display title/name of the landmark
  final String title;

  /// Latitude coordinate (-90 to 90)
  final double latitude;

  /// Longitude coordinate (-180 to 180)
  final double longitude;

  /// Remote URL for the landmark image
  final String? imageUrl;

  /// Local file path to cached image
  final String? imagePath;

  /// Sync status: true = synced with server, false = pending sync
  final bool isSynced;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Creates a new Landmark instance
  Landmark({
    this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.imagePath,
    this.isSynced = true,
    int? createdAt,
    int? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch {
    // Validate coordinates
    assert(latitude >= -90 && latitude <= 90, 'Latitude must be between -90 and 90');
    assert(longitude >= -180 && longitude <= 180, 'Longitude must be between -180 and 180');
  }

  /// Creates a Landmark from JSON data (API response)
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "title": "Shaheed Minar",
  ///   "lat": 23.8103,
  ///   "lon": 90.4125,
  ///   "image": "base64_or_url"
  /// }
  /// ```
  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      latitude: _parseDouble(json['lat'] ?? json['latitude']),
      longitude: _parseDouble(json['lon'] ?? json['longitude']),
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
      imagePath: json['imagePath']?.toString(),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: _parseInt(json['updatedAt']) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Converts the Landmark to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'lat': latitude,
      'lon': longitude,
      if (imageUrl != null) 'image': imageUrl,
      if (imagePath != null) 'imagePath': imagePath,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Helper method to safely parse integer values from dynamic types
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Helper method to safely parse double values from dynamic types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Creates a copy of this Landmark with updated fields
  Landmark copyWith({
    int? id,
    String? title,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? imagePath,
    bool? isSynced,
    int? createdAt,
    int? updatedAt,
  }) {
    return Landmark(
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

  /// Returns true if this landmark has a local image cached
  bool get hasLocalImage => imagePath != null && imagePath!.isNotEmpty;

  /// Returns true if this landmark has a remote image URL
  bool get hasRemoteImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Returns the best available image source (local preferred over remote)
  String? get bestImageSource => imagePath ?? imageUrl;

  /// Returns a formatted location string
  String get locationString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Returns a DateTime object for creation time
  DateTime get createdAtDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// Returns a DateTime object for update time
  DateTime get updatedAtDateTime => DateTime.fromMillisecondsSinceEpoch(updatedAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Landmark &&
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
    return 'Landmark(id: $id, title: $title, lat: $latitude, lon: $longitude, synced: $isSynced)';
  }
}
