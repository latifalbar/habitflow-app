import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local storage service for managing Hive and SharedPreferences
class LocalStorageService {
  static const String _syncStatusKey = 'sync_status';
  static const String _lastSyncKey = 'last_sync_time';
  static const String _pendingOperationsKey = 'pending_operations';
  static const String _syncEnabledKey = 'sync_enabled';
  
  /// Initialize local storage
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters for all models
    // Note: These should be registered in main.dart after model generation
    // await Hive.registerAdapter(HabitModelAdapter());
    // await Hive.registerAdapter(HabitLogModelAdapter());
    // etc.
  }
  
  /// Get Hive box
  static Future<Box<T>> getBox<T>(String boxName) async {
    return await Hive.openBox<T>(boxName);
  }
  
  /// Close Hive box
  static Future<void> closeBox(String boxName) async {
    final box = Hive.box(boxName);
    if (box.isOpen) {
      await box.close();
    }
  }
  
  /// Clear all data from box
  static Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }
  
  /// Delete box
  static Future<void> deleteBox(String boxName) async {
    final box = Hive.box(boxName);
    if (box.isOpen) {
      await box.close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }
  
  /// Get sync status
  static Future<String> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_syncStatusKey) ?? 'idle';
  }
  
  /// Set sync status
  static Future<void> setSyncStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncStatusKey, status);
  }
  
  /// Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  /// Set last sync time
  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }
  
  /// Get pending operations
  static Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final operationsJson = prefs.getString(_pendingOperationsKey);
    if (operationsJson == null) return [];
    
    try {
      // TODO: Implement JSON parsing for operations
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Add pending operation
  static Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    final operations = await getPendingOperations();
    operations.add(operation);
    
    final prefs = await SharedPreferences.getInstance();
    // TODO: Implement JSON serialization for operations
    await prefs.setString(_pendingOperationsKey, '[]');
  }
  
  /// Clear pending operations
  static Future<void> clearPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOperationsKey);
  }
  
  /// Check if sync is enabled
  static Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncEnabledKey) ?? false;
  }
  
  /// Set sync enabled
  static Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncEnabledKey, enabled);
  }
  
  /// Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final stats = <String, dynamic>{};
      
      // Get box sizes
      final habitBox = Hive.box('habits');
      final logBox = Hive.box('habit_logs');
      final userBox = Hive.box('users');
      final achievementBox = Hive.box('achievements');
      final progressBox = Hive.box('user_progress');
      final plantBox = Hive.box('plants');
      
      stats['habits_count'] = habitBox.length;
      stats['logs_count'] = logBox.length;
      stats['users_count'] = userBox.length;
      stats['achievements_count'] = achievementBox.length;
      stats['progress_count'] = progressBox.length;
      stats['plants_count'] = plantBox.length;
      
      // Calculate total size (approximate)
      int totalSize = 0;
      for (final box in [habitBox, logBox, userBox, achievementBox, progressBox, plantBox]) {
        totalSize += box.length;
      }
      stats['total_items'] = totalSize;
      
      // Get sync info
      stats['sync_enabled'] = await isSyncEnabled();
      stats['last_sync'] = await getLastSyncTime();
      stats['sync_status'] = await getSyncStatus();
      stats['pending_operations'] = (await getPendingOperations()).length;
      
      return stats;
    } catch (e) {
      return {
        'error': e.toString(),
        'habits_count': 0,
        'logs_count': 0,
        'total_items': 0,
        'sync_enabled': false,
      };
    }
  }
  
  /// Backup data to JSON
  static Future<Map<String, dynamic>> exportData() async {
    try {
      final data = <String, dynamic>{};
      
      // Export habits
      final habitBox = Hive.box('habits');
      data['habits'] = habitBox.values.map((habit) => habit.toJson()).toList();
      
      // Export habit logs
      final logBox = Hive.box('habit_logs');
      data['habit_logs'] = logBox.values.map((log) => log.toJson()).toList();
      
      // Export user data
      final userBox = Hive.box('users');
      data['users'] = userBox.values.map((user) => user.toJson()).toList();
      
      // Export achievements
      final achievementBox = Hive.box('achievements');
      data['achievements'] = achievementBox.values.map((achievement) => achievement.toJson()).toList();
      
      // Export progress
      final progressBox = Hive.box('user_progress');
      data['user_progress'] = progressBox.values.map((progress) => progress.toJson()).toList();
      
      // Export plants
      final plantBox = Hive.box('plants');
      data['plants'] = plantBox.values.map((plant) => plant.toJson()).toList();
      
      // Add metadata
      data['export_timestamp'] = DateTime.now().toIso8601String();
      data['app_version'] = '1.0.0'; // TODO: Get from package info
      
      return data;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
  
  /// Import data from JSON
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import habits
      if (data['habits'] != null) {
        final habitBox = Hive.box('habits');
        for (final habitData in data['habits'] as List) {
          // TODO: Create habit from JSON and save to box
          // final habit = HabitModel.fromJson(habitData);
          // await habitBox.put(habit.id, habit);
        }
      }
      
      // Import habit logs
      if (data['habit_logs'] != null) {
        final logBox = Hive.box('habit_logs');
        for (final logData in data['habit_logs'] as List) {
          // TODO: Create log from JSON and save to box
          // final log = HabitLogModel.fromJson(logData);
          // await logBox.put(log.id, log);
        }
      }
      
      // Import other data types...
      
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
  
  /// Clear all local data
  static Future<void> clearAllData() async {
    try {
      final boxNames = ['habits', 'habit_logs', 'users', 'achievements', 'user_progress', 'plants'];
      
      for (final boxName in boxNames) {
        await clearBox(boxName);
      }
      
      // Clear sync data
      await clearPendingOperations();
      await setSyncStatus('idle');
      await setSyncEnabled(false);
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
  
  /// Get database health status
  static Future<Map<String, dynamic>> getDatabaseHealth() async {
    try {
      final health = <String, dynamic>{
        'status': 'healthy',
        'issues': <String>[],
        'recommendations': <String>[],
      };
      
      // Check if boxes are accessible
      final boxNames = ['habits', 'habit_logs', 'users', 'achievements', 'user_progress', 'plants'];
      
      for (final boxName in boxNames) {
        try {
          final box = Hive.box(boxName);
          if (!box.isOpen) {
            health['issues'].add('Box $boxName is not open');
          }
        } catch (e) {
          health['issues'].add('Box $boxName error: $e');
        }
      }
      
      // Check for data consistency
      final stats = await getStorageStats();
      if (stats['total_items'] == 0) {
        health['recommendations'].add('No data found - consider importing or creating habits');
      }
      
      if (health['issues'].isNotEmpty) {
        health['status'] = 'unhealthy';
      }
      
      return health;
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'issues': ['Database health check failed'],
        'recommendations': ['Restart the app or contact support'],
      };
    }
  }
}

/// Riverpod provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Riverpod provider for storage stats
final storageStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await LocalStorageService.getStorageStats();
});

/// Riverpod provider for database health
final databaseHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await LocalStorageService.getDatabaseHealth();
});
