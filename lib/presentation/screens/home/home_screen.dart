import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/habit_log.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/habits_provider.dart';
import '../../providers/habit_logs_provider.dart';
import '../../widgets/habit_card.dart';
import '../habits/add_habit_screen.dart';
import '../habits/habit_detail_screen.dart';
import '../habits/habits_search_screen.dart';

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
    const ProfileTab(),
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
                      },
                      onCheck: () async {
                        try {
                          final repository = ref.read(habitLogRepositoryProvider);
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
                          
                          await ref.read(habitLogsProvider.notifier).addLog(log);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Marked "${habit.name}" as completed!'),
                                backgroundColor: AppColors.greenPrimary,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('0', '7', 'Completed'),
            _buildStatItem('0', 'Days', 'Streak'),
            _buildStatItem('1', 'Level', 'Your Level'),
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
}

// Analytics Tab
class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text('Analytics', style: AppTextStyles.h4),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Analytics Coming Soon',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Garden Tab
class GardenTab extends ConsumerWidget {
  const GardenTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text('Garden', style: AppTextStyles.h4),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco_outlined,
                  size: 80,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Garden Coming Soon',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Profile Tab
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text('Profile', style: AppTextStyles.h4),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                // Profile Avatar
                CircleAvatar(
                  radius: AppSpacing.avatarLg / 2,
                  backgroundColor: AppColors.oceanPrimary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: AppSpacing.iconXl,
                    color: AppColors.oceanPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Guest User', style: AppTextStyles.h5),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Level 1 • 0 XP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Profile Options
                _buildProfileOption(
                  context,
                  Icons.workspace_premium,
                  'Upgrade to Premium',
                  'Unlock all features',
                  () {},
                ),
                _buildProfileOption(
                  context,
                  Icons.emoji_events,
                  'Achievements',
                  'View your achievements',
                  () {},
                ),
                _buildProfileOption(
                  context,
                  Icons.settings,
                  'Settings',
                  'App preferences',
                  () {},
                ),
                _buildProfileOption(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  'Get help',
                  () {},
                ),
                _buildProfileOption(
                  context,
                  Icons.info_outline,
                  'About',
                  'Version ${AppConstants.appVersion}',
                  () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.oceanPrimary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
