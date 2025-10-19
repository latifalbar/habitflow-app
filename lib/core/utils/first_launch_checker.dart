import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First launch checker utility
class FirstLaunchChecker {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _firstLaunchKey = 'first_launch';
  
  /// Check if this is the first launch
  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      return true; // Default to first launch if error
    }
  }
  
  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      return false; // Default to not completed if error
    }
  }
  
  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
      await prefs.setBool(_firstLaunchKey, false);
    } catch (e) {
      // Silently fail
    }
  }
  
  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
      await prefs.remove(_firstLaunchKey);
    } catch (e) {
      // Silently fail
    }
  }
  
  /// Get onboarding status
  static Future<Map<String, dynamic>> getOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'isFirstLaunch': prefs.getBool(_firstLaunchKey) ?? true,
        'isOnboardingCompleted': prefs.getBool(_onboardingCompletedKey) ?? false,
        'shouldShowOnboarding': (prefs.getBool(_firstLaunchKey) ?? true) && 
                               !(prefs.getBool(_onboardingCompletedKey) ?? false),
      };
    } catch (e) {
      return {
        'isFirstLaunch': true,
        'isOnboardingCompleted': false,
        'shouldShowOnboarding': true,
      };
    }
  }
}

/// Riverpod provider for first launch status
final firstLaunchProvider = FutureProvider<bool>((ref) async {
  return await FirstLaunchChecker.isFirstLaunch();
});

/// Riverpod provider for onboarding completion status
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return await FirstLaunchChecker.isOnboardingCompleted();
});

/// Riverpod provider for onboarding status
final onboardingStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await FirstLaunchChecker.getOnboardingStatus();
});
