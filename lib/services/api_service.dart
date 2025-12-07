import 'dart:io';
import 'package:dio/dio.dart';
import '../models/landmark.dart';

/// API service for handling all HTTP requests to the landmark backend
///
/// This service uses Dio for HTTP requests and provides methods for
/// CRUD operations on landmarks. Implements singleton pattern for
/// efficient resource management.
class ApiService {
  // Singleton pattern implementation
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  /// Dio instance for HTTP requests
  late final Dio _dio;

  /// Base URL for the API
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 REQUEST[${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Fetches all landmarks from the API
  ///
  /// Returns a list of [Landmark] objects.
  /// Throws [ApiException] on error.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final landmarks = await ApiService().getLandmarks();
  ///   print('Found ${landmarks.length} landmarks');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  Future<List<Landmark>> getLandmarks() async {
    return fetchLandmarks();
  }

  Future<List<Landmark>> fetchLandmarks() async {
    try {
      final response = await _dio.get(baseUrl);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both array response and object with data field
        if (data is List) {
          return data.map((json) => Landmark.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => Landmark.fromJson(json))
              .toList();
        } else if (data is Map<String, dynamic> && data['landmarks'] is List) {
          return (data['landmarks'] as List)
              .map((json) => Landmark.fromJson(json))
              .toList();
        } else {
          throw ApiException('Unexpected response format');
        }
      } else {
        throw ApiException(
          'Failed to fetch landmarks: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Creates a new landmark on the server
  ///
  /// Parameters:
  /// - [title]: The landmark title
  /// - [latitude]: Latitude coordinate
  /// - [longitude]: Longitude coordinate
  /// - [imageFile]: Image file to upload (optional)
  ///
  /// Returns the created [Landmark] object.
  /// Throws [ApiException] on error.
  ///
  /// Example:
  /// ```dart
  /// final image = File('/path/to/image.jpg');
  /// final landmark = await ApiService().createLandmark(
  ///   title: 'Shaheed Minar',
  ///   latitude: 23.8103,
  ///   longitude: 90.4125,
  ///   imageFile: image,
  /// );
  /// ```
  Future<Landmark> createLandmark({
    required String title,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      // Prepare multipart form data
      final Map<String, dynamic> formFields = {
        'title': title,
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      };

      if (imageFile != null) {
        formFields['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formFields);

      final response = await _dio.post(
        baseUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Handle different response formats
        if (data is Map<String, dynamic>) {
          // If the response contains the created landmark
          if (data['landmark'] != null) {
            return Landmark.fromJson(data['landmark']);
          } else if (data['data'] != null) {
            return Landmark.fromJson(data['data']);
          } else if (data['id'] != null) {
            // Response is the landmark itself
            return Landmark.fromJson(data);
          } else {
            // If no landmark returned, create one from the request data
            return Landmark(
              id: data['id'],
              title: title,
              latitude: latitude,
              longitude: longitude,
              imageUrl: '', // Image URL will be set by server
            );
          }
        }

        throw ApiException('Unexpected response format');
      } else {
        throw ApiException(
          'Failed to create landmark: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Updates an existing landmark
  ///
  /// Parameters:
  /// - [id]: Landmark ID to update
  /// - [title]: New title
  /// - [latitude]: New latitude
  /// - [longitude]: New longitude
  /// - [imageFile]: Optional new image file
  ///
  /// Returns the updated Landmark object.
  /// Throws [ApiException] on error.
  ///
  /// Example:
  /// ```dart
  /// final landmark = await ApiService().updateLandmark(
  ///   id: 123,
  ///   title: 'Updated Title',
  ///   latitude: 23.8103,
  ///   longitude: 90.4125,
  /// );
  /// ```
  Future<Landmark> updateLandmark({
    required int id,
    required String title,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      // Prepare form data (x-www-form-urlencoded)
      final Map<String, dynamic> data = {
        'id': id.toString(),
        'title': title,
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      };

      Response response;

      if (imageFile != null) {
        // If image is provided, use multipart
        final formData = FormData.fromMap({
          ...data,
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        });

        response = await _dio.put(
          baseUrl,
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );
      } else {
        // Use x-www-form-urlencoded as specified
        response = await _dio.put(
          baseUrl,
          data: data,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Try to return the updated landmark from response
        if (responseData is Map<String, dynamic>) {
          if (responseData['landmark'] != null) {
            return Landmark.fromJson(responseData['landmark']);
          } else if (responseData['data'] != null) {
            return Landmark.fromJson(responseData['data']);
          }
        }

        // If no landmark in response, create one from request data
        return Landmark(
          id: id,
          title: title,
          latitude: latitude,
          longitude: longitude,
          imageUrl: imageFile != null ? '' : null,
        );
      } else if (response.statusCode == 204) {
        // No content - successful update, return landmark with updated data
        return Landmark(
          id: id,
          title: title,
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        throw ApiException(
          'Failed to update landmark: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Deletes a landmark from the server
  ///
  /// Parameters:
  /// - [id]: Landmark ID to delete
  ///
  /// Returns true if successful, false otherwise.
  /// Throws [ApiException] on error.
  ///
  /// Example:
  /// ```dart
  /// final success = await ApiService().deleteLandmark(123);
  /// if (success) {
  ///   print('Landmark deleted');
  /// }
  /// ```
  Future<bool> deleteLandmark(int id) async {
    try {
      final response = await _dio.delete(
        baseUrl,
        queryParameters: {'id': id.toString()},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;

        // Handle different success response formats
        if (data is Map<String, dynamic>) {
          return data['success'] == true ||
              data['status'] == 'success' ||
              data['message']?.toString().toLowerCase().contains('success') == true;
        }

        return true;
      } else {
        throw ApiException(
          'Failed to delete landmark: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Handles Dio errors and converts them to ApiException
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timeout. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?.toString() ?? error.message;
        return ApiException(
          'Server error: $message',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');

      case DioExceptionType.connectionError:
        return ApiException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
        return ApiException('Security certificate error');

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return ApiException('No internet connection');
        }
        return ApiException('Unexpected error: ${error.message}');
    }
  }

  /// Closes the Dio client and releases resources
  void dispose() {
    _dio.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}
