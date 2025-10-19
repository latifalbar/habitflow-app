import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/insight.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/user_progress.dart';
import '../../core/utils/ai_insights_generator.dart';
import 'analytics_provider.dart';
import 'habits_provider.dart';
import 'habit_logs_provider.dart';
import 'user_progress_provider.dart';

class InsightsNotifier extends StateNotifier<AsyncValue<List<Insight>>> {
  final Ref _ref;
  
  InsightsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      state = const AsyncValue.loading();
      
      // Get all required data
      final analyticsAsync = _ref.read(analyticsProvider);
      final habitsAsync = _ref.read(habitsProvider);
      final logsAsync = _ref.read(habitLogsProvider);
      final userProgressAsync = _ref.read(userProgressProvider);
      
      // Wait for all data to be available
      final analytics = await analyticsAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Analytics not loaded'),
        error: (error, stackTrace) => throw error,
      );
      
      final habits = await habitsAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Habits not loaded'),
        error: (error, stackTrace) => throw error,
      );
      
      final logs = await logsAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Logs not loaded'),
        error: (error, stackTrace) => throw error,
      );
      
      final userProgress = await userProgressAsync.when(
        data: (data) => data,
        loading: () => throw Exception('User progress not loaded'),
        error: (error, stackTrace) => throw error,
      );
      
      // Generate insights
      final insights = AIInsightsGenerator.generateInsights(
        analytics: analytics,
        habits: habits,
        logs: logs,
        userProgress: userProgress,
      );
      
      state = AsyncValue.data(insights);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshInsights() async {
    await _loadInsights();
  }

  Future<void> dismissInsight(String id) async {
    state.whenData((insights) {
      final updatedInsights = insights.map((insight) {
        if (insight.id == id) {
          return insight.copyWith(isDismissed: true);
        }
        return insight;
      }).toList();
      
      state = AsyncValue.data(updatedInsights);
    });
  }

  Future<void> filterByType(InsightType type) async {
    state.whenData((insights) {
      final filteredInsights = insights.where((insight) => insight.category == type).toList();
      state = AsyncValue.data(filteredInsights);
    });
  }

  Future<void> filterByPriority(InsightPriority priority) async {
    state.whenData((insights) {
      final filteredInsights = insights.where((insight) => insight.priority == priority).toList();
      state = AsyncValue.data(filteredInsights);
    });
  }

  Future<void> clearFilters() async {
    await _loadInsights();
  }

  Future<void> markAsRead(String id) async {
    state.whenData((insights) {
      final updatedInsights = insights.map((insight) {
        if (insight.id == id) {
          return insight.copyWith(metadata: {
            ...insight.metadata,
            'isRead': true,
            'readAt': DateTime.now().toIso8601String(),
          });
        }
        return insight;
      }).toList();
      
      state = AsyncValue.data(updatedInsights);
    });
  }

  Future<void> executeAction(String id) async {
    state.whenData((insights) {
      final insight = insights.firstWhere((i) => i.id == id);
      
      // Track action execution
      final updatedInsights = insights.map((i) {
        if (i.id == id) {
          return i.copyWith(metadata: {
            ...i.metadata,
            'actionExecuted': true,
            'actionExecutedAt': DateTime.now().toIso8601String(),
          });
        }
        return i;
      }).toList();
      
      state = AsyncValue.data(updatedInsights);
      
      // TODO: Implement specific actions based on insight type
      _handleInsightAction(insight);
    });
  }

  void _handleInsightAction(Insight insight) {
    switch (insight.category) {
      case InsightCategory.performance:
        // Navigate to analytics or specific habit
        break;
      case InsightCategory.behavioral:
        // Show pattern details or optimization suggestions
        break;
      case InsightCategory.predictive:
        // Navigate to habit completion or streak management
        break;
      case InsightCategory.motivational:
        // Navigate to progress or achievements
        break;
      case InsightCategory.recommendation:
        // Navigate to habit creation or habit management
        break;
      case InsightCategory.backup:
        // Navigate to backup settings or premium features
        break;
    }
  }

  // Getters for filtered insights
  List<Insight> get highPriorityInsights {
    return state.whenData((insights) => 
        insights.where((i) => i.isHighPriority && !i.isDismissed).toList()
    ).valueOrNull ?? [];
  }

  List<Insight> get urgentInsights {
    return state.whenData((insights) => 
        insights.where((i) => i.isUrgent && !i.isDismissed).toList()
    ).valueOrNull ?? [];
  }

  List<Insight> get actionableInsights {
    return state.whenData((insights) => 
        insights.where((i) => i.isActionable && !i.isDismissed).toList()
    ).valueOrNull ?? [];
  }

  int get unreadCount {
    return state.whenData((insights) => 
        insights.where((i) => !i.isDismissed && !(i.metadata['isRead'] ?? false)).length
    ).valueOrNull ?? 0;
  }

  int get totalCount {
    return state.whenData((insights) => insights.length).valueOrNull ?? 0;
  }
}

