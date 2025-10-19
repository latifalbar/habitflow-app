import '../../domain/entities/plant.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';

class PlantGrowthCalculator {
  static GrowthStage calculateStage(int daysAlive) {
    if (daysAlive < 7) return GrowthStage.seed;
    if (daysAlive < 14) return GrowthStage.sprout;
    if (daysAlive < 30) return GrowthStage.growing;
    return GrowthStage.mature;
  }
  
  static PlantType getPlantTypeForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'wellness':
        return PlantType.flower;
      case 'fitness':
      case 'exercise':
        return PlantType.tree;
      case 'learning':
      case 'education':
        return PlantType.herb;
      case 'productivity':
      case 'work':
        return PlantType.cactus;
      default:
        return PlantType.flower;
    }
  }
  
  static String getPlantEmoji(PlantType type, GrowthStage stage) {
    if (stage == GrowthStage.seed) return '🌱';
    if (stage == GrowthStage.sprout) return '🌿';
    if (stage == GrowthStage.growing) return '🪴';
    
    // Mature stage
    switch (type) {
      case PlantType.flower:
        return '🌸';
      case PlantType.tree:
        return '🌳';
      case PlantType.herb:
        return '🌿';
      case PlantType.cactus:
        return '🌵';
    }
  }
  
  static bool shouldWilt(Habit habit, List<HabitLog> recentLogs) {
    // Check if habit not completed in last 3 days
    final last3Days = DateTime.now().subtract(const Duration(days: 3));
    final recentCompletions = recentLogs.where(
      (log) => log.completedAt.isAfter(last3Days) && log.isCompleted,
    );
    return recentCompletions.isEmpty;
  }
  
  static int calculateDaysAlive(DateTime plantedDate) {
    return DateTime.now().difference(plantedDate).inDays;
  }
  
  static bool shouldEvolve(Plant plant) {
    final newStage = calculateStage(plant.daysAlive);
    return newStage != plant.stage;
  }
  
  static String getStageDescription(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return 'Seed';
      case GrowthStage.sprout:
        return 'Sprout';
      case GrowthStage.growing:
        return 'Growing';
      case GrowthStage.mature:
        return 'Mature';
    }
  }
  
  static String getNextStageDescription(GrowthStage currentStage) {
    switch (currentStage) {
      case GrowthStage.seed:
        return 'Sprout';
      case GrowthStage.sprout:
        return 'Growing';
      case GrowthStage.growing:
        return 'Mature';
      case GrowthStage.mature:
        return 'Mature';
    }
  }
  
  static int getDaysToNextStage(GrowthStage currentStage, int daysAlive) {
    switch (currentStage) {
      case GrowthStage.seed:
        return 7 - daysAlive;
      case GrowthStage.sprout:
        return 14 - daysAlive;
      case GrowthStage.growing:
        return 30 - daysAlive;
      case GrowthStage.mature:
        return 0;
    }
  }
}
