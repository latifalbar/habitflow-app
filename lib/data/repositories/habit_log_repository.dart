import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/habit_log.dart';
import '../models/habit_log_model.dart';
import '../../core/constants/storage_keys.dart';

class HabitLogRepository {
  final _uuid = const Uuid();
  late final Box<HabitLogModel> _logBox;
  
  HabitLogRepository() {
    _logBox = Hive.box<HabitLogModel>(StorageKeys.habitLogsBox);
  }
  
  // Get all logs
  List<HabitLog> getAllLogs() {
    return _logBox.values.map((model) => model.toEntity()).toList();
  }
  
  // Get log by ID
  HabitLog? getLogById(String id) {
    final model = _logBox.get(id);
    return model?.toEntity();
  }
  
  // Add new log
  Future<void> addLog(HabitLog log) async {
    final model = HabitLogModel.fromEntity(log);
    await _logBox.put(log.id, model);
  }
  
  // Update existing log
  Future<void> updateLog(HabitLog log) async {
    final model = HabitLogModel.fromEntity(log);
    await _logBox.put(log.id, model);
  }
  
  // Delete log
  Future<void> deleteLog(String id) async {
    await _logBox.delete(id);
  }
  
  // Get logs by habit ID
  List<HabitLog> getLogsByHabitId(String habitId) {
    final allLogs = getAllLogs();
    return allLogs.where((log) => log.habitId == habitId).toList();
  }
  
  // Get logs by date range
  List<HabitLog> getLogsByDateRange(DateTime startDate, DateTime endDate) {
    final allLogs = getAllLogs();
    return allLogs.where((log) {
      final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return logDate.isAtSameMomentAs(start) || 
             logDate.isAtSameMomentAs(end) ||
             (logDate.isAfter(start) && logDate.isBefore(end));
    }).toList();
  }
  
  // Get today's logs
  List<HabitLog> getTodaysLogs() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return getLogsByDateRange(startOfDay, endOfDay);
  }
  
  // Get logs for specific habit today
  List<HabitLog> getTodaysLogsForHabit(String habitId) {
    final todaysLogs = getTodaysLogs();
    return todaysLogs.where((log) => log.habitId == habitId).toList();
  }
  
  // Check if habit is completed today
  bool isHabitCompletedToday(String habitId) {
    final todaysLogs = getTodaysLogsForHabit(habitId);
    return todaysLogs.isNotEmpty;
  }
  
  // Get completion count for habit
  int getCompletionCount(String habitId) {
    final logs = getLogsByHabitId(habitId);
    return logs.length;
  }
  
  // Calculate current streak for habit
  int calculateCurrentStreak(String habitId) {
    final logs = getLogsByHabitId(habitId);
    if (logs.isEmpty) return 0;
    
    // Sort logs by date (newest first)
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    // Check if completed today
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final hasTodayLog = logs.any((log) {
      final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
      return logDate.isAtSameMomentAs(today);
    });
    
    if (!hasTodayLog) {
      // If not completed today, check yesterday
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    // Count consecutive days
    for (int i = 0; i < 365; i++) { // Max 365 days
      final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      final hasLogForDate = logs.any((log) {
        final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
        return logDate.isAtSameMomentAs(checkDate);
      });
      
      if (hasLogForDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  // Calculate best streak for habit
  int calculateBestStreak(String habitId) {
    final logs = getLogsByHabitId(habitId);
    if (logs.isEmpty) return 0;
    
    // Sort logs by date (oldest first)
    logs.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final log in logs) {
      final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
      
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDifference = logDate.difference(lastDate).inDays;
        if (daysDifference == 1) {
          currentStreak++;
        } else if (daysDifference > 1) {
          bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;
          currentStreak = 1;
        }
        // If daysDifference == 0, it's the same day, don't increment streak
      }
      
      lastDate = logDate;
    }
    
    // Check final streak
    bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;
    
    return bestStreak;
  }
  
  // Calculate completion rate for habit
  double calculateCompletionRate(String habitId, {int days = 30}) {
    final logs = getLogsByHabitId(habitId);
    if (logs.isEmpty) return 0.0;
    
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final logsInRange = getLogsByDateRange(startDate, endDate);
    
    // Count unique days with completions
    final uniqueDays = <String>{};
    for (final log in logsInRange) {
      final dateKey = '${log.completedAt.year}-${log.completedAt.month}-${log.completedAt.day}';
      uniqueDays.add(dateKey);
    }
    
    return uniqueDays.length / days;
  }
  
  // Get logs by month
  List<HabitLog> getLogsByMonth(int year, int month) {
    final allLogs = getAllLogs();
    return allLogs.where((log) {
      return log.completedAt.year == year && log.completedAt.month == month;
    }).toList();
  }
  
  // Get logs by year
  List<HabitLog> getLogsByYear(int year) {
    final allLogs = getAllLogs();
    return allLogs.where((log) {
      return log.completedAt.year == year;
    }).toList();
  }
  
  // Generate unique ID
  String generateId() {
    return _uuid.v4();
  }
  
  // Get logs count
  int getLogsCount() {
    return _logBox.length;
  }
  
  // Delete all logs for a habit (when habit is deleted)
  Future<void> deleteLogsForHabit(String habitId) async {
    final logsToDelete = _logBox.values
        .where((model) => model.habitId == habitId)
        .map((model) => model.id)
        .toList();
    
    for (final id in logsToDelete) {
      await _logBox.delete(id);
    }
  }
  
  // Get recent logs (last N days)
  List<HabitLog> getRecentLogs(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getLogsByDateRange(startDate, endDate);
  }

  // Get completion count for a specific period
  int getCompletionCountForPeriod(String habitId, DateTime start, DateTime end) {
    final logs = getLogsByHabitId(habitId);
    return logs.where((log) {
      final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return logDate.isAtSameMomentAs(startDate) || 
             logDate.isAtSameMomentAs(endDate) ||
             (logDate.isAfter(startDate) && logDate.isBefore(endDate));
    }).length;
  }

  // Get today's completion count for a habit
  int getTodaysCompletionCount(String habitId) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));
    
    return _logBox.values
        .where((log) => 
            log.habitId == habitId &&
            log.completedAt.isAfter(todayStart) &&
            log.completedAt.isBefore(todayEnd))
        .length;
  }

  // Get this week's completion count
  int getWeekCompletionCount(String habitId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return _logBox.values
        .where((log) => 
            log.habitId == habitId &&
            log.completedAt.isAfter(weekStartMidnight))
        .length;
  }

  // Check if can add more completions
  bool canAddMoreCompletions(String habitId, {required String frequency, int? timesPerWeek}) {
    switch (frequency) {
      case 'daily':
        return getTodaysCompletionCount(habitId) == 0;
      case 'timesPerWeek':
        return getWeekCompletionCount(habitId) < (timesPerWeek ?? 1);
      case 'customDays':
        return getTodaysCompletionCount(habitId) == 0;
      case 'everyXDays':
        return getTodaysCompletionCount(habitId) == 0;
      default:
        return getTodaysCompletionCount(habitId) == 0;
    }
  }
}

