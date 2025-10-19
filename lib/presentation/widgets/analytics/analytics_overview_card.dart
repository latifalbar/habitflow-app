import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsOverviewCard extends ConsumerWidget {
  const AnalyticsOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    
    return analytics.when(
      data: (data) => _buildOverviewCard(context, data),
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(error.toString()),
    );
  }

  Widget _buildOverviewCard(BuildContext context, analytics) {
    final overview = analytics.overview;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Habits',
                  '${overview.totalHabits}',
                  Icons.list_alt,
                  AppColors.oceanPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  'Completions',
                  '${overview.totalCompletions}',
                  Icons.check_circle,
                  AppColors.greenPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Secondary stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completion Rate',
                  '${(overview.averageCompletionRate * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppColors.bluePrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${overview.currentStreak}',
                  Icons.local_fire_department,
                  AppColors.orangePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Additional stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Best Streak',
                  '${overview.bestStreak}',
                  Icons.emoji_events,
                  AppColors.purplePrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  'Perfect Days',
                  '${overview.perfectDays}',
                  Icons.star,
                  AppColors.yellowPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Level and XP row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Level',
                  '${overview.currentLevel}',
                  Icons.workspace_premium,
                  AppColors.goldPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  'Total XP',
                  '${overview.totalXP}',
                  Icons.bolt,
                  AppColors.cyanPrimary,
                ),
              ),
            ],
          ),
          
          // Most consistent habit
          if (overview.mostConsistentHabit.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildConsistentHabitCard(overview.mostConsistentHabit),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistentHabitCard(String habitName) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          gradient: AppColors.oceanGradient,
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Most Consistent',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    habitName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLoadingStatCard()),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildLoadingStatCard()),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildLoadingStatCard()),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildLoadingStatCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.redPrimary,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load analytics',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.redPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}