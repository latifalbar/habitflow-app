import 'package:flutter/material.dart';
import '../../domain/entities/garden.dart';
import '../../domain/entities/plant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/plant_growth_calculator.dart';

class GardenGrid extends StatefulWidget {
  final Garden garden;
  final Function(Plant) onPlantTap;
  final Function(String, GridPosition) onPlantMove;
  
  const GardenGrid({
    Key? key,
    required this.garden,
    required this.onPlantTap,
    required this.onPlantMove,
  }) : super(key: key);

  @override
  State<GardenGrid> createState() => _GardenGridState();
}

class _GardenGridState extends State<GardenGrid> {
  String? _draggedPlantId;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.green200),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.garden.gridSize,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.0,
        ),
        itemCount: widget.garden.gridSize * widget.garden.gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ widget.garden.gridSize;
          final col = index % widget.garden.gridSize;
          final plant = widget.garden.getPlantAt(row, col);
          
          return _buildGridCell(row, col, plant);
        },
      ),
    );
  }
  
  Widget _buildGridCell(int row, int col, Plant? plant) {
    return DragTarget<Plant>(
      onWillAccept: (draggedPlant) {
        return draggedPlant != null && 
               widget.garden.isPositionEmpty(row, col);
      },
      onAccept: (draggedPlant) {
        if (draggedPlant != null) {
          widget.onPlantMove(draggedPlant.id, GridPosition(row: row, col: col));
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isDragTarget = candidateData.isNotEmpty;
        
        return Container(
          decoration: BoxDecoration(
            color: isDragTarget 
                ? AppColors.green200 
                : AppColors.green100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isDragTarget 
                  ? AppColors.greenPrimary 
                  : AppColors.green300,
              width: isDragTarget ? 2 : 1,
            ),
          ),
          child: plant != null
              ? PlantWidget(
                  plant: plant,
                  onTap: () => widget.onPlantTap(plant),
                  onDragStart: () => _draggedPlantId = plant.id,
                  onDragEnd: () => _draggedPlantId = null,
                )
              : _buildEmptyCell(row, col),
        );
      },
    );
  }
  
  Widget _buildEmptyCell(int row, int col) {
    return Center(
      child: Icon(
        Icons.add,
        color: AppColors.green400,
        size: 32,
      ),
    );
  }
}

class PlantWidget extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  
  const PlantWidget({
    Key? key,
    required this.plant,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emoji = PlantGrowthCalculator.getPlantEmoji(plant.type, plant.stage);
    
    return Draggable<Plant>(
      data: plant,
      onDragStarted: onDragStart,
      onDragEnd: (_) => onDragEnd(),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.green100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: plant.isWilting 
                ? AppColors.grey200 
                : AppColors.green100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: plant.isWilting 
                  ? AppColors.grey400 
                  : AppColors.green300,
            ),
          ),
          child: Stack(
            children: [
              // Plant emoji
              Center(
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 48,
                    color: plant.isWilting 
                        ? AppColors.grey500 
                        : null,
                  ),
                ),
              ),
              
              // Growth stage indicator
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStageColor(plant.stage),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStageEmoji(plant.stage),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              
              // Days alive indicator
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey700.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${plant.daysAlive}d',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStageColor(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return AppColors.brownPrimary;
      case GrowthStage.sprout:
        return AppColors.greenPrimary;
      case GrowthStage.growing:
        return AppColors.bluePrimary;
      case GrowthStage.mature:
        return AppColors.orangePrimary;
    }
  }
  
  String _getStageEmoji(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return '🌱';
      case GrowthStage.sprout:
        return '🌿';
      case GrowthStage.growing:
        return '🪴';
      case GrowthStage.mature:
        return '🌳';
    }
  }
}
