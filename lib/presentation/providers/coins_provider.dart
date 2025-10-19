import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/coins_transaction.dart';
import '../../data/models/coins_transaction_model.dart';
import '../../data/models/user_model.dart';

final coinsBoxProvider = FutureProvider<Box<CoinsTransactionModel>>((ref) async {
  return await Hive.openBox<CoinsTransactionModel>(StorageKeys.coinsBox);
});

class CoinsNotifier extends StateNotifier<AsyncValue<int>> {
  final Box<CoinsTransactionModel> _coinsBox;
  final Box<UserModel> _userBox;

  CoinsNotifier(this._coinsBox, this._userBox) : super(const AsyncValue.loading()) {
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      final user = _userBox.get(StorageKeys.currentUserKey);
      if (user != null) {
        state = AsyncValue.data(user.coins);
      } else {
        state = const AsyncValue.data(0);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> addCoins(int amount, String reason, {Map<String, dynamic>? metadata}) async {
    try {
      if (amount <= 0) return false;

      final user = _userBox.get(StorageKeys.currentUserKey);
      if (user == null) return false;

      // Create transaction record
      final transaction = CoinsTransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        type: CoinsTransactionType.earned,
        reason: reason,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _coinsBox.add(transaction);

      // Update user coins
      final updatedUser = user.copyWith(coins: user.coins + amount);
      await _userBox.put(StorageKeys.currentUserKey, updatedUser);

      await _loadCoins();
      return true;
    } catch (error) {
      print('Error adding coins: $error');
      return false;
    }
  }

  Future<bool> spendCoins(int amount, String reason, {Map<String, dynamic>? metadata}) async {
    try {
      if (amount <= 0) return false;

      final user = _userBox.get(StorageKeys.currentUserKey);
      if (user == null || user.coins < amount) return false;

      // Create transaction record
      final transaction = CoinsTransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        type: CoinsTransactionType.spent,
        reason: reason,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _coinsBox.add(transaction);

      // Update user coins
      final updatedUser = user.copyWith(coins: user.coins - amount);
      await _userBox.put(StorageKeys.currentUserKey, updatedUser);

      await _loadCoins();
      return true;
    } catch (error) {
      print('Error spending coins: $error');
      return false;
    }
  }

  Future<List<CoinsTransaction>> getTransactionHistory({int? limit}) async {
    try {
      final transactions = _coinsBox.values.toList();
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final limitedTransactions = limit != null 
          ? transactions.take(limit).toList()
          : transactions;
      
      return limitedTransactions.map((model) => model.toEntity()).toList();
    } catch (error) {
      print('Error getting transaction history: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> getCoinsStats() async {
    try {
      final transactions = _coinsBox.values.toList();
      
      final earned = transactions
          .where((t) => t.type == CoinsTransactionType.earned)
          .fold(0, (sum, t) => sum + t.amount);
      
      final spent = transactions
          .where((t) => t.type == CoinsTransactionType.spent)
          .fold(0, (sum, t) => sum + t.amount);
      
      final current = state.valueOrNull ?? 0;
      
      return {
        'current': current,
        'earned': earned,
        'spent': spent,
        'net': earned - spent,
        'transactionCount': transactions.length,
      };
    } catch (error) {
      print('Error getting coins stats: $error');
      return {};
    }
  }

  // Predefined earning methods
  Future<bool> earnFromHabitCompletion() async {
    return await addCoins(
      AppConstants.coinsPerCompletion,
      'Habit completed',
      metadata: {'source': 'habit_completion'},
    );
  }

  Future<bool> earnFromLevelUp() async {
    return await addCoins(
      AppConstants.coinsPerLevelUp,
      'Level up!',
      metadata: {'source': 'level_up'},
    );
  }

  Future<bool> earnFromAchievement(String achievementName) async {
    return await addCoins(
      AppConstants.commonAchievementCoins,
      'Achievement unlocked: $achievementName',
      metadata: {'source': 'achievement', 'achievement': achievementName},
    );
  }

  Future<bool> earnFromStreak(int streakDays) async {
    int coins = 0;
    String reason = '';
    
    if (streakDays == 7) {
      coins = AppConstants.coins7DayStreak;
      reason = '7-day streak bonus';
    } else if (streakDays == 30) {
      coins = AppConstants.coins30DayStreak;
      reason = '30-day streak bonus';
    } else if (streakDays == 100) {
      coins = AppConstants.coins100DayStreak;
      reason = '100-day streak bonus';
    }
    
    if (coins > 0) {
      return await addCoins(
        coins,
        reason,
        metadata: {'source': 'streak', 'days': streakDays},
      );
    }
    
    return false;
  }
}

final coinsNotifierProvider = StateNotifierProvider<CoinsNotifier, AsyncValue<int>>((ref) {
  // This will be initialized when the boxes are available
  throw UnimplementedError('CoinsNotifier requires boxes to be initialized');
});

// Provider for coins balance
final coinsProvider = FutureProvider<int>((ref) async {
  final coinsBox = await ref.watch(coinsBoxProvider.future);
  final userBox = await Hive.openBox<UserModel>(StorageKeys.userBox);
  
  final user = userBox.get(StorageKeys.currentUserKey);
  return user?.coins ?? 0;
});

// Provider for transaction history
final coinsTransactionHistoryProvider = FutureProvider<List<CoinsTransaction>>((ref) async {
  final coinsBox = await ref.watch(coinsBoxProvider.future);
  final transactions = coinsBox.values.toList();
  transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return transactions.map((model) => model.toEntity()).toList();
});

// Provider for coins statistics
final coinsStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final coinsBox = await ref.watch(coinsBoxProvider.future);
  final userBox = await Hive.openBox<UserModel>(StorageKeys.userBox);
  
  final user = userBox.get(StorageKeys.currentUserKey);
  final current = user?.coins ?? 0;
  
  final transactions = coinsBox.values.toList();
  
  final earned = transactions
      .where((t) => t.type == CoinsTransactionType.earned)
      .fold(0, (sum, t) => sum + t.amount);
  
  final spent = transactions
      .where((t) => t.type == CoinsTransactionType.spent)
      .fold(0, (sum, t) => sum + t.amount);
  
  return {
    'current': current,
    'earned': earned,
    'spent': spent,
    'net': earned - spent,
    'transactionCount': transactions.length,
  };
});
