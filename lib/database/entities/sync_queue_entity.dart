import 'package:floor/floor.dart';
import '../../models/sync_queue.dart';

/// Floor entity for SyncQueue table
///
/// This entity represents the database schema for synchronization queue
/// with Floor ORM. It tracks pending offline operations.
@Entity(
  tableName: 'sync_queue',
  indices: [
    Index(value: ['status']),
    Index(value: ['created_at']),
    Index(value: ['landmark_id']),
  ],
)
class SyncQueueEntity {
  /// Unique identifier (auto-increment primary key)
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Type of operation (CREATE, UPDATE, DELETE)
  @ColumnInfo(name: 'operation_type')
  final String operationType;

  /// ID of the landmark associated with this operation
  @ColumnInfo(name: 'landmark_id')
  final int? landmarkId;

  /// JSON payload containing the data to sync
  final String payload;

  /// Current status (PENDING, PROCESSING, FAILED, COMPLETED)
  final String status;

  /// Creation timestamp (milliseconds since epoch)
  @ColumnInfo(name: 'created_at')
  final int createdAt;

  /// Number of retry attempts
  @ColumnInfo(name: 'retry_count', defaultValue: '0')
  final int retryCount;

  /// Last error message if sync failed
  @ColumnInfo(name: 'error_message')
  final String? errorMessage;

  /// Timestamp of last retry attempt (milliseconds since epoch)
  @ColumnInfo(name: 'last_retry_at')
  final int? lastRetryAt;

  /// Creates a new SyncQueueEntity instance
  SyncQueueEntity({
    this.id,
    required this.operationType,
    this.landmarkId,
    required this.payload,
    this.status = 'PENDING',
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
    this.lastRetryAt,
  });

  /// Creates a SyncQueueEntity from a SyncQueue model
  factory SyncQueueEntity.fromModel(SyncQueue syncQueue) {
    return SyncQueueEntity(
      id: syncQueue.id,
      operationType: syncQueue.operationType.toStorageString(),
      landmarkId: syncQueue.landmarkId,
      payload: syncQueue.payload,
      status: syncQueue.status.toStorageString(),
      createdAt: syncQueue.createdAt,
      retryCount: syncQueue.retryCount,
      errorMessage: syncQueue.errorMessage,
      lastRetryAt: syncQueue.lastRetryAt,
    );
  }

  /// Converts this entity to a SyncQueue model
  SyncQueue toModel() {
    return SyncQueue(
      id: id,
      operationType: SyncOperationType.fromStorageString(operationType),
      landmarkId: landmarkId,
      payload: payload,
      status: SyncStatus.fromStorageString(status),
      createdAt: createdAt,
      retryCount: retryCount,
      errorMessage: errorMessage,
      lastRetryAt: lastRetryAt,
    );
  }

  /// Creates a copy of this entity with updated fields
  SyncQueueEntity copyWith({
    int? id,
    String? operationType,
    int? landmarkId,
    String? payload,
    String? status,
    int? createdAt,
    int? retryCount,
    String? errorMessage,
    int? lastRetryAt,
  }) {
    return SyncQueueEntity(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      landmarkId: landmarkId ?? this.landmarkId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncQueueEntity &&
        other.id == id &&
        other.operationType == operationType &&
        other.landmarkId == landmarkId &&
        other.payload == payload &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.retryCount == retryCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        operationType.hashCode ^
        landmarkId.hashCode ^
        payload.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        retryCount.hashCode;
  }

  @override
  String toString() {
    return 'SyncQueueEntity(id: $id, operation: $operationType, landmarkId: $landmarkId, status: $status)';
  }
}
