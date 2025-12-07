# Landmark Management API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Base URL](#base-url)
3. [Authentication](#authentication)
4. [API Endpoints](#api-endpoints)
5. [Flutter HTTP Implementation](#flutter-http-implementation)
6. [API Integration Patterns](#api-integration-patterns)
7. [Testing API Endpoints](#testing-api-endpoints)

---

## Overview

The Landmark Management API is a RESTful web service that enables CRUD (Create, Read, Update, Delete) operations for managing geographical landmarks. Each landmark contains a title, geographical coordinates (latitude and longitude), and an associated image.

### Key Features
- Create landmarks with image uploads
- Retrieve all stored landmarks
- Update existing landmark information
- Delete landmarks by ID
- Support for multipart form data (image uploads)
- Support for URL-encoded form data (updates)

---

## Base URL

```
https://labs.anontech.info/cse489/t3/api.php
```

All API requests should be made to this endpoint. The HTTP method (GET, POST, PUT, DELETE) determines the operation performed.

---

## Authentication

**Current Implementation:** No authentication required for basic functionality.

**Bonus Implementation (Optional):**
If authentication is implemented, include an API key or Bearer token in the request headers:

```
Authorization: Bearer YOUR_API_TOKEN
```

Or use API key in headers:

```
X-API-Key: YOUR_API_KEY
```

---

## API Endpoints

### 1. Create Landmark

Creates a new landmark with title, coordinates, and image.

#### Request Details
- **Method:** `POST`
- **URL:** `https://labs.anontech.info/cse489/t3/api.php`
- **Content-Type:** `multipart/form-data`

#### Request Parameters

| Parameter | Type   | Required | Description                          |
|-----------|--------|----------|--------------------------------------|
| title     | string | Yes      | Name/title of the landmark           |
| lat       | double | Yes      | Latitude coordinate (-90 to 90)      |
| lon       | double | Yes      | Longitude coordinate (-180 to 180)   |
| image     | file   | Yes      | Image file (JPEG/PNG, 800x600 recommended) |

#### cURL Example

```bash
curl -X POST https://labs.anontech.info/cse489/t3/api.php \
  -F "title=Eiffel Tower" \
  -F "lat=48.8584" \
  -F "lon=2.2945" \
  -F "image=@/path/to/image.jpg"
```

#### Dart/Flutter Example

```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, dynamic>> createLandmark({
  required String title,
  required double lat,
  required double lon,
  required File imageFile,
}) async {
  final uri = Uri.parse('https://labs.anontech.info/cse489/t3/api.php');

  var request = http.MultipartRequest('POST', uri);

  // Add text fields
  request.fields['title'] = title;
  request.fields['lat'] = lat.toString();
  request.fields['lon'] = lon.toString();

  // Add image file
  var imageStream = http.ByteStream(imageFile.openRead());
  var imageLength = await imageFile.length();

  var multipartFile = http.MultipartFile(
    'image',
    imageStream,
    imageLength,
    filename: imageFile.path.split('/').last,
  );

  request.files.add(multipartFile);

  // Send request
  var response = await request.send();
  var responseData = await response.stream.bytesToString();

  if (response.statusCode == 200 || response.statusCode == 201) {
    return json.decode(responseData);
  } else {
    throw Exception('Failed to create landmark: ${response.statusCode}');
  }
}
```

#### Response Format

**Success Response (201 Created):**

```json
{
  "success": true,
  "message": "Landmark created successfully",
  "data": {
    "id": 123,
    "title": "Eiffel Tower",
    "lat": 48.8584,
    "lon": 2.2945,
    "image_url": "https://labs.anontech.info/cse489/t3/uploads/123_eiffel.jpg",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Error Response (400 Bad Request):**

```json
{
  "success": false,
  "message": "Missing required field: title",
  "error_code": "MISSING_FIELD"
}
```

#### Status Codes

- `201 Created` - Landmark created successfully
- `400 Bad Request` - Missing or invalid parameters
- `413 Payload Too Large` - Image file too large
- `415 Unsupported Media Type` - Invalid image format
- `500 Internal Server Error` - Server error

---

### 2. Get All Landmarks

Retrieves a list of all stored landmarks.

#### Request Details
- **Method:** `GET`
- **URL:** `https://labs.anontech.info/cse489/t3/api.php`
- **Content-Type:** Not required

#### Request Parameters

None required.

#### cURL Example

```bash
curl -X GET https://labs.anontech.info/cse489/t3/api.php
```

#### Dart/Flutter Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Landmark>> getAllLandmarks() async {
  final uri = Uri.parse('https://labs.anontech.info/cse489/t3/api.php');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['success'] == true) {
      List<dynamic> landmarksJson = data['data'];
      return landmarksJson.map((json) => Landmark.fromJson(json)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to load landmarks');
    }
  } else {
    throw Exception('Failed to load landmarks: ${response.statusCode}');
  }
}
```

#### Response Format

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Landmarks retrieved successfully",
  "data": [
    {
      "id": 123,
      "title": "Eiffel Tower",
      "lat": 48.8584,
      "lon": 2.2945,
      "image_url": "https://labs.anontech.info/cse489/t3/uploads/123_eiffel.jpg",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": 124,
      "title": "Statue of Liberty",
      "lat": 40.6892,
      "lon": -74.0445,
      "image_url": "https://labs.anontech.info/cse489/t3/uploads/124_statue.jpg",
      "created_at": "2024-01-15T11:00:00Z",
      "updated_at": "2024-01-15T11:00:00Z"
    }
  ],
  "count": 2
}
```

**Error Response (500 Internal Server Error):**

```json
{
  "success": false,
  "message": "Database connection failed",
  "error_code": "DB_ERROR"
}
```

#### Status Codes

- `200 OK` - Landmarks retrieved successfully
- `404 Not Found` - No landmarks found
- `500 Internal Server Error` - Server error

---

### 3. Update Landmark

Updates an existing landmark's information.

#### Request Details
- **Method:** `PUT`
- **URL:** `https://labs.anontech.info/cse489/t3/api.php`
- **Content-Type:** `application/x-www-form-urlencoded`

#### Request Parameters

| Parameter | Type   | Required | Description                          |
|-----------|--------|----------|--------------------------------------|
| id        | int    | Yes      | ID of the landmark to update         |
| title     | string | Yes      | Updated name/title of the landmark   |
| lat       | double | Yes      | Updated latitude coordinate          |
| lon       | double | Yes      | Updated longitude coordinate         |
| image     | file   | No       | Updated image file (optional)        |

#### cURL Example

```bash
curl -X PUT https://labs.anontech.info/cse489/t3/api.php \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "id=123&title=Eiffel Tower Paris&lat=48.8584&lon=2.2945"
```

#### Dart/Flutter Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> updateLandmark({
  required int id,
  required String title,
  required double lat,
  required double lon,
}) async {
  final uri = Uri.parse('https://labs.anontech.info/cse489/t3/api.php');

  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'id': id.toString(),
      'title': title,
      'lat': lat.toString(),
      'lon': lon.toString(),
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to update landmark: ${response.statusCode}');
  }
}
```

#### Response Format

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Landmark updated successfully",
  "data": {
    "id": 123,
    "title": "Eiffel Tower Paris",
    "lat": 48.8584,
    "lon": 2.2945,
    "image_url": "https://labs.anontech.info/cse489/t3/uploads/123_eiffel.jpg",
    "updated_at": "2024-01-15T12:00:00Z"
  }
}
```

