import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/habit_log.dart';

part 'habit_log_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class HabitLogModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final double? value;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? syncedAt;

  @HiveField(8)
  final Map<String, dynamic> metadata;

  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.value,
    this.note,
    required this.isCompleted,
    required this.createdAt,
    this.syncedAt,
    required this.metadata,
  });

  factory HabitLogModel.fromEntity(HabitLog log) {
    return HabitLogModel(
      id: log.id,
      habitId: log.habitId,
      completedAt: log.completedAt,
      value: log.value,
      note: log.note,
      isCompleted: log.isCompleted,
      createdAt: log.createdAt,
      syncedAt: log.syncedAt,
      metadata: log.metadata,
    );
  }

  HabitLog toEntity() {
    return HabitLog(
      id: id,
      habitId: habitId,
      completedAt: completedAt,
      value: value,
      note: note,
      isCompleted: isCompleted,
      createdAt: createdAt,
      syncedAt: syncedAt,
      metadata: metadata,
    );
  }

  factory HabitLogModel.fromJson(Map<String, dynamic> json) =>
      _$HabitLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$HabitLogModelToJson(this);

  HabitLogModel copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    double? value,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? syncedAt,
    Map<String, dynamic>? metadata,
  }) {
    return HabitLogModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      value: value ?? this.value,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitLogModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HabitLogModel(id: $id, habitId: $habitId, completedAt: $completedAt, isCompleted: $isCompleted)';
  }

  // Helper methods
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(completedAt.year, completedAt.month, completedAt.day);
    return today == logDate;
  }

  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final logDate = DateTime(completedAt.year, completedAt.month, completedAt.day);
    return yesterday == logDate;
  }

  bool isOnDate(DateTime date) {
    final logDate = DateTime(completedAt.year, completedAt.month, completedAt.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return logDate == targetDate;
  }
}