// Provider instances
final insightsProvider = StateNotifierProvider<InsightsNotifier, AsyncValue<List<Insight>>>((ref) {
  return InsightsNotifier(ref);
});

// Computed providers for different views
final highPriorityInsightsProvider = Provider<List<Insight>>((ref) {
  final insights = ref.watch(insightsProvider);
  return insights.whenData((insights) => 
      insights.where((i) => i.isHighPriority && !i.isDismissed).toList()
  ).valueOrNull ?? [];
});

final urgentInsightsProvider = Provider<List<Insight>>((ref) {
  final insights = ref.watch(insightsProvider);
  return insights.whenData((insights) => 
      insights.where((i) => i.isUrgent && !i.isDismissed).toList()
  ).valueOrNull ?? [];
});

final insightsByTypeProvider = Provider.family<List<Insight>, InsightType>((ref, type) {
  final insights = ref.watch(insightsProvider);
  return insights.whenData((insights) => 
      insights.where((i) => i.category == type && !i.isDismissed).toList()
  ).valueOrNull ?? [];
});

final insightsByPriorityProvider = Provider.family<List<Insight>, InsightPriority>((ref, priority) {
  final insights = ref.watch(insightsProvider);
  return insights.whenData((insights) => 
      insights.where((i) => i.priority == priority && !i.isDismissed).toList()
  ).valueOrNull ?? [];
});

final insightsStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final insights = ref.watch(insightsProvider);
  return insights.whenData((insights) {
    final total = insights.length;
    final dismissed = insights.where((i) => i.isDismissed).length;
    final urgent = insights.where((i) => i.isUrgent).length;
    final high = insights.where((i) => i.priority == InsightPriority.high).length;
    final medium = insights.where((i) => i.priority == InsightPriority.medium).length;
    final low = insights.where((i) => i.priority == InsightPriority.low).length;
    
    final byType = <InsightType, int>{};
    for (final type in InsightType.values) {
      byType[type] = insights.where((i) => i.category == type).length;
    }
    
    return {
      'total': total,
      'dismissed': dismissed,
      'urgent': urgent,
      'high': high,
      'medium': medium,
      'low': low,
      'byType': byType,
      'unreadCount': insights.where((i) => !i.isDismissed && !(i.metadata['isRead'] ?? false)).length,
    };
  }).valueOrNull ?? {
    'total': 0,
    'dismissed': 0,
    'urgent': 0,
    'high': 0,
    'medium': 0,
    'low': 0,
    'byType': <InsightType, int>{},
    'unreadCount': 0,
  };
});

// Auto-refresh provider that regenerates insights when analytics change
final autoRefreshInsightsProvider = Provider<void>((ref) {
  final analytics = ref.watch(analyticsProvider);
  final habits = ref.watch(habitsProvider);
  final logs = ref.watch(habitLogsProvider);
  final userProgress = ref.watch(userProgressProvider);
  
  // Watch for changes in any of the dependencies
  analytics.whenData((_) {});
  habits.whenData((_) {});
  logs.whenData((_) {});
  userProgress.whenData((_) {});
  
  // Trigger insights refresh when any dependency changes
  ref.read(insightsProvider.notifier).refreshInsights();
});
