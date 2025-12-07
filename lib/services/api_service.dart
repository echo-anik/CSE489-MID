import 'dart:io';
import 'dart:convert';
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
  ///   final landmarks = await ApiService().fetchLandmarks();
  ///   print('Found ${landmarks.length} landmarks');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
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
  /// - [lat]: Latitude coordinate
  /// - [lon]: Longitude coordinate
  /// - [imageFile]: Image file to upload
  ///
  /// Returns the created [Landmark] object.
  /// Throws [ApiException] on error.
  ///
  /// Example:
  /// ```dart
  /// final image = File('/path/to/image.jpg');
  /// final landmark = await ApiService().createLandmark(
  ///   'Shaheed Minar',
  ///   23.8103,
  ///   90.4125,
  ///   image,
  /// );
  /// ```
  Future<Landmark> createLandmark(
    String title,
    double lat,
    double lon,
    File imageFile,
  ) async {
    try {
      // Prepare multipart form data
      final formData = FormData.fromMap({
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

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
              id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              lat: lat,
              lon: lon,
              image: '', // Image URL will be set by server
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
  /// - [lat]: New latitude
  /// - [lon]: New longitude
  /// - [imageFile]: Optional new image file
  ///
  /// Returns true if successful, false otherwise.
  /// Throws [ApiException] on error.
  ///
  /// Example:
  /// ```dart
  /// final success = await ApiService().updateLandmark(
  ///   '123',
  ///   'Updated Title',
  ///   23.8103,
  ///   90.4125,
  /// );
  /// ```
  Future<bool> updateLandmark(
    String id,
    String title,
    double lat,
    double lon, {
    File? imageFile,
  }) async {
    try {
      // Prepare form data (x-www-form-urlencoded)
      final Map<String, dynamic> data = {
        'id': id,
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
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

        // Handle different success response formats
        if (responseData is Map<String, dynamic>) {
          return responseData['success'] == true ||
              responseData['status'] == 'success' ||
              responseData['message']?.toString().toLowerCase().contains('success') == true;
        }

        return true;
      } else if (response.statusCode == 204) {
        // No content - successful update
        return true;
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
  /// final success = await ApiService().deleteLandmark('123');
  /// if (success) {
  ///   print('Landmark deleted');
  /// }
  /// ```
  Future<bool> deleteLandmark(String id) async {
    try {
      final response = await _dio.delete(
        baseUrl,
        queryParameters: {'id': id},
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
