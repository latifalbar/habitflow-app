import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/habit.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/habit_log_repository.dart';
import '../../core/utils/xp_calculator.dart';
import '../../core/utils/streak_calculator.dart';

class DailyProgress {
  final int completedToday;
  final int totalHabitsToday;
  final int currentStreak;
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final double completionRate;
  final bool isPerfectDay;
  final bool isLoading;
  final String? error;

  const DailyProgress({
    required this.completedToday,
    required this.totalHabitsToday,
    required this.currentStreak,
    required this.totalXP,
    required this.currentLevel,
    required this.xpToNextLevel,
    required this.completionRate,
    required this.isPerfectDay,
    this.isLoading = false,
    this.error,
  });

  DailyProgress copyWith({
    int? completedToday,
    int? totalHabitsToday,
    int? currentStreak,
    int? totalXP,
    int? currentLevel,
    int? xpToNextLevel,
    double? completionRate,
    bool? isPerfectDay,
    bool? isLoading,
    String? error,
  }) {
    return DailyProgress(
      completedToday: completedToday ?? this.completedToday,
      totalHabitsToday: totalHabitsToday ?? this.totalHabitsToday,
      currentStreak: currentStreak ?? this.currentStreak,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      completionRate: completionRate ?? this.completionRate,
      isPerfectDay: isPerfectDay ?? this.isPerfectDay,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  DailyProgress loading() {
    return copyWith(isLoading: true, error: null);
  }

  DailyProgress errorState(String errorMessage) {
    return copyWith(isLoading: false, error: errorMessage);
  }
}

class ProgressNotifier extends StateNotifier<DailyProgress> {
  final HabitRepository _habitRepository;
  final HabitLogRepository _logRepository;

  ProgressNotifier(this._habitRepository, this._logRepository)
      : super(const DailyProgress(
          completedToday: 0,
          totalHabitsToday: 0,
          currentStreak: 0,
          totalXP: 0,
          currentLevel: 1,
          xpToNextLevel: 100,
          completionRate: 0.0,
          isPerfectDay: false,
          isLoading: true,
        )) {
    _calculateProgress();
  }

  Future<void> _calculateProgress() async {
    try {
      state = state.loading();

      // Get all habits and logs
      final habits = _habitRepository.getActiveHabits();
      final allLogs = _logRepository.getAllLogs();

      // Get today's date
      final today = DateTime.now();

      // Get habits scheduled for today
      final habitsForToday = habits.where((habit) {
        return habit.shouldTrackOnDay(today);
      }).toList();

      // Get today's completions (not used in frequency-aware calculation)
      // final todaysLogs = allLogs.where((log) {
      //   final logDate = _getDateKey(log.completedAt);
      //   return logDate == todayKey;
      // }).toList();

      // Calculate completed habits today (frequency-aware)
      int completedToday = 0;
      int totalHabitsToday = habitsForToday.length;
      
      for (final habit in habitsForToday) {
        if (habit.frequency == HabitFrequency.timesPerWeek) {
          // For weekly habits, check if met weekly target
          final weekCount = _logRepository.getWeekCompletionCount(habit.id);
          if (weekCount >= habit.timesPerWeek) {
            completedToday++;
          }
        } else {
          // For daily habits, check today's completion
          final todayCount = _logRepository.getTodaysCompletionCount(habit.id);
          if (todayCount > 0) {
            completedToday++;
          }
        }
      }

      // Calculate completion rate
      final completionRate = totalHabitsToday > 0 
          ? completedToday / totalHabitsToday 
          : 0.0;

      // Check if perfect day
      final isPerfectDay = totalHabitsToday > 0 && completedToday == totalHabitsToday;

      // Calculate overall streak
      final currentStreak = StreakCalculator.calculateOverallStreak(allLogs);

      // Calculate total XP
      final totalXP = _calculateTotalXP(allLogs);

      // Calculate level info
      final levelInfo = XPCalculator.getLevelInfo(totalXP);

      state = DailyProgress(
        completedToday: completedToday,
        totalHabitsToday: totalHabitsToday,
        currentStreak: currentStreak,
        totalXP: totalXP,
        currentLevel: levelInfo.level,
        xpToNextLevel: levelInfo.xpNeededForNextLevel,
        completionRate: completionRate,
        isPerfectDay: isPerfectDay,
        isLoading: false,
      );
    } catch (e) {
      state = state.errorState('Failed to calculate progress: $e');
    }
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

  int _calculateDayXP(List<HabitLog> dayLogs) {
    if (dayLogs.isEmpty) return 0;

    int dayXP = 0;
    final habitIds = dayLogs.map((log) => log.habitId).toSet();

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

      // Check if perfect day (all habits completed)
      final allHabits = _habitRepository.getActiveHabits();
      final habitsForDay = allHabits.where((h) => h.shouldTrackOnDay(log.completedAt)).toList();
      final isPerfectDay = habitIds.length == habitsForDay.length;

      // Check if category is complete
      final isCategoryComplete = _isCategoryComplete(habit.category, dayLogs);

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

  bool _isCategoryComplete(String category, List<HabitLog> dayLogs) {
    final allHabits = _habitRepository.getActiveHabits();
    final categoryHabits = allHabits.where((h) => h.category == category).toList();
    final completedCategoryHabits = dayLogs.map((log) => log.habitId).toSet();
    
    return categoryHabits.every((habit) => completedCategoryHabits.contains(habit.id));
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> refresh() async {
    await _calculateProgress();
  }

  // Get level info
  LevelInfo getLevelInfo() {
    return XPCalculator.getLevelInfo(state.totalXP);
  }

  // Get streak stats
  Map<String, dynamic> getStreakStats() {
    final habits = _habitRepository.getActiveHabits();
    final logs = _logRepository.getAllLogs();
    return StreakCalculator.getStreakStats(logs, habits);
  }

  // Check if user reached a milestone
  Milestone? checkMilestone() {
    return XPCalculator.checkMilestone(state.totalXP);
  }
}

// Providers
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitLogRepositoryProvider = Provider<HabitLogRepository>((ref) {
  return HabitLogRepository();
});

final progressProvider = StateNotifierProvider<ProgressNotifier, DailyProgress>((ref) {
  final habitRepo = ref.watch(habitRepositoryProvider);
  final logRepo = ref.watch(habitLogRepositoryProvider);
  return ProgressNotifier(habitRepo, logRepo);
});

// Computed providers
final todaysProgressProvider = Provider<DailyProgress>((ref) {
  return ref.watch(progressProvider);
});

final levelInfoProvider = Provider<LevelInfo>((ref) {
  final progress = ref.watch(progressProvider);
  return XPCalculator.getLevelInfo(progress.totalXP);
});

final streakStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final progressNotifier = ref.watch(progressProvider.notifier);
  return progressNotifier.getStreakStats();
});

final milestoneProvider = Provider<Milestone?>((ref) {
  final progress = ref.watch(progressProvider);
  return XPCalculator.checkMilestone(progress.totalXP);
});
