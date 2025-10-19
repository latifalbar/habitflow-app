import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/habit.dart';

class ChartUtils {
  /// Format data for line chart
  static List<FlSpot> formatLineChartData(List<TimeSeriesData> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  /// Format data for bar chart
  static List<BarChartGroupData> formatBarChartData(List<HabitAnalytics> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final habit = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: habit.completionCount.toDouble(),
            color: habit.habitColor,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  /// Format data for pie chart
  static List<PieChartSectionData> formatPieChartData(List<CategoryStats> data) {
    final total = data.fold(0, (sum, category) => sum + category.totalCompletions);
    
    return data.map((category) {
      final percentage = total > 0 ? (category.totalCompletions / total) * 100 : 0.0;
      return PieChartSectionData(
        color: category.categoryColor,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Get chart colors based on theme
  static List<Color> getChartColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? [
      const Color(0xFF4FC3F7),
      const Color(0xFF29B6F6),
      const Color(0xFF03A9F4),
      const Color(0xFF0288D1),
      const Color(0xFF0277BD),
    ] : [
      const Color(0xFF1976D2),
      const Color(0xFF2196F3),
      const Color(0xFF03A9F4),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
    ];
  }

  /// Get gradient colors for charts
  static List<Color> getGradientColors(Color baseColor) {
    return [
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.4),
      baseColor.withOpacity(0.1),
    ];
  }

  /// Format date for x-axis labels
  static String formatDateLabel(DateTime date, AnalyticsTimeRange timeRange) {
    switch (timeRange) {
      case AnalyticsTimeRange.last7Days:
        return DateFormat('E').format(date); // Mon, Tue, etc.
      case AnalyticsTimeRange.last30Days:
        return DateFormat('MMM d').format(date); // Jan 1, Jan 2, etc.
      case AnalyticsTimeRange.last90Days:
        return DateFormat('MMM d').format(date); // Jan 1, Jan 2, etc.
      case AnalyticsTimeRange.lastYear:
        return DateFormat('MMM').format(date); // Jan, Feb, etc.
      case AnalyticsTimeRange.allTime:
        return DateFormat('MMM yyyy').format(date); // Jan 2024, Feb 2024, etc.
      case AnalyticsTimeRange.custom:
        return DateFormat('MMM d').format(date); // Jan 1, Jan 2, etc.
    }
  }

  /// Calculate chart bounds
  static FlTitlesData getTitlesData(
    BuildContext context,
    AnalyticsTimeRange timeRange,
    List<TimeSeriesData> data,
  ) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
    );

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _calculateXAxisInterval(data.length),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < data.length) {
              return Text(
                formatDateLabel(data[index].date, timeRange),
                style: textStyle,
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _calculateYAxisInterval(data),
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: textStyle,
            );
          },
        ),
      ),
    );
  }

  /// Calculate X-axis interval for labels
  static double _calculateXAxisInterval(int dataLength) {
    if (dataLength <= 7) return 1.0;
    if (dataLength <= 14) return 2.0;
    if (dataLength <= 30) return 5.0;
    return (dataLength / 6).ceilToDouble();
  }

  /// Calculate Y-axis interval for labels
  static double _calculateYAxisInterval(List<TimeSeriesData> data) {
    if (data.isEmpty) return 1.0;
    
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    if (maxValue <= 10) return 1.0;
    if (maxValue <= 50) return 5.0;
    if (maxValue <= 100) return 10.0;
    return (maxValue / 5).ceilToDouble();
  }

  /// Get heatmap color based on intensity
  static Color getHeatmapColor(double intensity) {
    if (intensity == 0) return Colors.grey.withOpacity(0.1);
    if (intensity <= 0.25) return Colors.green.withOpacity(0.3);
    if (intensity <= 0.5) return Colors.green.withOpacity(0.5);
    if (intensity <= 0.75) return Colors.green.withOpacity(0.7);
    return Colors.green.withOpacity(0.9);
  }

  /// Generate time series data from habit logs
  static List<TimeSeriesData> generateTimeSeriesData(
    List<HabitLog> logs,
    DateTime startDate,
    DateTime endDate,
    AnalyticsTimeRange timeRange,
  ) {
    final Map<String, int> dailyCompletions = {};
    
    // Initialize all dates in range with 0
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = _getDateKey(currentDate);
      dailyCompletions[dateKey] = 0;
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    // Count completions for each date
    for (final log in logs) {
      if (log.completedAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          log.completedAt.isBefore(endDate.add(const Duration(days: 1)))) {
        final dateKey = _getDateKey(log.completedAt);
        dailyCompletions[dateKey] = (dailyCompletions[dateKey] ?? 0) + 1;
      }
    }
    
    // Convert to TimeSeriesData
    final result = <TimeSeriesData>[];
    var currentDate2 = startDate;
    while (currentDate2.isBefore(endDate) || currentDate2.isAtSameMomentAs(endDate)) {
      final dateKey = _getDateKey(currentDate2);
      result.add(TimeSeriesData(
        date: currentDate2,
        value: dailyCompletions[dateKey]?.toDouble() ?? 0.0,
        label: formatDateLabel(currentDate2, timeRange),
      ));
      currentDate2 = currentDate2.add(const Duration(days: 1));
    }
    
    return result;
  }

  /// Generate heatmap data from habit logs
  static List<HeatmapData> generateHeatmapData(
    List<HabitLog> logs,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<String, List<String>> dailyHabitIds = {};
    final Map<String, int> dailyCompletions = {};
    
    // Initialize all dates in range
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = _getDateKey(currentDate);
      dailyHabitIds[dateKey] = [];
      dailyCompletions[dateKey] = 0;
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    // Count completions for each date
    for (final log in logs) {
      if (log.completedAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          log.completedAt.isBefore(endDate.add(const Duration(days: 1)))) {
        final dateKey = _getDateKey(log.completedAt);
        if (!dailyHabitIds[dateKey]!.contains(log.habitId)) {
          dailyHabitIds[dateKey]!.add(log.habitId);
          dailyCompletions[dateKey] = (dailyCompletions[dateKey] ?? 0) + 1;
        }
      }
    }
    
    // Find max completions for intensity calculation
    final maxCompletions = dailyCompletions.values.fold(0, (a, b) => a > b ? a : b);
    
    // Convert to HeatmapData
    final result = <HeatmapData>[];
    var currentDate2 = startDate;
    while (currentDate2.isBefore(endDate) || currentDate2.isAtSameMomentAs(endDate)) {
      final dateKey = _getDateKey(currentDate2);
      final completions = dailyCompletions[dateKey] ?? 0;
      final intensity = maxCompletions > 0 ? completions / maxCompletions : 0.0;
      
      result.add(HeatmapData(
        date: currentDate2,
        completionCount: completions,
        maxCompletions: maxCompletions,
        intensity: intensity,
        completedHabitIds: dailyHabitIds[dateKey] ?? [],
      ));
      currentDate2 = currentDate2.add(const Duration(days: 1));
    }
    
    return result;
  }

  /// Get date key for grouping
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate completion rate
  static double calculateCompletionRate(List<HabitLog> logs, List<Habit> habits, DateTime startDate, DateTime endDate) {
    if (habits.isEmpty) return 0.0;
    
    int totalPossibleCompletions = 0;
    int actualCompletions = 0;
    
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      for (final habit in habits) {
        if (habit.shouldTrackOnDay(currentDate)) {
          totalPossibleCompletions++;
          if (logs.any((log) => 
              log.habitId == habit.id && 
              log.completedAt.year == currentDate.year &&
              log.completedAt.month == currentDate.month &&
              log.completedAt.day == currentDate.day)) {
            actualCompletions++;
          }
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return totalPossibleCompletions > 0 ? actualCompletions / totalPossibleCompletions : 0.0;
  }

  /// Get chart tooltip
  static String getTooltipText(FlTouchEvent event, LineChartBarData barData, int spotIndex) {
    if (event is FlTapUpEvent && barData.spots.isNotEmpty) {
      final spot = barData.spots[spotIndex];
      return '${spot.y.toInt()} completions';
    }
    return '';
  }
}
