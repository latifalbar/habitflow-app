import 'dart:math';
import '../../domain/entities/habit.dart';

class XPCalculator {
  static int calculateCompletionXP(Habit habit, int currentStreak, bool isFirstCompletion) {
    int baseXP = 10;
    int streakBonus = min(currentStreak * 5, 50);
    int firstBonus = isFirstCompletion ? 50 : 0;
    return baseXP + streakBonus + firstBonus;
  }
  
  static int calculateLevelFromXP(int totalXP) {
    int level = 1;
    while (_xpForLevel(level + 1) <= totalXP) {
      level++;
    }
    return level;
  }
  
  static int _xpForLevel(int level) => (100 * pow(level, 1.5)).toInt();
  
  static int getXPForLevel(int level) => _xpForLevel(level);
  
  static int getXPNeededForNextLevel(int currentLevel) {
    return _xpForLevel(currentLevel + 1) - _xpForLevel(currentLevel);
  }
  
  static double getProgressToNextLevel(int currentXP, int currentLevel) {
    final xpInCurrentLevel = currentXP - _xpForLevel(currentLevel);
    final xpNeededForNextLevel = getXPNeededForNextLevel(currentLevel);
    return xpNeededForNextLevel > 0 ? xpInCurrentLevel / xpNeededForNextLevel : 1.0;
  }

  // Level Info class
  static LevelInfo getLevelInfo(int totalXP) {
    final level = calculateLevelFromXP(totalXP);
    final xpForCurrentLevel = _xpForLevel(level);
    final xpForNextLevel = _xpForLevel(level + 1);
    final xpInCurrentLevel = totalXP - xpForCurrentLevel;
    final xpNeededForNextLevel = xpForNextLevel - xpForCurrentLevel;
    final progressToNextLevel = xpInCurrentLevel / xpNeededForNextLevel;
    
    return LevelInfo(
      level: level,
      xpForCurrentLevel: xpForCurrentLevel,
      xpForNextLevel: xpForNextLevel,
      xpInCurrentLevel: xpInCurrentLevel,
      xpNeededForNextLevel: xpNeededForNextLevel,
      progressToNextLevel: progressToNextLevel,
    );
  }

  // Milestone class
  static Milestone? checkMilestone(int totalXP) {
    final level = calculateLevelFromXP(totalXP);
    
    // Define milestones
    if (level == 5) {
      return const Milestone(
        level: 5,
        title: 'Habit Novice',
        description: 'You\'ve reached level 5!',
        rewards: ['Unlock custom themes'],
      );
    } else if (level == 10) {
      return const Milestone(
        level: 10,
        title: 'Habit Apprentice',
        description: 'You\'ve reached level 10!',
        rewards: ['Unlock advanced statistics'],
      );
    } else if (level == 25) {
      return const Milestone(
        level: 25,
        title: 'Habit Master',
        description: 'You\'ve reached level 25!',
        rewards: ['Unlock exclusive garden plants'],
      );
    }
    
    return null;
  }
}

class LevelInfo {
  final int level;
  final int xpForCurrentLevel;
  final int xpForNextLevel;
  final int xpInCurrentLevel;
  final int xpNeededForNextLevel;
  final double progressToNextLevel;
  
  const LevelInfo({
    required this.level,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.xpInCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.progressToNextLevel,
  });
}

class Milestone {
  final int level;
  final String title;
  final String description;
  final List<String> rewards;
  
  const Milestone({
    required this.level,
    required this.title,
    required this.description,
    required this.rewards,
  });
}