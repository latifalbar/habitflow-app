import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';

class HabitRepository {
  final _uuid = const Uuid();
  final List<Habit> _habits = [];
  
  // Get all habits
  List<Habit> getAllHabits() {
    return List.from(_habits);
  }
  
  // Get habit by ID
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Add new habit
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
  }
  
  // Update existing habit
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }
  
  // Delete habit
  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((habit) => habit.id == id);
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
    return _habits.length;
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
}
