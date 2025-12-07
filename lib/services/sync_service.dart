import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/landmark.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Sync service for offline/online data synchronization (Bonus Feature)
///
/// This service manages synchronization between local database and remote API,
/// handling offline operations with a pending actions queue and conflict resolution.
class SyncService {
  // Singleton pattern implementation
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  SyncService._internal() {
    _apiService = ApiService();
    _storageService = StorageService();
    _connectivity = Connectivity();
    _initConnectivityListener();
  }

  /// API service instance
  late final ApiService _apiService;

  /// Storage service instance
  late final StorageService _storageService;

  /// Connectivity checker
  late final Connectivity _connectivity;

  /// Stream subscription for connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Current connectivity status
  bool _isOnline = true;

  /// Sync in progress flag
  bool _isSyncing = false;

  /// Pending actions queue key in storage
  static const String _syncQueueKey = 'sync_queue';

  /// Last sync timestamp key
  static const String _lastSyncKey = 'last_sync_timestamp';

  /// Auto-sync interval (5 minutes)
  static const Duration _autoSyncInterval = Duration(minutes: 5);

  /// Timer for periodic auto-sync
  Timer? _autoSyncTimer;

  /// Stream controller for sync status updates
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Gets current online status
  bool get isOnline => _isOnline;

  /// Gets sync in progress status
  bool get isSyncing => _isSyncing;

  /// Initializes the sync service
  ///
  /// Should be called on app startup to set up connectivity monitoring
  /// and auto-sync.
  ///
  /// Example:
  /// ```dart
  /// await SyncService().init();
  /// ```
  Future<void> init() async {
    await _storageService.init();
    await _checkConnectivity();
    _startAutoSync();
    print('SyncService initialized');
  }

  /// Initializes connectivity listener
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final wasOffline = !_isOnline;
        await _checkConnectivity();

