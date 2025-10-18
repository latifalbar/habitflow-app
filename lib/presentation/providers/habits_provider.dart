import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/habit_repository.dart';
import '../../domain/entities/habit.dart';
import 'habit_sort_provider.dart';
import 'habit_completion_provider.dart';

// Repository provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

// Habits list provider
final habitsProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitsNotifier(repository);
});

// Active habits provider
final activeHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  final sortOption = ref.watch(habitSortOptionProvider);
  
  return habitsAsync.when(
    data: (habits) {
      final activeHabits = habits
          .where((habit) => !habit.isArchived)
          .toList();
      
      // Sort based on user selection
      switch (sortOption) {
        case HabitSortOption.newestFirst:
          activeHabits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case HabitSortOption.oldestFirst:
          activeHabits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case HabitSortOption.nameAsc:
          activeHabits.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case HabitSortOption.nameDesc:
          activeHabits.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;
        case HabitSortOption.uncompletedFirst:
          // Sort by completion status, then by createdAt
          activeHabits.sort((a, b) {
            final aCompleted = ref.read(habitCompletionCountProvider(a.id)) > 0;
            final bCompleted = ref.read(habitCompletionCountProvider(b.id)) > 0;
            if (aCompleted == bCompleted) {
              return b.createdAt.compareTo(a.createdAt);
            }
            return aCompleted ? 1 : -1; // uncompleted first
          });
          break;
      }
      
      return AsyncValue.data(activeHabits);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Single habit provider
final habitProvider = StateProvider.family<Habit?, String>((ref, id) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitById(id);
});

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final HabitRepository _repository;

  HabitsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      state = const AsyncValue.loading();
      final habits = _repository.getAllHabits();
      state = AsyncValue.data(habits);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _repository.addHabit(habit);
      await _loadHabits();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
      await _loadHabits();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      await _loadHabits();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> archiveHabit(String id) async {
    try {
      final habit = _repository.getHabitById(id);
      if (habit != null) {
        final updatedHabit = habit.copyWith(isArchived: true);
        await _repository.updateHabit(updatedHabit);
        await _loadHabits();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> unarchiveHabit(String id) async {
    try {
      final habit = _repository.getHabitById(id);
      if (habit != null) {
        final updatedHabit = habit.copyWith(isArchived: false);
        await _repository.updateHabit(updatedHabit);
        await _loadHabits();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadHabits();
  }
}
