import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';

class StreakCalculator {
  /// Calculate overall streak (consecutive days with any habit completed)
  static int calculateOverallStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;

    // Sort logs by date (newest first)
    final sortedLogs = List<HabitLog>.from(logs)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    // Get unique completion dates (one per day)
    final completionDates = <String>{};
    for (final log in sortedLogs) {
      final dateKey = _getDateKey(log.completedAt);
      completionDates.add(dateKey);
    }
    
    final sortedDates = completionDates.toList()
      ..sort((a, b) => b.compareTo(a));

    // Check if completed today
    final today = _getDateKey(currentDate);
    if (!sortedDates.contains(today)) {
      // If not completed today, start from yesterday
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    // Count consecutive days
    for (int i = 0; i < 365; i++) { // Max 365 days
      final checkDate = _getDateKey(currentDate);
      if (sortedDates.contains(checkDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate streak for a specific habit
  static int calculateHabitStreak(String habitId, List<HabitLog> logs, Habit habit) {
    final habitLogs = logs.where((log) => log.habitId == habitId).toList();
    if (habitLogs.isEmpty) return 0;

    // Sort logs by date (newest first)
    habitLogs.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Check if habit should be tracked today
    if (!habit.shouldTrackOnDay(currentDate)) {
      // If habit shouldn't be tracked today, start from last valid day
      currentDate = _getLastValidDay(habit, currentDate);
    }

    // Count consecutive days
    for (int i = 0; i < 365; i++) { // Max 365 days
      if (habit.shouldTrackOnDay(currentDate)) {
        final hasCompletion = habitLogs.any((log) {
          final logDate = _getDateKey(log.completedAt);
          final checkDate = _getDateKey(currentDate);
          return logDate == checkDate;
        });

        if (hasCompletion) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else {
        // Skip days when habit shouldn't be tracked
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  /// Check if streak is still active
  static bool isStreakActive(int streak, DateTime lastCompletion) {
    if (streak == 0) return false;
    
    final now = DateTime.now();
    final daysSinceLastCompletion = now.difference(lastCompletion).inDays;
    
    // Allow 1 day grace period
    return daysSinceLastCompletion <= 1;
  }

  /// Get last completion date
  static DateTime? getLastCompletionDate(List<HabitLog> logs) {
    if (logs.isEmpty) return null;
    
    final sortedLogs = List<HabitLog>.from(logs)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    return sortedLogs.first.completedAt;
  }

  /// Get last completion date for specific habit
  static DateTime? getLastHabitCompletionDate(String habitId, List<HabitLog> logs) {
    final habitLogs = logs.where((log) => log.habitId == habitId).toList();
    return getLastCompletionDate(habitLogs);
  }

  /// Calculate best streak for a habit
  static int calculateBestStreak(String habitId, List<HabitLog> logs, Habit habit) {
    final habitLogs = logs.where((log) => log.habitId == habitId).toList();
    if (habitLogs.isEmpty) return 0;

    // Sort logs by date (oldest first)
    habitLogs.sort((a, b) => a.completedAt.compareTo(b.completedAt));

    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final log in habitLogs) {
      final logDate = _getDateKey(log.completedAt);
      
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDifference = _getDaysDifference(_getDateKey(lastDate!), logDate);
        if (daysDifference == 1) {
          currentStreak++;
        } else if (daysDifference > 1) {
          bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;
          currentStreak = 1;
        }
        // If daysDifference == 0, it's the same day, don't increment streak
      }
      
      lastDate = DateTime.parse(logDate);
    }

    // Check final streak
    bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;

    return bestStreak;
  }

  /// Calculate completion rate for a habit
  static double calculateCompletionRate(String habitId, List<HabitLog> logs, Habit habit, {int days = 30}) {
    final habitLogs = logs.where((log) => log.habitId == habitId).toList();
    if (habitLogs.isEmpty) return 0.0;

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    // Count days when habit should be tracked
    int totalTrackableDays = 0;
    int completedDays = 0;
    
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || _isSameDay(currentDate, endDate)) {
      if (habit.shouldTrackOnDay(currentDate)) {
        totalTrackableDays++;
        
        final hasCompletion = habitLogs.any((log) {
          return _isSameDay(log.completedAt, currentDate);
        });
        
        if (hasCompletion) {
          completedDays++;
        }
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return totalTrackableDays > 0 ? completedDays / totalTrackableDays : 0.0;
  }

  /// Get streak statistics
  static Map<String, dynamic> getStreakStats(List<HabitLog> logs, List<Habit> habits) {
    final overallStreak = calculateOverallStreak(logs);
    final lastCompletion = getLastCompletionDate(logs);
    final isActive = isStreakActive(overallStreak, lastCompletion ?? DateTime.now());
    
    // Calculate per-habit streaks
    final habitStreaks = <String, int>{};
    final habitBestStreaks = <String, int>{};
    final habitCompletionRates = <String, double>{};
    
    for (final habit in habits) {
      habitStreaks[habit.id] = calculateHabitStreak(habit.id, logs, habit);
      habitBestStreaks[habit.id] = calculateBestStreak(habit.id, logs, habit);
      habitCompletionRates[habit.id] = calculateCompletionRate(habit.id, logs, habit);
    }
    
    // Find best performing habit
    String? bestHabitId;
    int bestStreak = 0;
    for (final entry in habitStreaks.entries) {
      if (entry.value > bestStreak) {
        bestStreak = entry.value;
        bestHabitId = entry.key;
      }
    }
    
    return {
      'overallStreak': overallStreak,
      'isActive': isActive,
      'lastCompletion': lastCompletion,
      'habitStreaks': habitStreaks,
      'habitBestStreaks': habitBestStreaks,
      'habitCompletionRates': habitCompletionRates,
      'bestHabitId': bestHabitId,
      'bestHabitStreak': bestStreak,
    };
  }

  // Helper methods

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static int _getDaysDifference(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  static DateTime _getLastValidDay(Habit habit, DateTime currentDate) {
    DateTime checkDate = currentDate.subtract(const Duration(days: 1));
    
    // Go back up to 7 days to find last valid day
    for (int i = 0; i < 7; i++) {
      if (habit.shouldTrackOnDay(checkDate)) {
        return checkDate;
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return currentDate;
  }
}
