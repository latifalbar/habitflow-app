import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/chart_utils.dart';
import '../../providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class HeatmapCalendar extends ConsumerWidget {
  const HeatmapCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    
    if (analytics.isLoading) {
      return _buildLoadingCalendar();
    }
    
    if (analytics.error != null) {
      return _buildErrorCalendar(analytics.error!);
    }
    
    final heatmapData = analytics.chartData.heatmapData;
    
    if (heatmapData.isEmpty) {
      return _buildEmptyCalendar();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.oceanPrimary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Activity Heatmap',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildHeatmapGrid(heatmapData),
            const SizedBox(height: AppSpacing.sm),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(List<HeatmapData> data) {
    // Group data by weeks
    final weeks = <List<HeatmapData>>[];
    List<HeatmapData> currentWeek = [];
    
    for (int i = 0; i < data.length; i++) {
      final day = data[i];
      currentWeek.add(day);
      
      // Start new week on Sunday (weekday 7)
      if (day.date.weekday == 7 || i == data.length - 1) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }
    
    return Column(
      children: [
        // Day labels
        Row(
          children: [
            const SizedBox(width: 20), // Space for month labels
            ...List.generate(7, (index) {
              final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              return Expanded(
                child: Center(
                  child: Text(
                    dayNames[index],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Heatmap grid
        ...weeks.map((week) => _buildWeekRow(week)).toList(),
      ],
    );
  }

  Widget _buildWeekRow(List<HeatmapData> week) {
    return Row(
      children: [
        // Month label (only show for first week of month)
        SizedBox(
          width: 20,
          child: week.isNotEmpty && week.first.date.day <= 7
              ? Text(
                  DateFormat('MMM').format(week.first.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        
        // Day squares
        ...week.map((day) => _buildDaySquare(day)).toList(),
        
        // Fill remaining days if week is incomplete
        ...List.generate(7 - week.length, (index) => _buildEmptyDaySquare()),
      ],
    );
  }

  Widget _buildDaySquare(HeatmapData day) {
    final color = ChartUtils.getHeatmapColor(day.intensity);
    final isToday = _isToday(day.date);
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(1),
        child: Tooltip(
          message: _getTooltipMessage(day),
          child: GestureDetector(
            onTap: () => _showDayDetails(day),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                border: isToday
                    ? Border.all(
                        color: AppColors.oceanPrimary,
                        width: 1,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDaySquare() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(1),
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Less',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final intensity = index / 4.0;
            final color = ChartUtils.getHeatmapColor(intensity);
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        Text(
          'More',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getTooltipMessage(HeatmapData day) {
    final dateStr = DateFormat('MMM d, yyyy').format(day.date);
    if (day.completionCount == 0) {
      return '$dateStr\nNo completions';
    }
    return '$dateStr\n${day.completionCount} completion${day.completionCount == 1 ? '' : 's'}';
  }

  void _showDayDetails(HeatmapData day) {
    // TODO: Show detailed view for the selected day
    // This could be a bottom sheet or dialog showing which habits were completed
  }

  Widget _buildLoadingCalendar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCalendar(String error) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
              'Failed to load calendar',
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
    );
  }

  Widget _buildEmptyCalendar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.grey400,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No activity data',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete some habits to see your activity heatmap',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
