class HabitLog {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final double? value;
  final String? note;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final Map<String, dynamic> metadata;

  const HabitLog({
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

  HabitLog copyWith({
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
    return HabitLog(
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
    return other is HabitLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HabitLog(id: $id, habitId: $habitId, completedAt: $completedAt, isCompleted: $isCompleted)';
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

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
