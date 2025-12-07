import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider class for managing authentication state
///
/// Handles user login, registration, logout, and session persistence
class AuthProvider with ChangeNotifier {
  final ApiService _apiService;

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider({required ApiService apiService}) : _apiService = apiService;

  /// Check authentication status on app start
  ///
  /// Loads saved user data and validates token
  Future<void> checkAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');

      if (token != null && userId != null && email != null) {
        // Validate token with API
        try {
          // Set token in API service
          _apiService.setAuthToken(token);

          // Create user object from saved data
          _currentUser = User(
            id: userId,
            email: email,
            name: name ?? '',
          );

          _isAuthenticated = true;
        } catch (e) {
          // Token invalid, clear saved data
          await _clearAuthData();
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      print('Error checking auth: $e');
    }
  }

  /// Login user with email and password
  ///
  /// [email] User email
  /// [password] User password
  ///
  /// Returns true if login successful, false otherwise
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API login
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      // Extract user and token from response
      _currentUser = response['user'];
      final token = response['token'];

      // Save auth data
      await _saveAuthData(
        token: token,
        user: _currentUser!,
      );

      // Set token in API service
      _apiService.setAuthToken(token);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Login failed: ${e.toString()}';
      _isAuthenticated = false;
      notifyListeners();
      print('Error logging in: $e');
      return false;
    }
  }

  /// Register new user
  ///
  /// [name] User name
  /// [email] User email
  /// [password] User password
  ///
  /// Returns true if registration successful, false otherwise
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API register
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );

      // Extract user and token from response
      _currentUser = response['user'];
      final token = response['token'];

      // Save auth data
      await _saveAuthData(
        token: token,
        user: _currentUser!,
      );

      // Set token in API service
      _apiService.setAuthToken(token);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Registration failed: ${e.toString()}';
      _isAuthenticated = false;
      notifyListeners();
      print('Error registering: $e');
      return false;
    }
  }

  /// Logout current user
  ///
  /// Clears all saved authentication data
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call API logout (optional, for server-side session cleanup)
      try {
        await _apiService.logout();
      } catch (e) {
        print('API logout error (continuing anyway): $e');
      }

      // Clear local auth data
      await _clearAuthData();

      // Clear API token
      _apiService.clearAuthToken();

      _currentUser = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error logging out: $e');
    }
  }

  /// Update user profile
  ///
  /// [name] Updated name
  /// [email] Updated email
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API to update profile
      final updatedUser = await _apiService.updateProfile(
        name: name,
        email: email,
      );

      // Update current user
      _currentUser = updatedUser;

      // Update saved data
      final prefs = await SharedPreferences.getInstance();
      if (name != null) {
        await prefs.setString('user_name', name);
      }
      if (email != null) {
        await prefs.setString('user_email', email);
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Change user password
  ///
  /// [currentPassword] Current password
  /// [newPassword] New password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API to change password
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to change password: ${e.toString()}';
      notifyListeners();
      print('Error changing password: $e');
      return false;
    }
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData({
    required String token,
    required User user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setInt('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.name ?? '');
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  /// Clear authentication data from local storage
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }
}