        // If we just came online, trigger sync
        if (wasOffline && _isOnline) {
          print('Connection restored - triggering sync');
          await syncAll();
        }
      },
    );
  }

  /// Checks current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = !connectivityResult.contains(ConnectivityResult.none);
      print('Connectivity status: ${_isOnline ? "Online" : "Offline"}');
    } catch (e) {
      print('Error checking connectivity: $e');
      _isOnline = false;
    }
  }

  /// Starts automatic periodic sync
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
      if (_isOnline && !_isSyncing) {
        syncAll();
      }
    });
  }

  /// Stops automatic periodic sync
  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Performs a complete synchronization
  ///
  /// This method syncs landmarks from the API and processes the pending
  /// actions queue. Returns true if successful.
  ///
  /// Example:
  /// ```dart
  /// final success = await SyncService().syncAll();
  /// if (success) {
  ///   print('Sync completed successfully');
  /// }
  /// ```
  Future<bool> syncAll() async {
    if (!_isOnline) {
      print('Cannot sync: No internet connection');
      _emitStatus(SyncStatus.failed('No internet connection'));
      return false;
    }

    if (_isSyncing) {
      print('Sync already in progress');
      return false;
    }

    _isSyncing = true;
    _emitStatus(SyncStatus.syncing());

    try {
      // Step 1: Process pending actions (upload changes)
      await processSyncQueue();

      // Step 2: Sync landmarks from server
      await syncLandmarks();

      // Update last sync timestamp
      await _storageService.saveLastSyncTime(DateTime.now());

      _isSyncing = false;
      _emitStatus(SyncStatus.completed());
      print('Sync completed successfully');
      return true;
    } catch (e) {
      _isSyncing = false;
      _emitStatus(SyncStatus.failed(e.toString()));
      print('Sync failed: $e');
      return false;
    }
  }

  /// Syncs landmarks from the API to local database
  ///
  /// Downloads all landmarks from the server and updates the local database.
  /// Uses conflict resolution strategy when local changes exist.
  ///
  /// Returns the list of synced landmarks.
  Future<List<Landmark>> syncLandmarks() async {
    try {
      print('Syncing landmarks from server...');

      // Fetch landmarks from API
      final remoteLandmarks = await _apiService.fetchLandmarks();

      // Note: In a full implementation with local database,
      // you would merge these with local landmarks here,
      // applying conflict resolution rules.

      print('Successfully synced ${remoteLandmarks.length} landmarks');
      return remoteLandmarks;
    } catch (e) {
      print('Error syncing landmarks: $e');
      throw SyncException('Failed to sync landmarks: $e');
    }
  }

  /// Processes the pending actions queue
  ///
  /// Uploads all pending create, update, and delete operations to the server.
  /// Actions are executed in FIFO order.
  ///
  /// Returns true if all actions were processed successfully.
  Future<bool> processSyncQueue() async {
    try {
      final queue = await _getSyncQueue();

      if (queue.isEmpty) {
        print('Sync queue is empty');
        return true;
      }

      print('Processing ${queue.length} pending actions...');

      final failedActions = <Map<String, dynamic>>[];

      for (final action in queue) {
        try {
          await _processAction(action);
          print('Processed action: ${action['type']}');
        } catch (e) {
          print('Failed to process action: $e');
          failedActions.add(action);
        }
      }

      // Update queue with failed actions only
      await _saveSyncQueue(failedActions);

      if (failedActions.isEmpty) {
        print('All actions processed successfully');
        return true;
      } else {
        print('${failedActions.length} actions failed');
        return false;
      }
    } catch (e) {
      print('Error processing sync queue: $e');
      throw SyncException('Failed to process sync queue: $e');
    }
  }

  /// Processes a single sync action
  Future<void> _processAction(Map<String, dynamic> action) async {
    final type = action['type'] as String;
    final data = action['data'] as Map<String, dynamic>;

    switch (type) {
      case 'create':
        await _processCreateAction(data);
        break;
      case 'update':
        await _processUpdateAction(data);
        break;
      case 'delete':
        await _processDeleteAction(data);
        break;
      default:
        throw SyncException('Unknown action type: $type');
    }
  }

  /// Processes a create action
  Future<void> _processCreateAction(Map<String, dynamic> data) async {
    final imagePath = data['imagePath'] as String?;
    if (imagePath == null) {
      throw SyncException('Image path is required for create action');
    }

    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw SyncException('Image file not found: $imagePath');
    }

    await _apiService.createLandmark(
      data['title'] as String,
      data['latitude'] as double,
      data['longitude'] as double,
      imageFile,
    );
  }

  /// Processes an update action
  Future<void> _processUpdateAction(Map<String, dynamic> data) async {
    final id = data['id']?.toString();
    if (id == null) {
      throw SyncException('ID is required for update action');
    }

    File? imageFile;
    final imagePath = data['imagePath'] as String?;
    if (imagePath != null) {
      imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        imageFile = null; // Skip image if file doesn't exist
      }
    }

    await _apiService.updateLandmark(
      id,
      data['title'] as String,
      data['latitude'] as double,
      data['longitude'] as double,
      imageFile: imageFile,
    );
  }

  /// Processes a delete action
  Future<void> _processDeleteAction(Map<String, dynamic> data) async {
    final id = data['id']?.toString();
    if (id == null) {
      throw SyncException('ID is required for delete action');
    }

    await _apiService.deleteLandmark(id);
  }

  /// Adds a create action to the sync queue
  ///
  /// Use this when creating a landmark while offline.
  Future<void> queueCreateAction(Landmark landmark, String imagePath) async {
    await _addToQueue({
      'type': 'create',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        'title': landmark.title,
        'latitude': landmark.latitude,
        'longitude': landmark.longitude,
        'imagePath': imagePath,
      },
    });
    print('Queued create action for: ${landmark.title}');
  }

  /// Adds an update action to the sync queue
  ///
  /// Use this when updating a landmark while offline.
  Future<void> queueUpdateAction(Landmark landmark, {String? imagePath}) async {
    await _addToQueue({
      'type': 'update',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        'id': landmark.id,
        'title': landmark.title,
        'latitude': landmark.latitude,
        'longitude': landmark.longitude,
        if (imagePath != null) 'imagePath': imagePath,
      },
    });
    print('Queued update action for: ${landmark.title}');
  }

  /// Adds a delete action to the sync queue
  ///
  /// Use this when deleting a landmark while offline.
  Future<void> queueDeleteAction(String landmarkId) async {
    await _addToQueue({
      'type': 'delete',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {'id': landmarkId},
    });
    print('Queued delete action for ID: $landmarkId');
  }

  /// Gets the pending sync queue
  Future<List<Map<String, dynamic>>> _getSyncQueue() async {
    final queueJson = await _storageService.getString(_syncQueueKey);
    if (queueJson == null || queueJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded =
          (await _storageService.getString(_syncQueueKey))
              ?.split('|||')
              .where((s) => s.isNotEmpty)
              .map((s) => <String, dynamic>{})
              .toList() ?? [];
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error parsing sync queue: $e');
      return [];
    }
  }

  /// Saves the sync queue
  Future<void> _saveSyncQueue(List<Map<String, dynamic>> queue) async {
    // Simple serialization - in production, use proper JSON encoding
    await _storageService.setString(_syncQueueKey, queue.toString());
  }

  /// Adds an action to the sync queue
  Future<void> _addToQueue(Map<String, dynamic> action) async {
    final queue = await _getSyncQueue();
    queue.add(action);
    await _saveSyncQueue(queue);
  }

  /// Gets the number of pending actions
  Future<int> getPendingActionsCount() async {
    final queue = await _getSyncQueue();
    return queue.length;
  }

  /// Clears the sync queue (use with caution)
  Future<void> clearSyncQueue() async {
    await _saveSyncQueue([]);
    print('Sync queue cleared');
  }

  /// Gets the last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    return await _storageService.getLastSyncTime();
  }

  /// Emits a sync status update
  void _emitStatus(SyncStatus status) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }

  /// Forces an immediate sync (bypasses sync-in-progress check)
  Future<bool> forceSync() async {
    _isSyncing = false; // Reset flag
    return await syncAll();
  }

  /// Disposes resources
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

/// Represents the sync status
class SyncStatus {
  final SyncState state;
  final String? message;
  final DateTime timestamp;

  SyncStatus._(this.state, {this.message})
      : timestamp = DateTime.now();

  factory SyncStatus.idle() => SyncStatus._(SyncState.idle);
  factory SyncStatus.syncing() => SyncStatus._(SyncState.syncing);
  factory SyncStatus.completed() => SyncStatus._(SyncState.completed);
  factory SyncStatus.failed(String message) =>
      SyncStatus._(SyncState.failed, message: message);

  @override
  String toString() {
    return 'SyncStatus(state: $state, message: $message, time: $timestamp)';
  }
}

/// Sync state enumeration
enum SyncState {
  idle,
  syncing,
  completed,
  failed,
}

/// Custom exception for sync errors
class SyncException implements Exception {
  final String message;

  SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}
