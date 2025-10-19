import 'dart:math';

class UserProgress {
  final int currentXP;
  final int currentLevel;
  final int totalXPEarned;
  final DateTime lastUpdated;
  
  const UserProgress({
    required this.currentXP,
    required this.currentLevel,
    required this.totalXPEarned,
    required this.lastUpdated,
  });
  
  int get xpToNextLevel => _calculateXPForLevel(currentLevel + 1);
  int get xpInCurrentLevel => currentXP - _calculateXPForLevel(currentLevel);
  int get xpNeededForNextLevel => xpToNextLevel - _calculateXPForLevel(currentLevel);
  double get progressToNextLevel => xpNeededForNextLevel > 0 
      ? xpInCurrentLevel / xpNeededForNextLevel 
      : 1.0;
  
  int _calculateXPForLevel(int level) => (100 * pow(level, 1.5)).toInt();
  
  UserProgress copyWith({
    int? currentXP,
    int? currentLevel,
    int? totalXPEarned,
    DateTime? lastUpdated,
  }) {
    return UserProgress(
      currentXP: currentXP ?? this.currentXP,
      currentLevel: currentLevel ?? this.currentLevel,
      totalXPEarned: totalXPEarned ?? this.totalXPEarned,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress &&
        other.currentXP == currentXP &&
        other.currentLevel == currentLevel &&
        other.totalXPEarned == totalXPEarned &&
        other.lastUpdated == lastUpdated;
  }
  
  @override
  int get hashCode {
    return currentXP.hashCode ^
        currentLevel.hashCode ^
        totalXPEarned.hashCode ^
        lastUpdated.hashCode;
  }
}