**Error Response (404 Not Found):**

```json
{
  "success": false,
  "message": "Landmark not found",
  "error_code": "NOT_FOUND"
}
```

#### Status Codes

- `200 OK` - Landmark updated successfully
- `400 Bad Request` - Missing or invalid parameters
- `404 Not Found` - Landmark with specified ID not found
- `500 Internal Server Error` - Server error

---

### 4. Delete Landmark

Deletes a landmark by ID.

#### Request Details
- **Method:** `DELETE`
- **URL:** `https://labs.anontech.info/cse489/t3/api.php?id={id}`
- **Content-Type:** Not required

#### Request Parameters

| Parameter | Type | Required | Description                    |
|-----------|------|----------|--------------------------------|
| id        | int  | Yes      | ID of the landmark to delete   |

#### cURL Example

```bash
curl -X DELETE "https://labs.anontech.info/cse489/t3/api.php?id=123"
```

#### Dart/Flutter Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> deleteLandmark(int id) async {
  final uri = Uri.parse('https://labs.anontech.info/cse489/t3/api.php?id=$id');

  final response = await http.delete(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to delete landmark: ${response.statusCode}');
  }
}
```

#### Response Format

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Landmark deleted successfully",
  "data": {
    "id": 123
  }
}
```

**Error Response (404 Not Found):**

```json
{
  "success": false,
  "message": "Landmark not found",
  "error_code": "NOT_FOUND"
}
```

#### Status Codes

