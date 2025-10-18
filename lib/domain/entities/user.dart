class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final String selectedTheme;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final List<String> unlockedAchievements;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> metadata;

  const User({
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

  User copyWith({
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
    return User(
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
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, level: $level, xp: $xp, coins: $coins)';
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

  String get displayName {
    return name.isNotEmpty ? name : email.split('@').first;
  }

  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  T? getPreference<T>(String key, {T? defaultValue}) {
    return preferences[key] as T? ?? defaultValue;
  }

  void setPreference(String key, dynamic value) {
    preferences[key] = value;
  }
}
