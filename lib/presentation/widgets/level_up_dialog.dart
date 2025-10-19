import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/user_progress_provider.dart';

class LevelUpDialog extends StatefulWidget {
  final LevelUpResult levelUpResult;
  
  const LevelUpDialog({
    Key? key,
    required this.levelUpResult,
  }) : super(key: key);

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogDialogState();
}

class _LevelUpDialogDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _confettiAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5),
    ));
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    _confettiController.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: _buildDialogContent(),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDialogContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Confetti animation
          AnimatedBuilder(
            animation: _confettiAnimation,
            builder: (context, child) {
              return _buildConfetti();
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Level badge
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _getLevelColor(widget.levelUpResult.newLevel),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getLevelColor(widget.levelUpResult.newLevel).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.levelUpResult.newLevel}',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Level up text
          Text(
            'Level Up!',
            style: AppTextStyles.h2.copyWith(
              color: _getLevelColor(widget.levelUpResult.newLevel),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'You reached level ${widget.levelUpResult.newLevel}!',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Rewards section
          if (widget.levelUpResult.rewardsUnlocked.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.green200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: AppColors.greenPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Rewards Unlocked!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.greenPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...widget.levelUpResult.rewardsUnlocked.map((reward) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.greenPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              reward,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.green700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          
          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getLevelColor(widget.levelUpResult.newLevel),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'Continue',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfetti() {
    return SizedBox(
      height: 100,
      child: Stack(
        children: List.generate(20, (index) {
          final delay = index * 0.1;
          final animation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: _confettiController,
            curve: Interval(
              delay,
              (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ));
          
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                left: (index * 20.0) % 300,
                top: 50 - (animation.value * 100),
                child: Opacity(
                  opacity: 1.0 - animation.value,
                  child: Icon(
                    Icons.star,
                    color: _getConfettiColor(index),
                    size: 16,
                  ),
                ),
              );
            },
          );
        }),
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
  
  Color _getConfettiColor(int index) {
    final colors = [
      AppColors.bluePrimary,
      AppColors.greenPrimary,
      AppColors.orangePrimary,
      AppColors.purplePrimary,
      AppColors.redPrimary,
    ];
    return colors[index % colors.length];
  }
}

// Helper function to show level up dialog
void showLevelUpDialog(BuildContext context, LevelUpResult levelUpResult) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => LevelUpDialog(levelUpResult: levelUpResult),
  );
}
