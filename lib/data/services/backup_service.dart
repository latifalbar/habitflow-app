import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_service.dart';
import '../../core/utils/premium_checker.dart';
import '../repositories/habit_repository.dart';
import '../repositories/habit_log_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/plant.dart';

/// Backup service for premium users
class BackupService {
  final FirestoreService _firestoreService;
  final PremiumChecker _premiumChecker;
  final HabitRepository _habitRepository;
  final HabitLogRepository _habitLogRepository;
  
  BackupService({
    required FirestoreService firestoreService,
    required PremiumChecker premiumChecker,
    required HabitRepository habitRepository,
    required HabitLogRepository habitLogRepository,
  }) : _firestoreService = firestoreService,
       _premiumChecker = premiumChecker,
       _habitRepository = habitRepository,
       _habitLogRepository = habitLogRepository;
  
  /// Check if user can backup
  Future<bool> canBackup() async {
    return await PremiumChecker.isPremium();
  }
  
  /// Upload all local data to cloud (initial backup)
  Future<Map<String, dynamic>> uploadAllData() async {
    if (!await canBackup()) {
      throw Exception('Premium subscription required for cloud backup');
    }
    
    try {
      final results = <String, dynamic>{};
      
      // Upload habits
      final habits = _habitRepository.getAllHabits();
      results['habits'] = await _uploadHabits(habits);
      
      // Upload habit logs
      final logs = _habitLogRepository.getAllLogs();
      results['logs'] = await _uploadHabitLogs(logs);
      
      // Upload user progress (if exists)
      // TODO: Add user progress repository
      results['progress'] = await _uploadUserProgress();
      
      // Upload achievements (if exists)
      // TODO: Add achievement repository
      results['achievements'] = await _uploadAchievements();
      
      // Upload garden data (if exists)
      // TODO: Add garden repository
      results['garden'] = await _uploadGardenData();
      
      return {
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
        'results': results,
      };
    } catch (e) {
      throw Exception('Failed to upload data: $e');
    }
  }
  
  /// Download all cloud data to local (restore)
  Future<Map<String, dynamic>> downloadAllData() async {
    if (!await canBackup()) {
      throw Exception('Premium subscription required for cloud backup');
    }
    
    try {
      final results = <String, dynamic>{};
      
      // Download habits
      results['habits'] = await _downloadHabits();
      
      // Download habit logs
      results['logs'] = await _downloadHabitLogs();
      
      // Download user progress
      results['progress'] = await _downloadUserProgress();
      
      // Download achievements
      results['achievements'] = await _downloadAchievements();
      
      // Download garden data
      results['garden'] = await _downloadGardenData();
      
      return {
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
        'results': results,
      };
    } catch (e) {
      throw Exception('Failed to download data: $e');
    }
  }
  
  /// Merge local and cloud data
  Future<Map<String, dynamic>> mergeData() async {
    if (!await canBackup()) {
      throw Exception('Premium subscription required for cloud backup');
    }
    
    try {
      final results = <String, dynamic>{};
      
      // Get local data
      final localHabits = _habitRepository.getAllHabits();
      final localLogs = _habitLogRepository.getAllLogs();
      
      // Get cloud data
      final cloudHabits = await _downloadHabits();
      final cloudLogs = await _downloadHabitLogs();
      
      // Merge habits (keep both, avoid duplicates)
      results['habits'] = await _mergeHabits(localHabits, cloudHabits);
      
      // Merge logs (keep both, avoid duplicates)
      results['logs'] = await _mergeHabitLogs(localLogs, cloudLogs);
      
      return {
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
        'results': results,
      };
    } catch (e) {
      throw Exception('Failed to merge data: $e');
    }
  }
  
