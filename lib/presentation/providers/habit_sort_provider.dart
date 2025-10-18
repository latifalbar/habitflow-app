import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HabitSortOption {
  newestFirst,
  oldestFirst,
  nameAsc,
  nameDesc,
  uncompletedFirst,
}

extension HabitSortOptionExtension on HabitSortOption {
  String get label {
    switch (this) {
      case HabitSortOption.newestFirst:
        return 'Newest First';
      case HabitSortOption.oldestFirst:
        return 'Oldest First';
      case HabitSortOption.nameAsc:
        return 'Name (A-Z)';
      case HabitSortOption.nameDesc:
        return 'Name (Z-A)';
      case HabitSortOption.uncompletedFirst:
        return 'Uncompleted First';
    }
  }
  
  IconData get icon {
    switch (this) {
      case HabitSortOption.newestFirst:
        return Icons.arrow_downward;
      case HabitSortOption.oldestFirst:
        return Icons.arrow_upward;
      case HabitSortOption.nameAsc:
        return Icons.sort_by_alpha;
      case HabitSortOption.nameDesc:
        return Icons.sort_by_alpha;
      case HabitSortOption.uncompletedFirst:
        return Icons.radio_button_unchecked;
    }
  }
}

final habitSortOptionProvider = StateProvider<HabitSortOption>((ref) {
  return HabitSortOption.newestFirst; // default
});
