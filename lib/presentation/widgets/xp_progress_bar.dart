import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/user_progress_provider.dart';
import '../../domain/entities/user_progress.dart';

class XPProgressBar extends ConsumerWidget {
  const XPProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    
    return progressAsync.when(
      data: (progress) => _buildProgressBar(context, progress),
      loading: () => _buildLoadingBar(),
      error: (error, stack) => _buildErrorBar(),
    );
  }
  
  Widget _buildProgressBar(BuildContext context, UserProgress progress) {
    final progressValue = progress.progressToNextLevel.clamp(0.0, 1.0);
    final xpInLevel = progress.xpInCurrentLevel;
    final xpNeeded = progress.xpNeededForNextLevel;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getLevelColor(progress.currentLevel),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getLevelColor(progress.currentLevel).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${progress.currentLevel}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Progress section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // XP text
                Text(
                  '$xpInLevel / $xpNeeded XP',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getLevelColor(progress.currentLevel),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 100,
                  color: AppColors.grey300,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.grey200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.red50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.red200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.red500, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Failed to load XP progress',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.red600),
          ),
        ],
      ),
    );
  }
  
  Color _getLevelColor(int level) {
    if (level < 5) return AppColors.bluePrimary;
    if (level < 10) return AppColors.greenPrimary;
    if (level < 15) return AppColors.orangePrimary;
    if (level < 20) return AppColors.purplePrimary;
    return AppColors.redPrimary;
  }
}
