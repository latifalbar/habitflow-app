import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_completion_provider.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onCheck,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionStatus = ref.watch(habitCompletionStatusProvider(habit.id));
    final completionCount = ref.watch(habitCompletionCountProvider(habit.id));
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon + Title + Compact Checkbox
              Row(
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
                  
                  // Title and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: completionStatus == HabitCompletionStatus.completed ? TextDecoration.lineThrough : null,
                            color: completionStatus == HabitCompletionStatus.completed ? AppColors.grey500 : AppColors.grey800,
                          ),
                        ),
                        if (habit.description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            habit.description,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Compact Check Button
                  if (onCheck != null)
                    _buildCompactCheckButton(completionCount),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Row 2: Badges (flexible width)
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Row 3: Progress Indicator (conditional)
              if (habit.frequency == HabitFrequency.timesPerWeek) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildWeeklyProgress(completionCount),
              ] else if (habit.goalType == HabitGoalType.quantifiable) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildQuantifiableProgress(completionCount),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCheckButton(int completionCount) {
    final isCompleted = completionCount > 0;
    
    if (habit.frequency == HabitFrequency.daily) {
      // Daily habit - circular checkbox
      return GestureDetector(
        onTap: isCompleted ? null : onCheck,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isCompleted ? null : Border.all(color: habit.color, width: 2),
            color: isCompleted ? habit.color : Colors.transparent,
          ),
          child: isCompleted 
            ? Icon(Icons.check, color: Colors.white, size: 20)
            : null,
        ),
      );
    } else if (habit.frequency == HabitFrequency.timesPerWeek) {
      // Weekly habit - add button
      return GestureDetector(
        onTap: onCheck,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: habit.color,
          ),
          child: Icon(Icons.add, color: Colors.white, size: 20),
        ),
      );
    } else if (habit.goalType == HabitGoalType.quantifiable) {
      // Quantifiable habit - counter buttons
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: completionCount > 0 ? () => _decrementValue() : null,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completionCount > 0 ? habit.color.withOpacity(0.1) : Colors.grey[300],
              ),
              child: Icon(
                Icons.remove,
                color: completionCount > 0 ? habit.color : Colors.grey[500],
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onCheck,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.color,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      );
    }
    
    // Default - simple check button
    return GestureDetector(
      onTap: isCompleted ? null : onCheck,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCompleted ? null : Border.all(color: habit.color, width: 2),
          color: isCompleted ? habit.color : Colors.transparent,
        ),
        child: isCompleted 
          ? Icon(Icons.check, color: Colors.white, size: 20)
          : null,
      ),
    );
  }

  Widget _buildWeeklyProgress(int completionCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress dots
        Row(
          children: List.generate(habit.timesPerWeek, (index) {
            return Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                index < completionCount ? Icons.circle : Icons.circle_outlined,
                size: 12,
                color: index < completionCount ? habit.color : Colors.grey[400],
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Progress text
        Text(
          '$completionCount/${habit.timesPerWeek} ${habit.periodName}',
          style: AppTextStyles.labelSmall.copyWith(
            color: habit.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantifiableProgress(int completionCount) {
    final goalValue = habit.goalValue?.toInt() ?? 1;
    final progress = (completionCount / goalValue).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(habit.color),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Progress text
        Text(
          '$completionCount/$goalValue ${habit.goalUnit ?? 'units'}',
          style: AppTextStyles.labelSmall.copyWith(
            color: habit.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _decrementValue() {
    // TODO: Implement decrement logic
    // This would require a separate method to remove a completion
    // For now, we'll just show a placeholder
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
