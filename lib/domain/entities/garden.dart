import 'plant.dart';

class Garden {
  final String userId;
  final List<Plant> plants;
  final int gridSize; // 4x4 default, expandable to 6x6
  final DateTime lastWatered;
  
  const Garden({
    required this.userId,
    required this.plants,
    this.gridSize = 4,
    required this.lastWatered,
  });
  
  // Get plant at specific position
  Plant? getPlantAt(int row, int col) {
    try {
      return plants.firstWhere(
        (plant) => plant.position.row == row && plant.position.col == col,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Check if position is empty
  bool isPositionEmpty(int row, int col) {
    return getPlantAt(row, col) == null;
  }
  
  // Get empty positions
  List<GridPosition> getEmptyPositions() {
    final emptyPositions = <GridPosition>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (isPositionEmpty(row, col)) {
          emptyPositions.add(GridPosition(row: row, col: col));
        }
      }
    }
    return emptyPositions;
  }
  
  // Get first empty position
  GridPosition? getFirstEmptyPosition() {
    final emptyPositions = getEmptyPositions();
    return emptyPositions.isNotEmpty ? emptyPositions.first : null;
  }
  
  // Get plant by habit ID
  Plant? getPlantByHabitId(String habitId) {
    try {
      return plants.firstWhere((plant) => plant.habitId == habitId);
    } catch (e) {
      return null;
    }
  }
  
  Garden copyWith({
    String? userId,
    List<Plant>? plants,
    int? gridSize,
    DateTime? lastWatered,
  }) {
    return Garden(
      userId: userId ?? this.userId,
      plants: plants ?? this.plants,
      gridSize: gridSize ?? this.gridSize,
      lastWatered: lastWatered ?? this.lastWatered,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Garden &&
        other.userId == userId &&
        other.plants.length == plants.length &&
        other.gridSize == gridSize &&
        other.lastWatered == lastWatered;
  }
  
  @override
  int get hashCode {
    return userId.hashCode ^
        plants.hashCode ^
        gridSize.hashCode ^
        lastWatered.hashCode;
  }
}
