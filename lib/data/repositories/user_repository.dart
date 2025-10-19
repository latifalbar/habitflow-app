import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../core/constants/storage_keys.dart';
import '../services/firestore_service.dart';
import '../../core/utils/premium_checker.dart';

/// User repository for managing user data
class UserRepository {
  final _uuid = const Uuid();
  late final Box<UserModel> _userBox;
  final FirestoreService _firestoreService;
  final PremiumChecker _premiumChecker;
  
  UserRepository({
    required FirestoreService firestoreService,
    required PremiumChecker premiumChecker,
  }) : _firestoreService = firestoreService,
       _premiumChecker = premiumChecker {
    _userBox = Hive.box<UserModel>(StorageKeys.userBox);
  }
  
  /// Get current user
  User? getCurrentUser() {
    final userModels = _userBox.values.toList();
    if (userModels.isEmpty) return null;
    
    // Return the first (and should be only) user
    return userModels.first.toEntity();
  }
  
  /// Create new user
  Future<User> createUser({
    required String name,
    required String email,
    String? profileImageUrl,
    bool isPremium = false,
  }) async {
    final userId = _uuid.v4();
    final now = DateTime.now();
    
    final user = User(
      id: userId,
      name: name,
      email: email,
      avatarUrl: profileImageUrl,
      level: 1,
      xp: 0,
      coins: 0,
      currentStreak: 0,
      bestStreak: 0,
      totalCompletions: 0,
      isPremium: isPremium,
      createdAt: now,
      lastActiveAt: now,
      selectedTheme: 'ocean',
      unlockedAchievements: [],
      preferences: {},
      metadata: {},
    );
    
    await saveUser(user);
    return user;
  }
  
  /// Save user to local storage
  Future<void> saveUser(User user) async {
    final model = UserModel.fromEntity(user);
    await _userBox.put(user.id, model);
  }
  
  /// Update user
  Future<void> updateUser(User user) async {
    final updatedUser = user.copyWith(lastActiveAt: DateTime.now());
    await saveUser(updatedUser);
    
    // Sync to cloud if premium and authenticated
    if (await PremiumChecker.isPremium()) {
      await _syncUserToCloud(updatedUser);
    }
  }
  
  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
    
    // Delete from cloud if premium and authenticated
    if (await PremiumChecker.isPremium()) {
      await _deleteUserFromCloud(userId);
    }
  }
  
  /// Update user level
  Future<void> updateUserLevel(int newLevel) async {
    final user = getCurrentUser();
    if (user == null) return;
    
    final updatedUser = user.copyWith(
      level: newLevel,
    );
    
    await updateUser(updatedUser);
  }
  
  /// Add XP to user
  Future<void> addXp(int xpAmount) async {
    final user = getCurrentUser();
    if (user == null) return;
    
    final newXp = user.xp + xpAmount;
    final updatedUser = user.copyWith(
      xp: newXp,
    );
    
    await updateUser(updatedUser);
  }
  
  /// Add coins to user
  Future<void> addCoins(int coinAmount) async {
    final user = getCurrentUser();
    if (user == null) return;
    
    final newCoins = user.coins + coinAmount;
    final updatedUser = user.copyWith(
      coins: newCoins,
    );
    
    await updateUser(updatedUser);
  }
  
  /// Spend coins
  Future<bool> spendCoins(int coinAmount) async {
    final user = getCurrentUser();
    if (user == null || user.coins < coinAmount) return false;
    
    final newCoins = user.coins - coinAmount;
    final updatedUser = user.copyWith(
      coins: newCoins,
    );
    
    await updateUser(updatedUser);
    return true;
  }
  
  /// Update premium status
  Future<void> updatePremiumStatus(bool isPremium) async {
    final user = getCurrentUser();
    if (user == null) return;
    
    final updatedUser = user.copyWith(
      isPremium: isPremium,
    );
    
    await updateUser(updatedUser);
  }
  
  /// Update last active time
  Future<void> updateLastActiveTime() async {
    final user = getCurrentUser();
    if (user == null) return;
    
    final updatedUser = user.copyWith(
      lastActiveAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }
  
  /// Get user statistics
  Map<String, dynamic> getUserStats() {
    final user = getCurrentUser();
    if (user == null) {
      return {
        'level': 0,
        'xp': 0,
        'coins': 0,
        'isPremium': false,
        'daysActive': 0,
      };
    }
    
    final daysActive = user.lastActiveAt?.difference(user.createdAt).inDays ?? 0;
    
    return {
      'level': user.level,
      'xp': user.xp,
      'coins': user.coins,
      'isPremium': user.isPremium,
      'daysActive': daysActive,
      'createdAt': user.createdAt.toIso8601String(),
      'lastActiveAt': user.lastActiveAt?.toIso8601String(),
    };
  }
  
  /// Sync user to cloud
  Future<void> _syncUserToCloud(User user) async {
    try {
      await _firestoreService.createDocument(
        subcollection: 'profile',
        documentId: user.id,
        data: user.toJson(),
      );
    } catch (e) {
      // Log error but don't throw - local data is still saved
      print('Failed to sync user to cloud: $e');
    }
  }
  
  /// Delete user from cloud
  Future<void> _deleteUserFromCloud(String userId) async {
    try {
      await _firestoreService.deleteDocument(
        subcollection: 'profile',
        documentId: userId,
      );
    } catch (e) {
      // Log error but don't throw
      print('Failed to delete user from cloud: $e');
    }
  }
  
  /// Download user from cloud
  Future<User?> downloadUserFromCloud(String userId) async {
    try {
      final userData = await _firestoreService.readDocument(
        subcollection: 'profile',
        documentId: userId,
      );
      
      if (userData != null) {
        // TODO: Convert JSON to User entity
        // return User.fromJson(userData);
        return null;
      }
      
      return null;
    } catch (e) {
      print('Failed to download user from cloud: $e');
      return null;
    }
  }
  
  /// Check if user exists
  bool userExists() {
    return _userBox.isNotEmpty;
  }
  
  /// Get user count
  int getUserCount() {
    return _userBox.length;
  }
  
  /// Clear all users (for testing)
  Future<void> clearAllUsers() async {
    await _userBox.clear();
  }
  
  /// Export user data
  Map<String, dynamic> exportUserData() {
    final user = getCurrentUser();
    if (user == null) return {};
    
    return {
      'user': user.toJson(),
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Import user data
  Future<void> importUserData(Map<String, dynamic> data) async {
    if (data['user'] != null) {
      // TODO: Create user from JSON and save
      // final user = User.fromJson(data['user']);
      // await saveUser(user);
    }
  }
}

/// Riverpod provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return UserRepository(
    firestoreService: firestoreService,
    premiumChecker: PremiumChecker(),
  );
});

/// Riverpod provider for current user
final currentUserProvider = Provider<User?>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getCurrentUser();
});

/// Riverpod provider for user stats
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStats();
});
