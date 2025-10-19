enum PlantType {
  flower,     // 🌸 Wellness/Health habits
  tree,       // 🌳 Fitness habits
  herb,       // 🌿 Learning habits
  cactus,     // 🌵 Productivity habits
}

enum GrowthStage {
  seed,       // 🌱 0-7 days
  sprout,     // 🌿 7-14 days
  growing,    // 🪴 14-30 days
  mature,     // 🌳/🌸/🌵 30+ days
}

class GridPosition {
  final int row;
  final int col;
  
  const GridPosition({
    required this.row,
    required this.col,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridPosition &&
        other.row == row &&
        other.col == col;
  }
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class Plant {
  final String id;
  final String habitId;
  final PlantType type;
  final GrowthStage stage;
  final int daysAlive;
  final DateTime plantedDate;
  final GridPosition position;
  final bool isWilting; // true if habit broken 3+ days
  
  const Plant({
    required this.id,
    required this.habitId,
    required this.type,
    required this.stage,
    required this.daysAlive,
    required this.plantedDate,
    required this.position,
    this.isWilting = false,
  });
  
  Plant copyWith({
    String? id,
    String? habitId,
    PlantType? type,
    GrowthStage? stage,
    int? daysAlive,
    DateTime? plantedDate,
    GridPosition? position,
    bool? isWilting,
  }) {
    return Plant(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      daysAlive: daysAlive ?? this.daysAlive,
      plantedDate: plantedDate ?? this.plantedDate,
      position: position ?? this.position,
      isWilting: isWilting ?? this.isWilting,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plant &&
        other.id == id &&
        other.habitId == habitId &&
        other.type == type &&
        other.stage == stage &&
        other.daysAlive == daysAlive &&
        other.plantedDate == plantedDate &&
        other.position == position &&
        other.isWilting == isWilting;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        habitId.hashCode ^
        type.hashCode ^
        stage.hashCode ^
        daysAlive.hashCode ^
        plantedDate.hashCode ^
        position.hashCode ^
        isWilting.hashCode;
  }
}
