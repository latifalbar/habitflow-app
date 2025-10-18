class ApiConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String logsCollection = 'logs';
  static const String achievementsCollection = 'achievements';
  static const String feedbackCollection = 'feedback';
  static const String reportsCollection = 'reports';

  // Firebase Fields
  static const String fieldId = 'id';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldDeletedAt = 'deletedAt';
  static const String fieldSyncedAt = 'syncedAt';

  // API Endpoints (if using custom backend)
  static const String baseUrl = 'https://api.habitflow.app';
  static const String authEndpoint = '/auth';
  static const String habitsEndpoint = '/habits';
  static const String logsEndpoint = '/logs';
  static const String achievementsEndpoint = '/achievements';
  static const String analyticsEndpoint = '/analytics';
  static const String syncEndpoint = '/sync';

  // RevenueCat Keys (placeholder - should be in environment variables)
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';
  static const String revenueCatAppleKey = 'YOUR_APPLE_API_KEY';
  static const String revenueCatGoogleKey = 'YOUR_GOOGLE_API_KEY';

  // Product IDs for IAP
  static const String monthlyPremiumId = 'habitflow_monthly_premium';
  static const String yearlyPremiumId = 'habitflow_yearly_premium';
  static const String lifetimePremiumId = 'habitflow_lifetime_premium';

  // Entitlement IDs
  static const String premiumEntitlement = 'premium';

  // Analytics Events
  static const String eventHabitCreated = 'habit_created';
  static const String eventHabitCompleted = 'habit_completed';
  static const String eventStreakAchieved = 'streak_achieved';
  static const String eventLevelUp = 'level_up';
  static const String eventAchievementUnlocked = 'achievement_unlocked';
  static const String eventPremiumUpgrade = 'premium_upgrade';
  static const String eventPaywallShown = 'paywall_shown';
  static const String eventOnboardingCompleted = 'onboarding_completed';

  // Error Codes
  static const String errorNetworkUnavailable = 'NETWORK_UNAVAILABLE';
  static const String errorAuthenticationFailed = 'AUTHENTICATION_FAILED';
  static const String errorPermissionDenied = 'PERMISSION_DENIED';
  static const String errorResourceNotFound = 'RESOURCE_NOT_FOUND';
  static const String errorInvalidData = 'INVALID_DATA';
  static const String errorSyncFailed = 'SYNC_FAILED';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;

  // Request Timeouts (seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int rateLimitWindow = 60; // seconds
}
