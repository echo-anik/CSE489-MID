/// User data model representing an authenticated user
///
/// This model stores user authentication information and session data.
/// It works in conjunction with UserEntity for Floor database operations.
class User {
  /// Unique identifier for the user (synced with server)
  final int? id;

  /// User's username
  final String username;

  /// User's email address
  final String email;

  /// Authentication token (JWT or session token)
  final String? authToken;

  /// Token expiration timestamp (milliseconds since epoch)
  final int? tokenExpiry;

  /// Last login timestamp (milliseconds since epoch)
  final int? lastLogin;

  /// Creates a new User instance
  User({
    this.id,
    required this.username,
    required this.email,
    this.authToken,
    this.tokenExpiry,
    this.lastLogin,
  });

  /// Creates a User from JSON data (API response)
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "username": "john_doe",
  ///   "email": "john@example.com",
  ///   "authToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///   "tokenExpiry": 1704067200000,
  ///   "lastLogin": 1703980800000
  /// }
  /// ```
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      authToken: json['authToken']?.toString() ?? json['auth_token']?.toString(),
      tokenExpiry: _parseInt(json['tokenExpiry'] ?? json['token_expiry']),
      lastLogin: _parseInt(json['lastLogin'] ?? json['last_login']),
    );
  }

  /// Converts the User to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      if (authToken != null) 'authToken': authToken,
      if (tokenExpiry != null) 'tokenExpiry': tokenExpiry,
      if (lastLogin != null) 'lastLogin': lastLogin,
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

  /// Creates a copy of this User with updated fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? authToken,
    int? tokenExpiry,
    int? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      authToken: authToken ?? this.authToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  /// Returns true if the user has a valid authentication token
  bool get isAuthenticated => authToken != null && authToken!.isNotEmpty;

  /// Returns true if the authentication token has expired
  bool get isTokenExpired {
    if (tokenExpiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > tokenExpiry!;
  }

  /// Returns true if the user is authenticated and token is not expired
  bool get isValidSession => isAuthenticated && !isTokenExpired;

  /// Returns a DateTime object for token expiry time
  DateTime? get tokenExpiryDateTime {
    if (tokenExpiry == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(tokenExpiry!);
  }

  /// Returns a DateTime object for last login time
  DateTime? get lastLoginDateTime {
    if (lastLogin == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastLogin!);
  }

  /// Returns the number of milliseconds until token expires (null if expired or no expiry)
  int? get timeUntilTokenExpiry {
    if (tokenExpiry == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = tokenExpiry! - now;
    return remaining > 0 ? remaining : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.authToken == authToken &&
        other.tokenExpiry == tokenExpiry &&
        other.lastLogin == lastLogin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        authToken.hashCode ^
        tokenExpiry.hashCode ^
        lastLogin.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, authenticated: $isAuthenticated)';
  }
}
