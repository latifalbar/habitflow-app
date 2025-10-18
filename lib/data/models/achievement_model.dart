import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/achievement.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class AchievementModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final AchievementCategory category;

  @HiveField(5)
  final AchievementRarity rarity;

  @HiveField(6)
  final int xpReward;

  @HiveField(7)
  final int coinReward;

  @HiveField(8)
  final Map<String, dynamic> requirements;

  @HiveField(9)
  final bool isHidden;

  @HiveField(10)
  final DateTime? unlockedAt;

  @HiveField(11)
  final double progress;

  @HiveField(12)
  final Map<String, dynamic> metadata;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.xpReward,
    required this.coinReward,
    required this.requirements,
    required this.isHidden,
    this.unlockedAt,
    required this.progress,
    required this.metadata,
  });

  factory AchievementModel.fromEntity(Achievement achievement) {
    return AchievementModel(
      id: achievement.id,
      name: achievement.name,
      description: achievement.description,
      icon: achievement.icon,
      category: achievement.category,
      rarity: achievement.rarity,
      xpReward: achievement.xpReward,
      coinReward: achievement.coinReward,
      requirements: achievement.requirements,
      isHidden: achievement.isHidden,
      unlockedAt: achievement.unlockedAt,
      progress: achievement.progress,
      metadata: achievement.metadata,
    );
  }

  Achievement toEntity() {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      rarity: rarity,
      xpReward: xpReward,
      coinReward: coinReward,
      requirements: requirements,
      isHidden: isHidden,
      unlockedAt: unlockedAt,
      progress: progress,
      metadata: metadata,
    );
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementModelToJson(this);

  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementRarity? rarity,
    int? xpReward,
    int? coinReward,
    Map<String, dynamic>? requirements,
    bool? isHidden,
    DateTime? unlockedAt,
    double? progress,
    Map<String, dynamic>? metadata,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      requirements: requirements ?? this.requirements,
      isHidden: isHidden ?? this.isHidden,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, category: $category, rarity: $rarity)';
  }

  // Helper methods
  bool get isUnlocked => unlockedAt != null;

  bool get isCompleted => progress >= 1.0;

  String get progressText {
    if (isUnlocked) return 'Unlocked';
    if (progress == 0.0) return 'Not started';
    return '${(progress * 100).toInt()}% complete';
  }

  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return '#9E9E9E'; // Grey
      case AchievementRarity.uncommon:
        return '#4CAF50'; // Green
      case AchievementRarity.rare:
        return '#2196F3'; // Blue
      case AchievementRarity.epic:
        return '#9C27B0'; // Purple
      case AchievementRarity.legendary:
        return '#FF9800'; // Orange
    }
  }
}

// Enums are defined in domain/entities/achievement.dart
