import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../core/utils/xp_calculator.dart';
import '../../data/models/user_progress_model.dart';
import '../../core/constants/storage_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LevelUpResult {
  final int oldLevel;
  final int newLevel;
  final List<String> rewardsUnlocked;
  
  const LevelUpResult({
    required this.oldLevel,
    required this.newLevel,
    required this.rewardsUnlocked,
  });
}

final userProgressProvider = StateNotifierProvider<UserProgressNotifier, AsyncValue<UserProgress>>((ref) {
  return UserProgressNotifier(ref);
});

class UserProgressNotifier extends StateNotifier<AsyncValue<UserProgress>> {
  UserProgressNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadUserProgress();
  }
  
  final Ref ref;
  
  Future<void> _loadUserProgress() async {
    try {
      final box = await Hive.openBox<UserProgressModel>(StorageKeys.userProgressBox);
      final progressModel = box.get('user_progress');
      
      if (progressModel != null) {
        state = AsyncValue.data(progressModel.toEntity());
      } else {
        // Initialize with default values
        final defaultProgress = UserProgress(
          currentXP: 0,
          currentLevel: 1,
          totalXPEarned: 0,
          lastUpdated: DateTime.now(),
        );
        state = AsyncValue.data(defaultProgress);
        await _saveUserProgress(defaultProgress);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> _saveUserProgress(UserProgress progress) async {
    try {
      final box = await Hive.openBox<UserProgressModel>(StorageKeys.userProgressBox);
      final progressModel = UserProgressModel.fromEntity(progress);
      await box.put('user_progress', progressModel);
    } catch (error) {
      // Handle error silently for now
      print('Error saving user progress: $error');
    }
  }
  
  Future<LevelUpResult?> addXP(int amount, XPSource source, String? habitId) async {
    try {
      final currentProgress = state.value;
      if (currentProgress == null) return null;
      
      final oldLevel = currentProgress.currentLevel;
      final newTotalXP = currentProgress.totalXPEarned + amount;
      final newLevel = XPCalculator.calculateLevelFromXP(newTotalXP);
      
      final updatedProgress = currentProgress.copyWith(
        currentXP: newTotalXP,
        currentLevel: newLevel,
        totalXPEarned: newTotalXP,
        lastUpdated: DateTime.now(),
      );
      
      await _saveUserProgress(updatedProgress);
      state = AsyncValue.data(updatedProgress);
      
      // Check if leveled up
      if (newLevel > oldLevel) {
        final rewardsUnlocked = _getRewardsForLevel(newLevel);
        return LevelUpResult(
          oldLevel: oldLevel,
          newLevel: newLevel,
          rewardsUnlocked: rewardsUnlocked,
        );
      }
      
      return null;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
  
  List<String> _getRewardsForLevel(int level) {
    final rewards = <String>[];
    
    if (level >= 5) rewards.add('New plant type unlocked! 🌸');
    if (level >= 10) rewards.add('Garden expansion available!');
    if (level >= 15) rewards.add('Special decorations unlocked!');
    if (level >= 20) rewards.add('Weather effects enabled!');
    
    return rewards;
  }
  
  Future<void> resetProgress() async {
    try {
      final defaultProgress = UserProgress(
        currentXP: 0,
        currentLevel: 1,
        totalXPEarned: 0,
        lastUpdated: DateTime.now(),
      );
      
      await _saveUserProgress(defaultProgress);
      state = AsyncValue.data(defaultProgress);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
