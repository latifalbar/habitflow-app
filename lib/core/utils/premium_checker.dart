import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class to check premium status and handle premium feature access
class PremiumChecker {
  static const String _premiumKey = 'is_premium_user';
  static const String _premiumExpiryKey = 'premium_expiry_date';
  
  /// Check if user has premium access
  static Future<bool> isPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool(_premiumKey) ?? false;
      
      if (isPremium) {
        // Check if premium has expired
        final expiryString = prefs.getString(_premiumExpiryKey);
        if (expiryString != null) {
          final expiryDate = DateTime.parse(expiryString);
          if (DateTime.now().isAfter(expiryDate)) {
            // Premium expired, remove premium status
            await _removePremiumStatus();
            return false;
          }
        }
      }
      
      return isPremium;
    } catch (e) {
      // If error, assume not premium
      return false;
    }
  }
  
  /// Set premium status (for testing or after successful purchase)
  static Future<void> setPremiumStatus(bool isPremium, {DateTime? expiryDate}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    
    if (expiryDate != null) {
      await prefs.setString(_premiumExpiryKey, expiryDate.toIso8601String());
    }
  }
  
  /// Remove premium status
  static Future<void> _removePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_premiumKey);
    await prefs.remove(_premiumExpiryKey);
  }
  
  /// Check if user can access premium features
  static Future<bool> canAccessPremiumFeature() async {
    return await isPremium();
  }
  
  /// Get premium status with expiry info
  static Future<Map<String, dynamic>> getPremiumInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;
    final expiryString = prefs.getString(_premiumExpiryKey);
    
    return {
      'isPremium': isPremium,
      'expiryDate': expiryString != null ? DateTime.parse(expiryString) : null,
      'isExpired': expiryString != null && DateTime.now().isAfter(DateTime.parse(expiryString)),
    };
  }
}

/// Riverpod provider for premium status
final premiumStatusProvider = FutureProvider<bool>((ref) async {
  return await PremiumChecker.isPremium();
});

/// Riverpod provider for premium info
final premiumInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await PremiumChecker.getPremiumInfo();
});

/// Riverpod provider for premium feature access
final canAccessPremiumFeatureProvider = FutureProvider<bool>((ref) async {
  return await PremiumChecker.canAccessPremiumFeature();
});
