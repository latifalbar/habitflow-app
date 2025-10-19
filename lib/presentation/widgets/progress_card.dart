import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ProgressCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String subtitle;
  final Color color;
  final String? trend;
  final VoidCallback? onTap;

  const ProgressCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and trend
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTrendColor(trend!, context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTrendIcon(trend!),
                            size: 12,
                            color: _getTrendColor(trend!, context),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getTrendColor(trend!, context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Value
              Text(
                value,
                style: AppTextStyles.numberLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // Label and subtitle
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTrendColor(String trend, BuildContext context) {
    if (trend.startsWith('+')) {
      return AppColors.greenPrimary;
    } else if (trend.startsWith('-')) {
      return AppColors.redPrimary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getTrendIcon(String trend) {
    if (trend.startsWith('+')) {
      return Icons.trending_up;
    } else if (trend.startsWith('-')) {
      return Icons.trending_down;
    } else {
      return Icons.trending_flat;
    }
  }
}

// Specialized progress cards for different metrics
class StreakProgressCard extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final VoidCallback? onTap;

  const StreakProgressCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Fire icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.orangePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: AppColors.orangePrimary,
                  size: 24,
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Current streak
              Text(
                '$currentStreak',
                style: AppTextStyles.numberLarge.copyWith(
                  color: AppColors.orangePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Text(
                'Current Streak',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Best streak
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: AppColors.goldPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Best: $bestStreak',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletionRateCard extends StatelessWidget {
  final double completionRate;
  final int totalDays;
  final int completedDays;
  final VoidCallback? onTap;

  const CompletionRateCard({
    super.key,
    required this.completionRate,
    required this.totalDays,
    required this.completedDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: completionRate,
                      strokeWidth: 6,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCompletionColor(completionRate),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(completionRate * 100).toInt()}%',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getCompletionColor(completionRate),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Text(
                'Success Rate',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              Text(
                '$completedDays of $totalDays days',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.8) {
      return AppColors.greenPrimary;
    } else if (rate >= 0.6) {
      return AppColors.orangePrimary;
    } else {
      return AppColors.redPrimary;
    }
  }
}
