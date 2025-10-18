import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/habit_log_repository.dart';
import '../../domain/entities/habit_log.dart';

// Repository provider
final habitLogRepositoryProvider = Provider<HabitLogRepository>((ref) {
  return HabitLogRepository();
});

// All logs provider
final habitLogsProvider = StateNotifierProvider<HabitLogsNotifier, AsyncValue<List<HabitLog>>>((ref) {
  final repository = ref.watch(habitLogRepositoryProvider);
  return HabitLogsNotifier(repository);
});

// Logs for specific habit provider
final habitLogsForHabitProvider = Provider.family<AsyncValue<List<HabitLog>>, String>((ref, habitId) {
  final logsAsync = ref.watch(habitLogsProvider);
  return logsAsync.when(
    data: (logs) => AsyncValue.data(logs.where((log) => log.habitId == habitId).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Today's logs provider
final todaysLogsProvider = Provider<AsyncValue<List<HabitLog>>>((ref) {
  final logsAsync = ref.watch(habitLogsProvider);
  return logsAsync.when(
    data: (logs) {
      final repository = ref.watch(habitLogRepositoryProvider);
      final todaysLogs = repository.getTodaysLogs();
      return AsyncValue.data(todaysLogs);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Habit completion status provider
final habitCompletionStatusProvider = Provider.family<AsyncValue<bool>, String>((ref, habitId) {
  final logsAsync = ref.watch(habitLogsProvider);
  return logsAsync.when(
    data: (logs) {
      final repository = ref.watch(habitLogRepositoryProvider);
      final isCompleted = repository.isHabitCompletedToday(habitId);
      return AsyncValue.data(isCompleted);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Habit stats provider
final habitStatsProvider = Provider.family<AsyncValue<HabitStats>, String>((ref, habitId) {
  final logsAsync = ref.watch(habitLogsProvider);
  return logsAsync.when(
    data: (logs) {
      final repository = ref.watch(habitLogRepositoryProvider);
      final stats = HabitStats(
        completionCount: repository.getCompletionCount(habitId),
        currentStreak: repository.calculateCurrentStreak(habitId),
        bestStreak: repository.calculateBestStreak(habitId),
        completionRate: repository.calculateCompletionRate(habitId),
        isCompletedToday: repository.isHabitCompletedToday(habitId),
      );
      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class HabitLogsNotifier extends StateNotifier<AsyncValue<List<HabitLog>>> {
  final HabitLogRepository _repository;

  HabitLogsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      state = const AsyncValue.loading();
      final logs = _repository.getAllLogs();
      state = AsyncValue.data(logs);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addLog(HabitLog log) async {
    try {
      await _repository.addLog(log);
      await _loadLogs();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateLog(HabitLog log) async {
    try {
      await _repository.updateLog(log);
      await _loadLogs();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await _repository.deleteLog(id);
      await _loadLogs();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteLogsForHabit(String habitId) async {
    try {
      await _repository.deleteLogsForHabit(habitId);
      await _loadLogs();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadLogs();
  }

  // Helper methods
  List<HabitLog> getLogsByHabitId(String habitId) {
    return _repository.getLogsByHabitId(habitId);
  }

  List<HabitLog> getTodaysLogs() {
    return _repository.getTodaysLogs();
  }

  List<HabitLog> getTodaysLogsForHabit(String habitId) {
    return _repository.getTodaysLogsForHabit(habitId);
  }

  bool isHabitCompletedToday(String habitId) {
    return _repository.isHabitCompletedToday(habitId);
  }

  int getCompletionCount(String habitId) {
    return _repository.getCompletionCount(habitId);
  }

  int calculateCurrentStreak(String habitId) {
    return _repository.calculateCurrentStreak(habitId);
  }

  int calculateBestStreak(String habitId) {
    return _repository.calculateBestStreak(habitId);
  }

  double calculateCompletionRate(String habitId, {int days = 30}) {
    return _repository.calculateCompletionRate(habitId, days: days);
  }
}

// Habit stats data class
class HabitStats {
  final int completionCount;
  final int currentStreak;
  final int bestStreak;
  final double completionRate;
  final bool isCompletedToday;

  HabitStats({
    required this.completionCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.completionRate,
    required this.isCompletedToday,
  });

  HabitStats copyWith({
    int? completionCount,
    int? currentStreak,
    int? bestStreak,
    double? completionRate,
    bool? isCompletedToday,
  }) {
    return HabitStats(
      completionCount: completionCount ?? this.completionCount,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      completionRate: completionRate ?? this.completionRate,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }
}

