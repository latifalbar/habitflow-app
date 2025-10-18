import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import 'habit_logs_provider.dart';
import 'habits_provider.dart';

// Provider for habit completion count
final habitCompletionCountProvider = Provider.family<int, String>((ref, habitId) {
  final logRepository = ref.watch(habitLogRepositoryProvider);
  final habitRepository = ref.watch(habitRepositoryProvider);
  
  final habit = habitRepository.getHabitById(habitId);
  if (habit == null) return 0;
  
  // For weekly habits, return week count
  if (habit.frequency == HabitFrequency.timesPerWeek) {
    return logRepository.getWeekCompletionCount(habitId);
  } else {
    // For daily habits, return today's count
    return logRepository.getTodaysCompletionCount(habitId);
  }
});

// Provider to check if habit can be completed
final canCompleteHabitProvider = Provider.family<bool, String>((ref, habitId) {
  final logRepository = ref.watch(habitLogRepositoryProvider);
  final habitRepository = ref.watch(habitRepositoryProvider);
  
  final habit = habitRepository.getHabitById(habitId);
  if (habit == null) return false;
  
  return logRepository.canAddMoreCompletions(
    habitId, 
    frequency: habit.frequencyString,
    timesPerWeek: habit.timesPerWeek,
  );
});

// Provider for habit completion status (for UI display)
final habitCompletionStatusProvider = Provider.family<HabitCompletionStatus, String>((ref, habitId) {
  final completionCount = ref.watch(habitCompletionCountProvider(habitId));
  final habitRepository = ref.watch(habitRepositoryProvider);
  
  final habit = habitRepository.getHabitById(habitId);
  if (habit == null) return HabitCompletionStatus.notCompleted;
  
  if (habit.frequency == HabitFrequency.timesPerWeek) {
    if (completionCount >= habit.timesPerWeek) {
      return HabitCompletionStatus.completed;
    } else if (completionCount > 0) {
      return HabitCompletionStatus.partiallyCompleted;
    } else {
      return HabitCompletionStatus.notCompleted;
    }
  } else {
    return completionCount > 0 ? HabitCompletionStatus.completed : HabitCompletionStatus.notCompleted;
  }
});

// Provider for habit progress text
final habitProgressTextProvider = Provider.family<String, String>((ref, habitId) {
  final completionCount = ref.watch(habitCompletionCountProvider(habitId));
  final habitRepository = ref.watch(habitRepositoryProvider);
  
  final habit = habitRepository.getHabitById(habitId);
  if (habit == null) return '0/1';
  
  if (habit.frequency == HabitFrequency.timesPerWeek) {
    return '$completionCount/${habit.timesPerWeek}';
  } else {
    return completionCount > 0 ? 'Completed' : 'Not completed';
  }
});

enum HabitCompletionStatus {
  notCompleted,
  partiallyCompleted,
  completed,
}
