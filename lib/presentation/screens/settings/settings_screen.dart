import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/profile_section_header.dart';
import '../../widgets/profile_option_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  ProfileSectionHeader(
                    title: 'Appearance',
                    subtitle: 'Customize your app experience',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: [
                        ProfileOptionTile(
                          icon: Icons.palette,
                          title: 'Theme',
                          subtitle: themeNotifier.getThemeDisplayName(currentTheme),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showThemeSelector(context, ref),
                        ),
                        ProfileOptionTile(
                          icon: Icons.brightness_6,
                          title: 'Accent Color',
                          subtitle: 'Coming soon',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Accent color customization coming soon!'),
                              ),
                            );
                          },
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Notifications Section
                  ProfileSectionHeader(
                    title: 'Notifications',
                    subtitle: 'Manage your reminders',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: [
                        ProfileOptionTile(
                          icon: Icons.notifications,
                          title: 'Push Notifications',
                          subtitle: 'Enable/disable notifications',
                          trailing: Switch(
                            value: true, // TODO: Connect to notification provider
                            onChanged: (value) {
                              // TODO: Implement notification toggle
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notification settings coming soon!'),
                                ),
                              );
                            },
                          ),
                        ),
                        ProfileOptionTile(
                          icon: Icons.schedule,
                          title: 'Reminder Times',
                          subtitle: 'Set your daily reminder times',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder times coming soon!'),
                              ),
                            );
                          },
                        ),
                        ProfileOptionTile(
                          icon: Icons.vibration,
                          title: 'Haptic Feedback',
                          subtitle: 'Vibration on interactions',
                          trailing: Switch(
                            value: true, // TODO: Connect to haptic settings
                            onChanged: (value) {
                              // TODO: Implement haptic toggle
                            },
                          ),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Data Management Section
                  ProfileSectionHeader(
                    title: 'Data Management',
                    subtitle: 'Manage your app data',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: [
                        ProfileOptionTile(
                          icon: Icons.download,
                          title: 'Export Data',
                          subtitle: 'Download your data as CSV',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data export coming soon!'),
                              ),
                            );
                          },
                        ),
                        ProfileOptionTile(
                          icon: Icons.backup,
                          title: 'Backup Data',
                          subtitle: 'Create a backup of your progress',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data backup coming soon!'),
                              ),
                            );
                          },
                        ),
                        ProfileOptionTile(
                          icon: Icons.refresh,
                          title: 'Reset Progress',
                          subtitle: 'Reset all your progress (irreversible)',
                          iconColor: AppColors.redPrimary,
                          onTap: () => _showResetConfirmation(context),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Privacy Section
                  ProfileSectionHeader(
                    title: 'Privacy',
                    subtitle: 'Your privacy and data',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: [
                        ProfileOptionTile(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          subtitle: 'Help improve the app',
                          trailing: Switch(
                            value: true, // TODO: Connect to analytics settings
                            onChanged: (value) {
                              // TODO: Implement analytics toggle
                            },
                          ),
                        ),
                        ProfileOptionTile(
                          icon: Icons.bug_report,
                          title: 'Crash Reports',
                          subtitle: 'Send crash reports automatically',
                          trailing: Switch(
                            value: true, // TODO: Connect to crash reporting settings
                            onChanged: (value) {
                              // TODO: Implement crash reporting toggle
                            },
                          ),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Theme',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...AppThemeMode.values.map((theme) {
              final themeNotifier = ref.read(themeProvider.notifier);
              final isSelected = ref.watch(themeProvider) == theme;
              
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.oceanPrimary : AppColors.textSecondary,
                ),
                title: Text(themeNotifier.getThemeDisplayName(theme)),
                subtitle: Text(_getThemeDescription(theme)),
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(theme);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system setting';
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'This will permanently delete all your habits, progress, and data. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement reset functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset functionality coming soon!'),
                  backgroundColor: AppColors.redPrimary,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.redPrimary,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
