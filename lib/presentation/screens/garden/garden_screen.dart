import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/garden_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../widgets/garden_grid.dart';
import '../../widgets/plant_info_sheet.dart';
import '../../../domain/entities/garden.dart';
import '../../../domain/entities/plant.dart';
import '../../../core/utils/database_seeder.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardenAsync = ref.watch(gardenProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Garden',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.water_drop),
            onPressed: () async {
              await ref.read(gardenProvider.notifier).waterGarden();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Garden watered! 🌧️'),
                    backgroundColor: AppColors.bluePrimary,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Water garden',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(gardenProvider.notifier).updatePlantGrowth();
            },
            tooltip: 'Update growth',
          ),
        ],
      ),
      body: gardenAsync.when(
        data: (garden) => _buildGardenContent(context, ref, garden),
        loading: () => _buildLoadingContent(),
        error: (error, stack) => _buildErrorContent(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await DatabaseSeeder.seedAll();
          ref.invalidate(gardenProvider);
          ref.invalidate(userProgressProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Garden seeded successfully! 🌱'),
                backgroundColor: AppColors.greenPrimary,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Icon(Icons.agriculture),
        tooltip: 'Seed Garden',
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  Widget _buildGardenContent(BuildContext context, WidgetRef ref, Garden garden) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather indicator
          _buildWeatherIndicator(),
          const SizedBox(height: AppSpacing.lg),
          
          // Garden grid
          GardenGrid(
            garden: garden,
            onPlantTap: (plant) {
              _showPlantInfoSheet(context, plant);
            },
            onPlantMove: (plantId, newPosition) async {
              await ref.read(gardenProvider.notifier).movePlant(plantId, newPosition);
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Garden stats
          _buildGardenStats(garden),
        ],
      ),
    );
  }
  
  Widget _buildWeatherIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.blue200),
      ),
      child: Row(
        children: [
          const Text('☀️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sunny Day',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.blue700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Perfect for growing!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.blue600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGardenStats(Garden garden) {
    final totalPlants = garden.plants.length;
    final maturePlants = garden.plants.where((p) => p.stage == GrowthStage.mature).length;
    final wiltingPlants = garden.plants.where((p) => p.isWilting).length;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Garden Stats',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildStatItem('Total Plants', '$totalPlants', '🌱'),
              const SizedBox(width: AppSpacing.md),
              _buildStatItem('Mature', '$maturePlants', '🌳'),
              const SizedBox(width: AppSpacing.md),
              _buildStatItem('Wilting', '$wiltingPlants', '🥀'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.grey700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text('Loading garden...'),
        ],
      ),
    );
  }
  
  Widget _buildErrorContent(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.redPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load garden',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.redPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showPlantInfoSheet(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlantInfoSheet(plant: plant),
    );
  }
}
