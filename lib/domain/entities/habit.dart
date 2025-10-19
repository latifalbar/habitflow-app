import 'package:flutter/material.dart';

enum HabitFrequency {
  daily,
  customDays,
  timesPerWeek,
  everyXDays,
}

enum HabitGoalType {
  simple,
  quantifiable,
  timeBased,
}

class Habit {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final HabitFrequency frequency;
  final HabitGoalType goalType;
  final double? goalValue;
  final String? goalUnit;
  final List<int> customDays; // 0 = Sunday, 1 = Monday, etc.
  final int timesPerWeek;
  final int everyXDays;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final String category;
  final bool isArchived;
  final int sortOrder;
  final Map<String, dynamic> metadata;

  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.goalType,
    this.goalValue,
    this.goalUnit,
    required this.customDays,
    required this.timesPerWeek,
    required this.everyXDays,
    required this.createdAt,
    this.reminderTime,
    required this.category,
    required this.isArchived,
    required this.sortOrder,
    required this.metadata,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    Color? color,
    HabitFrequency? frequency,
    HabitGoalType? goalType,
    double? goalValue,
    String? goalUnit,
    List<int>? customDays,
    int? timesPerWeek,
    int? everyXDays,
    DateTime? createdAt,
    DateTime? reminderTime,
    String? category,
    bool? isArchived,
    int? sortOrder,
    Map<String, dynamic>? metadata,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      goalType: goalType ?? this.goalType,
      goalValue: goalValue ?? this.goalValue,
      goalUnit: goalUnit ?? this.goalUnit,
      customDays: customDays ?? this.customDays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      everyXDays: everyXDays ?? this.everyXDays,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, frequency: $frequency, goalType: $goalType)';
  }

  // Helper methods
  bool shouldTrackOnDay(DateTime date) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.customDays:
        return customDays.contains(date.weekday % 7);
      case HabitFrequency.timesPerWeek:
        // This would need more complex logic based on tracking history
        return true;
      case HabitFrequency.everyXDays:
        // This would need more complex logic based on tracking history
        return true;
    }
  }

  String get frequencyDescription {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.customDays:
        final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final selectedDays = customDays.map((day) => dayNames[day]).join(', ');
        return 'On $selectedDays';
      case HabitFrequency.timesPerWeek:
        return '$timesPerWeek times per week';
      case HabitFrequency.everyXDays:
        return 'Every $everyXDays days';
    }
  }

  String get goalDescription {
    switch (goalType) {
      case HabitGoalType.simple:
        return 'Complete habit';
      case HabitGoalType.quantifiable:
        return '${goalValue?.toStringAsFixed(0) ?? '0'} ${goalUnit ?? 'units'}';
      case HabitGoalType.timeBased:
        final minutes = (goalValue ?? 0).toInt();
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        if (hours > 0) {
          return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
        }
        return '${minutes}m';
    }
  }

  // Check if allows multiple completions per day
  bool get allowsMultipleCompletions {
    return frequency == HabitFrequency.timesPerWeek;
  }

  // Get target for current period
  int get targetCompletions {
    switch (frequency) {
      case HabitFrequency.daily:
        return 1;
      case HabitFrequency.timesPerWeek:
        return timesPerWeek;
      case HabitFrequency.customDays:
        return 1;
      case HabitFrequency.everyXDays:
        return 1;
    }
  }

  // Get period name
  String get periodName {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'today';
      case HabitFrequency.timesPerWeek:
        return 'this week';
      case HabitFrequency.customDays:
        return 'today';
      case HabitFrequency.everyXDays:
        return 'this period';
    }
  }

  // Get frequency string for repository methods
  String get frequencyString {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'daily';
      case HabitFrequency.timesPerWeek:
        return 'timesPerWeek';
      case HabitFrequency.customDays:
        return 'customDays';
      case HabitFrequency.everyXDays:
        return 'everyXDays';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color.value,
      'frequency': frequency.toString(),
      'goalType': goalType.toString(),
      'goalValue': goalValue,
      'goalUnit': goalUnit,
      'customDays': customDays,
      'timesPerWeek': timesPerWeek,
      'everyXDays': everyXDays,
      'createdAt': createdAt.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'category': category,
      'isArchived': isArchived,
      'sortOrder': sortOrder,
      'metadata': metadata,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