- `200 OK` - Landmark deleted successfully
- `400 Bad Request` - Missing ID parameter
- `404 Not Found` - Landmark with specified ID not found
- `500 Internal Server Error` - Server error

---

## Flutter HTTP Implementation

### Required Packages

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  # OR use dio for more features
  dio: ^5.4.0
  image: ^4.1.3  # For image resizing
  geolocator: ^11.0.0  # For GPS location
  permission_handler: ^11.1.0  # For permissions
```

### Service Class Structure

Create a dedicated service class for API operations:

```dart
// lib/services/landmark_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class LandmarkService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // Singleton pattern
  static final LandmarkService _instance = LandmarkService._internal();
  factory LandmarkService() => _instance;
  LandmarkService._internal();

  // Create landmark
  Future<Landmark> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      // Add image
      var imageStream = http.ByteStream(imageFile.openRead());
      var imageLength = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseData);
        return Landmark.fromJson(data['data']);
      } else {
        throw LandmarkException('Failed to create landmark', response.statusCode);
      }
    } catch (e) {
      throw LandmarkException('Error creating landmark: $e');
    }
  }

  // Get all landmarks
  Future<List<Landmark>> getAllLandmarks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> landmarksJson = data['data'];
          return landmarksJson.map((json) => Landmark.fromJson(json)).toList();
        } else {
          throw LandmarkException(data['message'] ?? 'Unknown error');
        }
      } else {
        throw LandmarkException('Failed to load landmarks', response.statusCode);
      }
    } catch (e) {
      throw LandmarkException('Error loading landmarks: $e');
    }
  }

  // Update landmark
  Future<Landmark> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id.toString(),
          'title': title,
          'lat': lat.toString(),
          'lon': lon.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Landmark.fromJson(data['data']);
      } else {
        throw LandmarkException('Failed to update landmark', response.statusCode);
      }
    } catch (e) {
      throw LandmarkException('Error updating landmark: $e');
    }
  }

  // Delete landmark
  Future<void> deleteLandmark(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?id=$id'),
      );

      if (response.statusCode != 200) {
        throw LandmarkException('Failed to delete landmark', response.statusCode);
      }
    } catch (e) {
      throw LandmarkException('Error deleting landmark: $e');
    }
  }
}

// Custom exception class
class LandmarkException implements Exception {
  final String message;
  final int? statusCode;

  LandmarkException(this.message, [this.statusCode]);

  @override
  String toString() => 'LandmarkException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}
```

### Error Handling

Implement comprehensive error handling:

```dart
// lib/utils/error_handler.dart

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is LandmarkException) {
      return error.message;
    } else if (error is SocketException) {
      return 'No internet connection';
    } else if (error is HttpException) {
      return 'Server error occurred';
    } else if (error is FormatException) {
      return 'Invalid response format';
    } else {
      return 'An unexpected error occurred';
    }
  }

  static void handleError(dynamic error, Function(String) onError) {
    final message = getErrorMessage(error);
    onError(message);
  }
}
```

### Image Upload Handling

Handle image uploads with proper error checking:

```dart
import 'package:image/image.dart' as img;
import 'dart:io';

Future<File> prepareImageForUpload(File imageFile) async {
  try {
    // Read the image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Invalid image file');
    }

    // Resize to 800x600
    final resized = img.copyResize(
      image,
      width: 800,
      height: 600,
      interpolation: img.Interpolation.linear,
    );

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempFile = File(tempPath);

    await tempFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

    return tempFile;
  } catch (e) {
    throw Exception('Failed to process image: $e');
  }
}
```

### Using Dio (Alternative)

Dio provides more features like interceptors, timeout, and better error handling:

```dart
import 'package:dio/dio.dart';

