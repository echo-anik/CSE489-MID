# Database Schema Documentation
## Flutter Landmark Management Application

---

## Table of Contents
1. [Database Overview](#database-overview)
2. [Technology Stack](#technology-stack)
3. [Entity-Relationship Diagram](#entity-relationship-diagram)
4. [Table Schemas](#table-schemas)
5. [Data Flow Diagrams](#data-flow-diagrams)
6. [Synchronization Strategy](#synchronization-strategy)
7. [Migration Strategy](#migration-strategy)
8. [Best Practices](#best-practices)

---

## Database Overview

### Purpose of Local Database

The local database serves as the foundation for an **offline-first architecture**, enabling the Flutter landmark management app to:

1. **Offline Functionality**: Allow users to view and interact with landmarks without an active internet connection
2. **Performance Optimization**: Reduce API calls and improve app responsiveness by caching data locally
3. **Data Persistence**: Store user authentication credentials and session tokens securely
4. **Sync Management**: Queue offline operations for synchronization when connectivity is restored
5. **Conflict Resolution**: Track changes and manage data conflicts between local and remote states

### Offline-First Strategy

The application follows an **offline-first approach**:

- All data is initially loaded from the local database
- Background sync operations update the local cache with remote data
- User modifications are saved locally and queued for server synchronization
- Optimistic UI updates provide immediate feedback to users
- Conflict resolution ensures data consistency across devices

---

## Technology Stack

### Recommended: Floor (with SQLite)

**Floor** is the recommended ORM (Object-Relational Mapping) library for this Flutter application.

#### Why Floor?

| Feature | Description |
|---------|-------------|
| **Type Safety** | Compile-time verification of SQL queries |
| **Code Generation** | Automatic DAO and entity generation |
| **SQLite Foundation** | Built on the robust SQLite database engine |
| **Room-like API** | Familiar architecture for Android developers |
| **Stream Support** | Real-time data updates with Dart streams |
| **Migration Support** | Built-in database versioning and migration |

#### Alternative: Drift (formerly Moor)

Drift is a more feature-rich alternative offering:
- Pure Dart SQL queries
- Advanced query capabilities
- Better testing support
- Web support through SQL.js

#### Dependencies

```yaml
dependencies:
  floor: ^1.4.2
  sqflite: ^2.3.0
  path_provider: ^2.1.1

dev_dependencies:
  floor_generator: ^1.4.2
  build_runner: ^2.4.6
```

---

## Entity-Relationship Diagram

```
+-------------------+
|      User         |
+-------------------+
| PK id             |
|    username       |
|    email          |
|    auth_token     |
|    token_expiry   |
|    last_login     |
+-------------------+
         |
         | (1 user can have multiple landmarks)
         |
         v
+-------------------+           +-----------------------+
|    Landmark       |           |     SyncQueue         |
+-------------------+           +-----------------------+
| PK id             |           | PK id                 |
|    title          |           |    operation_type     |
|    latitude       |           | FK landmark_id ------>|
|    longitude      |           |    payload            |
|    image_path     |           |    status             |
|    image_url      |           |    created_at         |
|    is_synced      |           |    retry_count        |
|    created_at     |           +-----------------------+
|    updated_at     |
+-------------------+


Legend:
--------
PK = Primary Key
FK = Foreign Key
```

### Relationship Summary

| Relationship | Type | Description |
|--------------|------|-------------|
| User ↔ Landmark | One-to-Many (Optional) | A user can have multiple landmarks (for multi-user support) |
| Landmark ↔ SyncQueue | One-to-Many | A landmark can have multiple pending sync operations |

---

## Table Schemas

### 1. Landmarks Table

Primary table for caching landmark data with offline support.

#### Schema Definition

```sql
CREATE TABLE landmarks (
    id INTEGER PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    image_path TEXT,
    image_url TEXT,
    is_synced INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,

    -- Constraints
    CHECK (latitude >= -90 AND latitude <= 90),
    CHECK (longitude >= -180 AND longitude <= 180),
    CHECK (is_synced IN (0, 1))
);

-- Indexes for performance optimization
CREATE INDEX idx_landmarks_title ON landmarks(title);
CREATE INDEX idx_landmarks_sync_status ON landmarks(is_synced);
CREATE INDEX idx_landmarks_updated_at ON landmarks(updated_at DESC);
CREATE INDEX idx_landmarks_location ON landmarks(latitude, longitude);
```

#### Field Specifications

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, NOT NULL | Unique identifier, synced with server ID |
| `title` | TEXT | NOT NULL | Landmark name/title |
| `latitude` | REAL | NOT NULL, CHECK (-90 to 90) | Geographic latitude coordinate |
| `longitude` | REAL | NOT NULL, CHECK (-180 to 180) | Geographic longitude coordinate |
| `image_path` | TEXT | NULLABLE | Local file path to cached image |
| `image_url` | TEXT | NULLABLE | Remote URL for the landmark image |
| `is_synced` | INTEGER | NOT NULL, DEFAULT 1 | Sync status: 0 = not synced, 1 = synced |
| `created_at` | INTEGER | NOT NULL | Unix timestamp (milliseconds) of creation |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp (milliseconds) of last update |

#### Floor Entity (Dart)

```dart
import 'package:floor/floor.dart';

@Entity(tableName: 'landmarks', indices: [
  Index(value: ['title']),
  Index(value: ['is_synced']),
  Index(value: ['updated_at']),
])
class Landmark {
  @PrimaryKey()
  final int id;

  final String title;

  final double latitude;

  final double longitude;

  @ColumnInfo(name: 'image_path')
  final String? imagePath;

  @ColumnInfo(name: 'image_url')
  final String? imageUrl;

  @ColumnInfo(name: 'is_synced', defaultValue: '1')
  final bool isSynced;

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  Landmark({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    this.imageUrl,
    this.isSynced = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Validation method
  bool isValid() {
    return latitude >= -90 && latitude <= 90 &&
           longitude >= -180 && longitude <= 180 &&
           title.isNotEmpty;
  }
}
```

---

### 2. User Table

Stores user authentication data and session information.

#### Schema Definition

```sql
CREATE TABLE user (
    id INTEGER PRIMARY KEY NOT NULL,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE,
    auth_token TEXT,
    token_expiry INTEGER,
    last_login INTEGER,

    -- Constraints
    CHECK (LENGTH(username) >= 3),
    CHECK (email IS NULL OR email LIKE '%_@_%._%')
);

-- Indexes
CREATE UNIQUE INDEX idx_user_username ON user(username);
CREATE UNIQUE INDEX idx_user_email ON user(email) WHERE email IS NOT NULL;
```

#### Field Specifications

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, NOT NULL | User's unique identifier |
| `username` | TEXT | UNIQUE, NOT NULL, MIN LENGTH 3 | User's login username |
| `email` | TEXT | UNIQUE, NULLABLE, EMAIL FORMAT | User's email address |
| `auth_token` | TEXT | NULLABLE | JWT or session token from server |
| `token_expiry` | INTEGER | NULLABLE | Unix timestamp when token expires |
| `last_login` | INTEGER | NULLABLE | Unix timestamp of last successful login |

#### Floor Entity (Dart)

```dart
import 'package:floor/floor.dart';

@Entity(tableName: 'user', indices: [
  Index(value: ['username'], unique: true),
  Index(value: ['email'], unique: true),
])
class User {
  @PrimaryKey()
  final int id;

  final String username;

  final String? email;

  @ColumnInfo(name: 'auth_token')
  final String? authToken;

  @ColumnInfo(name: 'token_expiry')
  final int? tokenExpiry;

  @ColumnInfo(name: 'last_login')
  final int? lastLogin;

  User({
    required this.id,
    required this.username,
    this.email,
    this.authToken,
    this.tokenExpiry,
    this.lastLogin,
  });

  // Check if token is valid
  bool isTokenValid() {
    if (authToken == null || tokenExpiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < tokenExpiry!;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return authToken != null && isTokenValid();
  }
}
```

---

### 3. Sync Queue Table

Manages offline operations that need to be synchronized with the server.

#### Schema Definition

```sql
CREATE TABLE sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation_type TEXT NOT NULL,
    landmark_id INTEGER,
    payload TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at INTEGER NOT NULL,
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,

    -- Constraints
    CHECK (operation_type IN ('CREATE', 'UPDATE', 'DELETE')),
    CHECK (status IN ('PENDING', 'SYNCED', 'FAILED')),
    CHECK (retry_count >= 0),

    -- Foreign Key (optional, can be NULL for CREATE operations)
    FOREIGN KEY (landmark_id) REFERENCES landmarks(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_created_at ON sync_queue(created_at ASC);
CREATE INDEX idx_sync_queue_landmark ON sync_queue(landmark_id);
```

#### Field Specifications

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Auto-generated unique identifier |
| `operation_type` | TEXT | NOT NULL, ENUM | Type of operation: CREATE, UPDATE, DELETE |
| `landmark_id` | INTEGER | NULLABLE, FOREIGN KEY | Reference to landmark (NULL for CREATE) |
| `payload` | TEXT | NOT NULL | JSON serialized landmark data |
| `status` | TEXT | NOT NULL, DEFAULT 'PENDING' | Sync status: PENDING, SYNCED, FAILED |
| `created_at` | INTEGER | NOT NULL | Unix timestamp when queued |
| `retry_count` | INTEGER | NOT NULL, DEFAULT 0 | Number of sync attempts |
| `last_error` | TEXT | NULLABLE | Error message from last failed attempt |

#### Floor Entity (Dart)

```dart
import 'package:floor/floor.dart';

@Entity(
  tableName: 'sync_queue',
  foreignKeys: [
    ForeignKey(
      childColumns: ['landmark_id'],
      parentColumns: ['id'],
      entity: Landmark,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [
    Index(value: ['status']),
    Index(value: ['created_at']),
    Index(value: ['landmark_id']),
  ],
)
class SyncQueueItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'operation_type')
  final String operationType; // 'CREATE', 'UPDATE', 'DELETE'

  @ColumnInfo(name: 'landmark_id')
  final int? landmarkId;

  final String payload; // JSON string

  final String status; // 'PENDING', 'SYNCED', 'FAILED'

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'retry_count', defaultValue: '0')
  final int retryCount;

  @ColumnInfo(name: 'last_error')
  final String? lastError;

  SyncQueueItem({
    this.id,
    required this.operationType,
    this.landmarkId,
    required this.payload,
    this.status = 'PENDING',
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  // Check if should retry
  bool shouldRetry() {
    return status == 'FAILED' && retryCount < 3;
  }
}
```

---

## Data Flow Diagrams

### 1. Application Startup Flow

```
+------------------+
| App Launches     |
+------------------+
         |
         v
+------------------+
| Initialize DB    |
| (Floor)          |
+------------------+
         |
         v
+------------------+
| Check User Auth  |
| (User Table)     |
+------------------+
         |
         +------ Token Valid? ------+
         |                          |
        YES                        NO
         |                          |
         v                          v
+------------------+      +------------------+
| Load Landmarks   |      | Show Login       |
| from Local DB    |      | Screen           |
+------------------+      +------------------+
         |
         v
+------------------+
| Display UI       |
+------------------+
         |
         v
+------------------+
| Background Sync  |
| (If Connected)   |
+------------------+
```

### 2. Data Fetch Flow (Read Operation)

```
+------------------------+
| User Requests Data     |
+------------------------+
         |
         v
+------------------------+
| Query Local DB         |
| (Landmarks Table)      |
+------------------------+
         |
         v
+------------------------+
| Display Cached Data    |
| (Immediate Response)   |
+------------------------+
         |
         v
+------------------------+      YES    +------------------------+
| Internet Available?    |------------>| Fetch from API         |
+------------------------+             +------------------------+
         |                                        |
         NO                                       v
         |                             +------------------------+
         |                             | Compare with Local     |
         |                             | (by updated_at)        |
         |                             +------------------------+
         |                                        |
         |                                        v
         |                             +------------------------+
         |                             | Update Local DB        |
         |                             | (if newer)             |
         |                             +------------------------+
         |                                        |
         |                                        v
         |                             +------------------------+
         |                             | Download Images        |
         |                             | (Save to image_path)   |
         |                             +------------------------+
         |                                        |
         +----------------------------------------+
         |
         v
+------------------------+
| Display Final Data     |
+------------------------+
```

### 3. Data Modification Flow (Create/Update/Delete)

```
+------------------------+
| User Modifies Data     |
| (Create/Update/Delete) |
+------------------------+
         |
         v
+------------------------+
| Save to Local DB       |
| (Optimistic Update)    |
+------------------------+
         |
         v
+------------------------+
| Set is_synced = 0      |
| (Mark as Unsynced)     |
+------------------------+
         |
         v
+------------------------+
| Add to SyncQueue       |
| (operation_type,       |
|  payload, status)      |
+------------------------+
         |
         v
+------------------------+
| Update UI              |
| (Show Success)         |
+------------------------+
         |
         v
+------------------------+      YES    +------------------------+
| Internet Available?    |------------>| Process Sync Queue     |
+------------------------+             +------------------------+
         |                                        |
         NO                                       v
         |                             +------------------------+
         |                             | Send to API            |
         |                             +------------------------+
         |                                        |
         |                             +----------+----------+
         |                             |                     |
         |                           SUCCESS              FAILURE
         |                             |                     |
         |                             v                     v
         |                  +-------------------+  +-------------------+
         |                  | Update Local DB   |  | Increment         |
         |                  | Set is_synced = 1 |  | retry_count       |
         |                  | Update id if new  |  | Set status=FAILED |
         |                  | Remove from queue |  | Store last_error  |
         |                  +-------------------+  +-------------------+
         |                             |                     |
         +-----------------------------+---------------------+
         |
         v
+------------------------+
| Wait for Connection    |
| (Background Sync)      |
+------------------------+
```

### 4. Sync Process Flow

```
+---------------------------+
| Connectivity Restored     |
+---------------------------+
         |
         v
+---------------------------+
| Query SyncQueue           |
| WHERE status = 'PENDING'  |
| OR status = 'FAILED'      |
| ORDER BY created_at ASC   |
+---------------------------+
         |
         v
+---------------------------+
| Process Items             |
| Sequentially              |
+---------------------------+
         |
         v
+---------------------------+
| For Each Item:            |
+---------------------------+
         |
         +------ operation_type ------+
         |              |              |
      CREATE         UPDATE         DELETE
         |              |              |
         v              v              v
+-------------+  +-------------+  +-------------+
| POST /api/  |  | PUT /api/   |  | DELETE /api/|
| landmarks   |  | landmarks/  |  | landmarks/  |
+-------------+  | {id}        |  | {id}        |
         |       +-------------+  +-------------+
         |              |              |
         +------ Response Check -------+
         |
         +------ Success? ------+
         |                      |
        YES                    NO
         |                      |
         v                      v
+------------------+  +----------------------+
| Mark as SYNCED   |  | Increment retry_count|
| Update landmark  |  | Mark as FAILED       |
| is_synced = 1    |  | Store error message  |
| Remove from queue|  +----------------------+
+------------------+            |
         |                      v
         |            +----------------------+
         |            | retry_count > 3?     |
         |            +----------------------+
         |                      |
         |                      v
         |            +----------------------+
         |            | Show User Error      |
         |            | Require Manual       |
         |            | Resolution           |
         |            +----------------------+
         |                      |
         +----------------------+
         |
         v
+---------------------------+
| Fetch Latest from Server  |
| (Full Sync)               |
+---------------------------+
         |
         v
+---------------------------+
| Update Local Cache        |
+---------------------------+
```

---

## Synchronization Strategy

### Sync Policies

#### 1. **Pull Sync (Server to Local)**

| Trigger | Frequency | Strategy |
|---------|-----------|----------|
| App Launch | Every time | Fetch all landmarks, compare timestamps |
| Manual Refresh | On demand | User-initiated full sync |
| Background Sync | Every 15 min | Fetch updates since last sync |
| After Push Sync | Immediately | Verify changes were applied |

#### 2. **Push Sync (Local to Server)**

| Trigger | Strategy |
|---------|----------|
| Immediate (Online) | Send to server immediately after local save |
| Queued (Offline) | Add to sync_queue, process when connected |
| Batch Sync | Process all pending items in sequence |

### Conflict Resolution

#### Timestamp-Based Resolution (Last-Write-Wins)

```dart
Future<Landmark> resolveConflict(Landmark local, Landmark remote) async {
  // Compare updated_at timestamps
  if (local.updatedAt > remote.updatedAt) {
    // Local is newer, push to server
    await apiService.updateLandmark(local);
    return local;
  } else {
    // Remote is newer, update local
    await landmarkDao.updateLandmark(remote);
    return remote;
  }
}
```

#### Conflict Detection

```sql
-- Find landmarks with sync conflicts
SELECT l.*
FROM landmarks l
INNER JOIN sync_queue sq ON l.id = sq.landmark_id
WHERE l.is_synced = 0
  AND sq.status = 'FAILED'
  AND sq.retry_count > 0;
```

### Sync State Management

| State | is_synced | In SyncQueue | Description |
|-------|-----------|--------------|-------------|
| Clean | 1 | No | Synced with server, no pending changes |
| Dirty | 0 | Yes (PENDING) | Local changes not yet synced |
| Syncing | 0 | Yes (PENDING) | Currently being synced |
| Conflict | 0 | Yes (FAILED) | Sync failed, requires resolution |
| Orphaned | 0 | No | Unsynced but not in queue (error state) |

---

## Migration Strategy

### Database Versioning

Floor uses version numbers to manage schema changes.

#### Version History

| Version | Date | Changes | Migration Required |
|---------|------|---------|-------------------|
| 1 | Initial | Create landmarks, user, sync_queue tables | N/A |
| 2 | Future | Add user_id to landmarks table | Yes |
| 3 | Future | Add favorite field to landmarks | No (DEFAULT value) |

### Migration Implementation

#### Migration Example: Version 1 to Version 2

```dart
import 'package:floor/floor.dart';

// Migration from version 1 to 2
final migration1to2 = Migration(1, 2, (database) async {
  // Add user_id column to landmarks table
  await database.execute(
    'ALTER TABLE landmarks ADD COLUMN user_id INTEGER'
  );

  // Create index on new column
  await database.execute(
    'CREATE INDEX idx_landmarks_user ON landmarks(user_id)'
  );
});

// Migration from version 2 to 3
final migration2to3 = Migration(2, 3, (database) async {
  // Add is_favorite column with default value
  await database.execute(
    'ALTER TABLE landmarks ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0'
  );

  // Create index for favorites
  await database.execute(
    'CREATE INDEX idx_landmarks_favorite ON landmarks(is_favorite) WHERE is_favorite = 1'
  );
});
```

#### Database Builder with Migrations

```dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

@Database(version: 3, entities: [Landmark, User, SyncQueueItem])
abstract class AppDatabase extends FloorDatabase {
  LandmarkDao get landmarkDao;
  UserDao get userDao;
  SyncQueueDao get syncQueueDao;
}

// Database initialization
Future<AppDatabase> initializeDatabase() async {
  return await $FloorAppDatabase
      .databaseBuilder('landmark_database.db')
      .addMigrations([
        migration1to2,
        migration2to3,
      ])
      .build();
}
```

### Fallback Strategy

If migration fails, implement a fallback:

```dart
Future<AppDatabase> initializeDatabaseWithFallback() async {
  try {
    return await $FloorAppDatabase
        .databaseBuilder('landmark_database.db')
        .addMigrations([migration1to2, migration2to3])
        .build();
  } catch (e) {
    // Migration failed, create fresh database
    // WARNING: This will delete all local data
    await sqflite.deleteDatabase('landmark_database.db');

    return await $FloorAppDatabase
        .databaseBuilder('landmark_database.db')
        .build();
  }
}
```

### Schema Export

```sql
-- Complete schema for version 1

CREATE TABLE landmarks (
    id INTEGER PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    image_path TEXT,
    image_url TEXT,
    is_synced INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    CHECK (latitude >= -90 AND latitude <= 90),
    CHECK (longitude >= -180 AND longitude <= 180),
    CHECK (is_synced IN (0, 1))
);

CREATE TABLE user (
    id INTEGER PRIMARY KEY NOT NULL,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE,
    auth_token TEXT,
    token_expiry INTEGER,
    last_login INTEGER,
    CHECK (LENGTH(username) >= 3),
    CHECK (email IS NULL OR email LIKE '%_@_%._%')
);

CREATE TABLE sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation_type TEXT NOT NULL,
    landmark_id INTEGER,
    payload TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at INTEGER NOT NULL,
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    CHECK (operation_type IN ('CREATE', 'UPDATE', 'DELETE')),
    CHECK (status IN ('PENDING', 'SYNCED', 'FAILED')),
    CHECK (retry_count >= 0),
    FOREIGN KEY (landmark_id) REFERENCES landmarks(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_landmarks_title ON landmarks(title);
CREATE INDEX idx_landmarks_sync_status ON landmarks(is_synced);
CREATE INDEX idx_landmarks_updated_at ON landmarks(updated_at DESC);
CREATE INDEX idx_landmarks_location ON landmarks(latitude, longitude);
CREATE UNIQUE INDEX idx_user_username ON user(username);
CREATE UNIQUE INDEX idx_user_email ON user(email) WHERE email IS NOT NULL;
CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_created_at ON sync_queue(created_at ASC);
CREATE INDEX idx_sync_queue_landmark ON sync_queue(landmark_id);
```

---

## Best Practices

### 1. Data Access Objects (DAOs)

```dart
import 'package:floor/floor.dart';

@dao
abstract class LandmarkDao {
  // Query all landmarks
  @Query('SELECT * FROM landmarks ORDER BY updated_at DESC')
  Stream<List<Landmark>> watchAllLandmarks();

  // Query by ID
  @Query('SELECT * FROM landmarks WHERE id = :id')
  Future<Landmark?> findLandmarkById(int id);

  // Query unsynced landmarks
  @Query('SELECT * FROM landmarks WHERE is_synced = 0')
  Future<List<Landmark>> findUnsyncedLandmarks();

  // Insert landmark
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertLandmark(Landmark landmark);

  // Update landmark
  @Update()
  Future<void> updateLandmark(Landmark landmark);

  // Delete landmark
  @delete
  Future<void> deleteLandmark(Landmark landmark);

  // Custom query: Search by title
  @Query('SELECT * FROM landmarks WHERE title LIKE :searchTerm ORDER BY title')
  Future<List<Landmark>> searchLandmarks(String searchTerm);

  // Bulk insert
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertLandmarks(List<Landmark> landmarks);

  // Clear all landmarks
  @Query('DELETE FROM landmarks')
  Future<void> deleteAllLandmarks();
}

@dao
abstract class UserDao {
  @Query('SELECT * FROM user LIMIT 1')
  Future<User?> getCurrentUser();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(User user);

  @Update()
  Future<void> updateUser(User user);

  @Query('DELETE FROM user')
  Future<void> logout();
}

@dao
abstract class SyncQueueDao {
  @Query('SELECT * FROM sync_queue WHERE status = :status ORDER BY created_at ASC')
  Future<List<SyncQueueItem>> findByStatus(String status);

  @Insert()
  Future<void> insertSyncItem(SyncQueueItem item);

  @Update()
  Future<void> updateSyncItem(SyncQueueItem item);

  @delete
  Future<void> deleteSyncItem(SyncQueueItem item);

  @Query('DELETE FROM sync_queue WHERE status = :status')
  Future<void> clearByStatus(String status);
}
```

### 2. Repository Pattern

```dart
class LandmarkRepository {
  final LandmarkDao _landmarkDao;
  final SyncQueueDao _syncQueueDao;
  final ApiService _apiService;

  LandmarkRepository(this._landmarkDao, this._syncQueueDao, this._apiService);

  // Get landmarks (offline-first)
  Stream<List<Landmark>> watchLandmarks() {
    // Return stream from local database
    _syncInBackground();
    return _landmarkDao.watchAllLandmarks();
  }

  // Create landmark
  Future<void> createLandmark(Landmark landmark) async {
    await _landmarkDao.insertLandmark(landmark.copyWith(isSynced: false));
    await _queueSync('CREATE', landmark);

    if (await _isOnline()) {
      await _processSync();
    }
  }

  // Background sync
  Future<void> _syncInBackground() async {
    if (await _isOnline()) {
      try {
        final remoteLandmarks = await _apiService.fetchLandmarks();
        await _landmarkDao.insertLandmarks(remoteLandmarks);
      } catch (e) {
        // Silently fail, use cached data
      }
    }
  }

  // Queue sync operation
  Future<void> _queueSync(String operation, Landmark landmark) async {
    final syncItem = SyncQueueItem(
      operationType: operation,
      landmarkId: landmark.id,
      payload: jsonEncode(landmark.toJson()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueueDao.insertSyncItem(syncItem);
  }

  Future<bool> _isOnline() async {
    // Check connectivity
    return true; // Implement connectivity check
  }

  Future<void> _processSync() async {
    // Process sync queue
  }
}
```

### 3. Error Handling

```dart
class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  DatabaseException(this.message, [this.originalError]);

  @override
  String toString() => 'DatabaseException: $message';
}

class SyncException implements Exception {
  final String message;
  final SyncQueueItem? failedItem;

  SyncException(this.message, [this.failedItem]);

  @override
  String toString() => 'SyncException: $message';
}
```

### 4. Testing Strategy

```dart
// Unit test example
void main() {
  group('Landmark DAO Tests', () {
    late AppDatabase database;
    late LandmarkDao landmarkDao;

    setUp(() async {
      database = await $FloorAppDatabase
          .inMemoryDatabaseBuilder()
          .build();
      landmarkDao = database.landmarkDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('Insert and retrieve landmark', () async {
      final landmark = Landmark(
        id: 1,
        title: 'Test Landmark',
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await landmarkDao.insertLandmark(landmark);
      final retrieved = await landmarkDao.findLandmarkById(1);

      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Test Landmark'));
    });
  });
}
```

### 5. Performance Optimization

- **Use Indexes**: Create indexes on frequently queried columns
- **Batch Operations**: Use bulk insert/update for multiple records
- **Streams**: Use `Stream` for reactive UI updates
- **Pagination**: Implement cursor-based pagination for large datasets
- **Lazy Loading**: Load images on-demand, not with landmark data
- **Transaction**: Wrap related operations in transactions

```dart
// Transaction example
Future<void> bulkUpdate(List<Landmark> landmarks) async {
  await database.transaction(() async {
    for (final landmark in landmarks) {
      await landmarkDao.updateLandmark(landmark);
    }
  });
}
```

### 6. Security Considerations

- **Encrypt Sensitive Data**: Use `flutter_secure_storage` for auth tokens
- **SQL Injection Protection**: Floor/SQLite automatically prevents SQL injection
- **Validation**: Always validate data before inserting
- **Token Expiry**: Check token expiry before API calls
- **Clear on Logout**: Delete user data when logging out

```dart
// Secure token storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

---

## Summary

This database schema provides a robust foundation for a Flutter landmark management application with:

- **Offline-first architecture** using Floor and SQLite
- **Efficient data synchronization** with conflict resolution
- **User authentication** with secure token management
- **Scalable design** supporting future enhancements
- **Performance optimization** through proper indexing
- **Migration support** for schema evolution

For implementation questions or schema modifications, refer to the [Floor documentation](https://pub.dev/packages/floor) and [SQLite reference](https://www.sqlite.org/docs.html).

---

**Document Version**: 1.0
**Last Updated**: 2025-12-07
**Author**: Development Team
