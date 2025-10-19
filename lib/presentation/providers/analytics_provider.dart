import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/habit.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/habit_log_repository.dart';
import '../../core/utils/chart_utils.dart';
import '../../core/utils/streak_calculator.dart';
import '../../core/utils/xp_calculator.dart';

class DateRange {
  final DateTime start;
  final DateTime end;
  
  const DateRange({
    required this.start,
    required this.end,
  });
}

class AnalyticsNotifier extends StateNotifier<AsyncValue<AnalyticsData>> {
  final HabitRepository _habitRepository;
  final HabitLogRepository _logRepository;
  
  // State tracking variables
  AnalyticsTimeRange _currentTimeRange = AnalyticsTimeRange.last30Days;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  AnalyticsNotifier(this._habitRepository, this._logRepository)
      : super(const AsyncValue.loading()) {
    _loadAnalytics();
  }

  Future<void> _loadAnalytics([AnalyticsTimeRange? timeRange, DateTime? customStart, DateTime? customEnd]) async {
    try {
      state = const AsyncValue.loading();
      
      // Update current state if provided
      if (timeRange != null) {
        _currentTimeRange = timeRange;
        if (timeRange == AnalyticsTimeRange.custom) {
          _customStartDate = customStart;
          _customEndDate = customEnd;
        }
      }
      
      final habits = _habitRepository.getActiveHabits();
      final logs = _logRepository.getAllLogs();
      
      // Use _currentTimeRange instead of hardcoded value
      final dateRange = _getDateRange(_currentTimeRange, _customStartDate, _customEndDate);
      
      // Filter logs by date range
      final filteredLogs = logs.where((log) =>
          log.completedAt.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
          log.completedAt.isBefore(dateRange.end.add(const Duration(days: 1)))
      ).toList();
      
      // Calculate overview
      final overview = _calculateOverview(habits, filteredLogs, dateRange);
      
      // Calculate habit analytics
      final habitAnalytics = _calculateHabitAnalytics(habits, filteredLogs, dateRange);
      
      // Calculate category stats
      final categoryStats = _calculateCategoryStats(habits, filteredLogs);
      
      // Generate chart data
      final chartData = _generateChartData(filteredLogs, dateRange);
      
      final analyticsData = AnalyticsData(
        overview: overview,
        habitAnalytics: habitAnalytics,
        categoryStats: categoryStats,
        chartData: chartData,
        timeRange: _currentTimeRange,  // Use _currentTimeRange
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
        isLoading: false,
      );
      
      state = AsyncValue.data(analyticsData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> setTimeRange(AnalyticsTimeRange timeRange, {DateTime? customStart, DateTime? customEnd}) async {
    await _loadAnalytics(timeRange, customStart, customEnd);
  }

  Future<void> refresh() async {
    await _loadAnalytics();
  }

  DateRange _getDateRange(AnalyticsTimeRange timeRange, DateTime? customStart, DateTime? customEnd) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (timeRange) {
      case AnalyticsTimeRange.last7Days:
        return DateRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case AnalyticsTimeRange.last30Days:
        return DateRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case AnalyticsTimeRange.last90Days:
        return DateRange(
          start: today.subtract(const Duration(days: 89)),
          end: today,
        );
      case AnalyticsTimeRange.lastYear:
        return DateRange(
          start: DateTime(now.year - 1, 1, 1),
          end: today,
        );
      case AnalyticsTimeRange.allTime:
        return DateRange(
          start: DateTime(2020, 1, 1), // Arbitrary start date
          end: today,
        );
      case AnalyticsTimeRange.custom:
        return DateRange(
          start: customStart ?? today.subtract(const Duration(days: 29)),
          end: customEnd ?? today,
        );
    }
  }

  AnalyticsOverview _calculateOverview(List<Habit> habits, List<HabitLog> logs, DateRange dateRange) {
    final totalHabits = habits.length;
    final totalCompletions = logs.length;
    final averageCompletionRate = ChartUtils.calculateCompletionRate(logs, habits, dateRange.start, dateRange.end);
    
    // Calculate streaks
    final currentStreak = StreakCalculator.calculateOverallStreak(logs);
    final bestStreak = _calculateBestStreak(logs);
    
    // Calculate perfect days
    final perfectDays = _calculatePerfectDays(logs, habits, dateRange);
    
    // Find most consistent habit
    final mostConsistentHabit = _findMostConsistentHabit(habits, logs);
    
    // Calculate XP and level
    final totalXP = _calculateTotalXP(logs);
    final levelInfo = XPCalculator.getLevelInfo(totalXP);
    
    return AnalyticsOverview(
      totalHabits: totalHabits,
      totalCompletions: totalCompletions,
      averageCompletionRate: averageCompletionRate,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      perfectDays: perfectDays,
      mostConsistentHabit: mostConsistentHabit,
      totalXP: totalXP,
      currentLevel: levelInfo.level,
      dateRangeStart: dateRange.start,
      dateRangeEnd: dateRange.end,
    );
  }

  List<HabitAnalytics> _calculateHabitAnalytics(List<Habit> habits, List<HabitLog> logs, DateRange dateRange) {
    return habits.map((habit) {
      final habitLogs = logs.where((log) => log.habitId == habit.id).toList();
      final completionCount = habitLogs.length;
      final currentStreak = StreakCalculator.calculateHabitStreak(habit.id, logs, habit);
      final bestStreak = _calculateHabitBestStreak(habit.id, logs);
      final completionRate = ChartUtils.calculateCompletionRate(habitLogs, [habit], dateRange.start, dateRange.end);
      final trendData = ChartUtils.generateTimeSeriesData(habitLogs, dateRange.start, dateRange.end, AnalyticsTimeRange.last30Days);
      final isCompletedToday = _logRepository.isHabitCompletedToday(habit.id);
      final lastCompletionDate = habitLogs.isNotEmpty ? habitLogs.last.completedAt : null;
      final totalXP = _calculateHabitXP(habitLogs);
      
      return HabitAnalytics(
        habitId: habit.id,
        habitName: habit.name,
        habitIcon: habit.icon,
        habitColor: habit.color,
        category: habit.category,
        completionCount: completionCount,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        completionRate: completionRate,
        trendData: trendData,
        isCompletedToday: isCompletedToday,
        lastCompletionDate: lastCompletionDate,
        totalXP: totalXP,
      );
    }).toList();
  }

  List<CategoryStats> _calculateCategoryStats(List<Habit> habits, List<HabitLog> logs) {
    final categoryMap = <String, List<Habit>>{};
    
    // Group habits by category
    for (final habit in habits) {
      categoryMap[habit.category] ??= [];
      categoryMap[habit.category]!.add(habit);
    }
    
    return categoryMap.entries.map((entry) {
      final category = entry.key;
      final categoryHabits = entry.value;
      final categoryLogs = logs.where((log) => 
          categoryHabits.any((habit) => habit.id == log.habitId)).toList();
      
      final habitCount = categoryHabits.length;
      final totalCompletions = categoryLogs.length;
      final averageCompletionRate = habitCount > 0 ? totalCompletions / (habitCount * 30) : 0.0; // Approximate
      final totalXP = _calculateHabitXP(categoryLogs);
      
      // Use first habit's color as category color
      final categoryColor = categoryHabits.isNotEmpty ? categoryHabits.first.color : const Color(0xFF9E9E9E);
      
      return CategoryStats(
        category: category,
        habitCount: habitCount,
        totalCompletions: totalCompletions,
        averageCompletionRate: averageCompletionRate,
        totalXP: totalXP,
        categoryColor: categoryColor,
      );
    }).toList();
  }

  ChartData _generateChartData(List<HabitLog> logs, DateRange dateRange) {
    final lineData = ChartUtils.generateTimeSeriesData(logs, dateRange.start, dateRange.end, AnalyticsTimeRange.last30Days);
    final heatmapData = ChartUtils.generateHeatmapData(logs, dateRange.start, dateRange.end);
    
    return ChartData(
      lineData: lineData,
      barData: [], // Will be populated by the calling method
      pieData: [], // Will be populated by the calling method
      heatmapData: heatmapData,
    );
  }

  int _calculateBestStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;
    
    final logsByDate = <String, List<HabitLog>>{};
    for (final log in logs) {
      final dateKey = _getDateKey(log.completedAt);
      logsByDate[dateKey] ??= [];
      logsByDate[dateKey]!.add(log);
    }
    
    final sortedDates = logsByDate.keys.toList()..sort();
    int bestStreak = 0;
    int currentStreak = 0;
    
    for (int i = 0; i < sortedDates.length; i++) {
      if (i == 0 || _isConsecutiveDay(sortedDates[i - 1], sortedDates[i])) {
        currentStreak++;
        bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return bestStreak;
  }

  int _calculateHabitBestStreak(String habitId, List<HabitLog> logs) {
    final habitLogs = logs.where((log) => log.habitId == habitId).toList();
    return _calculateBestStreak(habitLogs);
  }

  int _calculatePerfectDays(List<HabitLog> logs, List<Habit> habits, DateRange dateRange) {
    if (habits.isEmpty) return 0;
    
    final logsByDate = <String, List<HabitLog>>{};
    for (final log in logs) {
      final dateKey = _getDateKey(log.completedAt);
      logsByDate[dateKey] ??= [];
      logsByDate[dateKey]!.add(log);
    }
    
    int perfectDays = 0;
    var currentDate = dateRange.start;
    while (currentDate.isBefore(dateRange.end) || currentDate.isAtSameMomentAs(dateRange.end)) {
      final dateKey = _getDateKey(currentDate);
      final dayLogs = logsByDate[dateKey] ?? [];
      final dayHabits = habits.where((habit) => habit.shouldTrackOnDay(currentDate)).toList();
      
      if (dayHabits.isNotEmpty) {
        final completedHabitIds = dayLogs.map((log) => log.habitId).toSet();
        final allHabitsCompleted = dayHabits.every((habit) => completedHabitIds.contains(habit.id));
        if (allHabitsCompleted) perfectDays++;
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return perfectDays;
  }

  String _findMostConsistentHabit(List<Habit> habits, List<HabitLog> logs) {
    if (habits.isEmpty) return '';
    
    String mostConsistent = '';
    double bestRate = 0.0;
    
    for (final habit in habits) {
      final habitLogs = logs.where((log) => log.habitId == habit.id).toList();
      final rate = ChartUtils.calculateCompletionRate(habitLogs, [habit], 
          DateTime.now().subtract(const Duration(days: 30)), DateTime.now());
      
      if (rate > bestRate) {
        bestRate = rate;
        mostConsistent = habit.name;
      }
    }
    
    return mostConsistent;
  }

  int _calculateTotalXP(List<HabitLog> logs) {
    int totalXP = 0;
    
    // Group logs by date to calculate daily bonuses
    final logsByDate = <String, List<HabitLog>>{};
    for (final log in logs) {
      final dateKey = _getDateKey(log.completedAt);
      logsByDate[dateKey] ??= [];
      logsByDate[dateKey]!.add(log);
    }
    
    // Calculate XP for each day
    for (final dateLogs in logsByDate.values) {
      totalXP += _calculateDayXP(dateLogs);
    }
    
    return totalXP;
  }

  int _calculateHabitXP(List<HabitLog> habitLogs) {
    int totalXP = 0;
    
    for (final _ in habitLogs) {
      // Simple XP calculation - can be enhanced
      totalXP += 10; // Base XP per completion
    }
    
    return totalXP;
  }

  int _calculateDayXP(List<HabitLog> dayLogs) {
    if (dayLogs.isEmpty) return 0;
    
    int dayXP = 0;
    
    for (final log in dayLogs) {
      // Get habit info for streak calculation
      final habit = _habitRepository.getHabitById(log.habitId);
      if (habit == null) continue;
      
      // Calculate streak for this habit
      final habitStreak = StreakCalculator.calculateHabitStreak(
        log.habitId, 
        _logRepository.getAllLogs(), 
        habit
      );
      
      // Check if this is first completion of this habit
      final isFirstTime = _isFirstCompletion(log.habitId, log.completedAt);
      
      // Calculate XP for this completion
      final completionXP = XPCalculator.calculateCompletionXP(
        habit,
        habitStreak,
        isFirstTime,
      );
      
      dayXP += completionXP;
    }
    
    return dayXP;
  }

  bool _isFirstCompletion(String habitId, DateTime completionDate) {
    final habitLogs = _logRepository.getLogsByHabitId(habitId);
    final earlierLogs = habitLogs.where((log) => 
        log.completedAt.isBefore(completionDate)).toList();
    return earlierLogs.isEmpty;
  }

  bool _isConsecutiveDay(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays == 1;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Providers
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitLogRepositoryProvider = Provider<HabitLogRepository>((ref) {
  return HabitLogRepository();
});

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsData>>((ref) {
  final habitRepo = ref.watch(habitRepositoryProvider);
  final logRepo = ref.watch(habitLogRepositoryProvider);
  return AnalyticsNotifier(habitRepo, logRepo);
});

// Computed providers
final analyticsOverviewProvider = Provider<AnalyticsOverview>((ref) {
  return ref.watch(analyticsProvider).when(
    data: (analytics) => analytics.overview,
    loading: () => AnalyticsOverview(
      totalHabits: 0,
      totalCompletions: 0,
      averageCompletionRate: 0.0,
      currentStreak: 0,
      bestStreak: 0,
      perfectDays: 0,
      mostConsistentHabit: '',
      totalXP: 0,
      currentLevel: 1,
      dateRangeStart: DateTime.now(),
      dateRangeEnd: DateTime.now(),
    ),
    error: (_, __) => AnalyticsOverview(
      totalHabits: 0,
      totalCompletions: 0,
      averageCompletionRate: 0.0,
      currentStreak: 0,
      bestStreak: 0,
      perfectDays: 0,
      mostConsistentHabit: '',
      totalXP: 0,
      currentLevel: 1,
      dateRangeStart: DateTime.now(),
      dateRangeEnd: DateTime.now(),
    ),
  );
});

final habitAnalyticsProvider = Provider<List<HabitAnalytics>>((ref) {
  return ref.watch(analyticsProvider).when(
    data: (analytics) => analytics.habitAnalytics,
    loading: () => [],
    error: (_, __) => [],
  );
});

final categoryStatsProvider = Provider<List<CategoryStats>>((ref) {
  return ref.watch(analyticsProvider).when(
    data: (analytics) => analytics.categoryStats,
    loading: () => [],
    error: (_, __) => [],
  );
});

final chartDataProvider = Provider<ChartData>((ref) {
  return ref.watch(analyticsProvider).when(
    data: (analytics) => analytics.chartData,
    loading: () => ChartData(
      lineData: [],
      barData: [],
      pieData: [],
      heatmapData: [],
    ),
    error: (_, __) => ChartData(
      lineData: [],
      barData: [],
      pieData: [],
      heatmapData: [],
    ),
  );
});
