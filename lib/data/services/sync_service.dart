import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_service.dart';
import 'conflict_resolver.dart';
import '../../core/utils/network_checker.dart';
import '../../core/utils/premium_checker.dart';

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  pending,
  disabled,
}

/// Sync service for premium users with cloud backup enabled
class SyncService {
  final FirestoreService _firestoreService;
  final NetworkChecker _networkChecker;
  final PremiumChecker _premiumChecker;
  
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;
  String? _lastError;
  Timer? _syncTimer;
  StreamSubscription<bool>? _networkSubscription;
  
  SyncService({
    required FirestoreService firestoreService,
    required NetworkChecker networkChecker,
    required PremiumChecker premiumChecker,
  }) : _firestoreService = firestoreService,
       _networkChecker = networkChecker,
       _premiumChecker = premiumChecker;
  
  /// Get current sync status
  SyncStatus get status => _status;
  
  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Get last error
  String? get lastError => _lastError;
  
  /// Check if sync is enabled
  Future<bool> get isSyncEnabled async {
    final isPremium = await PremiumChecker.isPremium();
    return isPremium && _status != SyncStatus.disabled;
  }
  
  /// Initialize sync service
  Future<void> initialize() async {
    final isEnabled = await isSyncEnabled;
    if (isEnabled) {
      await _startNetworkListener();
      await _startPeriodicSync();
    }
  }
  
  /// Start network listener
  Future<void> _startNetworkListener() async {
    _networkSubscription?.cancel();
    _networkSubscription = NetworkChecker.networkStatusStream.listen((isConnected) {
      if (isConnected && _status == SyncStatus.pending) {
        _performSync();
      }
    });
  }
  
  /// Start periodic sync
  Future<void> _startPeriodicSync() async {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await NetworkChecker.isConnected() && await isSyncEnabled) {
        await _performSync();
      }
    });
  }
  
  /// Stop sync service
  Future<void> stop() async {
    _syncTimer?.cancel();
    _networkSubscription?.cancel();
    _status = SyncStatus.disabled;
  }
  
  /// Enable sync
  Future<void> enableSync() async {
    final isPremium = await PremiumChecker.isPremium();
    if (!isPremium) {
      throw Exception('Premium subscription required for cloud sync');
    }
    
    _status = SyncStatus.idle;
    await initialize();
  }
  
  /// Disable sync
  Future<void> disableSync() async {
    await stop();
    _status = SyncStatus.disabled;
  }
  
  /// Manual sync trigger
  Future<void> manualSync() async {
    if (!await isSyncEnabled) {
      throw Exception('Sync is not enabled');
    }
    
    if (!await NetworkChecker.isConnected()) {
      _status = SyncStatus.pending;
      throw Exception('No internet connection');
    }
    
    await _performSync();
  }
  
  /// Perform sync operation
  Future<void> _performSync() async {
    if (_status == SyncStatus.syncing) return;
    
    try {
      _status = SyncStatus.syncing;
      _lastError = null;
      
      // TODO: Implement actual sync logic
      // This would involve:
      // 1. Compare local and cloud data
      // 2. Detect conflicts
      // 3. Sync changes
      // 4. Update timestamps
      
      // Simulate sync operation
      await Future.delayed(const Duration(seconds: 2));
      
      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      rethrow;
    }
  }
  
  /// Sync specific data type
  Future<void> syncDataType(String dataType) async {
    if (!await isSyncEnabled) return;
    
    try {
      _status = SyncStatus.syncing;
      
      // TODO: Implement specific data type sync
      // This would sync habits, logs, achievements, etc.
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      rethrow;
    }
  }
  
  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    return {
      'status': _status.toString(),
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'lastError': _lastError,
      'isEnabled': await isSyncEnabled,
      'isConnected': await NetworkChecker.isConnected(),
    };
  }
  
  /// Force sync all data
  Future<void> forceSyncAll() async {
    if (!await isSyncEnabled) {
      throw Exception('Sync is not enabled');
    }
    
    try {
      _status = SyncStatus.syncing;
      
      // TODO: Implement full sync
      // This would sync all data types: habits, logs, achievements, progress, garden
      
      await Future.delayed(const Duration(seconds: 3));
      
      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      rethrow;
    }
  }
  
  /// Check for conflicts
  Future<List<ConflictData>> checkConflicts() async {
    if (!await isSyncEnabled) return [];
    
    try {
      // TODO: Implement conflict detection
      // This would compare local and cloud data timestamps
      // and return list of conflicts
      
      return [];
    } catch (e) {
      throw Exception('Failed to check conflicts: $e');
    }
  }
  
  /// Resolve conflict
  Future<void> resolveConflict({
    required String conflictId,
    required String resolution, // 'local', 'cloud', 'merge'
  }) async {
    if (!await isSyncEnabled) return;
    
    try {
      // TODO: Implement conflict resolution
      // This would apply the user's choice for conflict resolution
      
    } catch (e) {
      throw Exception('Failed to resolve conflict: $e');
    }
  }
}

/// Riverpod provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SyncService(
    firestoreService: firestoreService,
    networkChecker: NetworkChecker(),
    premiumChecker: PremiumChecker(),
  );
});

/// Riverpod provider for sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) => syncService.status);
});

/// Riverpod provider for sync stats
final syncStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.getSyncStats();
});
