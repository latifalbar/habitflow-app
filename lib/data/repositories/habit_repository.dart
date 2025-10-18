import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/habit.dart';
import '../models/habit_model.dart';
import '../../core/constants/storage_keys.dart';

class HabitRepository {
  final _uuid = const Uuid();
  late final Box<HabitModel> _habitBox;
  
  HabitRepository() {
    _habitBox = Hive.box<HabitModel>(StorageKeys.habitsBox);
  }
  
  // Get all habits
  List<Habit> getAllHabits() {
    return _habitBox.values.map((model) => model.toEntity()).toList();
  }
  
  // Get habit by ID
  Habit? getHabitById(String id) {
    final model = _habitBox.get(id);
    return model?.toEntity();
  }
  
  // Add new habit
  Future<void> addHabit(Habit habit) async {
    final model = HabitModel.fromEntity(habit);
    await _habitBox.put(habit.id, model);
  }
  
  // Update existing habit
  Future<void> updateHabit(Habit habit) async {
    final model = HabitModel.fromEntity(habit);
    await _habitBox.put(habit.id, model);
  }
  
  // Delete habit
  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
  }
  
  // Get habits by category
  List<Habit> getHabitsByCategory(String category) {
    final allHabits = getAllHabits();
    return allHabits.where((habit) => habit.category == category).toList();
  }
  
  // Get active habits (not archived)
  List<Habit> getActiveHabits() {
    final allHabits = getAllHabits();
    return allHabits.where((habit) => !habit.isArchived).toList();
  }
  
  // Get archived habits
  List<Habit> getArchivedHabits() {
    final allHabits = getAllHabits();
    return allHabits.where((habit) => habit.isArchived).toList();
  }
  
  // Generate unique ID
  String generateId() {
    return _uuid.v4();
  }
  
  // Get habits count
  int getHabitsCount() {
    return _habitBox.length;
  }
  
  // Search habits by name
  List<Habit> searchHabits(String query) {
    final allHabits = getAllHabits();
    final lowercaseQuery = query.toLowerCase();
    return allHabits.where((habit) => 
      habit.name.toLowerCase().contains(lowercaseQuery) ||
      habit.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Get habits scheduled for today
  List<Habit> getHabitsForToday() {
    final today = DateTime.now();
    final activeHabits = getActiveHabits();
    
    return activeHabits.where((habit) {
      return habit.shouldTrackOnDay(today);
    }).toList();
  }
  
  // Get habits by date range
  List<Habit> getHabitsByDateRange(DateTime start, DateTime end) {
    final allHabits = getAllHabits();
    return allHabits.where((habit) {
      return habit.createdAt.isAfter(start) && habit.createdAt.isBefore(end);
    }).toList();
  }
}
