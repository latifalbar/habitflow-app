import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import 'package:intl/intl.dart';

class HabitAnalyticsCard extends ConsumerWidget {
  final HabitAnalytics habit;
  
  const HabitAnalyticsCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with habit info
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: habit.habitColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    _getIconData(habit.habitIcon),
                    color: habit.habitColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.habitName,
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.grey800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        habit.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (habit.isCompletedToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'Today',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.greenPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Completions',
                    '${habit.completionCount}',
                    Icons.check_circle,
                    AppColors.greenPrimary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Current Streak',
                    '${habit.currentStreak}',
                    Icons.local_fire_department,
                    AppColors.orangePrimary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Best Streak',
                    '${habit.bestStreak}',
                    Icons.emoji_events,
                    AppColors.purplePrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Completion rate and last completion
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Success Rate',
                    '${(habit.completionRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    AppColors.bluePrimary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total XP',
                    '${habit.totalXP}',
                    Icons.bolt,
                    AppColors.cyanPrimary,
                  ),
                ),
                if (habit.lastCompletionDate != null)
                  Expanded(
                    child: _buildStatItem(
                      'Last Done',
                      _formatLastCompletion(habit.lastCompletionDate!),
                      Icons.schedule,
                      AppColors.grey600,
                    ),
                  ),
              ],
            ),
            
            // Progress indicator
            if (habit.completionRate > 0) ...[
              const SizedBox(height: AppSpacing.md),
              _buildProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(habit.completionRate * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: habit.habitColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: habit.completionRate,
          backgroundColor: AppColors.grey200,
          valueColor: AlwaysStoppedAnimation<Color>(habit.habitColor),
          minHeight: 6,
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    // Map icon names to actual IconData
    switch (iconName.toLowerCase()) {
      case 'exercise':
        return Icons.fitness_center;
      case 'water':
        return Icons.water_drop;
      case 'sleep':
        return Icons.bedtime;
      case 'meditation':
        return Icons.self_improvement;
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit;
      case 'walking':
        return Icons.directions_walk;
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      case 'yoga':
        return Icons.self_improvement;
      case 'gym':
        return Icons.fitness_center;
      case 'study':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'cooking':
        return Icons.restaurant;
      case 'gardening':
        return Icons.eco;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      case 'dance':
        return Icons.music_note;
      case 'social':
        return Icons.people;
      case 'family':
        return Icons.family_restroom;
      case 'friends':
        return Icons.people_outline;
      case 'pets':
        return Icons.pets;
      case 'travel':
        return Icons.travel_explore;
      case 'photography':
        return Icons.camera_alt;
      case 'gaming':
        return Icons.sports_esports;
      case 'coding':
        return Icons.code;
      case 'language':
        return Icons.language;
      case 'volunteer':
        return Icons.volunteer_activism;
      case 'finance':
        return Icons.account_balance_wallet;
      case 'health':
        return Icons.health_and_safety;
      case 'mindfulness':
        return Icons.psychology;
      case 'journaling':
        return Icons.article;
      case 'gratitude':
        return Icons.favorite;
      case 'learning':
        return Icons.lightbulb;
      case 'creativity':
        return Icons.auto_awesome;
      case 'productivity':
        return Icons.trending_up;
      case 'relaxation':
        return Icons.spa;
      case 'hobby':
        return Icons.interests;
      default:
        return Icons.check_circle;
    }
  }

  String _formatLastCompletion(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
