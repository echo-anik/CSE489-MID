import 'dart:convert';
import 'package:dio/dio.dart';
import 'storage_service.dart';

/// Authentication service for user management (Bonus Feature)
///
/// This service handles user authentication including login, registration,
/// logout, and token management. Tokens are stored securely using
/// SharedPreferences via StorageService.
class AuthService {
  // Singleton pattern implementation
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _storageService = StorageService();
  }

  /// Dio instance for HTTP requests
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _authBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  /// Storage service for persisting auth data
  late final StorageService _storageService;

  /// Base URL for authentication API
  /// Note: Update this with your actual auth endpoint
  static const String _authBaseUrl = 'https://labs.anontech.info/cse489/t3';

  /// Current authenticated user
  Map<String, dynamic>? _currentUser;

  /// Gets the current authenticated user
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Initializes the auth service and checks for existing session
  ///
  /// Should be called on app startup to restore previous session.
  ///
  /// Example:
  /// ```dart
  /// await AuthService().init();
  /// if (AuthService().isAuthenticated()) {
  ///   // User is logged in
  /// }
  /// ```
  Future<void> init() async {
    await _storageService.init();

    // Try to restore user session
    if (await _storageService.isAuthenticated()) {
      _currentUser = await _storageService.getUserData();
      print('User session restored: ${_currentUser?['email']}');
    }
  }

  /// Logs in a user with username/email and password
  ///
  /// Parameters:
  /// - [username]: User's username or email
  /// - [password]: User's password
  ///
  /// Returns user data on success.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await AuthService().login('user@example.com', 'password123');
  ///   print('Welcome ${user['name']}');
  /// } catch (e) {
  ///   print('Login failed: $e');
  /// }
  /// ```
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Extract token and user data
        final token = data['token'] ?? data['access_token'];
        final userData = data['user'] ?? data['data'] ?? data;

        if (token == null) {
          throw AuthException('No authentication token received');
        }

        // Save token and user data
        await _storageService.saveAuthToken(token);
        await _storageService.saveUserData(userData);

        _currentUser = userData;

        print('Login successful: ${userData['email'] ?? userData['username']}');
        return userData;
      } else {
        final errorMessage = response.data['message'] ??
                            response.data['error'] ??
                            'Login failed';
        throw AuthException(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: $e');
    }
  }

  /// Registers a new user account
  ///
  /// Parameters:
  /// - [username]: Desired username
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [name]: Optional full name
  ///
  /// Returns user data on success.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await AuthService().register(
  ///     'johndoe',
  ///     'john@example.com',
  ///     'password123',
  ///     name: 'John Doe',
  ///   );
  ///   print('Account created for ${user['email']}');
  /// } catch (e) {
  ///   print('Registration failed: $e');
  /// }
  /// ```
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Extract token and user data
        final token = data['token'] ?? data['access_token'];
        final userData = data['user'] ?? data['data'] ?? data;

        if (token != null) {
          // Auto-login after registration
          await _storageService.saveAuthToken(token);
          await _storageService.saveUserData(userData);
          _currentUser = userData;
        }

        print('Registration successful: $email');
        return userData;
      } else {
        final errorMessage = response.data['message'] ??
                            response.data['error'] ??
                            'Registration failed';
        throw AuthException(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: $e');
    }
  }

  /// Logs out the current user
  ///
  /// Clears all stored authentication data and session information.
  ///
  /// Example:
  /// ```dart
  /// await AuthService().logout();
  /// // Navigate to login screen
  /// ```
  Future<void> logout() async {
    try {
      // Optional: Call server logout endpoint
      final token = await _storageService.getAuthToken();
      if (token != null) {
        try {
          await _dio.post(
            '/auth/logout',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );
        } catch (e) {
          print('Server logout failed (continuing anyway): $e');
        }
      }

      // Clear local data
      await _storageService.clearAuthData();
      _currentUser = null;

      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      // Clear local data even if server call fails
      await _storageService.clearAuthData();
      _currentUser = null;
    }
  }

  /// Checks if a user is currently authenticated
  ///
  /// Returns true if user has a valid session.
  Future<bool> isAuthenticated() async {
    return await _storageService.isAuthenticated();
  }

  /// Gets the stored authentication token
  ///
  /// Returns the token or null if not authenticated.
  Future<String?> getAuthToken() async {
    return await _storageService.getAuthToken();
  }

  /// Gets user data from storage
  ///
  /// Returns user data map or null if not available.
  Future<Map<String, dynamic>?> getUserData() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    return await _storageService.getUserData();
  }

  /// Refreshes the authentication token
  ///
  /// Some APIs require periodic token refresh. This method
  /// requests a new token using the current token.
  ///
  /// Returns the new token.
  /// Throws [AuthException] on failure.
  Future<String> refreshToken() async {
    try {
      final currentToken = await getAuthToken();
      if (currentToken == null) {
        throw AuthException('No token to refresh');
      }

      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['token'] ?? data['access_token'];

        if (newToken == null) {
          throw AuthException('No token in refresh response');
        }

        await _storageService.saveAuthToken(newToken);
        print('Token refreshed successfully');
        return newToken;
      } else {
        throw AuthException('Token refresh failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Token refresh failed: $e');
    }
  }

  /// Updates user profile information
  ///
  /// Parameters:
  /// - [updates]: Map of fields to update (e.g., name, email, phone)
  ///
  /// Returns updated user data.
  /// Throws [AuthException] on failure.
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _dio.put(
        '/auth/profile',
        data: updates,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data['data'] ?? response.data;

        // Update stored user data
        await _storageService.saveUserData(userData);
        _currentUser = userData;

        print('Profile updated successfully');
        return userData;
      } else {
        throw AuthException('Profile update failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Profile update failed: $e');
    }
  }

  /// Changes user password
  ///
  /// Parameters:
  /// - [currentPassword]: Current password for verification
  /// - [newPassword]: New password to set
  ///
  /// Returns true on success.
  /// Throws [AuthException] on failure.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        print('Password changed successfully');
        return true;
      } else {
        final errorMessage = response.data['message'] ??
                            response.data['error'] ??
                            'Password change failed';
        throw AuthException(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Password change failed: $e');
    }
  }

  /// Requests a password reset email
  ///
  /// Parameters:
  /// - [email]: Email address to send reset link to
  ///
  /// Returns true on success.
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        print('Password reset email sent to $email');
        return true;
      } else {
        throw AuthException('Failed to send password reset email');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Password reset request failed: $e');
    }
  }

  /// Validates authentication token
  ///
  /// Checks if the current token is still valid with the server.
  /// Returns true if valid, false otherwise.
  Future<bool> validateToken() async {
    try {
      final token = await getAuthToken();
      if (token == null) return false;

      final response = await _dio.get(
        '/auth/validate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }

  /// Gets authorization headers for API requests
  ///
  /// Returns headers map with Authorization bearer token.
  /// Returns empty map if not authenticated.
  ///
  /// Example:
  /// ```dart
  /// final headers = await AuthService().getAuthHeaders();
  /// final response = await dio.get('/api/data', options: Options(headers: headers));
  /// ```
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {};
  }

  /// Handles Dio errors and converts them to AuthException
  AuthException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AuthException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AuthException('Invalid credentials');
        } else if (statusCode == 403) {
          return AuthException('Access forbidden');
        } else if (statusCode == 422) {
          final message = error.response?.data['message'] ?? 'Validation error';
          return AuthException(message);
        }
        return AuthException('Server error: ${error.response?.data}');

      case DioExceptionType.cancel:
        return AuthException('Request cancelled');

      case DioExceptionType.connectionError:
        return AuthException('No internet connection');

      default:
        return AuthException('Unexpected error: ${error.message}');
    }
  }

  /// Closes the Dio client and releases resources
  void dispose() {
    _dio.close();
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
