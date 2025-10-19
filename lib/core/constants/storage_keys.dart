class StorageKeys {
  // Hive Box Names
  static const String habitsBox = 'habits';
  static const String habitLogsBox = 'habit_logs';
  static const String userBox = 'user';
  static const String achievementsBox = 'achievements';
  static const String userProgressBox = 'user_progress';
  static const String plantsBox = 'plants';
  static const String settingsBox = 'settings';

  // User Preferences
  static const String themeMode = 'theme_mode';
  static const String selectedTheme = 'selected_theme';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';

  // Onboarding & Tutorial
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String hasSeenTutorial = 'has_seen_tutorial';
  static const String lastOnboardingVersion = 'last_onboarding_version';

  // User Data
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userAvatar = 'user_avatar';
  static const String isPremium = 'is_premium';
  static const String premiumExpiresAt = 'premium_expires_at';

  // Sync & Backup
  static const String lastSyncTime = 'last_sync_time';
  static const String pendingSyncOperations = 'pending_sync_operations';
  static const String autoSyncEnabled = 'auto_sync_enabled';
  static const String lastBackupTime = 'last_backup_time';

  // App State
  static const String lastAppVersion = 'last_app_version';
  static const String installationDate = 'installation_date';
  static const String launchCount = 'launch_count';
  static const String lastActiveDate = 'last_active_date';

  // Analytics
  static const String totalCompletions = 'total_completions';
  static const String currentStreak = 'current_streak';
  static const String bestStreak = 'best_streak';
  static const String totalXP = 'total_xp';
  static const String currentLevel = 'current_level';
  static const String totalCoins = 'total_coins';

  // Feature Discovery
  static const String hasDiscoveredStreakFreeze = 'has_discovered_streak_freeze';
  static const String hasDiscoveredGarden = 'has_discovered_garden';
  static const String hasDiscoveredAchievements = 'has_discovered_achievements';
  static const String hasDiscoveredAnalytics = 'has_discovered_analytics';

  // Premium Upsell
  static const String lastPaywallShownDate = 'last_paywall_shown_date';
  static const String paywallShownCount = 'paywall_shown_count';
  static const String hasDeclinedPremium = 'has_declined_premium';

  // Privacy & Permissions
  static const String hasRequestedNotificationPermission =
      'has_requested_notification_permission';
  static const String hasRequestedLocationPermission =
      'has_requested_location_permission';
  static const String analyticsEnabled = 'analytics_enabled';
  static const String crashReportingEnabled = 'crash_reporting_enabled';

  // Cache Keys
  static const String cachedHabits = 'cached_habits';
  static const String cachedLogs = 'cached_logs';
  static const String cachedAchievements = 'cached_achievements';
  static const String cacheTimestamp = 'cache_timestamp';

  // Development & Debug
  static const String debugMode = 'debug_mode';
  static const String showPerformanceOverlay = 'show_performance_overlay';
  static const String enableVerboseLogging = 'enable_verbose_logging';
}
