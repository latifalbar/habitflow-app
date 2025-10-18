import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_completion_provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class HabitCheckInButton extends ConsumerWidget {
  final Habit habit;
  final VoidCallback onCheckIn;
  final bool isDetailScreen;
  
  const HabitCheckInButton({
    Key? key,
    required this.habit,
    required this.onCheckIn,
    this.isDetailScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionCount = ref.watch(habitCompletionCountProvider(habit.id));
    final canComplete = ref.watch(canCompleteHabitProvider(habit.id));
    
    // Render different UI based on habit type
    if (habit.frequency == HabitFrequency.daily) {
      return _buildDailyCheckbox(context, completionCount, canComplete);
    } else if (habit.frequency == HabitFrequency.timesPerWeek) {
      return _buildWeeklyCounter(context, completionCount, canComplete);
    } else if (habit.goalType == HabitGoalType.quantifiable) {
      return _buildMeasurableControls(context, completionCount, canComplete);
    }
    
    return _buildDefaultButton(context, completionCount, canComplete);
  }
  
  Widget _buildDailyCheckbox(BuildContext context, int count, bool canComplete) {
    final isCompleted = count > 0;
    
    return Center(
      child: Column(
        children: [
          // Large circular button (80x80)
          GestureDetector(
            onTap: isCompleted ? null : () {
              HapticFeedback.lightImpact();
              onCheckIn();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? habit.color : Colors.transparent,
                border: Border.all(
                  color: habit.color,
                  width: isCompleted ? 0 : 3,
                ),
                boxShadow: isCompleted ? [
                  BoxShadow(
                    color: habit.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                        key: const ValueKey('completed'),
                      )
                    : Icon(
                        Icons.add,
                        color: habit.color,
                        size: 32,
                        key: const ValueKey('pending'),
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Status text
          Text(
            isCompleted ? 'Completed!' : 'Tap to complete today',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isCompleted ? AppColors.greenPrimary : AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyCounter(BuildContext context, int count, bool canComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress text
        Text(
          'This Week: $count/${habit.timesPerWeek} times',
          style: AppTextStyles.bodyLarge.copyWith(
            color: habit.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Interactive progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(habit.timesPerWeek, (index) {
              final isCompleted = index < count;
              return GestureDetector(
                onTap: isCompleted ? null : () {
                  HapticFeedback.lightImpact();
                  onCheckIn();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? habit.color : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? habit.color : Colors.grey[400]!,
                      width: 2,
                    ),
                    boxShadow: isCompleted ? [
                      BoxShadow(
                        color: habit.color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(habit.timesPerWeek, (index) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Quick add button
        Center(
          child: ElevatedButton.icon(
            onPressed: canComplete ? () {
              HapticFeedback.lightImpact();
              onCheckIn();
            } : null,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Check-in'),
            style: ElevatedButton.styleFrom(
              backgroundColor: habit.color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMeasurableControls(BuildContext context, int count, bool canComplete) {
    final goalValue = habit.goalValue?.toInt() ?? 1;
    final progress = (count / goalValue).clamp(0.0, 1.0);
    final isCompleted = count >= goalValue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Progress',
              style: AppTextStyles.bodyLarge.copyWith(
                color: habit.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.greenPrimary : habit.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                isCompleted ? 'Goal Reached!' : '$count/$goalValue',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isCompleted ? Colors.white : habit.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Animated progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              color: habit.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Progress text
        Text(
          '${habit.goalUnit ?? 'units'} completed',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Quick add buttons
        Row(
          children: [
            Expanded(
              child: _buildQuickAddButton(
                label: '+15',
                onTap: () => _quickAdd(15),
                color: habit.color.withOpacity(0.1),
                textColor: habit.color,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildQuickAddButton(
                label: '+30',
                onTap: () => _quickAdd(30),
                color: habit.color.withOpacity(0.1),
                textColor: habit.color,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildQuickAddButton(
                label: '+60',
                onTap: () => _quickAdd(60),
                color: habit.color.withOpacity(0.1),
                textColor: habit.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Stepper controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decrement button
            GestureDetector(
              onTap: count > 0 ? () {
                HapticFeedback.lightImpact();
                _decrementValue();
              } : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: count > 0 ? habit.color.withOpacity(0.1) : Colors.grey[300],
                  border: Border.all(
                    color: count > 0 ? habit.color : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  color: count > 0 ? habit.color : Colors.grey[500],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            
            // Add button
            GestureDetector(
              onTap: canComplete ? () {
                HapticFeedback.lightImpact();
                onCheckIn();
              } : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canComplete ? habit.color : Colors.grey[300],
                  boxShadow: canComplete ? [
                    BoxShadow(
                      color: habit.color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Icon(
                  Icons.add,
                  color: canComplete ? Colors.white : Colors.grey[500],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickAddButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  void _quickAdd(int value) {
    // TODO: Implement quick add logic
    // This would require a method to add specific values
    // For now, we'll just call the regular onCheckIn
    onCheckIn();
  }
  
  Widget _buildDefaultButton(BuildContext context, int count, bool canComplete) {
    final isCompleted = count > 0;
    
    return Center(
      child: Column(
        children: [
          // Large circular button
          GestureDetector(
            onTap: isCompleted ? null : () {
              HapticFeedback.lightImpact();
              onCheckIn();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.greenPrimary : habit.color,
                boxShadow: isCompleted ? [
                  BoxShadow(
                    color: AppColors.greenPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : [
                  BoxShadow(
                    color: habit.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                        key: const ValueKey('completed'),
                      )
                    : Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                        key: const ValueKey('pending'),
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Status text
          Text(
            isCompleted ? 'Completed!' : 'Mark as Completed',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isCompleted ? AppColors.greenPrimary : AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _decrementValue() {
    // TODO: Implement decrement logic
    // This would require a separate method to remove a completion
    // For now, we'll just show a placeholder
  }
}
