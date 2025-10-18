class AppConstants {
  // App Info
  static const String appName = 'HabitFlow';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Transform Your Daily Routines';

  // Free Tier Limits
  static const int maxFreeHabits = 5;
  static const int maxFreeThemes = 3;
  static const int freeStreakFreezesPerWeek = 1;

  // XP & Leveling
  static const int baseXpPerCompletion = 10;
  static const int streakBonusXp = 5;
  static const int maxStreakBonusXp = 50;
  static const int perfectDayBonusXp = 100;
  static const int firstTimeBonusXp = 50;
  static const int categoryBonusXp = 25;
  static const int maxLevel = 100;

  // Coins Economy
  static const int coinsPerCompletion = 5;
  static const int coinsPerLevelUp = 100;
  static const int coins7DayStreak = 50;
  static const int coins30DayStreak = 200;
  static const int coins100DayStreak = 500;

  // Coin Costs
  static const int themeUnlockCost = 500;
  static const int customIconCost = 200;
  static const int streakFreezeCost = 100;
  static const int petFoodCost = 50;
  static const int gardenDecorationCost = 100;

  // Achievement Rewards
  static const int commonAchievementCoins = 25;
  static const int uncommonAchievementCoins = 50;
  static const int rareAchievementCoins = 100;
  static const int epicAchievementCoins = 150;
  static const int legendaryAchievementCoins = 200;

  // Habit Categories
  static const List<String> habitCategories = [
    'Wellness',
    'Productivity',
    'Fitness',
    'Learning',
    'Social',
    'Finance',
    'Creative',
    'Mindfulness',
    'Health',
    'Other',
  ];

  // Default Icons
  static const List<String> habitIcons = [
    'fitness_center',
    'restaurant',
    'local_drink',
    'book',
    'music_note',
    'brush',
    'sports',
    'spa',
    'self_improvement',
    'work',
    'school',
    'lightbulb',
    'favorite',
    'eco',
    'pets',
    'home',
    'directions_run',
    'directions_bike',
    'pool',
    'wb_sunny',
    'bedtime',
    'coffee',
    'emoji_food_beverage',
    'psychology',
    'volunteer_activism',
    'savings',
    'attach_money',
    'shopping_cart',
    'phone',
    'computer',
    'camera',
    'palette',
    'piano',
    'guitar',
    'microphone',
    'movie',
    'gamepad',
    'casino',
    'extension',
    'build',
    'science',
    'local_hospital',
    'medical_services',
    'masks',
    'sanitizer',
    'shower',
    'bathtub',
    'dry_cleaning',
    'checkroom',
  ];

  // Time of Day
  static const int earlyBirdHour = 8; // Before 8am
  static const int nightOwlHour = 22; // After 10pm

  // Sync Settings
  static const int syncIntervalMinutes = 5;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 5;

  // Performance
  static const int lazyLoadThreshold = 5;
  static const int cacheExpiryMinutes = 5;
  static const int maxCachedItems = 100;

  // Animation Durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Premium Pricing
  static const String monthlyPremiumPrice = '\$4.99';
  static const String yearlyPremiumPrice = '\$39.99';
  static const String lifetimePremiumPrice = '\$79.99';

  // Support & Legal
  static const String supportEmail = 'support@habitflow.app';
  static const String privacyPolicyUrl = 'https://habitflow.app/privacy';
  static const String termsOfServiceUrl = 'https://habitflow.app/terms';
  static const String websiteUrl = 'https://habitflow.app';

  // Social Media (placeholder)
  static const String instagramUrl = 'https://instagram.com/habitflow';
  static const String twitterUrl = 'https://twitter.com/habitflow';
  static const String discordUrl = 'https://discord.gg/habitflow';

  // Feature Flags
  static const bool enableSocialFeatures = false;
  static const bool enableAIInsights = true;
  static const bool enableGarden = true;
  static const bool enableAchievements = true;

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Calculation Methods
  static int calculateXpForLevel(int level) {
    return (100 * (level * level * 1.5)).round();
  }

  static int calculateCoinsForAchievement(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return commonAchievementCoins;
      case 'uncommon':
        return uncommonAchievementCoins;
      case 'rare':
        return rareAchievementCoins;
      case 'epic':
        return epicAchievementCoins;
      case 'legendary':
        return legendaryAchievementCoins;
      default:
        return commonAchievementCoins;
    }
  }
}
