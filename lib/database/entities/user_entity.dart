import 'package:floor/floor.dart';
import '../../models/user.dart';

/// Floor entity for User table
///
/// This entity represents the database schema for users with Floor ORM.
/// It stores authentication credentials and session information.
@Entity(
  tableName: 'users',
  indices: [
    Index(value: ['username'], unique: true),
    Index(value: ['email'], unique: true),
  ],
)
class UserEntity {
  /// Unique identifier (auto-increment primary key)
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// User's username (unique)
  final String username;

  /// User's email address (unique)
  final String email;

  /// Authentication token (JWT or session token)
  @ColumnInfo(name: 'auth_token')
  final String? authToken;

  /// Token expiration timestamp (milliseconds since epoch)
  @ColumnInfo(name: 'token_expiry')
  final int? tokenExpiry;

  /// Last login timestamp (milliseconds since epoch)
  @ColumnInfo(name: 'last_login')
  final int? lastLogin;

  /// Creates a new UserEntity instance
  UserEntity({
    this.id,
    required this.username,
    required this.email,
    this.authToken,
    this.tokenExpiry,
    this.lastLogin,
  });

  /// Creates a UserEntity from a User model
  factory UserEntity.fromModel(User user) {
    return UserEntity(
      id: user.id,
      username: user.username,
      email: user.email,
      authToken: user.authToken,
      tokenExpiry: user.tokenExpiry,
      lastLogin: user.lastLogin,
    );
  }

  /// Converts this entity to a User model
  User toModel() {
    return User(
      id: id,
      username: username,
      email: email,
      authToken: authToken,
      tokenExpiry: tokenExpiry,
      lastLogin: lastLogin,
    );
  }

  /// Creates a copy of this entity with updated fields
  UserEntity copyWith({
    int? id,
    String? username,
    String? email,
    String? authToken,
    int? tokenExpiry,
    int? lastLogin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      authToken: authToken ?? this.authToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
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
    return 'UserEntity(id: $id, username: $username, email: $email)';
  }
}
