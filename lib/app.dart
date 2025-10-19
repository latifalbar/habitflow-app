import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/utils/first_launch_checker.dart';

class HabitFlowApp extends ConsumerWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(materialThemeModeProvider);

    return MaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme(themeName: 'ocean'),
      darkTheme: AppTheme.darkTheme(themeName: 'ocean'),
      themeMode: themeMode,

      // Home
      home: const AppInitializer(),

      // Routes
      routes: {
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

/// App initializer that checks first launch and navigates accordingly
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirstLaunchChecker.getOnboardingStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // If error, default to home
          return const HomeScreen();
        }

        final status = snapshot.data ?? {};
        final shouldShowOnboarding = status['shouldShowOnboarding'] ?? true;

        if (shouldShowOnboarding) {
          return const OnboardingScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
