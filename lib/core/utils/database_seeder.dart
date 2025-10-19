import 'package:hive/hive.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/models/plant_model.dart';
import '../constants/storage_keys.dart';

class DatabaseSeeder {
  static Future<void> seedUserProgress() async {
    // Seed user dengan level tinggi dan XP banyak
    final box = await Hive.openBox<UserProgressModel>(StorageKeys.userProgressBox);
    final progress = UserProgressModel(
      currentXP: 2500,
      currentLevel: 8,
      totalXPEarned: 5000,
      lastUpdated: DateTime.now(),
    );
    await box.put('user_progress', progress);
  }

  static Future<void> seedGarden() async {
    // Seed garden dengan 16 plants (4x4 grid) di berbagai tahap
    final box = await Hive.openBox<PlantModel>(StorageKeys.plantsBox);
    
    // Clear existing plants
    await box.clear();
    
    // Create plants dengan berbagai kombinasi type dan stage
    final plants = [
      // Row 0 - Mature plants
      PlantModel(
        id: 'p1', 
        habitId: 'h1', 
        plantTypeIndex: 0, // Flower
        growthStageIndex: 3, // Mature
        daysAlive: 30, 
        plantedDate: DateTime.now().subtract(Duration(days: 30)), 
        row: 0, 
        col: 0
      ),
      PlantModel(
        id: 'p2', 
        habitId: 'h2', 
        plantTypeIndex: 1, // Tree
        growthStageIndex: 3, // Mature
        daysAlive: 25, 
        plantedDate: DateTime.now().subtract(Duration(days: 25)), 
        row: 0, 
        col: 1
      ),
      PlantModel(
        id: 'p3', 
        habitId: 'h3', 
        plantTypeIndex: 2, // Herb
        growthStageIndex: 2, // Growing
        daysAlive: 15, 
        plantedDate: DateTime.now().subtract(Duration(days: 15)), 
        row: 0, 
        col: 2
      ),
      PlantModel(
        id: 'p4', 
        habitId: 'h4', 
        plantTypeIndex: 3, // Cactus
        growthStageIndex: 2, // Growing
        daysAlive: 12, 
        plantedDate: DateTime.now().subtract(Duration(days: 12)), 
        row: 0, 
        col: 3
      ),
      
      // Row 1 - Mixed stages
      PlantModel(
        id: 'p5', 
        habitId: 'h5', 
        plantTypeIndex: 0, // Flower
        growthStageIndex: 3, // Mature
        daysAlive: 28, 
        plantedDate: DateTime.now().subtract(Duration(days: 28)), 
        row: 1, 
        col: 0
      ),
      PlantModel(
        id: 'p6', 
        habitId: 'h6', 
        plantTypeIndex: 1, // Tree
        growthStageIndex: 1, // Sprout
        daysAlive: 8, 
        plantedDate: DateTime.now().subtract(Duration(days: 8)), 
        row: 1, 
        col: 1
      ),
      PlantModel(
        id: 'p7', 
        habitId: 'h7', 
        plantTypeIndex: 2, // Herb
        growthStageIndex: 1, // Sprout
        daysAlive: 6, 
        plantedDate: DateTime.now().subtract(Duration(days: 6)), 
        row: 1, 
        col: 2
      ),
      PlantModel(
        id: 'p8', 
        habitId: 'h8', 
        plantTypeIndex: 3, // Cactus
        growthStageIndex: 0, // Seed
        daysAlive: 2, 
        plantedDate: DateTime.now().subtract(Duration(days: 2)), 
        row: 1, 
        col: 3
      ),
      
      // Row 2 - Growing and mature
      PlantModel(
        id: 'p9', 
        habitId: 'h9', 
        plantTypeIndex: 0, // Flower
        growthStageIndex: 2, // Growing
        daysAlive: 14, 
        plantedDate: DateTime.now().subtract(Duration(days: 14)), 
        row: 2, 
        col: 0
      ),
      PlantModel(
        id: 'p10', 
        habitId: 'h10', 
        plantTypeIndex: 1, // Tree
        growthStageIndex: 2, // Growing
        daysAlive: 16, 
        plantedDate: DateTime.now().subtract(Duration(days: 16)), 
        row: 2, 
        col: 1
      ),
      PlantModel(
        id: 'p11', 
        habitId: 'h11', 
        plantTypeIndex: 2, // Herb
        growthStageIndex: 3, // Mature
        daysAlive: 22, 
        plantedDate: DateTime.now().subtract(Duration(days: 22)), 
        row: 2, 
        col: 2
      ),
      PlantModel(
        id: 'p12', 
        habitId: 'h12', 
        plantTypeIndex: 3, // Cactus
        growthStageIndex: 3, // Mature
        daysAlive: 26, 
        plantedDate: DateTime.now().subtract(Duration(days: 26)), 
        row: 2, 
        col: 3
      ),
      
      // Row 3 - Mixed stages
      PlantModel(
        id: 'p13', 
        habitId: 'h13', 
        plantTypeIndex: 0, // Flower
        growthStageIndex: 1, // Sprout
        daysAlive: 7, 
        plantedDate: DateTime.now().subtract(Duration(days: 7)), 
        row: 3, 
        col: 0
      ),
      PlantModel(
        id: 'p14', 
        habitId: 'h14', 
        plantTypeIndex: 1, // Tree
        growthStageIndex: 0, // Seed
        daysAlive: 3, 
        plantedDate: DateTime.now().subtract(Duration(days: 3)), 
        row: 3, 
        col: 1
      ),
      PlantModel(
        id: 'p15', 
        habitId: 'h15', 
        plantTypeIndex: 2, // Herb
        growthStageIndex: 2, // Growing
        daysAlive: 13, 
        plantedDate: DateTime.now().subtract(Duration(days: 13)), 
        row: 3, 
        col: 2
      ),
      PlantModel(
        id: 'p16', 
        habitId: 'h16', 
        plantTypeIndex: 3, // Cactus
        growthStageIndex: 1, // Sprout
        daysAlive: 9, 
        plantedDate: DateTime.now().subtract(Duration(days: 9)), 
        row: 3, 
        col: 3
      ),
    ];
    
    for (var plant in plants) {
      await box.put(plant.id, plant);
    }
  }

  static Future<void> seedAll() async {
    await seedUserProgress();
    await seedGarden();
  }
}
