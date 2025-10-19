import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/conflict_resolver.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/crashlytics_service.dart';
import '../../core/utils/network_checker.dart';
import '../../core/utils/premium_checker.dart';

/// Sync state
class SyncState {
  final bool isLoading;
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? error;
  final bool isEnabled;
  final bool isConnected;
  final List<ConflictData> conflicts;
  
  const SyncState({
    this.isLoading = false,
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.error,
    this.isEnabled = false,
    this.isConnected = false,
    this.conflicts = const [],
  });
  
  SyncState copyWith({
    bool? isLoading,
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? error,
    bool? isEnabled,
    bool? isConnected,
    List<ConflictData>? conflicts,
  }) {
    return SyncState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error ?? this.error,
      isEnabled: isEnabled ?? this.isEnabled,
      isConnected: isConnected ?? this.isConnected,
      conflicts: conflicts ?? this.conflicts,
    );
  }
  
  bool get hasError => error != null;
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get canSync => isEnabled && isConnected && !isLoading;
}

/// Sync notifier
class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;
  final BackupService _backupService;
  final ConflictResolver _conflictResolver;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;
  final NetworkChecker _networkChecker;
  final PremiumChecker _premiumChecker;
  
  SyncNotifier({
    required SyncService syncService,
    required BackupService backupService,
    required ConflictResolver conflictResolver,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
    required NetworkChecker networkChecker,
    required PremiumChecker premiumChecker,
  }) : _syncService = syncService,
       _backupService = backupService,
       _conflictResolver = conflictResolver,
       _analyticsService = analyticsService,
       _crashlyticsService = crashlyticsService,
       _networkChecker = networkChecker,
       _premiumChecker = premiumChecker,
       super(const SyncState()) {
    _initialize();
  }
  
  /// Initialize sync state
  void _initialize() async {
    // Check premium status
    final isPremium = await PremiumChecker.isPremium();
    final isEnabled = await _syncService.isSyncEnabled;
    final isConnected = await NetworkChecker.isConnected();
    
    state = state.copyWith(
      isEnabled: isPremium && isEnabled,
      isConnected: isConnected,
    );
    
    // Listen to network changes
    NetworkChecker.networkStatusStream.listen((connected) {
      state = state.copyWith(isConnected: connected);
    });
    
    // Listen to conflicts
    _conflictResolver.conflictsStream.listen((conflicts) {
      state = state.copyWith(conflicts: conflicts);
    });
  }
  
  /// Enable sync
  Future<void> enableSync() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final isPremium = await PremiumChecker.isPremium();
      if (!isPremium) {
        throw Exception('Premium subscription required for cloud sync');
      }
      
      await _syncService.enableSync();
      
      // Track analytics
      await _analyticsService.trackBackupEvent(
        eventName: 'backup_enabled',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        isEnabled: true,
        status: SyncStatus.idle,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackBackupEvent(
        eventName: 'backup_enabled',
        success: false,
        errorMessage: e.toString(),
      );
      
      await _crashlyticsService.trackBackupError(
        errorType: 'enable_failed',
        operation: 'enable_sync',
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Disable sync
  Future<void> disableSync() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _syncService.disableSync();
      
      // Track analytics
      await _analyticsService.trackBackupEvent(
        eventName: 'backup_disabled',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        isEnabled: false,
        status: SyncStatus.disabled,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackBackupEvent(
        eventName: 'backup_disabled',
        success: false,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Manual sync
  Future<void> manualSync() async {
    if (!state.canSync) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null, status: SyncStatus.syncing);
      
      await _syncService.manualSync();
      
      // Track analytics
      await _analyticsService.trackSyncEvent(
        eventName: 'manual_sync',
        success: true,
        syncType: 'manual',
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackSyncEvent(
        eventName: 'manual_sync',
        success: false,
        errorMessage: e.toString(),
        syncType: 'manual',
      );
      
      await _crashlyticsService.trackSyncError(
        errorType: 'manual_sync_failed',
        syncType: 'manual',
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.error,
        error: e.toString(),
      );
    }
  }
  
  /// Force sync all data
  Future<void> forceSyncAll() async {
    if (!state.canSync) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null, status: SyncStatus.syncing);
      
      await _syncService.forceSyncAll();
      
      // Track analytics
      await _analyticsService.trackSyncEvent(
        eventName: 'force_sync_all',
        success: true,
        syncType: 'force',
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackSyncEvent(
        eventName: 'force_sync_all',
        success: false,
        errorMessage: e.toString(),
        syncType: 'force',
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.error,
        error: e.toString(),
      );
    }
  }
  
  /// Upload all data to cloud
  Future<void> uploadAllData() async {
    if (!state.canSync) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null, status: SyncStatus.syncing);
      
      final result = await _backupService.uploadAllData();
      
      // Track analytics
      await _analyticsService.trackBackupEvent(
        eventName: 'upload_all_data',
        success: true,
        dataSize: result['results']?.length ?? 0,
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackBackupEvent(
        eventName: 'upload_all_data',
        success: false,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.error,
        error: e.toString(),
      );
    }
  }
  
  /// Download all data from cloud
  Future<void> downloadAllData() async {
    if (!state.canSync) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null, status: SyncStatus.syncing);
      
      final result = await _backupService.downloadAllData();
      
      // Track analytics
      await _analyticsService.trackBackupEvent(
        eventName: 'download_all_data',
        success: true,
        dataSize: result['results']?.length ?? 0,
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackBackupEvent(
        eventName: 'download_all_data',
        success: false,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.error,
        error: e.toString(),
      );
    }
  }
  
  /// Merge local and cloud data
  Future<void> mergeData() async {
    if (!state.canSync) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null, status: SyncStatus.syncing);
      
      final result = await _backupService.mergeData();
      
      // Track analytics
      await _analyticsService.trackBackupEvent(
        eventName: 'merge_data',
        success: true,
        dataSize: result['results']?.length ?? 0,
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackBackupEvent(
        eventName: 'merge_data',
        success: false,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        status: SyncStatus.error,
        error: e.toString(),
      );
    }
  }
  
  /// Resolve conflict
  Future<void> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _conflictResolver.resolveConflict(
        conflictId: conflictId,
        resolution: resolution,
      );
      
      // Track analytics
      await _analyticsService.trackEvent(
        name: 'conflict_resolved',
        parameters: {
          'conflict_id': conflictId,
          'resolution': resolution.toString(),
        },
      );
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Clear conflicts
  void clearConflicts() {
    _conflictResolver.clearConflicts();
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Check for conflicts
  Future<void> checkConflicts() async {
    try {
      final conflicts = await _syncService.checkConflicts();
      state = state.copyWith(conflicts: conflicts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    return await _syncService.getSyncStats();
  }
  
  /// Check if cloud data exists
  Future<bool> hasCloudData() async {
    return await _backupService.hasCloudData();
  }
}

/// Riverpod provider for SyncNotifier
final syncNotifierProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final backupService = ref.watch(backupServiceProvider);
  final conflictResolver = ref.watch(conflictResolverProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  final crashlyticsService = ref.watch(crashlyticsServiceProvider);
  
  return SyncNotifier(
    syncService: syncService,
    backupService: backupService,
    conflictResolver: conflictResolver,
    analyticsService: analyticsService,
    crashlyticsService: crashlyticsService,
    networkChecker: NetworkChecker(),
    premiumChecker: PremiumChecker(),
  );
});

/// Riverpod provider for sync state
final syncStateProvider = StateProvider<SyncState>((ref) {
  return ref.watch(syncNotifierProvider);
});

/// Riverpod provider for sync statistics
final syncStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final syncNotifier = ref.watch(syncNotifierProvider.notifier);
  return await syncNotifier.getSyncStats();
});

/// Riverpod provider for cloud data existence
final hasCloudDataProvider = FutureProvider<bool>((ref) async {
  final syncNotifier = ref.watch(syncNotifierProvider.notifier);
  return await syncNotifier.hasCloudData();
});
