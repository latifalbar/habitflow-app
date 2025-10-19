import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../domain/entities/achievement.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repository = ref.read(achievementRepositoryProvider);
  return await repository.getAllAchievements();
});

final unlockedAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repository = ref.read(achievementRepositoryProvider);
  return await repository.getUnlockedAchievements();
});

final achievementStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(achievementRepositoryProvider);
  return await repository.getAchievementStats();
});

class AchievementNotifier extends StateNotifier<AsyncValue<List<Achievement>>> {
  final AchievementRepository _repository;

  AchievementNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final achievements = await _repository.getAllAchievements();
      state = AsyncValue.data(achievements);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshAchievements() async {
    state = const AsyncValue.loading();
    await _loadAchievements();
  }

  Future<bool> unlockAchievement(String id) async {
    try {
      final success = await _repository.unlockAchievement(id);
      if (success) {
        await _loadAchievements();
      }
      return success;
    } catch (error) {
      print('Error unlocking achievement: $error');
      return false;
    }
  }

  Future<bool> updateProgress(String id, double progress) async {
    try {
      final success = await _repository.updateProgress(id, progress);
      if (success) {
        await _loadAchievements();
      }
      return success;
    } catch (error) {
      print('Error updating achievement progress: $error');
      return false;
    }
  }

  Future<bool> saveAchievement(Achievement achievement) async {
    try {
      final success = await _repository.saveAchievement(achievement);
      if (success) {
        await _loadAchievements();
      }
      return success;
    } catch (error) {
      print('Error saving achievement: $error');
      return false;
    }
  }

  Future<List<Achievement>> getAchievementsByCategory(AchievementCategory category) async {
    try {
      return await _repository.getAchievementsByCategory(category);
    } catch (error) {
      print('Error getting achievements by category: $error');
      return [];
    }
  }

  Future<Achievement?> getAchievementById(String id) async {
    try {
      return await _repository.getAchievementById(id);
    } catch (error) {
      print('Error getting achievement by ID: $error');
      return null;
    }
  }
}

final achievementNotifierProvider = StateNotifierProvider<AchievementNotifier, AsyncValue<List<Achievement>>>((ref) {
  final repository = ref.read(achievementRepositoryProvider);
  return AchievementNotifier(repository);
});

// Achievement checker for automatic unlocking
class AchievementChecker {
  final AchievementRepository _repository;

  AchievementChecker(this._repository);

  /// Check streak achievements
  Future<List<String>> checkStreakAchievements(int streak) async {
    final unlockedIds = <String>[];
    
    // 7-day streak
    if (streak >= 7) {
      final achievement = await _repository.getAchievementById('streak_7_days');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('streak_7_days');
        unlockedIds.add('streak_7_days');
      }
    }

    // 30-day streak
    if (streak >= 30) {
      final achievement = await _repository.getAchievementById('streak_30_days');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('streak_30_days');
        unlockedIds.add('streak_30_days');
      }
    }

    // 100-day streak
    if (streak >= 100) {
      final achievement = await _repository.getAchievementById('streak_100_days');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('streak_100_days');
        unlockedIds.add('streak_100_days');
      }
    }

    // 365-day streak
    if (streak >= 365) {
      final achievement = await _repository.getAchievementById('streak_365_days');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('streak_365_days');
        unlockedIds.add('streak_365_days');
      }
    }

    return unlockedIds;
  }

  /// Check completion achievements
  Future<List<String>> checkCompletionAchievements(int totalCompletions) async {
    final unlockedIds = <String>[];
    
    // 10 completions
    if (totalCompletions >= 10) {
      final achievement = await _repository.getAchievementById('completions_10');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('completions_10');
        unlockedIds.add('completions_10');
      }
    }

    // 50 completions
    if (totalCompletions >= 50) {
      final achievement = await _repository.getAchievementById('completions_50');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('completions_50');
        unlockedIds.add('completions_50');
      }
    }

    // 100 completions
    if (totalCompletions >= 100) {
      final achievement = await _repository.getAchievementById('completions_100');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('completions_100');
        unlockedIds.add('completions_100');
      }
    }

    // 500 completions
    if (totalCompletions >= 500) {
      final achievement = await _repository.getAchievementById('completions_500');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('completions_500');
        unlockedIds.add('completions_500');
      }
    }

    // 1000 completions
    if (totalCompletions >= 1000) {
      final achievement = await _repository.getAchievementById('completions_1000');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('completions_1000');
        unlockedIds.add('completions_1000');
      }
    }

    return unlockedIds;
  }

  /// Check getting started achievements
  Future<List<String>> checkGettingStartedAchievements(int habitCount, int completionCount) async {
    final unlockedIds = <String>[];
    
    // First step
    if (completionCount >= 1) {
      final achievement = await _repository.getAchievementById('first_step');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('first_step');
        unlockedIds.add('first_step');
      }
    }

    // Getting started
    if (habitCount >= 1) {
      final achievement = await _repository.getAchievementById('getting_started');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('getting_started');
        unlockedIds.add('getting_started');
      }
    }

    // Week warrior
    if (completionCount >= 7) {
      final achievement = await _repository.getAchievementById('week_warrior');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('week_warrior');
        unlockedIds.add('week_warrior');
      }
    }

    return unlockedIds;
  }

  /// Check time-based achievements
  Future<List<String>> checkTimeBasedAchievements(DateTime completionTime) async {
    final unlockedIds = <String>[];
    final hour = completionTime.hour;
    
    // Early bird (completed before 7 AM)
    if (hour < 7) {
      final achievement = await _repository.getAchievementById('early_bird');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('early_bird');
        unlockedIds.add('early_bird');
      }
    }

    // Night owl (completed after 10 PM)
    if (hour >= 22) {
      final achievement = await _repository.getAchievementById('night_owl');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('night_owl');
        unlockedIds.add('night_owl');
      }
    }

    // Weekend warrior (completed on weekend)
    if (completionTime.weekday >= 6) {
      final achievement = await _repository.getAchievementById('weekend_warrior');
      if (achievement != null && !achievement.isUnlocked) {
        await _repository.unlockAchievement('weekend_warrior');
        unlockedIds.add('weekend_warrior');
      }
    }

    return unlockedIds;
  }

  /// Check all achievements based on user data
  Future<List<String>> checkAllAchievements({
    required int streak,
    required int totalCompletions,
    required int habitCount,
    required DateTime? lastCompletionTime,
  }) async {
    final allUnlockedIds = <String>[];
    
    // Check streak achievements
    final streakUnlocked = await checkStreakAchievements(streak);
    allUnlockedIds.addAll(streakUnlocked);
    
    // Check completion achievements
    final completionUnlocked = await checkCompletionAchievements(totalCompletions);
    allUnlockedIds.addAll(completionUnlocked);
    
    // Check getting started achievements
    final gettingStartedUnlocked = await checkGettingStartedAchievements(habitCount, totalCompletions);
    allUnlockedIds.addAll(gettingStartedUnlocked);
    
    // Check time-based achievements
    if (lastCompletionTime != null) {
      final timeBasedUnlocked = await checkTimeBasedAchievements(lastCompletionTime);
      allUnlockedIds.addAll(timeBasedUnlocked);
    }
    
    return allUnlockedIds;
  }
}

final achievementCheckerProvider = Provider<AchievementChecker>((ref) {
  final repository = ref.read(achievementRepositoryProvider);
  return AchievementChecker(repository);
});
