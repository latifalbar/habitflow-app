import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/profile_section_header.dart';
import '../../widgets/profile_option_tile.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
                  // App Info Card
                  _buildAppInfoCard(context),
                  const SizedBox(height: AppSpacing.lg),

                  // Features Section
                  ProfileSectionHeader(
                    title: 'Features',
                    subtitle: 'What makes HabitFlow special',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildFeaturesList(),
                  const SizedBox(height: AppSpacing.lg),

                  // Support Section
                  ProfileSectionHeader(
                    title: 'Support',
                    subtitle: 'Get help and stay connected',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSupportOptions(context),
                  const SizedBox(height: AppSpacing.lg),

                  // Legal Section
                  ProfileSectionHeader(
                    title: 'Legal',
                    subtitle: 'Terms and privacy',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildLegalOptions(context),
                  const SizedBox(height: AppSpacing.lg),

                  // Credits Section
                  ProfileSectionHeader(
                    title: 'Credits',
                    subtitle: 'Thanks to our contributors',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCreditsCard(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // App Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.oceanPrimary,
                    AppColors.oceanPrimary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: AppSpacing.iconXl,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // App Name and Version
            Text(
              AppConstants.appName,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Version ${AppConstants.appVersion}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Description
            Text(
              'Transform your daily routines into a fun, engaging journey with beautiful UI, smart insights, and powerful analytics. Build better habits with gamification, track your progress, and watch your virtual garden grow.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.track_changes, 'title': 'Smart Habit Tracking', 'description': 'Create and track unlimited habits with flexible scheduling'},
      {'icon': Icons.analytics, 'title': 'Beautiful Analytics', 'description': 'Detailed insights, heatmaps, and pattern recognition'},
      {'icon': Icons.emoji_events, 'title': 'Gamification', 'description': 'XP system, levels, achievements, and virtual garden'},
      {'icon': Icons.local_fire_department, 'title': 'Streak System', 'description': 'Visual streak tracking with freeze and recovery options'},
      {'icon': Icons.eco, 'title': 'Virtual Garden', 'description': 'Watch your habits grow into a beautiful garden'},
      {'icon': Icons.offline_bolt, 'title': 'Offline-First', 'description': 'Works seamlessly without internet connection'},
    ];

    return Card(
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          final isLast = index == features.length - 1;
          
          return ProfileOptionTile(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            subtitle: feature['description'] as String,
            showDivider: !isLast,
            onTap: null, // No action for feature items
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSupportOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ProfileOptionTile(
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'Find answers to common questions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help Center coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Help us improve the app',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug reporting coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.lightbulb,
            title: 'Suggest a Feature',
            subtitle: 'Share your ideas with us',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature suggestions coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.contact_support,
            title: 'Contact Support',
            subtitle: 'Get help from our team',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact support coming soon!'),
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ProfileOptionTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of Service coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy coming soon!'),
                ),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.copyright,
            title: 'Open Source Licenses',
            subtitle: 'Third-party library licenses',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open source licenses coming soon!'),
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Development Team',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Built with ❤️ by the HabitFlow team',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Special Thanks',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '• Flutter team for the amazing framework\n'
              '• Material Design for the design system\n'
              '• Firebase for backend services\n'
              '• Open source community for inspiration',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Made with Flutter ${AppConstants.appVersion}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
