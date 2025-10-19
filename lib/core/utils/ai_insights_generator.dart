import 'package:flutter/material.dart';
import '../../domain/entities/insight.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/user_progress.dart';

class AIInsightsGenerator {
  /// Generate all insights based on analytics data
  static List<Insight> generateInsights({
    required AnalyticsData analytics,
    required List<Habit> habits,
    required List<HabitLog> logs,
    required UserProgress userProgress,
  }) {
    final insights = <Insight>[];
    
    // Generate insights from each category
    insights.addAll(_generatePerformanceInsights(analytics, habits, logs));
    insights.addAll(_generateBehavioralInsights(analytics, habits, logs));
    insights.addAll(_generatePredictiveInsights(analytics, habits, logs, userProgress));
    insights.addAll(_generateMotivationalInsights(analytics, habits, logs, userProgress));
    insights.addAll(_generateRecommendationInsights(analytics, habits, logs));
    insights.addAll(_generateBackupReminderInsights(analytics, habits, logs, userProgress));
    
    // Sort by priority (urgent first, then high, medium, low)
    insights.sort((a, b) {
      final priorityOrder = {
        InsightPriority.urgent: 0,
        InsightPriority.high: 1,
        InsightPriority.medium: 2,
        InsightPriority.low: 3,
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
    
    return insights;
  }

  /// Performance Insights - Focus on completion rates and consistency
  static List<Insight> _generatePerformanceInsights(
    AnalyticsData analytics,
    List<Habit> habits,
    List<HabitLog> logs,
  ) {
    final insights = <Insight>[];
    
    // Best performing habit insight
    if (analytics.habitAnalytics.isNotEmpty) {
      final bestHabit = analytics.habitAnalytics
          .where((h) => h.completionCount > 0)
          .reduce((a, b) => a.completionRate > b.completionRate ? a : b);
      
      if (bestHabit.completionRate > 0.8) {
        insights.add(Insight(
          id: 'best_habit_${bestHabit.habitId}',
          title: '${bestHabit.habitIcon} Star Performer',
          description: '${bestHabit.habitName} has an amazing ${(bestHabit.completionRate * 100).toInt()}% completion rate! Keep up the excellent work.',
          actionText: 'View Details',
          category: InsightCategory.performance,
          priority: InsightPriority.medium,
          icon: '⭐',
          color: const Color(0xFF4CAF50),
          metadata: {'habitId': bestHabit.habitId, 'completionRate': bestHabit.completionRate},
          generatedAt: DateTime.now(),
        ));
      }
    }

    // Consistency analysis
    if (analytics.overview.averageCompletionRate > 0.7) {
      insights.add(Insight(
        id: 'high_consistency',
        title: '🎯 Consistency Champion',
        description: 'You maintain a ${(analytics.overview.averageCompletionRate * 100).toInt()}% average completion rate. Your consistency is impressive!',
        actionText: 'View Analytics',
        category: InsightCategory.performance,
        priority: InsightPriority.medium,
        icon: '🎯',
        color: const Color(0xFF2196F3),
        metadata: {'completionRate': analytics.overview.averageCompletionRate},
        generatedAt: DateTime.now(),
      ));
    }

    // Perfect days insight
    if (analytics.overview.perfectDays > 0) {
      insights.add(Insight(
        id: 'perfect_days_${analytics.overview.perfectDays}',
        title: '🏆 Perfect Day${analytics.overview.perfectDays > 1 ? 's' : ''}',
        description: 'You had ${analytics.overview.perfectDays} perfect day${analytics.overview.perfectDays > 1 ? 's' : ''} where you completed all habits!',
        actionText: 'View Calendar',
        category: InsightCategory.performance,
        priority: analytics.overview.perfectDays >= 3 ? InsightPriority.high : InsightPriority.medium,
        icon: '🏆',
        color: const Color(0xFFFF9800),
        metadata: {'perfectDays': analytics.overview.perfectDays},
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  /// Behavioral Insights - Focus on patterns and timing
  static List<Insight> _generateBehavioralInsights(
    AnalyticsData analytics,
    List<Habit> habits,
    List<HabitLog> logs,
  ) {
    final insights = <Insight>[];
    
    // Weekday vs Weekend pattern
    final weekdayLogs = logs.where((log) => log.completedAt.weekday < 6).length;
    final weekendLogs = logs.where((log) => log.completedAt.weekday >= 6).length;
    final weekdayDays = _getWeekdayCount(analytics.overview.dateRangeStart, analytics.overview.dateRangeEnd);
    final weekendDays = _getWeekendCount(analytics.overview.dateRangeStart, analytics.overview.dateRangeEnd);
    
    if (weekdayDays > 0 && weekendDays > 0) {
      final weekdayRate = weekdayLogs / (weekdayDays * habits.length);
      final weekendRate = weekendLogs / (weekendDays * habits.length);
      
      if (weekdayRate > weekendRate * 1.3) {
        insights.add(Insight(
          id: 'weekday_warrior',
          title: '💼 Weekday Warrior',
          description: 'You\'re ${((weekdayRate / weekendRate - 1) * 100).toInt()}% more consistent on weekdays (${(weekdayRate * 100).toInt()}% vs ${(weekendRate * 100).toInt()}%). Consider focusing new habits on weekdays first.',
          actionText: 'View Patterns',
          category: InsightCategory.behavioral,
          priority: InsightPriority.medium,
          icon: '💼',
          color: const Color(0xFF2196F3),
          metadata: {'weekdayRate': weekdayRate, 'weekendRate': weekendRate},
          generatedAt: DateTime.now(),
        ));
      }
    }

    // Time of day patterns
    final morningLogs = logs.where((log) => log.completedAt.hour < 12).length;
    final afternoonLogs = logs.where((log) => log.completedAt.hour >= 12 && log.completedAt.hour < 18).length;
    final eveningLogs = logs.where((log) => log.completedAt.hour >= 18).length;
    
    if (morningLogs > afternoonLogs && morningLogs > eveningLogs) {
      insights.add(Insight(
        id: 'morning_person',
        title: '🌅 Early Bird',
        description: 'You complete most habits in the morning (${morningLogs} vs ${afternoonLogs} afternoon, ${eveningLogs} evening). Your morning routine is working well!',
        actionText: 'Optimize Schedule',
        category: InsightCategory.behavioral,
        priority: InsightPriority.low,
        icon: '🌅',
        color: const Color(0xFFFF9800),
        metadata: {'morning': morningLogs, 'afternoon': afternoonLogs, 'evening': eveningLogs},
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  /// Predictive Insights - Focus on future risks and opportunities
  static List<Insight> _generatePredictiveInsights(
    AnalyticsData analytics,
    List<Habit> habits,
    List<HabitLog> logs,
    UserProgress userProgress,
  ) {
    final insights = <Insight>[];
    
    // Streak at risk
    final currentStreak = analytics.overview.currentStreak;
    final today = DateTime.now();
    final hasCompletedToday = logs.any((log) => 
        log.completedAt.year == today.year &&
        log.completedAt.month == today.month &&
        log.completedAt.day == today.day);
    
    if (currentStreak > 7 && !hasCompletedToday && today.hour > 18) {
      insights.add(Insight(
        id: 'streak_at_risk',
        title: '⚠️ Streak at Risk',
        description: 'You have a ${currentStreak}-day streak that might break today. Complete at least one habit before midnight!',
        actionText: 'Complete Habit',
        category: InsightCategory.predictive,
        priority: InsightPriority.urgent,
        icon: '⚠️',
        color: const Color(0xFFF44336),
        metadata: {'streak': currentStreak, 'hoursLeft': 24 - today.hour},
        generatedAt: DateTime.now(),
      ));
    }

    // Habit abandonment prediction
    for (final habit in habits) {
      final habitLogs = logs.where((log) => log.habitId == habit.id).toList();
      if (habitLogs.isNotEmpty) {
        final lastCompletion = habitLogs.last.completedAt;
        final daysSinceLastCompletion = DateTime.now().difference(lastCompletion).inDays;
        
        if (daysSinceLastCompletion >= 7) {
          insights.add(Insight(
            id: 'habit_abandonment_${habit.id}',
            title: '📉 ${habit.icon} ${habit.name} Needs Attention',
            description: 'You haven\'t completed ${habit.name} in ${daysSinceLastCompletion} days. Consider adjusting the habit or taking a break.',
            actionText: 'Review Habit',
            category: InsightCategory.predictive,
            priority: daysSinceLastCompletion >= 14 ? InsightPriority.high : InsightPriority.medium,
            icon: '📉',
            color: const Color(0xFFFF9800),
            metadata: {'habitId': habit.id, 'daysSince': daysSinceLastCompletion},
            generatedAt: DateTime.now(),
          ));
        }
      }
    }

    return insights;
  }

  /// Motivational Insights - Focus on achievements and milestones
  static List<Insight> _generateMotivationalInsights(
    AnalyticsData analytics,
    List<Habit> habits,
    List<HabitLog> logs,
    UserProgress userProgress,
  ) {
    final insights = <Insight>[];
    
    // Level up approaching
    final currentXP = userProgress.currentXP;
    final currentLevel = userProgress.currentLevel;
    final nextLevelXP = userProgress.xpToNextLevel;
    final xpNeeded = nextLevelXP - currentXP;
    
    if (xpNeeded <= 200 && xpNeeded > 0) {
      insights.add(Insight(
        id: 'level_up_approaching',
        title: '🎯 Almost There!',
        description: 'You\'re only $xpNeeded XP away from Level ${currentLevel + 1}. Complete 2-3 more habits today!',
        actionText: 'View Progress',
        category: InsightCategory.motivational,
        priority: InsightPriority.high,
        icon: '🎯',
        color: const Color(0xFF4CAF50),
        metadata: {'currentLevel': currentLevel, 'nextLevel': currentLevel + 1, 'xpNeeded': xpNeeded},
        generatedAt: DateTime.now(),
      ));
    }

    // Streak milestone approaching
    final currentStreak = analytics.overview.currentStreak;
    if (currentStreak > 0) {
      final nextMilestone = _getNextStreakMilestone(currentStreak);
      if (nextMilestone != null && nextMilestone - currentStreak <= 3) {
        insights.add(Insight(
          id: 'streak_milestone_$nextMilestone',
          title: '🔥 Streak Milestone Approaching',
          description: 'You\'re ${nextMilestone - currentStreak} days away from a ${nextMilestone}-day streak! Keep going!',
          actionText: 'View Streak',
          category: InsightCategory.motivational,
          priority: InsightPriority.high,
          icon: '🔥',
          color: const Color(0xFFFF5722),
          metadata: {'currentStreak': currentStreak, 'targetStreak': nextMilestone},
          generatedAt: DateTime.now(),
        ));
      }
    }

    // Personal record
    if (analytics.overview.bestStreak > 0 && analytics.overview.currentStreak == analytics.overview.bestStreak) {
      insights.add(Insight(
        id: 'personal_record_${analytics.overview.bestStreak}',
        title: '🏆 Personal Record!',
        description: 'You\'re on your longest streak ever: ${analytics.overview.bestStreak} days! This is your new personal record!',
        actionText: 'Celebrate',
        category: InsightCategory.motivational,
        priority: InsightPriority.high,
        icon: '🏆',
        color: const Color(0xFFFFD700),
        metadata: {'streak': analytics.overview.bestStreak},
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  /// Recommendation Insights - Focus on actionable suggestions
  static List<Insight> _generateRecommendationInsights(
    AnalyticsData analytics,
    List<Habit> habits,
    List<HabitLog> logs,
  ) {
    final insights = <Insight>[];
    
    // Habit stacking opportunity
    if (habits.length >= 2) {
      final habitCorrelations = _findHabitCorrelations(habits, logs);
      if (habitCorrelations.isNotEmpty) {
        final bestCorrelation = habitCorrelations.first;
        insights.add(Insight(
          id: 'habit_stacking_${bestCorrelation['habit1']}_${bestCorrelation['habit2']}',
          title: '🔗 Habit Stacking Opportunity',
          description: 'When you complete ${bestCorrelation['habit1Name']}, you\'re ${(bestCorrelation['correlation'] * 100).toInt()}% more likely to complete ${bestCorrelation['habit2Name']}. Try doing them together!',
          actionText: 'Create Stack',
          category: InsightCategory.recommendation,
          priority: InsightPriority.medium,
          icon: '🔗',
          color: const Color(0xFF9C27B0),
          metadata: bestCorrelation,
          generatedAt: DateTime.now(),
        ));
      }
    }

    // Optimal habit addition timing
    if (habits.length < 5) {
      final avgCompletionRate = analytics.overview.averageCompletionRate;
      if (avgCompletionRate > 0.7) {
        insights.add(Insight(
          id: 'add_new_habit',
          title: '➕ Ready for a New Habit',
          description: 'You\'re maintaining ${(avgCompletionRate * 100).toInt()}% completion rate. You might be ready to add a new habit to your routine!',
          actionText: 'Add Habit',
          category: InsightCategory.recommendation,
          priority: InsightPriority.medium,
          icon: '➕',
          color: const Color(0xFF4CAF50),
          metadata: {'completionRate': avgCompletionRate, 'habitCount': habits.length},
          generatedAt: DateTime.now(),
        ));
      }
    }

    // Break prevention
    final recentLogs = logs.where((log) => 
        DateTime.now().difference(log.completedAt).inDays <= 3).toList();
    if (recentLogs.isEmpty && habits.isNotEmpty) {
      insights.add(Insight(
        id: 'break_prevention',
        title: '🛡️ Break Prevention',
        description: 'You haven\'t completed any habits in the last 3 days. Start with just one small habit to get back on track.',
        actionText: 'Complete Habit',
        category: InsightCategory.recommendation,
        priority: InsightPriority.high,
        icon: '🛡️',
        color: const Color(0xFFFF9800),
        metadata: {'daysSinceLastCompletion': 3},
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  // Helper methods
  static int _getWeekdayCount(DateTime start, DateTime end) {
    int count = 0;
    for (DateTime date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1))) {
      if (date.weekday < 6) count++;
    }
    return count;
  }

  static int _getWeekendCount(DateTime start, DateTime end) {
    int count = 0;
    for (DateTime date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1))) {
      if (date.weekday >= 6) count++;
    }
    return count;
  }

  static int? _getNextStreakMilestone(int currentStreak) {
    final milestones = [7, 14, 30, 60, 100, 200, 365];
    for (final milestone in milestones) {
      if (milestone > currentStreak) return milestone;
    }
    return null;
  }

  static List<Map<String, dynamic>> _findHabitCorrelations(List<Habit> habits, List<HabitLog> logs) {
    final correlations = <Map<String, dynamic>>[];
    
    for (int i = 0; i < habits.length; i++) {
      for (int j = i + 1; j < habits.length; j++) {
        final habit1 = habits[i];
        final habit2 = habits[j];
        
        final habit1Logs = logs.where((log) => log.habitId == habit1.id).toList();
        final habit2Logs = logs.where((log) => log.habitId == habit2.id).toList();
        
        if (habit1Logs.isNotEmpty && habit2Logs.isNotEmpty) {
          final correlation = _calculateCorrelation(habit1Logs, habit2Logs);
          if (correlation > 0.3) { // Only consider significant correlations
            correlations.add({
              'habit1': habit1.id,
              'habit1Name': habit1.name,
              'habit2': habit2.id,
              'habit2Name': habit2.name,
              'correlation': correlation,
            });
          }
        }
      }
    }
    
    // Sort by correlation strength
    correlations.sort((a, b) => b['correlation'].compareTo(a['correlation']));
    return correlations;
  }

  static double _calculateCorrelation(List<HabitLog> logs1, List<HabitLog> logs2) {
    // Simple correlation: if both habits are completed on the same day
    final days1 = logs1.map((log) => _getDateKey(log.completedAt)).toSet();
    final days2 = logs2.map((log) => _getDateKey(log.completedAt)).toSet();
    
    final intersection = days1.intersection(days2).length;
    final union = days1.union(days2).length;
    
    return union > 0 ? intersection / union : 0.0;
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Backup Reminder Insights - Encourage users to backup their data
  static List<Insight> _generateBackupReminderInsights(
    AnalyticsData analytics,
    List<Habit> habits,
    List<HabitLog> logs,
    UserProgress userProgress,
  ) {
    final insights = <Insight>[];
    
    // Only show backup reminders for users with valuable data
    if (habits.length < 3) return insights; // Not enough data yet
    
    final totalDays = _calculateTotalActiveDays(logs);
    final totalCompletions = logs.length;
    final currentStreak = _calculateCurrentStreak(logs);
    final level = userProgress.currentLevel;
    
    // Streak milestone reminder
    if (currentStreak >= 7 && currentStreak % 7 == 0) {
      insights.add(Insight(
        id: 'backup_streak_${currentStreak}',
        title: '🔥 ${currentStreak}-Day Streak!',
        description: 'Protect your progress with Cloud Backup (Premium)',
        category: InsightCategory.backup,
        priority: InsightPriority.medium,
        icon: 'cloud_upload',
        color: const Color(0xFF2196F3), // Blue
        actionText: 'Enable Backup',
        generatedAt: DateTime.now(),
        metadata: {
          'streak': currentStreak,
          'type': 'streak_milestone',
        },
      ));
    }
    
    // Habit count milestone
    if (habits.length >= 10 && habits.length % 5 == 0) {
      insights.add(Insight(
        id: 'backup_habits_${habits.length}',
        title: '📊 ${habits.length} Habits Tracked!',
        description: 'Keep them safe with automatic backup',
        category: InsightCategory.backup,
        priority: InsightPriority.medium,
        icon: 'cloud_sync',
        color: const Color(0xFF4CAF50), // Green
        actionText: 'Backup Now',
        generatedAt: DateTime.now(),
        metadata: {
          'habitCount': habits.length,
          'type': 'habit_milestone',
        },
      ));
    }
    
    // Level milestone
    if (level >= 5 && level % 5 == 0) {
      insights.add(Insight(
        id: 'backup_level_${level}',
        title: '🎉 Level $level Unlocked!',
        description: 'Never lose your achievements - Enable Backup',
        category: InsightCategory.backup,
        priority: InsightPriority.medium,
        icon: 'emoji_events',
        color: const Color(0xFFFF9800), // Orange
        actionText: 'Protect Progress',
        generatedAt: DateTime.now(),
        metadata: {
          'level': level,
          'type': 'level_milestone',
        },
      ));
    }
    
    // Completion milestone
    if (totalCompletions >= 100 && totalCompletions % 50 == 0) {
      insights.add(Insight(
        id: 'backup_completions_${totalCompletions}',
        title: '💯 $totalCompletions Check-ins!',
        description: 'Backup to cloud and access from any device',
        category: InsightCategory.backup,
        priority: InsightPriority.medium,
        icon: 'check_circle',
        color: const Color(0xFF9C27B0), // Purple
        actionText: 'Backup Data',
        generatedAt: DateTime.now(),
        metadata: {
          'completions': totalCompletions,
          'type': 'completion_milestone',
        },
      ));
    }
    
    // Garden growth reminder (if user has plants)
    if (userProgress.currentXP > 1000) { // Assume garden exists if high XP
      insights.add(Insight(
        id: 'backup_garden_growth',
        title: '🌱 Your Garden is Growing!',
        description: 'Protect your plants with cloud backup',
        category: InsightCategory.backup,
        priority: InsightPriority.low,
        icon: 'local_florist',
        color: const Color(0xFF4CAF50), // Green
        actionText: 'Backup Garden',
        generatedAt: DateTime.now(),
        metadata: {
          'xp': userProgress.currentXP,
          'type': 'garden_reminder',
        },
      ));
    }
    
    // Weekly gentle reminder (only if no other backup insights)
    if (insights.isEmpty && totalDays >= 7) {
      final now = DateTime.now();
      final dayOfWeek = now.weekday;
      
      // Show on Sundays (day 7)
      if (dayOfWeek == 7) {
        insights.add(Insight(
          id: 'backup_weekly_reminder',
          title: '💾 Weekly Backup Reminder',
          description: 'Keep your progress safe with cloud backup',
          category: InsightCategory.backup,
          priority: InsightPriority.low,
          icon: 'backup',
          color: const Color(0xFF607D8B), // Blue Grey
          actionText: 'Learn More',
          generatedAt: DateTime.now(),
          metadata: {
            'type': 'weekly_reminder',
            'dayOfWeek': dayOfWeek,
          },
        ));
      }
    }
    
    return insights;
  }
  
  static int _calculateTotalActiveDays(List<HabitLog> logs) {
    final uniqueDays = logs.map((log) => _getDateKey(log.completedAt)).toSet();
    return uniqueDays.length;
  }
  
  static int _calculateCurrentStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;
    
    // Sort logs by completion date (newest first)
    final sortedLogs = List<HabitLog>.from(logs);
    sortedLogs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if today was completed
    final todayCompleted = sortedLogs.any((log) {
      final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
      return logDate == today;
    });
    
    if (!todayCompleted) return 0;
    
    streak = 1;
    DateTime currentDate = today.subtract(const Duration(days: 1));
    
    while (true) {
      final dayCompleted = sortedLogs.any((log) {
        final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
        return logDate == currentDate;
      });
      
      if (dayCompleted) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
}
