import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences
///
/// This service provides a wrapper around SharedPreferences for
/// storing and retrieving various types of data including authentication
/// tokens, user data, and app preferences.
class StorageService {
  // Singleton pattern implementation
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  /// SharedPreferences instance
  SharedPreferences? _prefs;

  /// Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  /// Initializes the SharedPreferences instance
  ///
  /// Should be called before using any other methods.
  /// Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// await StorageService().init();
  /// ```
  Future<bool> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      return true;
    } catch (e) {
      print('Error initializing StorageService: $e');
      return false;
    }
  }

  /// Ensures SharedPreferences is initialized
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== Authentication ====================

  /// Saves the authentication token
  ///
  /// Parameters:
  /// - [token]: The authentication token to save
  ///
  /// Example:
  /// ```dart
  /// await StorageService().saveAuthToken('your_token_here');
  /// ```
  Future<bool> saveAuthToken(String token) async {
    try {
      final prefs = await _getPrefs();
      final success = await prefs.setString(_authTokenKey, token);
      if (success) {
        await prefs.setBool(_isAuthenticatedKey, true);
      }
      return success;
    } catch (e) {
      print('Error saving auth token: $e');
      return false;
    }
  }

  /// Retrieves the stored authentication token
  ///
  /// Returns the token string or null if not found.
  ///
  /// Example:
  /// ```dart
  /// final token = await StorageService().getAuthToken();
  /// ```
  Future<String?> getAuthToken() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  /// Checks if the user is authenticated
  ///
  /// Returns true if authenticated, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (await StorageService().isAuthenticated()) {
  ///   // User is logged in
  /// }
  /// ```
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await _getPrefs();
      final hasToken = prefs.getString(_authTokenKey) != null;
      final isAuth = prefs.getBool(_isAuthenticatedKey) ?? false;
      return hasToken && isAuth;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // ==================== User Data ====================

  /// Saves user data as JSON
  ///
  /// Parameters:
  /// - [userData]: Map containing user information
  ///
  /// Example:
  /// ```dart
  /// await StorageService().saveUserData({
  ///   'id': '123',
  ///   'name': 'John Doe',
  ///   'email': 'john@example.com',
  /// });
  /// ```
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = json.encode(userData);
      final success = await prefs.setString(_userDataKey, jsonString);

      // Also save individual fields for quick access
      if (success) {
        await prefs.setString(_userIdKey, userData['id']?.toString() ?? '');
        await prefs.setString(_userNameKey, userData['name']?.toString() ?? '');
        await prefs.setString(_userEmailKey, userData['email']?.toString() ?? '');
      }

      return success;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  /// Retrieves stored user data
  ///
  /// Returns a Map containing user information or null if not found.
  ///
  /// Example:
  /// ```dart
  /// final userData = await StorageService().getUserData();
  /// print('User: ${userData?['name']}');
  /// ```
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_userDataKey);

      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Gets the stored user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  /// Gets the stored user name
  Future<String?> getUserName() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  /// Gets the stored user email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // ==================== Sync Management ====================

  /// Saves the last sync timestamp
  ///
  /// Example:
  /// ```dart
  /// await StorageService().saveLastSyncTime(DateTime.now());
  /// ```
  Future<bool> saveLastSyncTime(DateTime timestamp) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setString(
        _lastSyncTimeKey,
        timestamp.toIso8601String(),
      );
    } catch (e) {
      print('Error saving last sync time: $e');
      return false;
    }
  }

  /// Gets the last sync timestamp
  ///
  /// Returns the DateTime of last sync or null if never synced.
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await _getPrefs();
      final timeString = prefs.getString(_lastSyncTimeKey);

      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  // ==================== App Preferences ====================

  /// Saves the theme mode preference
  ///
  /// Parameters:
  /// - [isDark]: true for dark mode, false for light mode
  Future<bool> saveThemeMode(bool isDark) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      print('Error saving theme mode: $e');
      return false;
    }
  }

  /// Gets the theme mode preference
  ///
  /// Returns true for dark mode, false for light mode, null if not set.
  Future<bool?> getThemeMode() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_themeKey);
    } catch (e) {
      print('Error getting theme mode: $e');
      return null;
    }
  }

  /// Saves the language preference
  Future<bool> saveLanguage(String languageCode) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
      return false;
    }
  }

  /// Gets the language preference
  Future<String?> getLanguage() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_languageKey);
    } catch (e) {
      print('Error getting language: $e');
      return null;
    }
  }

  // ==================== Generic Methods ====================

  /// Saves a string value
  Future<bool> setString(String key, String value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setString(key, value);
    } catch (e) {
      print('Error setting string: $e');
      return false;
    }
  }

  /// Gets a string value
  Future<String?> getString(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    } catch (e) {
      print('Error getting string: $e');
      return null;
    }
  }

  /// Saves an integer value
  Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setInt(key, value);
    } catch (e) {
      print('Error setting int: $e');
      return false;
    }
  }

  /// Gets an integer value
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(key);
    } catch (e) {
      print('Error getting int: $e');
      return null;
    }
  }

  /// Saves a boolean value
  Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(key, value);
    } catch (e) {
      print('Error setting bool: $e');
      return false;
    }
  }

  /// Gets a boolean value
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(key);
    } catch (e) {
      print('Error getting bool: $e');
      return null;
    }
  }

  /// Saves a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setStringList(key, value);
    } catch (e) {
      print('Error setting string list: $e');
      return false;
    }
  }

  /// Gets a list of strings
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getStringList(key);
    } catch (e) {
      print('Error getting string list: $e');
      return null;
    }
  }

  /// Removes a specific key from storage
  Future<bool> remove(String key) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.remove(key);
    } catch (e) {
      print('Error removing key: $e');
      return false;
    }
  }

  /// Checks if a key exists in storage
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey(key);
    } catch (e) {
      print('Error checking key: $e');
      return false;
    }
  }

  // ==================== Logout ====================

  /// Clears all authentication-related data
  ///
  /// This should be called when the user logs out.
  ///
  /// Example:
  /// ```dart
  /// await StorageService().clearAuthData();
  /// ```
  Future<bool> clearAuthData() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.setBool(_isAuthenticatedKey, false);
      return true;
    } catch (e) {
      print('Error clearing auth data: $e');
      return false;
    }
  }

  /// Clears all stored data
  ///
  /// WARNING: This removes all data including preferences.
  /// Use [clearAuthData] for logout instead.
  Future<bool> clearAll() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  /// Gets all stored keys
  Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getKeys();
    } catch (e) {
      print('Error getting all keys: $e');
      return {};
    }
  }
}
