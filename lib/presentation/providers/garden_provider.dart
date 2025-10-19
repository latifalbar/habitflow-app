import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/garden.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/habit.dart';
import '../../data/models/plant_model.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/plant_growth_calculator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

final gardenProvider = StateNotifierProvider<GardenNotifier, AsyncValue<Garden>>((ref) {
  return GardenNotifier(ref);
});

class GardenNotifier extends StateNotifier<AsyncValue<Garden>> {
  GardenNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadGarden();
  }
  
  final Ref ref;
  final _uuid = const Uuid();
  
  Future<void> _loadGarden() async {
    try {
      final box = await Hive.openBox<PlantModel>(StorageKeys.plantsBox);
      final plantModels = box.values.toList();
      
      final plants = plantModels.map((model) => model.toEntity()).toList();
      
      final garden = Garden(
        userId: 'default_user', // TODO: Get from user provider
        plants: plants,
        lastWatered: DateTime.now(),
      );
      
      state = AsyncValue.data(garden);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> _saveGarden(Garden garden) async {
    try {
      final box = await Hive.openBox<PlantModel>(StorageKeys.plantsBox);
      await box.clear();
      
      for (final plant in garden.plants) {
        final plantModel = PlantModel.fromEntity(plant);
        await box.put(plant.id, plantModel);
      }
    } catch (error) {
      print('Error saving garden: $error');
    }
  }
  
  Future<void> plantSeed(Habit habit, GridPosition position) async {
    try {
      final currentGarden = state.value;
      if (currentGarden == null) return;
      
      // Check if position is already occupied
      if (!currentGarden.isPositionEmpty(position.row, position.col)) {
        throw Exception('Position is already occupied');
      }
      
      final plantType = PlantGrowthCalculator.getPlantTypeForCategory(habit.category);
      final newPlant = Plant(
        id: _uuid.v4(),
        habitId: habit.id,
        type: plantType,
        stage: GrowthStage.seed,
        daysAlive: 0,
        plantedDate: DateTime.now(),
        position: position,
      );
      
      final updatedPlants = [...currentGarden.plants, newPlant];
      final updatedGarden = currentGarden.copyWith(plants: updatedPlants);
      
      await _saveGarden(updatedGarden);
      state = AsyncValue.data(updatedGarden);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updatePlantGrowth() async {
    try {
      final currentGarden = state.value;
      if (currentGarden == null) return;
      
      final updatedPlants = <Plant>[];
      
      for (final plant in currentGarden.plants) {
        final newDaysAlive = PlantGrowthCalculator.calculateDaysAlive(plant.plantedDate);
        final newStage = PlantGrowthCalculator.calculateStage(newDaysAlive);
        
        final updatedPlant = plant.copyWith(
          daysAlive: newDaysAlive,
          stage: newStage,
        );
        
        updatedPlants.add(updatedPlant);
      }
      
      final updatedGarden = currentGarden.copyWith(plants: updatedPlants);
      await _saveGarden(updatedGarden);
      state = AsyncValue.data(updatedGarden);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> movePlant(String plantId, GridPosition newPosition) async {
    try {
      final currentGarden = state.value;
      if (currentGarden == null) return;
      
      // Check if new position is empty
      if (!currentGarden.isPositionEmpty(newPosition.row, newPosition.col)) {
        throw Exception('New position is already occupied');
      }
      
      final updatedPlants = currentGarden.plants.map((plant) {
        if (plant.id == plantId) {
          return plant.copyWith(position: newPosition);
        }
        return plant;
      }).toList();
      
      final updatedGarden = currentGarden.copyWith(plants: updatedPlants);
      await _saveGarden(updatedGarden);
      state = AsyncValue.data(updatedGarden);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> waterGarden() async {
    try {
      final currentGarden = state.value;
      if (currentGarden == null) return;
      
      final updatedGarden = currentGarden.copyWith(
        lastWatered: DateTime.now(),
      );
      
      await _saveGarden(updatedGarden);
      state = AsyncValue.data(updatedGarden);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> removePlant(String plantId) async {
    try {
      final currentGarden = state.value;
      if (currentGarden == null) return;
      
      final updatedPlants = currentGarden.plants
          .where((plant) => plant.id != plantId)
          .toList();
      
      final updatedGarden = currentGarden.copyWith(plants: updatedPlants);
      await _saveGarden(updatedGarden);
      state = AsyncValue.data(updatedGarden);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
