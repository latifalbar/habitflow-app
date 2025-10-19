import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/habit.dart';

class CalendarHeatmap extends StatelessWidget {
  final Habit habit;
  final Function(DateTime)? onDateTap;
  final int daysToShow;

  const CalendarHeatmap({
    super.key,
    required this.habit,
    this.onDateTap,
    this.daysToShow = 365,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: daysToShow - 1));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last ${daysToShow == 365 ? 'Year' : '$daysToShow Days'}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildLegend(),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Calendar grid
            _buildCalendarGrid(startDate, today),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Month labels
            _buildMonthLabels(startDate, today),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Less',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.grey500,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        ...List.generate(5, (index) {
          final intensity = (index + 1) / 5;
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getHeatmapColor(intensity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'More',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime startDate, DateTime endDate) {
    final weeks = <Widget>[];
    final currentDate = startDate;
    
    // Add empty cells for days before the start date (to align with weekdays)
    final startWeekday = startDate.weekday;
    final emptyCells = <Widget>[];
    for (int i = 1; i < startWeekday; i++) {
      emptyCells.add(const SizedBox(width: 11, height: 11));
    }
    
    // Generate calendar cells
    final cells = <Widget>[];
    var date = startDate;
    while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
      final isCompleted = _isDateCompleted(date);
      final intensity = _getCompletionIntensity(date);
      
      cells.add(
        GestureDetector(
          onTap: () => onDateTap?.call(date),
          child: Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? _getHeatmapColor(intensity)
                  : AppColors.grey100,
              borderRadius: BorderRadius.circular(2),
              border: date.isAtSameMomentAs(DateTime.now()) 
                  ? Border.all(color: habit.color, width: 1)
                  : null,
            ),
          ),
        ),
      );
      
      date = date.add(const Duration(days: 1));
    }
    
    // Group cells into weeks
    final allCells = [...emptyCells, ...cells];
    for (int i = 0; i < allCells.length; i += 7) {
      final weekCells = allCells.skip(i).take(7).toList();
      // Pad with empty cells if needed
      while (weekCells.length < 7) {
        weekCells.add(const SizedBox(width: 11, height: 11));
      }
      
      weeks.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: weekCells,
        ),
      );
    }
    
    return Column(
      children: weeks,
    );
  }

  Widget _buildMonthLabels(DateTime startDate, DateTime endDate) {
    final monthLabels = <Widget>[];
    var currentMonth = startDate.month;
    var currentYear = startDate.year;
    
    // Calculate approximate position for month labels
    final totalDays = endDate.difference(startDate).inDays;
    final weeks = (totalDays / 7).ceil();
    
    for (int week = 0; week < weeks; week += 4) {
      final monthDate = startDate.add(Duration(days: week * 7));
      final monthName = _getMonthName(monthDate.month);
      
      monthLabels.add(
        SizedBox(
          width: 44, // 4 weeks * 11px
          child: Text(
            monthName,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: monthLabels,
      ),
    );
  }

  bool _isDateCompleted(DateTime date) {
    // TODO: Check actual completion data from repository
    // For now, return mock data
    final random = date.day % 3;
    return random == 0; // Mock: complete every 3rd day
  }

  double _getCompletionIntensity(DateTime date) {
    // TODO: Calculate based on actual completion data
    // For now, return mock intensity
    if (!_isDateCompleted(date)) return 0.0;
    
    final random = date.day % 5;
    return (random + 1) / 5; // Mock: intensity 0.2 to 1.0
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) return AppColors.grey100;
    
    // Create gradient from light to dark habit color
    final baseColor = habit.color;
    final alpha = (0.2 + (intensity * 0.8)).clamp(0.0, 1.0);
    
    return baseColor.withOpacity(alpha);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// Simplified version for smaller spaces
class CompactCalendarHeatmap extends StatelessWidget {
  final Habit habit;
  final Function(DateTime)? onDateTap;
  final int daysToShow;

  const CompactCalendarHeatmap({
    super.key,
    required this.habit,
    this.onDateTap,
    this.daysToShow = 30,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: daysToShow - 1));
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last $daysToShow Days',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Simple row of dots
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(daysToShow, (index) {
              final date = startDate.add(Duration(days: index));
              final isCompleted = _isDateCompleted(date);
              final intensity = _getCompletionIntensity(date);
              
              return GestureDetector(
                onTap: () => onDateTap?.call(date),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? _getHeatmapColor(intensity)
                        : AppColors.grey200,
                    shape: BoxShape.circle,
                    border: date.isAtSameMomentAs(DateTime.now()) 
                        ? Border.all(color: habit.color, width: 1)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isDateCompleted(DateTime date) {
    // TODO: Check actual completion data
    final random = date.day % 3;
    return random == 0;
  }

  double _getCompletionIntensity(DateTime date) {
    if (!_isDateCompleted(date)) return 0.0;
    final random = date.day % 5;
    return (random + 1) / 5;
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) return AppColors.grey100;
    final baseColor = habit.color;
    final alpha = (0.3 + (intensity * 0.7)).clamp(0.0, 1.0);
    return baseColor.withOpacity(alpha);
  }
}
