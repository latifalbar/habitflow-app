import 'package:flutter/material.dart';

/// Overall analytics overview data
class AnalyticsOverview {
  final int totalHabits;
  final int totalCompletions;
  final double averageCompletionRate;
  final int currentStreak;
  final int bestStreak;
  final int perfectDays;
  final String mostConsistentHabit;
  final int totalXP;
  final int currentLevel;
  final DateTime dateRangeStart;
  final DateTime dateRangeEnd;

  const AnalyticsOverview({
    required this.totalHabits,
    required this.totalCompletions,
    required this.averageCompletionRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.perfectDays,
    required this.mostConsistentHabit,
    required this.totalXP,
    required this.currentLevel,
    required this.dateRangeStart,
    required this.dateRangeEnd,
  });

  AnalyticsOverview copyWith({
    int? totalHabits,
    int? totalCompletions,
    double? averageCompletionRate,
    int? currentStreak,
    int? bestStreak,
    int? perfectDays,
    String? mostConsistentHabit,
    int? totalXP,
    int? currentLevel,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
  }) {
    return AnalyticsOverview(
      totalHabits: totalHabits ?? this.totalHabits,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      averageCompletionRate: averageCompletionRate ?? this.averageCompletionRate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      perfectDays: perfectDays ?? this.perfectDays,
      mostConsistentHabit: mostConsistentHabit ?? this.mostConsistentHabit,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
    );
  }
}

/// Individual habit analytics data
class HabitAnalytics {
  final String habitId;
  final String habitName;
  final String habitIcon;
  final Color habitColor;
  final String category;
  final int completionCount;
  final int currentStreak;
  final int bestStreak;
  final double completionRate;
  final List<TimeSeriesData> trendData;
  final bool isCompletedToday;
  final DateTime? lastCompletionDate;
  final int totalXP;

  const HabitAnalytics({
    required this.habitId,
    required this.habitName,
    required this.habitIcon,
    required this.habitColor,
    required this.category,
    required this.completionCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.completionRate,
    required this.trendData,
    required this.isCompletedToday,
    this.lastCompletionDate,
    required this.totalXP,
  });

  HabitAnalytics copyWith({
    String? habitId,
    String? habitName,
    String? habitIcon,
    Color? habitColor,
    String? category,
    int? completionCount,
    int? currentStreak,
    int? bestStreak,
    double? completionRate,
    List<TimeSeriesData>? trendData,
    bool? isCompletedToday,
    DateTime? lastCompletionDate,
    int? totalXP,
  }) {
    return HabitAnalytics(
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      habitIcon: habitIcon ?? this.habitIcon,
      habitColor: habitColor ?? this.habitColor,
      category: category ?? this.category,
      completionCount: completionCount ?? this.completionCount,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      completionRate: completionRate ?? this.completionRate,
      trendData: trendData ?? this.trendData,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      totalXP: totalXP ?? this.totalXP,
    );
  }
}

/// Time series data point for charts
class TimeSeriesData {
  final DateTime date;
  final double value;
  final String label;
  final Map<String, dynamic> metadata;

  const TimeSeriesData({
    required this.date,
    required this.value,
    required this.label,
    this.metadata = const {},
  });

  TimeSeriesData copyWith({
    DateTime? date,
    double? value,
    String? label,
    Map<String, dynamic>? metadata,
  }) {
    return TimeSeriesData(
      date: date ?? this.date,
      value: value ?? this.value,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Heatmap calendar data
class HeatmapData {
  final DateTime date;
  final int completionCount;
  final int maxCompletions;
  final double intensity; // 0.0 to 1.0
  final List<String> completedHabitIds;

  const HeatmapData({
    required this.date,
    required this.completionCount,
    required this.maxCompletions,
    required this.intensity,
    required this.completedHabitIds,
  });

  HeatmapData copyWith({
    DateTime? date,
    int? completionCount,
    int? maxCompletions,
    double? intensity,
    List<String>? completedHabitIds,
  }) {
    return HeatmapData(
      date: date ?? this.date,
      completionCount: completionCount ?? this.completionCount,
      maxCompletions: maxCompletions ?? this.maxCompletions,
      intensity: intensity ?? this.intensity,
      completedHabitIds: completedHabitIds ?? this.completedHabitIds,
    );
  }
}

/// Category-wise statistics
class CategoryStats {
  final String category;
  final int habitCount;
  final int totalCompletions;
  final double averageCompletionRate;
  final int totalXP;
  final Color categoryColor;

  const CategoryStats({
    required this.category,
    required this.habitCount,
    required this.totalCompletions,
    required this.averageCompletionRate,
    required this.totalXP,
    required this.categoryColor,
  });

  CategoryStats copyWith({
    String? category,
    int? habitCount,
    int? totalCompletions,
    double? averageCompletionRate,
    int? totalXP,
    Color? categoryColor,
  }) {
    return CategoryStats(
      category: category ?? this.category,
      habitCount: habitCount ?? this.habitCount,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      averageCompletionRate: averageCompletionRate ?? this.averageCompletionRate,
      totalXP: totalXP ?? this.totalXP,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}

/// Time range enum for analytics
enum AnalyticsTimeRange {
  last7Days,
  last30Days,
  last90Days,
  lastYear,
  allTime,
  custom,
}

/// Chart data for different chart types
class ChartData {
  final List<TimeSeriesData> lineData;
  final List<HabitAnalytics> barData;
  final List<CategoryStats> pieData;
  final List<HeatmapData> heatmapData;

  const ChartData({
    required this.lineData,
    required this.barData,
    required this.pieData,
    required this.heatmapData,
  });

  ChartData copyWith({
    List<TimeSeriesData>? lineData,
    List<HabitAnalytics>? barData,
    List<CategoryStats>? pieData,
    List<HeatmapData>? heatmapData,
  }) {
    return ChartData(
      lineData: lineData ?? this.lineData,
      barData: barData ?? this.barData,
      pieData: pieData ?? this.pieData,
      heatmapData: heatmapData ?? this.heatmapData,
    );
  }
}

/// Complete analytics data container
class AnalyticsData {
  final AnalyticsOverview overview;
  final List<HabitAnalytics> habitAnalytics;
  final List<CategoryStats> categoryStats;
  final ChartData chartData;
  final AnalyticsTimeRange timeRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool isLoading;
  final String? error;

  const AnalyticsData({
    required this.overview,
    required this.habitAnalytics,
    required this.categoryStats,
    required this.chartData,
    required this.timeRange,
    this.customStartDate,
    this.customEndDate,
    this.isLoading = false,
    this.error,
  });

  AnalyticsData copyWith({
    AnalyticsOverview? overview,
    List<HabitAnalytics>? habitAnalytics,
    List<CategoryStats>? categoryStats,
    ChartData? chartData,
    AnalyticsTimeRange? timeRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsData(
      overview: overview ?? this.overview,
      habitAnalytics: habitAnalytics ?? this.habitAnalytics,
      categoryStats: categoryStats ?? this.categoryStats,
      chartData: chartData ?? this.chartData,
      timeRange: timeRange ?? this.timeRange,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  AnalyticsData loading() {
    return copyWith(isLoading: true, error: null);
  }

  AnalyticsData errorState(String errorMessage) {
    return copyWith(isLoading: false, error: errorMessage);
  }
}
