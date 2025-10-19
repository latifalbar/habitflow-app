import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/habit_log.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/habits_provider.dart';
import '../../providers/habit_logs_provider.dart' as logs;
import '../../providers/progress_provider.dart';
import '../../providers/habit_completion_provider.dart';
import '../../providers/habit_sort_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/garden_provider.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/xp_progress_bar.dart';
import '../../widgets/xp_gain_animation.dart';
import '../../widgets/level_up_dialog.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../domain/entities/xp_transaction.dart';
import '../habits/add_habit_screen.dart';
import '../habits/habit_detail_screen.dart';
import '../habits/habits_search_screen.dart';
import '../garden/garden_screen.dart';
import '../analytics/analytics_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HabitsTab(),
    const AnalyticsTab(),
    const GardenTab(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// Habits Tab
class HabitsTab extends ConsumerStatefulWidget {
  const HabitsTab({super.key});

  @override
  ConsumerState<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends ConsumerState<HabitsTab> {
  @override
  void initState() {
    super.initState();
    // Refresh progress when tab is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            AppConstants.appName,
            style: AppTextStyles.h4,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HabitsSearchScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Implement menu
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // XP Progress Bar
                Consumer(
                  builder: (context, ref, child) {
                    final userProgressAsync = ref.watch(userProgressProvider);
                    return userProgressAsync.when(
                      data: (progress) => XPProgressBar(
                        currentXP: progress.currentXP,
                        currentLevel: progress.currentLevel,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Greeting Card
                _buildGreetingCard(context),
                const SizedBox(height: AppSpacing.lg),

                // Today's Progress
                Text('Today\'s Progress', style: AppTextStyles.h5),
                const SizedBox(height: AppSpacing.md),
                _buildProgressCard(context),
                const SizedBox(height: AppSpacing.lg),

                // Habits List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Habits', style: AppTextStyles.h5),
                    Row(
                      children: [
                        // Sort Menu - ICON ONLY
                        PopupMenuButton<HabitSortOption>(
                          icon: Icon(Icons.sort, size: 20, color: AppColors.grey600),
                          tooltip: 'Sort habits',
                          offset: Offset(0, 40),
                          onSelected: (option) {
                            ref.read(habitSortOptionProvider.notifier).state = option;
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: HabitSortOption.newestFirst,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_downward, size: 18),
                                  SizedBox(width: 12),
                                  Text('Newest First'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: HabitSortOption.oldestFirst,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_upward, size: 18),
                                  SizedBox(width: 12),
                                  Text('Oldest First'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: HabitSortOption.nameAsc,
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha, size: 18),
                                  SizedBox(width: 12),
                                  Text('Name (A-Z)'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: HabitSortOption.nameDesc,
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha, size: 18),
                                  SizedBox(width: 12),
                                  Text('Name (Z-A)'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: HabitSortOption.uncompletedFirst,
                              child: Row(
                                children: [
                                  Icon(Icons.radio_button_unchecked, size: 18),
                                  SizedBox(width: 12),
                                  Text('Uncompleted First'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Refresh Button
                        TextButton(
                          onPressed: () {
                            ref.read(habitsProvider.notifier).refresh();
                          },
                          child: Text(
                            'Refresh',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.oceanPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
        
        // Habits List
        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No habits yet',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tap the + button to create your first habit',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = habits[index];
                    return HabitCard(
                      habit: habit,
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HabitDetailScreen(habit: habit),
                          ),
                        );
                        
                        // Refresh habits list if habit was updated/deleted
                        if (result == true) {
                          ref.read(habitsProvider.notifier).refresh();
                        }
                        
                        // Always refresh progress when returning from detail screen
                        ref.read(progressProvider.notifier).refresh();
                      },
                      onCheck: () async {
                        try {
                          final repository = ref.read(logs.habitLogRepositoryProvider);
                          final log = HabitLog(
                            id: repository.generateId(),
                            habitId: habit.id,
                            completedAt: DateTime.now(),
                            value: habit.goalType != HabitGoalType.simple ? habit.goalValue : null,
                            note: null,
                            isCompleted: true,
                            createdAt: DateTime.now(),
                            metadata: {},
                          );
                          
                          await ref.read(logs.habitLogsProvider.notifier).addLog(log);
                          
                          // Refresh progress to get updated stats
                          await ref.read(progressProvider.notifier).refresh();
                          
                          // Invalidate completion count to trigger checkbox rebuild
                          ref.invalidate(habitCompletionCountProvider(habit.id));
                          
                          if (mounted) {
                            // Calculate XP earned
                            final currentStreak = ref.read(habitCompletionCountProvider(habit.id));
                            final isFirstCompletion = currentStreak == 1;
                            final xpEarned = XPCalculator.calculateCompletionXP(habit, currentStreak, isFirstCompletion);
                            
                            // Add XP to user progress
                            final levelUpResult = await ref.read(userProgressProvider.notifier).addXP(
                              xpEarned,
                              XPSource.habitCompletion,
                              habit.id,
                            );
                            
                            // Show XP gain animation
                            showXPGainAnimation(context, xpEarned);
                            
                            // Show level up dialog if leveled up
                            if (levelUpResult != null) {
                              showLevelUpDialog(context, levelUpResult);
                            }
                            
                            // Update plant growth in garden
                            try {
                              await ref.read(gardenProvider.notifier).updatePlantGrowth();
                            } catch (e) {
                              // Garden update failed, but don't block habit completion
                              print('Failed to update plant growth: $e');
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Marked "${habit.name}" as completed!'),
                                backgroundColor: AppColors.greenPrimary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (error) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error marking habit as completed: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                  childCount: habits.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.redPrimary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Error loading habits',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.redPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(habitsProvider.notifier).refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning! ☀️';
    } else if (hour < 17) {
      greeting = 'Good Afternoon! 🌤️';
    } else {
      greeting = 'Good Evening! 🌙';
    }

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.oceanGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: AppTextStyles.h4.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ready to build great habits today?',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final progress = ref.watch(progressProvider);
    
    if (progress.isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('...', '...', 'Completed'),
              _buildStatItem('...', 'Days', 'Streak'),
              _buildStatItem('...', 'Level', 'Your Level'),
            ],
          ),
        ),
      );
    }
    
    if (progress.error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: Text(
              'Error loading progress: ${progress.error}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.redPrimary,
              ),
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '${progress.completedToday}', 
              '${progress.totalHabitsToday}', 
              'Completed'
            ),
            _buildStatItem(
              '${progress.currentStreak}', 
              'Days', 
              progress.currentStreak > 0 ? 'Streak 🔥' : 'Streak'
            ),
            _buildStatItem(
              '${progress.currentLevel}', 
              'Level', 
              'Your Level'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String subtitle, String label) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: AppTextStyles.numberMedium),
            Text(
              '/$subtitle',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  int _calculateXPForCompletion(Habit habit, DailyProgress progress) {
    // Simple XP calculation for display
    // Base XP + streak bonus + perfect day bonus
    int xp = 10; // Base XP
    
    // Add streak bonus (simplified)
    if (progress.currentStreak > 0) {
      xp += (progress.currentStreak * 5).clamp(0, 50);
    }
    
    // Add perfect day bonus
    if (progress.isPerfectDay) {
      xp += 100;
    }
    
    return xp;
  }
}

// Analytics Tab
class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AnalyticsScreen();
  }
}

// Garden Tab
class GardenTab extends ConsumerWidget {
  const GardenTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const GardenScreen();
  }
}

