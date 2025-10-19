import 'package:flutter/material.dart';

enum InsightType {
  performance,
  behavioral,
  predictive,
  motivational,
  recommendation,
  backup,
}

enum InsightCategory {
  performance,
  behavioral,
  predictive,
  motivational,
  recommendation,
  backup,
}

enum InsightPriority {
  low,    // Nice to know
  medium, // Worth attention
  high,   // Important
  urgent, // Needs immediate action
}

class Insight {
  final String id;
  final String title;
  final String description;
  final String actionText;
  final InsightCategory category;
  final InsightPriority priority;
  final String icon;
  final Color color;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;
  final bool isDismissed;

  const Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.actionText,
    required this.category,
    required this.priority,
    required this.icon,
    required this.color,
    this.metadata = const {},
    required this.generatedAt,
    this.isDismissed = false,
  });

  Insight copyWith({
    String? id,
    String? title,
    String? description,
    String? actionText,
    InsightCategory? category,
    InsightPriority? priority,
    String? icon,
    Color? color,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
    bool? isDismissed,
  }) {
    return Insight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      actionText: actionText ?? this.actionText,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Insight &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.actionText == actionText &&
        other.category == category &&
        other.priority == priority &&
        other.icon == icon &&
        other.color == color &&
        other.generatedAt == generatedAt &&
        other.isDismissed == isDismissed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      actionText,
      category,
      priority,
      icon,
      color,
      generatedAt,
      isDismissed,
    );
  }

  @override
  String toString() {
    return 'Insight(id: $id, title: $title, category: $category, priority: $priority, isDismissed: $isDismissed)';
  }

  // Helper getters
  String get categoryDisplayName {
    switch (category) {
      case InsightCategory.performance:
        return 'Performance';
      case InsightCategory.behavioral:
        return 'Behavioral';
      case InsightCategory.predictive:
        return 'Predictive';
      case InsightCategory.motivational:
        return 'Motivational';
      case InsightCategory.recommendation:
        return 'Recommendation';
      case InsightCategory.backup:
        return 'Backup';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case InsightPriority.low:
        return 'Low';
      case InsightPriority.medium:
        return 'Medium';
      case InsightPriority.high:
        return 'High';
      case InsightPriority.urgent:
        return 'Urgent';
    }
  }

  bool get isActionable => actionText.isNotEmpty;
  
  bool get isHighPriority => priority == InsightPriority.high || priority == InsightPriority.urgent;
  
  bool get isUrgent => priority == InsightPriority.urgent;
}

// Extension for InsightCategory
extension InsightCategoryExtension on InsightCategory {
  String get displayName {
    switch (this) {
      case InsightCategory.performance:
        return 'Performance';
      case InsightCategory.behavioral:
        return 'Behavioral';
      case InsightCategory.predictive:
        return 'Predictive';
      case InsightCategory.motivational:
        return 'Motivational';
      case InsightCategory.recommendation:
        return 'Recommendation';
      case InsightCategory.backup:
        return 'Backup';
    }
  }

  String get icon {
    switch (this) {
      case InsightCategory.performance:
        return '📊';
      case InsightCategory.behavioral:
        return '🧠';
      case InsightCategory.predictive:
        return '🔮';
      case InsightCategory.motivational:
        return '🎯';
      case InsightCategory.recommendation:
        return '💡';
      case InsightCategory.backup:
        return '💾';
    }
  }
}

// Extension for InsightPriority
extension InsightPriorityExtension on InsightPriority {
  String get displayName {
    switch (this) {
      case InsightPriority.low:
        return 'Low';
      case InsightPriority.medium:
        return 'Medium';
      case InsightPriority.high:
        return 'High';
      case InsightPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case InsightPriority.low:
        return const Color(0xFF9E9E9E); // Grey
      case InsightPriority.medium:
        return const Color(0xFF2196F3); // Blue
      case InsightPriority.high:
        return const Color(0xFFFF9800); // Orange
      case InsightPriority.urgent:
        return const Color(0xFFF44336); // Red
    }
  }
}
