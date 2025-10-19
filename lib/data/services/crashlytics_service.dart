import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Crashlytics service for error tracking and crash reporting
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  /// Initialize crashlytics
  Future<void> initialize() async {
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterFatalError(details);
    };
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  /// Record error
  Future<void> recordError({
    required dynamic error,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      // Silently fail to avoid disrupting user experience
      if (kDebugMode) {
        print('Crashlytics error: $e');
      }
    }
  }
  
  /// Record custom error
  Future<void> recordCustomError({
    required String message,
    required String errorCode,
    StackTrace? stackTrace,
    Map<String, dynamic>? customData,
  }) async {
    try {
      await _crashlytics.recordError(
        Exception(message),
        stackTrace,
        reason: errorCode,
        information: customData?.entries
            .map((e) => DiagnosticsProperty(e.key, e.value))
            .toList() ?? [],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics custom error: $e');
      }
    }
  }
  
  /// Set user identifier
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics set user ID error: $e');
      }
    }
  }
  
  /// Set custom key-value data
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics set custom key error: $e');
      }
    }
  }
  
  /// Set custom keys
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics set custom keys error: $e');
      }
    }
  }
  
  /// Log message
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics log error: $e');
      }
    }
  }
  
  /// Track habit-related errors
  Future<void> trackHabitError({
    required String errorType,
    required String habitId,
    String? habitName,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordCustomError(
      message: 'Habit Error: $errorType',
      errorCode: 'HABIT_${errorType.toUpperCase()}',
      customData: {
        'habit_id': habitId,
        if (habitName != null) 'habit_name': habitName,
        if (errorMessage != null) 'error_message': errorMessage,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }
  
  /// Track sync errors
  Future<void> trackSyncError({
    required String errorType,
    required String syncType,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordCustomError(
      message: 'Sync Error: $errorType',
      errorCode: 'SYNC_${errorType.toUpperCase()}',
      customData: {
        'sync_type': syncType,
        if (errorMessage != null) 'error_message': errorMessage,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }
  
  /// Track authentication errors
  Future<void> trackAuthError({
    required String errorType,
    required String method,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordCustomError(
      message: 'Auth Error: $errorType',
      errorCode: 'AUTH_${errorType.toUpperCase()}',
      customData: {
        'method': method,
        if (errorMessage != null) 'error_message': errorMessage,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }
  
  /// Track backup errors
  Future<void> trackBackupError({
    required String errorType,
    required String operation,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordCustomError(
      message: 'Backup Error: $errorType',
      errorCode: 'BACKUP_${errorType.toUpperCase()}',
      customData: {
        'operation': operation,
        if (errorMessage != null) 'error_message': errorMessage,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }
  
  /// Track premium feature errors
  Future<void> trackPremiumError({
    required String errorType,
    required String feature,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordCustomError(
      message: 'Premium Error: $errorType',
      errorCode: 'PREMIUM_${errorType.toUpperCase()}',
      customData: {
        'feature': feature,
        if (errorMessage != null) 'error_message': errorMessage,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }
  
  /// Track data corruption errors
  Future<void> trackDataError({
    required String errorType,
    required String dataType,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await recordCustomError(
      message: 'Data Error: $errorType',
      errorCode: 'DATA_${errorType.toUpperCase()}',
      customData: {
        'data_type': dataType,
        if (errorMessage != null) 'error_message': errorMessage,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }
  
  /// Set user context for debugging
  Future<void> setUserContext({
    String? userId,
    bool? isPremium,
    int? level,
    int? totalHabits,
    String? appVersion,
  }) async {
    try {
      if (userId != null) {
        await setUserId(userId);
      }
      
      await setCustomKeys({
        if (isPremium != null) 'is_premium': isPremium,
        if (level != null) 'user_level': level,
        if (totalHabits != null) 'total_habits': totalHabits,
        if (appVersion != null) 'app_version': appVersion,
        'platform': defaultTargetPlatform.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics set user context error: $e');
      }
    }
  }
  
  /// Check if crashlytics is enabled
  Future<bool> isCrashlyticsEnabled() async {
    try {
      return await _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      return false;
    }
  }
  
  /// Enable/disable crashlytics collection
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics set collection enabled error: $e');
      }
    }
  }
  
  /// Get crashlytics instance
  FirebaseCrashlytics get instance => _crashlytics;
}

/// Riverpod provider for CrashlyticsService
final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService();
});
