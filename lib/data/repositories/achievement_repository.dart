import 'package:hive/hive.dart';
import '../../core/constants/storage_keys.dart';
import '../../domain/entities/achievement.dart';
import '../models/achievement_model.dart';

class AchievementRepository {
  static const String _boxName = StorageKeys.achievementsBox;

  Future<Box<AchievementModel>> _getBox() async {
    return await Hive.openBox<AchievementModel>(_boxName);
  }

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final box = await _getBox();
      final achievements = box.values.map((model) => model.toEntity()).toList();
      return achievements;
    } catch (error) {
      print('Error getting all achievements: $error');
      return [];
    }
  }

  /// Get unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    try {
      final box = await _getBox();
      final achievements = box.values
          .where((model) => model.isUnlocked)
          .map((model) => model.toEntity())
          .toList();
      return achievements;
    } catch (error) {
      print('Error getting unlocked achievements: $error');
      return [];
    }
  }

  /// Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(AchievementCategory category) async {
    try {
      final box = await _getBox();
      final achievements = box.values
          .where((model) => model.category == category)
          .map((model) => model.toEntity())
          .toList();
      return achievements;
    } catch (error) {
      print('Error getting achievements by category: $error');
      return [];
    }
  }

  /// Get achievement by ID
  Future<Achievement?> getAchievementById(String id) async {
    try {
      final box = await _getBox();
      final model = box.get(id);
      return model?.toEntity();
    } catch (error) {
      print('Error getting achievement by ID: $error');
      return null;
    }
  }

  /// Unlock an achievement
  Future<bool> unlockAchievement(String id) async {
    try {
      final box = await _getBox();
      final model = box.get(id);
      if (model == null) return false;

      final updatedModel = model.copyWith(
        unlockedAt: DateTime.now(),
        progress: 1.0,
      );

      await box.put(id, updatedModel);
      return true;
    } catch (error) {
      print('Error unlocking achievement: $error');
      return false;
    }
  }

  /// Update achievement progress
  Future<bool> updateProgress(String id, double progress) async {
    try {
      final box = await _getBox();
      final model = box.get(id);
      if (model == null) return false;

      final updatedModel = model.copyWith(progress: progress);
      await box.put(id, updatedModel);
      return true;
    } catch (error) {
      print('Error updating achievement progress: $error');
      return false;
    }
  }

  /// Add or update achievement
  Future<bool> saveAchievement(Achievement achievement) async {
    try {
      final box = await _getBox();
      final model = AchievementModel.fromEntity(achievement);
      await box.put(achievement.id, model);
      return true;
    } catch (error) {
      print('Error saving achievement: $error');
      return false;
    }
  }

  /// Delete achievement
  Future<bool> deleteAchievement(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      return true;
    } catch (error) {
      print('Error deleting achievement: $error');
      return false;
    }
  }

  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStats() async {
    try {
      final box = await _getBox();
      final achievements = box.values.toList();
      
      final total = achievements.length;
      final unlocked = achievements.where((a) => a.isUnlocked).length;
      final locked = total - unlocked;
      final completionRate = total > 0 ? (unlocked / total) : 0.0;

      // Count by category
      final categoryCounts = <AchievementCategory, int>{};
      for (final achievement in achievements) {
        categoryCounts[achievement.category] = (categoryCounts[achievement.category] ?? 0) + 1;
      }

      // Count by rarity
      final rarityCounts = <AchievementRarity, int>{};
      for (final achievement in achievements) {
        rarityCounts[achievement.rarity] = (rarityCounts[achievement.rarity] ?? 0) + 1;
      }

      return {
        'total': total,
        'unlocked': unlocked,
        'locked': locked,
        'completionRate': completionRate,
        'categoryCounts': categoryCounts,
        'rarityCounts': rarityCounts,
      };
    } catch (error) {
      print('Error getting achievement stats: $error');
      return {};
    }
  }

  /// Clear all achievements (for testing)
  Future<bool> clearAllAchievements() async {
    try {
      final box = await _getBox();
      await box.clear();
      return true;
    } catch (error) {
      print('Error clearing achievements: $error');
      return false;
    }
  }
}
