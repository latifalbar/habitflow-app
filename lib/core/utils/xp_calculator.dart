import 'dart:math';

class XPCalculator {
  // XP Rules
  static const int baseXP = 10; // Base XP per habit completion
  static const int streakBonusPerDay = 5; // XP bonus per streak day
  static const int maxStreakBonus = 50; // Maximum streak bonus
  static const int perfectDayBonus = 100; // Bonus for completing all habits
  static const int firstTimeBonus = 50; // Bonus for first completion of new habit
  static const int categoryBonus = 25; // Bonus for completing all habits in category

  /// Calculate XP earned for a single habit completion
  static int calculateCompletionXP({
    required bool isFirstTime,
    required int currentStreak,
    required bool isPerfectDay,
    required bool isCategoryComplete,
  }) {
    int xp = baseXP;

    // Streak bonus (max 50 XP)
    final streakBonus = min(currentStreak * streakBonusPerDay, maxStreakBonus);
    xp += streakBonus;

    // First time bonus
    if (isFirstTime) {
      xp += firstTimeBonus;
    }

    // Perfect day bonus
    if (isPerfectDay) {
      xp += perfectDayBonus;
    }

    // Category completion bonus
    if (isCategoryComplete) {
      xp += categoryBonus;
    }

    return xp;
  }

  /// Calculate total XP from all habit logs
  static int calculateTotalXP(List<Map<String, dynamic>> logs) {
    int totalXP = 0;
    
    for (final log in logs) {
      totalXP += log['xp'] as int? ?? 0;
    }
    
    return totalXP;
  }

  /// Calculate current level based on total XP
  static int calculateLevel(int totalXP) {
    if (totalXP <= 0) return 1;
    return (sqrt(totalXP / 100)).floor() + 1;
  }

  /// Calculate XP needed for next level
  static int calculateXPToNextLevel(int currentLevel, int totalXP) {
    final nextLevelXP = (currentLevel * currentLevel) * 100;
    return nextLevelXP - totalXP;
  }

  /// Calculate XP needed for a specific level
  static int calculateXPForLevel(int level) {
    if (level <= 1) return 0;
    return ((level - 1) * (level - 1)) * 100;
  }

  /// Get level information
  static Map<String, int> getLevelInfo(int totalXP) {
    final currentLevel = calculateLevel(totalXP);
    final xpForCurrentLevel = calculateXPForLevel(currentLevel);
    final xpForNextLevel = calculateXPForLevel(currentLevel + 1);
    final xpToNextLevel = xpForNextLevel - totalXP;
    final progressInLevel = totalXP - xpForCurrentLevel;
    final totalXPInLevel = xpForNextLevel - xpForCurrentLevel;

    return {
      'currentLevel': currentLevel,
      'totalXP': totalXP,
      'xpToNextLevel': xpToNextLevel,
      'progressInLevel': progressInLevel,
      'totalXPInLevel': totalXPInLevel,
      'progressPercentage': totalXPInLevel > 0 ? (progressInLevel / totalXPInLevel * 100).round() : 0,
    };
  }

  /// Get level name based on level
  static String getLevelName(int level) {
    if (level <= 5) return 'Beginner';
    if (level <= 10) return 'Intermediate';
    if (level <= 20) return 'Advanced';
    if (level <= 30) return 'Expert';
    if (level <= 50) return 'Master';
    return 'Legendary';
  }

  /// Get level color based on level
  static String getLevelColor(int level) {
    if (level <= 5) return 'green';
    if (level <= 10) return 'blue';
    if (level <= 20) return 'purple';
    if (level <= 30) return 'orange';
    if (level <= 50) return 'red';
    return 'gold';
  }

  /// Calculate XP breakdown for a completion
  static Map<String, int> getXPBreakdown({
    required bool isFirstTime,
    required int currentStreak,
    required bool isPerfectDay,
    required bool isCategoryComplete,
  }) {
    final breakdown = <String, int>{
      'base': baseXP,
      'streak': 0,
      'firstTime': 0,
      'perfectDay': 0,
      'category': 0,
    };

    // Streak bonus
    final streakBonus = min(currentStreak * streakBonusPerDay, maxStreakBonus);
    breakdown['streak'] = streakBonus;

    // First time bonus
    if (isFirstTime) {
      breakdown['firstTime'] = firstTimeBonus;
    }

    // Perfect day bonus
    if (isPerfectDay) {
      breakdown['perfectDay'] = perfectDayBonus;
    }

    // Category completion bonus
    if (isCategoryComplete) {
      breakdown['category'] = categoryBonus;
    }

    return breakdown;
  }

  /// Get XP milestones for achievements
  static List<Map<String, dynamic>> getXPMilestones() {
    return [
      {'level': 1, 'xp': 0, 'name': 'Getting Started'},
      {'level': 5, 'xp': 1600, 'name': 'Habit Builder'},
      {'level': 10, 'xp': 8100, 'name': 'Consistency Master'},
      {'level': 15, 'xp': 19600, 'name': 'Discipline Expert'},
      {'level': 20, 'xp': 36100, 'name': 'Habit Legend'},
      {'level': 25, 'xp': 57600, 'name': 'Transformation Hero'},
      {'level': 30, 'xp': 84100, 'name': 'Life Changer'},
      {'level': 50, 'xp': 240100, 'name': 'Ultimate Master'},
    ];
  }

  /// Check if user reached a milestone
  static Map<String, dynamic>? checkMilestone(int totalXP) {
    final milestones = getXPMilestones();
    
    for (int i = milestones.length - 1; i >= 0; i--) {
      final milestone = milestones[i];
      if (totalXP >= milestone['xp']) {
        return milestone;
      }
    }
    
    return null;
  }

  /// Calculate daily XP goal (optional feature)
  static int calculateDailyXPGoal(int currentLevel) {
    // Goal: earn enough XP to level up in 30 days
    final xpForNextLevel = calculateXPForLevel(currentLevel + 1);
    final xpForCurrentLevel = calculateXPForLevel(currentLevel);
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    
    return (xpNeeded / 30).ceil();
  }
}
