import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' as material;

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      state = AppThemeMode.values[themeIndex];
    } catch (e) {
      // Default to system theme if loading fails
      state = AppThemeMode.system;
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      state = theme;
    } catch (e) {
      // Handle error silently
      print('Error saving theme preference: $e');
    }
  }

  String getThemeDisplayName(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

// Computed provider for Material ThemeMode
final materialThemeModeProvider = Provider<material.ThemeMode>((ref) {
  final theme = ref.watch(themeProvider);
  switch (theme) {
    case AppThemeMode.light:
      return material.ThemeMode.light;
    case AppThemeMode.dark:
      return material.ThemeMode.dark;
    case AppThemeMode.system:
      return material.ThemeMode.system;
  }
});
