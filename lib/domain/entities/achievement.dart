enum AchievementCategory {
  gettingStarted,
  streaks,
  completions,
  timeBased,
  special,
  social,
  premium,
}

extension AchievementCategoryExtension on AchievementCategory {
  String get categoryDisplayName {
    switch (this) {
      case AchievementCategory.gettingStarted:
        return 'Getting Started';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.completions:
        return 'Completions';
      case AchievementCategory.timeBased:
        return 'Time Based';
      case AchievementCategory.special:
        return 'Special';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.premium:
        return 'Premium';
    }
  }
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int xpReward;
  final int coinReward;
  final Map<String, dynamic> requirements;
  final bool isHidden;
  final DateTime? unlockedAt;
  final double progress;
  final Map<String, dynamic> metadata;

  const Achievement({
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

  Achievement copyWith({
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
    return Achievement(
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
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, category: $category, rarity: $rarity)';
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

  String get categoryDisplayName {
    switch (category) {
      case AchievementCategory.gettingStarted:
        return 'Getting Started';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.completions:
        return 'Completions';
      case AchievementCategory.timeBased:
        return 'Time Based';
      case AchievementCategory.special:
        return 'Special';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.premium:
        return 'Premium';
    }
  }

  String get rarityDisplayName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  String get timeAgo {
    if (unlockedAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(unlockedAt!);

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