  /// Check if cloud data exists
  Future<bool> hasCloudData() async {
    if (!await canBackup()) return false;
    
    try {
      final habits = await _firestoreService.readAllDocuments(
        subcollection: 'habits',
        limit: 1,
      );
      return habits.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Get backup status
  Future<Map<String, dynamic>> getBackupStatus() async {
    final canBackup = await this.canBackup();
    final hasCloudData = await this.hasCloudData();
    
    return {
      'canBackup': canBackup,
      'hasCloudData': hasCloudData,
      'lastBackup': null, // TODO: Store and retrieve last backup time
      'dataSize': await _getDataSize(),
    };
  }
  
  /// Upload habits to cloud
  Future<int> _uploadHabits(List<Habit> habits) async {
    int uploaded = 0;
    
    for (final habit in habits) {
      try {
        await _firestoreService.createDocument(
          subcollection: 'habits',
          documentId: habit.id,
          data: habit.toJson(),
        );
        uploaded++;
      } catch (e) {
        // Log error but continue with other habits
        print('Failed to upload habit ${habit.id}: $e');
      }
    }
    
    return uploaded;
  }
  
  /// Upload habit logs to cloud
  Future<int> _uploadHabitLogs(List<HabitLog> logs) async {
    int uploaded = 0;
    
    for (final log in logs) {
      try {
        await _firestoreService.createDocument(
          subcollection: 'logs',
          documentId: log.id,
          data: log.toJson(),
        );
        uploaded++;
      } catch (e) {
        // Log error but continue with other logs
        print('Failed to upload log ${log.id}: $e');
      }
    }
    
    return uploaded;
  }
  
  /// Upload user progress to cloud
  Future<int> _uploadUserProgress() async {
    // TODO: Implement user progress upload
    return 0;
  }
  
  /// Upload achievements to cloud
  Future<int> _uploadAchievements() async {
    // TODO: Implement achievements upload
    return 0;
  }
  
  /// Upload garden data to cloud
  Future<int> _uploadGardenData() async {
    // TODO: Implement garden data upload
    return 0;
  }
  
  /// Download habits from cloud
  Future<List<Map<String, dynamic>>> _downloadHabits() async {
    try {
      return await _firestoreService.readAllDocuments(
        subcollection: 'habits',
      );
    } catch (e) {
      throw Exception('Failed to download habits: $e');
    }
  }
  
  /// Download habit logs from cloud
  Future<List<Map<String, dynamic>>> _downloadHabitLogs() async {
    try {
      return await _firestoreService.readAllDocuments(
        subcollection: 'logs',
      );
    } catch (e) {
      throw Exception('Failed to download habit logs: $e');
    }
  }
  
  /// Download user progress from cloud
  Future<List<Map<String, dynamic>>> _downloadUserProgress() async {
    try {
      return await _firestoreService.readAllDocuments(
        subcollection: 'progress',
      );
    } catch (e) {
      throw Exception('Failed to download user progress: $e');
    }
  }
  
  /// Download achievements from cloud
  Future<List<Map<String, dynamic>>> _downloadAchievements() async {
    try {
      return await _firestoreService.readAllDocuments(
        subcollection: 'achievements',
      );
    } catch (e) {
      throw Exception('Failed to download achievements: $e');
    }
  }
  
  /// Download garden data from cloud
  Future<List<Map<String, dynamic>>> _downloadGardenData() async {
    try {
      return await _firestoreService.readAllDocuments(
        subcollection: 'garden',
      );
    } catch (e) {
      throw Exception('Failed to download garden data: $e');
    }
  }
  
  /// Merge habits from local and cloud
  Future<int> _mergeHabits(List<Habit> localHabits, List<Map<String, dynamic>> cloudHabits) async {
    // TODO: Implement smart merge logic
    // This would avoid duplicates and handle conflicts
    return localHabits.length + cloudHabits.length;
  }
  
  /// Merge habit logs from local and cloud
  Future<int> _mergeHabitLogs(List<HabitLog> localLogs, List<Map<String, dynamic>> cloudLogs) async {
    // TODO: Implement smart merge logic
    // This would avoid duplicates and handle conflicts
    return localLogs.length + cloudLogs.length;
  }
  
  /// Get data size for backup
  Future<Map<String, dynamic>> _getDataSize() async {
    final habits = _habitRepository.getAllHabits();
    final logs = _habitLogRepository.getAllLogs();
    
    return {
      'habits': habits.length,
      'logs': logs.length,
      'totalSize': '${habits.length + logs.length} items',
    };
  }
}

/// Riverpod provider for BackupService
final backupServiceProvider = Provider<BackupService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final habitRepository = ref.watch(habitRepositoryProvider);
  final habitLogRepository = ref.watch(habitLogRepositoryProvider);
  
  return BackupService(
    firestoreService: firestoreService,
    premiumChecker: PremiumChecker(),
    habitRepository: habitRepository,
    habitLogRepository: habitLogRepository,
  );
});

/// Riverpod provider for backup status
final backupStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  return await backupService.getBackupStatus();
});
