/// SyncQueue data model representing a pending synchronization operation
///
/// This model tracks offline operations that need to be synced with the server
/// when network connectivity is restored. It works in conjunction with
/// SyncQueueEntity for Floor database operations.

/// Enum representing the type of synchronization operation
enum SyncOperationType {
  create,
  update,
  delete;

  /// Converts the enum to a string for storage
  String toStorageString() {
    switch (this) {
      case SyncOperationType.create:
        return 'CREATE';
      case SyncOperationType.update:
        return 'UPDATE';
      case SyncOperationType.delete:
        return 'DELETE';
    }
  }

  /// Creates an enum from a storage string
  static SyncOperationType fromStorageString(String value) {
    switch (value.toUpperCase()) {
      case 'CREATE':
        return SyncOperationType.create;
      case 'UPDATE':
        return SyncOperationType.update;
      case 'DELETE':
        return SyncOperationType.delete;
      default:
        return SyncOperationType.create;
    }
  }
}

/// Enum representing the status of a sync operation
enum SyncStatus {
  pending,
  processing,
  failed,
  completed;

  /// Converts the enum to a string for storage
  String toStorageString() {
    switch (this) {
      case SyncStatus.pending:
        return 'PENDING';
      case SyncStatus.processing:
        return 'PROCESSING';
      case SyncStatus.failed:
        return 'FAILED';
      case SyncStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Creates an enum from a storage string
  static SyncStatus fromStorageString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return SyncStatus.pending;
      case 'PROCESSING':
        return SyncStatus.processing;
      case 'FAILED':
        return SyncStatus.failed;
      case 'COMPLETED':
        return SyncStatus.completed;
      default:
        return SyncStatus.pending;
    }
  }
}

class SyncQueue {
  /// Unique identifier for the sync queue item
  final int? id;

  /// Type of operation to perform
  final SyncOperationType operationType;

  /// ID of the landmark associated with this operation
  final int? landmarkId;

  /// JSON payload containing the data to sync
  final String payload;

  /// Current status of the sync operation
  final SyncStatus status;

  /// Timestamp when this item was created (milliseconds since epoch)
  final int createdAt;

  /// Number of times this sync has been retried
  final int retryCount;

  /// Last error message if the sync failed
  final String? errorMessage;

  /// Timestamp of the last retry attempt (milliseconds since epoch)
  final int? lastRetryAt;

  /// Creates a new SyncQueue instance
  SyncQueue({
    this.id,
    required this.operationType,
    this.landmarkId,
    required this.payload,
    this.status = SyncStatus.pending,
    int? createdAt,
    this.retryCount = 0,
    this.errorMessage,
    this.lastRetryAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// Creates a SyncQueue from JSON data
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "operationType": "CREATE",
  ///   "landmarkId": 123,
  ///   "payload": "{\"title\":\"Test\",\"lat\":23.8103}",
  ///   "status": "PENDING",
  ///   "createdAt": 1704067200000,
  ///   "retryCount": 0
  /// }
  /// ```
  factory SyncQueue.fromJson(Map<String, dynamic> json) {
    return SyncQueue(
      id: _parseInt(json['id']),
      operationType: SyncOperationType.fromStorageString(
        json['operationType']?.toString() ?? 'CREATE',
      ),
      landmarkId: _parseInt(json['landmarkId']),
      payload: json['payload']?.toString() ?? '{}',
      status: SyncStatus.fromStorageString(
        json['status']?.toString() ?? 'PENDING',
      ),
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
      retryCount: _parseInt(json['retryCount']) ?? 0,
      errorMessage: json['errorMessage']?.toString(),
      lastRetryAt: _parseInt(json['lastRetryAt']),
    );
  }

  /// Converts the SyncQueue to JSON format
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'operationType': operationType.toStorageString(),
      if (landmarkId != null) 'landmarkId': landmarkId,
      'payload': payload,
      'status': status.toStorageString(),
      'createdAt': createdAt,
      'retryCount': retryCount,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (lastRetryAt != null) 'lastRetryAt': lastRetryAt,
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

  /// Creates a copy of this SyncQueue with updated fields
  SyncQueue copyWith({
    int? id,
    SyncOperationType? operationType,
    int? landmarkId,
    String? payload,
    SyncStatus? status,
    int? createdAt,
    int? retryCount,
    String? errorMessage,
    int? lastRetryAt,
  }) {
    return SyncQueue(
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

  /// Returns true if this sync operation can be retried
  bool get canRetry => status == SyncStatus.failed && retryCount < 5;

  /// Returns true if this sync operation is pending
  bool get isPending => status == SyncStatus.pending;

  /// Returns true if this sync operation is processing
  bool get isProcessing => status == SyncStatus.processing;

  /// Returns true if this sync operation has failed
  bool get hasFailed => status == SyncStatus.failed;

  /// Returns true if this sync operation is completed
  bool get isCompleted => status == SyncStatus.completed;

  /// Returns a DateTime object for creation time
  DateTime get createdAtDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// Returns a DateTime object for last retry time
  DateTime? get lastRetryAtDateTime {
    if (lastRetryAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastRetryAt!);
  }

  /// Returns the age of this sync queue item in milliseconds
  int get age => DateTime.now().millisecondsSinceEpoch - createdAt;

  /// Returns the age in hours
  double get ageInHours => age / (1000 * 60 * 60);

  /// Returns a human-readable description of the operation
  String get operationDescription {
    final operation = operationType.toStorageString();
    if (landmarkId != null) {
      return '$operation landmark #$landmarkId';
    }
    return '$operation landmark';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncQueue &&
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
    return 'SyncQueue(id: $id, operation: ${operationType.toStorageString()}, '
        'landmarkId: $landmarkId, status: ${status.toStorageString()}, retries: $retryCount)';
  }
}
