enum XPSource {
  habitCompletion,    // +10 XP
  streakBonus,        // +5 XP per streak day (max +50)
  perfectDay,         // +100 XP (all habits completed)
  firstCompletion,    // +50 XP (first time completing habit)
}

class XPTransaction {
  final String id;
  final int xpAmount;
  final XPSource source;
  final String? habitId;
  final DateTime timestamp;
  
  const XPTransaction({
    required this.id,
    required this.xpAmount,
    required this.source,
    this.habitId,
    required this.timestamp,
  });
  
  String get sourceDescription {
    switch (source) {
      case XPSource.habitCompletion:
        return 'Habit completed';
      case XPSource.streakBonus:
        return 'Streak bonus';
      case XPSource.perfectDay:
        return 'Perfect day!';
      case XPSource.firstCompletion:
        return 'First completion';
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XPTransaction &&
        other.id == id &&
        other.xpAmount == xpAmount &&
        other.source == source &&
        other.habitId == habitId &&
        other.timestamp == timestamp;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        xpAmount.hashCode ^
        source.hashCode ^
        habitId.hashCode ^
        timestamp.hashCode;
  }
}
