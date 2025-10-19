import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: achievement.isUnlocked ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.getRarityColor(achievement.rarity.name).withOpacity(0.1),
                      AppColors.getRarityColor(achievement.rarity.name).withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Achievement Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.getRarityColor(achievement.rarity.name).withOpacity(0.2)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Center(
                  child: Text(
                    achievement.isUnlocked ? achievement.icon : '🔒',
                    style: TextStyle(
                      fontSize: achievement.isUnlocked ? 24 : 16,
                      color: achievement.isUnlocked 
                          ? AppColors.getRarityColor(achievement.rarity.name)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Achievement Name
              Text(
                achievement.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // Achievement Description
              Text(
                achievement.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Progress or Status
              if (achievement.isUnlocked) ...[
                // Unlocked Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.greenPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Unlocked',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.greenPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Progress Bar
                Column(
                  children: [
                    Text(
                      achievement.progressText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.getRarityColor(achievement.rarity.name),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: AppSpacing.xs),
              
              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getRarityColor(achievement.rarity.name).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text(
                  achievement.rarityDisplayName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.getRarityColor(achievement.rarity.name),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
