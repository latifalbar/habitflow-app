import 'package:hive/hive.dart';
import '../../domain/entities/plant.dart';

part 'plant_model.g.dart';

@HiveType(typeId: 6)
class PlantModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String habitId;
  
  @HiveField(2)
  int plantTypeIndex;
  
  @HiveField(3)
  int growthStageIndex;
  
  @HiveField(4)
  int daysAlive;
  
  @HiveField(5)
  DateTime plantedDate;
  
  @HiveField(6)
  int row;
  
  @HiveField(7)
  int col;
  
  @HiveField(8)
  bool isWilting;
  
  PlantModel({
    required this.id,
    required this.habitId,
    required this.plantTypeIndex,
    required this.growthStageIndex,
    required this.daysAlive,
    required this.plantedDate,
    required this.row,
    required this.col,
    this.isWilting = false,
  });
  
  Plant toEntity() {
    return Plant(
      id: id,
      habitId: habitId,
      type: PlantType.values[plantTypeIndex],
      stage: GrowthStage.values[growthStageIndex],
      daysAlive: daysAlive,
      plantedDate: plantedDate,
      position: GridPosition(row: row, col: col),
      isWilting: isWilting,
    );
  }
  
  factory PlantModel.fromEntity(Plant plant) {
    return PlantModel(
      id: plant.id,
      habitId: plant.habitId,
      plantTypeIndex: plant.type.index,
      growthStageIndex: plant.stage.index,
      daysAlive: plant.daysAlive,
      plantedDate: plant.plantedDate,
      row: plant.position.row,
      col: plant.position.col,
      isWilting: plant.isWilting,
    );
  }
  
  PlantModel copyWith({
    String? id,
    String? habitId,
    int? plantTypeIndex,
    int? growthStageIndex,
    int? daysAlive,
    DateTime? plantedDate,
    int? row,
    int? col,
    bool? isWilting,
  }) {
    return PlantModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      plantTypeIndex: plantTypeIndex ?? this.plantTypeIndex,
      growthStageIndex: growthStageIndex ?? this.growthStageIndex,
      daysAlive: daysAlive ?? this.daysAlive,
      plantedDate: plantedDate ?? this.plantedDate,
      row: row ?? this.row,
      col: col ?? this.col,
      isWilting: isWilting ?? this.isWilting,
    );
  }
}
