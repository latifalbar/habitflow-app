import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics service for tracking user behavior and app performance
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Track custom event
  Future<void> trackEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail to avoid disrupting user experience
      print('Analytics error: $e');
    }
  }
  
  /// Track habit-related events
  Future<void> trackHabitEvent({
    required String eventName,
    required String habitId,
    String? habitName,
    Map<String, dynamic>? additionalParams,
  }) async {
    final parameters = <String, dynamic>{
      'habit_id': habitId,
      if (habitName != null) 'habit_name': habitName,
      ...?additionalParams,
    };
    
    await trackEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  /// Track habit creation
  Future<void> trackHabitCreated({
    required String habitId,
    required String habitName,
    required String category,
    required String frequency,
  }) async {
    await trackHabitEvent(
      eventName: 'habit_created',
      habitId: habitId,
      habitName: habitName,
      additionalParams: {
        'category': category,
        'frequency': frequency,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  /// Track habit completion
  Future<void> trackHabitCompleted({
    required String habitId,
    required String habitName,
    required int streak,
    required int totalCompletions,
  }) async {
    await trackHabitEvent(
      eventName: 'habit_completed',
      habitId: habitId,
      habitName: habitName,
      additionalParams: {
        'streak': streak,
        'total_completions': totalCompletions,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  /// Track streak achievement
  Future<void> trackStreakAchieved({
    required String habitId,
    required String habitName,
    required int streak,
    required int milestone, // 7, 30, 100, etc.
  }) async {
    await trackHabitEvent(
      eventName: 'streak_achieved',
      habitId: habitId,
      habitName: habitName,
      additionalParams: {
        'streak': streak,
        'milestone': milestone,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  /// Track level up
  Future<void> trackLevelUp({
    required int newLevel,
    required int totalXp,
    required int xpGained,
  }) async {
    await trackEvent(
      name: 'level_up',
      parameters: {
        'new_level': newLevel,
        'total_xp': totalXp,
        'xp_gained': xpGained,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  /// Track achievement unlock
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
    required String category,
    required String rarity,
  }) async {
    await trackEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'category': category,
        'rarity': rarity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  /// Track premium events
  Future<void> trackPremiumEvent({
    required String eventName,
    String? planType,
    double? price,
    String? currency,
    Map<String, dynamic>? additionalParams,
  }) async {
    final parameters = <String, dynamic>{
      if (planType != null) 'plan_type': planType,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalParams,
    };
    
    await trackEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  /// Track premium upgrade
  Future<void> trackPremiumUpgrade({
    required String planType,
    required double price,
    required String currency,
  }) async {
    await trackPremiumEvent(
      eventName: 'premium_upgrade',
      planType: planType,
      price: price,
      currency: currency,
    );
  }
  
  /// Track paywall shown
  Future<void> trackPaywallShown({
    required String source, // 'backup_button', 'premium_features', etc.
    String? planType,
  }) async {
    await trackPremiumEvent(
      eventName: 'paywall_shown',
      planType: planType,
      additionalParams: {
        'source': source,
      },
    );
  }
  
  /// Track backup events
  Future<void> trackBackupEvent({
    required String eventName,
    required bool success,
    String? errorMessage,
    int? dataSize,
    Map<String, dynamic>? additionalParams,
  }) async {
    final parameters = <String, dynamic>{
      'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
      if (dataSize != null) 'data_size': dataSize,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalParams,
    };
    
    await trackEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  /// Track backup enabled
  Future<void> trackBackupEnabled() async {
    await trackBackupEvent(
      eventName: 'backup_enabled',
      success: true,
    );
  }
  
  /// Track backup disabled
  Future<void> trackBackupDisabled() async {
    await trackBackupEvent(
      eventName: 'backup_disabled',
      success: true,
    );
  }
  
  /// Track sync events
  Future<void> trackSyncEvent({
    required String eventName,
    required bool success,
    String? errorMessage,
    int? itemsSynced,
    String? syncType, // 'automatic', 'manual', 'initial'
  }) async {
    final parameters = <String, dynamic>{
      'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
      if (itemsSynced != null) 'items_synced': itemsSynced,
      if (syncType != null) 'sync_type': syncType,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await trackEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  /// Track authentication events
  Future<void> trackAuthEvent({
    required String eventName,
    required String method, // 'email', 'google'
    required bool success,
    String? errorMessage,
  }) async {
    await trackEvent(
      name: eventName,
      parameters: {
        'method': method,
        'success': success,
        if (errorMessage != null) 'error_message': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  /// Track user engagement
  Future<void> trackEngagement({
    required String screenName,
    required int timeSpent, // in seconds
    Map<String, dynamic>? additionalParams,
  }) async {
    await trackEvent(
      name: 'screen_engagement',
      parameters: {
        'screen_name': screenName,
        'time_spent': timeSpent,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      },
    );
  }
  
  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    bool? isPremium,
    int? level,
    int? totalHabits,
    int? totalStreak,
  }) async {
    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }
      
      await _analytics.setUserProperty(
        name: 'is_premium',
        value: isPremium?.toString(),
      );
      
      await _analytics.setUserProperty(
        name: 'user_level',
        value: level?.toString(),
      );
      
      await _analytics.setUserProperty(
        name: 'total_habits',
        value: totalHabits?.toString(),
      );
      
      await _analytics.setUserProperty(
        name: 'total_streak',
        value: totalStreak?.toString(),
      );
    } catch (e) {
      print('Analytics user properties error: $e');
    }
  }
  
  /// Track app lifecycle events
  Future<void> trackAppLifecycle({
    required String eventName,
    Map<String, dynamic>? additionalParams,
  }) async {
    await trackEvent(
      name: eventName,
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      },
    );
  }
  
  /// Track onboarding completion
  Future<void> trackOnboardingCompleted({
    required int stepsCompleted,
    required int totalSteps,
    required int timeSpent, // in seconds
  }) async {
    await trackEvent(
      name: 'onboarding_completed',
      parameters: {
        'steps_completed': stepsCompleted,
        'total_steps': totalSteps,
        'time_spent': timeSpent,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

/// Riverpod provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
