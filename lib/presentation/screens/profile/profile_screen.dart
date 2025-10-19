import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/garden_provider.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/profile_section_header.dart';
import '../../widgets/profile_option_tile.dart';
import '../../widgets/xp_progress_bar.dart';
import '../settings/settings_screen.dart';
import '../about/about_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgressAsync = ref.watch(userProgressProvider);
    final analyticsAsync = ref.watch(analyticsProvider);
    final gardenAsync = ref.watch(gardenProvider);
    final habitsAsync = ref.watch(activeHabitsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'Profile',
            style: AppTextStyles.h4,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Progress Card
                _buildUserProgressCard(context, userProgressAsync),
                const SizedBox(height: AppSpacing.lg),

                // Quick Stats Section
                ProfileSectionHeader(
                  title: 'Quick Stats',
                  subtitle: 'Your progress overview',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildStatsGrid(context, analyticsAsync, habitsAsync),
                const SizedBox(height: AppSpacing.lg),

                // Garden Preview Section
                ProfileSectionHeader(
                  title: 'Garden',
                  subtitle: 'Your virtual garden',
                  action: TextButton(
                    onPressed: () {
                    // Navigate to Garden tab
                    DefaultTabController.of(context).animateTo(2);
                    },
                    child: const Text('View Garden'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildGardenPreview(context, gardenAsync),
                const SizedBox(height: AppSpacing.lg),

                // Settings Section
                ProfileSectionHeader(
                  title: 'Settings',
                  subtitle: 'App preferences',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSettingsOptions(context),
                const SizedBox(height: AppSpacing.lg),

                // App Info Section
                ProfileSectionHeader(
                  title: 'App Info',
                  subtitle: 'About HabitFlow',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildAppInfoOptions(context),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProgressCard(BuildContext context, AsyncValue userProgressAsync) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.oceanPrimary,
              AppColors.oceanPrimary.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Avatar and Level
              Row(
                children: [
                  CircleAvatar(
                    radius: AppSpacing.avatarLg / 2,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: userProgressAsync.when(
                      data: (progress) => Text(
                        '${progress.currentLevel}',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      error: (_, __) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guest User',
                          style: AppTextStyles.h5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        userProgressAsync.when(
                          data: (progress) => Text(
                            'Level ${progress.currentLevel} • ${progress.currentXP} XP',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          loading: () => Text(
                            'Loading...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          error: (_, __) => Text(
                            'Level 1 • 0 XP',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Coins display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: AppSpacing.iconSm,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        userProgressAsync.when(
                          data: (progress) => Text(
                            '${progress.currentXP ~/ 10}', // Simple coins calculation
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          loading: () => const Text(
                            '0',
                            style: TextStyle(color: Colors.white),
                          ),
                          error: (_, __) => const Text(
                            '0',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // XP Progress Bar
              userProgressAsync.when(
                data: (progress) => XPProgressBar(
                  currentXP: progress.currentXP,
                  currentLevel: progress.currentLevel,
                ),
                loading: () => const LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AsyncValue analyticsAsync, AsyncValue habitsAsync) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.2,
      children: [
        StatCard(
          icon: Icons.list_alt,
          value: habitsAsync.when(
            data: (habits) => '${habits.length}',
            loading: () => '0',
            error: (_, __) => '0',
          ),
          label: 'Total Habits',
          iconColor: AppColors.oceanPrimary,
        ),
        StatCard(
          icon: Icons.check_circle,
          value: analyticsAsync.when(
            data: (analytics) => '${analytics.overview.totalCompletions}',
            loading: () => '0',
            error: (_, __) => '0',
          ),
          label: 'Completions',
          iconColor: AppColors.greenPrimary,
        ),
        StatCard(
          icon: Icons.local_fire_department,
          value: analyticsAsync.when(
            data: (analytics) => '${analytics.overview.currentStreak}',
            loading: () => '0',
            error: (_, __) => '0',
          ),
          label: 'Current Streak',
          iconColor: AppColors.orangePrimary,
        ),
        StatCard(
          icon: Icons.emoji_events,
          value: analyticsAsync.when(
            data: (analytics) => '${analytics.overview.bestStreak}',
            loading: () => '0',
            error: (_, __) => '0',
          ),
          label: 'Best Streak',
          iconColor: AppColors.purplePrimary,
        ),
      ],
    );
  }

  Widget _buildGardenPreview(BuildContext context, AsyncValue gardenAsync) {
    return Card(
      child: InkWell(
        onTap: () {
                    // Navigate to Garden tab
                    DefaultTabController.of(context).animateTo(2);
        },
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.greenPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.eco,
                  color: AppColors.greenPrimary,
                  size: AppSpacing.iconLg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Garden',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    gardenAsync.when(
                      data: (garden) => Text(
                        '${garden.plants.length} plants • ${garden.plants.where((p) => !p.isWilting).length} healthy',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      loading: () => Text(
                        'Loading garden...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      error: (_, __) => Text(
                        '0 plants',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ProfileOptionTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Light, Dark, or System',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage your reminders',
            onTap: () {
              // TODO: Implement notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications settings coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.storage,
            title: 'Data Management',
            subtitle: 'Export, backup, and reset data',
            onTap: () {
              // TODO: Implement data management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data management coming soon!'),
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ProfileOptionTile(
            icon: Icons.info,
            title: 'About HabitFlow',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // TODO: Implement help screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.star,
            title: 'Rate App',
            subtitle: 'Rate HabitFlow on the store',
            onTap: () {
              // TODO: Implement rate app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rate app feature coming soon!'),
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
