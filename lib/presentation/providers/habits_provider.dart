import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/habit_repository.dart';
import '../../domain/entities/habit.dart';

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
  return habitsAsync.when(
    data: (habits) => AsyncValue.data(habits.where((habit) => !habit.isArchived).toList()),
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
