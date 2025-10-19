import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/providers/theme_provider.dart';

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
      home: const HomeScreen(),

      // TODO: Add routing with go_router
      // routerConfig: AppRouter.router,
    );
  }
}
