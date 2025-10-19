import 'package:hive/hive.dart';
import '../../domain/entities/user_progress.dart';

part 'user_progress_model.g.dart';

@HiveType(typeId: 7)
class UserProgressModel extends HiveObject {
  @HiveField(0)
  int currentXP;
  
  @HiveField(1)
  int currentLevel;
  
  @HiveField(2)
  int totalXPEarned;
  
  @HiveField(3)
  DateTime lastUpdated;
  
  UserProgressModel({
    required this.currentXP,
    required this.currentLevel,
    required this.totalXPEarned,
    required this.lastUpdated,
  });
  
  UserProgress toEntity() {
    return UserProgress(
      currentXP: currentXP,
      currentLevel: currentLevel,
      totalXPEarned: totalXPEarned,
      lastUpdated: lastUpdated,
    );
  }
  
  factory UserProgressModel.fromEntity(UserProgress progress) {
    return UserProgressModel(
      currentXP: progress.currentXP,
      currentLevel: progress.currentLevel,
      totalXPEarned: progress.totalXPEarned,
      lastUpdated: progress.lastUpdated,
    );
  }
  
  UserProgressModel copyWith({
    int? currentXP,
    int? currentLevel,
    int? totalXPEarned,
    DateTime? lastUpdated,
  }) {
    return UserProgressModel(
      currentXP: currentXP ?? this.currentXP,
      currentLevel: currentLevel ?? this.currentLevel,
      totalXPEarned: totalXPEarned ?? this.totalXPEarned,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
