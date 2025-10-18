import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final int colorValue; // Store Color as int value

  @HiveField(5)
  final int frequencyIndex; // Store enum as index

  @HiveField(6)
  final int goalTypeIndex; // Store enum as index

  @HiveField(7)
  final double? goalValue;

  @HiveField(8)
  final String? goalUnit;

  @HiveField(9)
  final List<int> customDays;

  @HiveField(10)
  final int timesPerWeek;

  @HiveField(11)
  final int everyXDays;

  @HiveField(12)
  final int createdAtMillis; // Store DateTime as milliseconds

  @HiveField(13)
  final int? reminderTimeMillis; // Store DateTime as milliseconds

  @HiveField(14)
  final String category;

  @HiveField(15)
  final bool isArchived;

  @HiveField(16)
  final int sortOrder;

  @HiveField(17)
  final Map<String, dynamic> metadata;

  HabitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.colorValue,
    required this.frequencyIndex,
    required this.goalTypeIndex,
    this.goalValue,
    this.goalUnit,
    required this.customDays,
    required this.timesPerWeek,
    required this.everyXDays,
    required this.createdAtMillis,
    this.reminderTimeMillis,
    required this.category,
    required this.isArchived,
    required this.sortOrder,
    required this.metadata,
  });

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      icon: habit.icon,
      colorValue: habit.color.value,
      frequencyIndex: habit.frequency.index,
      goalTypeIndex: habit.goalType.index,
      goalValue: habit.goalValue,
      goalUnit: habit.goalUnit,
      customDays: habit.customDays,
      timesPerWeek: habit.timesPerWeek,
      everyXDays: habit.everyXDays,
      createdAtMillis: habit.createdAt.millisecondsSinceEpoch,
      reminderTimeMillis: habit.reminderTime?.millisecondsSinceEpoch,
      category: habit.category,
      isArchived: habit.isArchived,
      sortOrder: habit.sortOrder,
      metadata: habit.metadata,
    );
  }

  Habit toEntity() {
    return Habit(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: Color(colorValue),
      frequency: HabitFrequency.values[frequencyIndex],
      goalType: HabitGoalType.values[goalTypeIndex],
      goalValue: goalValue,
      goalUnit: goalUnit,
      customDays: customDays,
      timesPerWeek: timesPerWeek,
      everyXDays: everyXDays,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      reminderTime: reminderTimeMillis != null 
          ? DateTime.fromMillisecondsSinceEpoch(reminderTimeMillis!)
          : null,
      category: category,
      isArchived: isArchived,
      sortOrder: sortOrder,
      metadata: metadata,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) => _$HabitModelFromJson(json);
  Map<String, dynamic> toJson() => _$HabitModelToJson(this);
}
