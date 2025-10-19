import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/plant_growth_calculator.dart';

class PlantInfoSheet extends StatelessWidget {
  final Plant plant;
  
  const PlantInfoSheet({
    Key? key,
    required this.plant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emoji = PlantGrowthCalculator.getPlantEmoji(plant.type, plant.stage);
    final stageDescription = PlantGrowthCalculator.getStageDescription(plant.stage);
    final nextStageDescription = PlantGrowthCalculator.getNextStageDescription(plant.stage);
    final daysToNextStage = PlantGrowthCalculator.getDaysToNextStage(plant.stage, plant.daysAlive);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Plant emoji (large)
            Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Plant info
            _buildInfoSection(
              'Growth Stage',
              stageDescription,
              _getStageEmoji(plant.stage),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            _buildInfoSection(
              'Days Alive',
              '${plant.daysAlive} days old',
              '📅',
            ),
            
            if (plant.stage != GrowthStage.mature) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoSection(
                'Next Stage',
                '$nextStageDescription in $daysToNextStage days',
                '⏳',
              ),
            ],
            
            const SizedBox(height: AppSpacing.sm),
            
            _buildInfoSection(
              'Status',
              plant.isWilting ? 'Wilting 🥀' : 'Healthy 🌱',
              plant.isWilting ? '🥀' : '🌱',
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to habit details
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Habit Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.bluePrimary,
                      side: BorderSide(color: AppColors.bluePrimary),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Water plant
                    },
                    icon: const Icon(Icons.water_drop),
                    label: const Text('Water Plant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
