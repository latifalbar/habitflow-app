import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onCheck,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon
              Hero(
                tag: 'habit_icon_${habit.id}',
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    _getIconData(habit.icon),
                    color: habit.color,
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? AppColors.grey500 : AppColors.grey800,
                      ),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        habit.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: habit.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            habit.frequencyDescription,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: habit.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            habit.goalDescription,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Check button
              if (onCheck != null)
                GestureDetector(
                  onTap: onCheck,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppColors.greenPrimary
                          : AppColors.grey200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.add,
                      color: isCompleted ? Colors.white : AppColors.grey600,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconString) {
    // Parse the icon string to get the actual IconData
    // This is a simplified version - in a real app you might want to store icon codes
    try {
      // For now, return a default icon based on the string
      // You could implement a more sophisticated icon mapping here
      switch (iconString.toLowerCase()) {
        case 'fitness_center':
          return Icons.fitness_center;
        case 'water_drop':
          return Icons.water_drop;
        case 'book':
          return Icons.book;
        case 'self_improvement':
          return Icons.self_improvement;
        case 'bedtime':
          return Icons.bedtime;
      case 'wake':
        return Icons.wb_sunny;
        case 'restaurant':
          return Icons.restaurant;
        case 'coffee':
          return Icons.coffee;
        case 'work':
          return Icons.work;
        case 'school':
          return Icons.school;
        case 'home':
          return Icons.home;
        case 'directions_walk':
          return Icons.directions_walk;
        case 'directions_run':
          return Icons.directions_run;
        case 'pool':
          return Icons.pool;
        case 'bike_scooter':
          return Icons.bike_scooter;
        case 'psychology':
          return Icons.psychology;
        case 'volunteer_activism':
          return Icons.volunteer_activism;
        case 'music_note':
          return Icons.music_note;
        case 'palette':
          return Icons.palette;
        case 'camera_alt':
          return Icons.camera_alt;
        case 'games':
          return Icons.games;
        case 'movie':
          return Icons.movie;
        case 'shopping_cart':
          return Icons.shopping_cart;
        case 'cleaning_services':
          return Icons.cleaning_services;
        case 'pets':
          return Icons.pets;
        case 'family_restroom':
          return Icons.family_restroom;
        case 'favorite':
          return Icons.favorite;
        case 'health_and_safety':
          return Icons.health_and_safety;
        case 'eco':
          return Icons.eco;
        case 'star':
          return Icons.star;
        case 'celebration':
          return Icons.celebration;
        case 'travel_explore':
          return Icons.travel_explore;
        case 'language':
          return Icons.language;
        case 'code':
          return Icons.code;
        case 'brush':
          return Icons.brush;
        default:
          return Icons.check_circle_outline;
      }
    } catch (e) {
      return Icons.check_circle_outline;
    }
  }
}
