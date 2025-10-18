import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final int level;

  @HiveField(5)
  final int xp;

  @HiveField(6)
  final int coins;

  @HiveField(7)
  final int currentStreak;

  @HiveField(8)
  final int bestStreak;

  @HiveField(9)
  final int totalCompletions;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? lastActiveAt;

  @HiveField(12)
  final String selectedTheme;

  @HiveField(13)
  final bool isPremium;

  @HiveField(14)
  final DateTime? premiumExpiresAt;

  @HiveField(15)
  final List<String> unlockedAchievements;

  @HiveField(16)
  final Map<String, dynamic> preferences;

  @HiveField(17)
  final Map<String, dynamic> metadata;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.coins,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompletions,
    required this.createdAt,
    this.lastActiveAt,
    required this.selectedTheme,
    required this.isPremium,
    this.premiumExpiresAt,
    required this.unlockedAchievements,
    required this.preferences,
    required this.metadata,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      level: user.level,
      xp: user.xp,
      coins: user.coins,
      currentStreak: user.currentStreak,
      bestStreak: user.bestStreak,
      totalCompletions: user.totalCompletions,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
      selectedTheme: user.selectedTheme,
      isPremium: user.isPremium,
      premiumExpiresAt: user.premiumExpiresAt,
      unlockedAchievements: user.unlockedAchievements,
      preferences: user.preferences,
      metadata: user.metadata,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      level: level,
      xp: xp,
      coins: coins,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCompletions: totalCompletions,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      selectedTheme: selectedTheme,
      isPremium: isPremium,
      premiumExpiresAt: premiumExpiresAt,
      unlockedAchievements: unlockedAchievements,
      preferences: preferences,
      metadata: metadata,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? level,
    int? xp,
    int? coins,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletions,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? selectedTheme,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    List<String>? unlockedAchievements,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, level: $level, xp: $xp, coins: $coins)';
  }

  // Helper methods
  int get xpToNextLevel {
    return _calculateXpForLevel(level + 1) - xp;
  }

  double get levelProgress {
    final currentLevelXp = _calculateXpForLevel(level);
    final nextLevelXp = _calculateXpForLevel(level + 1);
    final progress = (xp - currentLevelXp) / (nextLevelXp - currentLevelXp);
    return progress.clamp(0.0, 1.0);
  }

  int _calculateXpForLevel(int level) {
    return (100 * (level * level * 1.5)).round();
  }

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true; // Lifetime premium
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  String get premiumStatus {
    if (!isPremium) return 'Free';
    if (premiumExpiresAt == null) return 'Lifetime';
    if (isPremiumActive) {
      final daysLeft = premiumExpiresAt!.difference(DateTime.now()).inDays;
      return 'Premium ($daysLeft days left)';
    }
    return 'Expired';
  }
}
