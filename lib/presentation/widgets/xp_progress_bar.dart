import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int currentLevel;
  
  const XPProgressBar({
    Key? key,
    required this.currentXP,
    required this.currentLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildProgressBar(context);
  }
  
  Widget _buildProgressBar(BuildContext context) {
    // Calculate XP needed for next level (simplified formula)
    final xpNeededForNextLevel = (currentLevel * 100).toDouble();
    final xpInCurrentLevel = (currentXP % 100).toDouble();
    final progressValue = (xpInCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $currentLevel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${xpInCurrentLevel.toInt()}/${xpNeededForNextLevel.toInt()} XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}