class LandmarkServiceDio {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://labs.anontech.info/cse489/t3',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<Landmark> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required File imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post('/api.php', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Landmark.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Failed to create landmark',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
```

---

## API Integration Patterns

### Model Class

Create a Landmark model to handle JSON serialization:

```dart
// lib/models/landmark.dart

class Landmark {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as int,
      title: json['title'] as String,
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      imageUrl: json['image_url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Landmark copyWith({
    int? id,
    String? title,
    double? lat,
    double? lon,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Landmark(
      id: id ?? this.id,
      title: title ?? this.title,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### State Management Integration

Using Provider pattern:

```dart
// lib/providers/landmark_provider.dart

import 'package:flutter/foundation.dart';
import '../models/landmark.dart';
import '../services/landmark_service.dart';

class LandmarkProvider extends ChangeNotifier {
  final LandmarkService _service = LandmarkService();

  List<Landmark> _landmarks = [];
  bool _isLoading = false;
  String? _error;

  List<Landmark> get landmarks => _landmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLandmarks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _landmarks = await _service.getAllLandmarks();
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLandmark({
    required String title,
    required double lat,
    required double lon,
    required File imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final landmark = await _service.createLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: imageFile,
      );
      _landmarks.add(landmark);
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateLandmark(
        id: id,
        title: title,
        lat: lat,
        lon: lon,
      );

      final index = _landmarks.indexWhere((l) => l.id == id);
      if (index != -1) {
        _landmarks[index] = updated;
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLandmark(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteLandmark(id);
      _landmarks.removeWhere((l) => l.id == id);
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Testing API Endpoints

### Using Postman

#### 1. Create Landmark (POST)

1. Set method to `POST`
2. URL: `https://labs.anontech.info/cse489/t3/api.php`
3. Go to Body tab
4. Select `form-data`
5. Add key-value pairs:
   - `title`: Text - "Test Landmark"
   - `lat`: Text - "23.8103"
   - `lon`: Text - "90.4125"
   - `image`: File - Select an image file
6. Click Send

#### 2. Get All Landmarks (GET)

1. Set method to `GET`
2. URL: `https://labs.anontech.info/cse489/t3/api.php`
3. Click Send

#### 3. Update Landmark (PUT)

1. Set method to `PUT`
2. URL: `https://labs.anontech.info/cse489/t3/api.php`
3. Go to Headers tab
4. Add: `Content-Type`: `application/x-www-form-urlencoded`
5. Go to Body tab
6. Select `x-www-form-urlencoded`
7. Add key-value pairs:
   - `id`: "1"
   - `title`: "Updated Landmark"
   - `lat`: "23.8104"
   - `lon`: "90.4126"
8. Click Send

#### 4. Delete Landmark (DELETE)

1. Set method to `DELETE`
2. URL: `https://labs.anontech.info/cse489/t3/api.php?id=1`
3. Click Send

### Using cURL

Test all endpoints from the command line:

```bash
# Create
curl -X POST https://labs.anontech.info/cse489/t3/api.php \
  -F "title=Test" \
  -F "lat=23.8103" \
  -F "lon=90.4125" \
  -F "image=@test.jpg"

# Get All
curl -X GET https://labs.anontech.info/cse489/t3/api.php

# Update
curl -X PUT https://labs.anontech.info/cse489/t3/api.php \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "id=1&title=Updated&lat=23.8104&lon=90.4126"

# Delete
curl -X DELETE "https://labs.anontech.info/cse489/t3/api.php?id=1"
```

### Testing in Flutter

Create integration tests:

```dart
// test/landmark_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/services/landmark_service.dart';

void main() {
  group('LandmarkService Tests', () {
    final service = LandmarkService();

    test('Get all landmarks returns list', () async {
      final landmarks = await service.getAllLandmarks();
      expect(landmarks, isA<List<Landmark>>());
    });

    test('Create landmark succeeds', () async {
      final file = File('test_assets/test_image.jpg');
      final landmark = await service.createLandmark(
        title: 'Test Landmark',
        lat: 23.8103,
        lon: 90.4125,
        imageFile: file,
      );

      expect(landmark.title, 'Test Landmark');
      expect(landmark.lat, 23.8103);
      expect(landmark.lon, 90.4125);
    });
  });
}
```

---

## Best Practices

1. **Always handle errors gracefully** - Show user-friendly error messages
2. **Use try-catch blocks** - Wrap all API calls in error handlers
3. **Implement loading states** - Show spinners during API requests
4. **Cache responses** - Store data locally to reduce API calls
5. **Validate input** - Check data before sending to API
6. **Use timeouts** - Prevent indefinite waiting for responses
7. **Log requests** - Use interceptors to log API calls for debugging
8. **Handle offline scenarios** - Queue requests when offline
9. **Optimize images** - Resize before upload to reduce bandwidth
10. **Use constants** - Store API URLs and keys in config files

---

## Additional Resources

- [HTTP Package Documentation](https://pub.dev/packages/http)
- [Dio Package Documentation](https://pub.dev/packages/dio)
- [Flutter Networking Guide](https://docs.flutter.dev/development/data-and-backend/networking)
- [REST API Best Practices](https://restfulapi.net/)

---

**Document Version:** 1.0
**Last Updated:** 2024-01-15
