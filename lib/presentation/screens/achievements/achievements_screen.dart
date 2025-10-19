import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/achievement.dart';
import '../../providers/achievement_provider.dart';
import '../../widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with TickerProviderStateMixin {
  AchievementCategory? _selectedCategory;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final statsAsync = ref.watch(achievementStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: AppTextStyles.h4,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All'),
            const Tab(text: 'Getting Started'),
            const Tab(text: 'Streaks'),
            const Tab(text: 'Completions'),
            const Tab(text: 'Time Based'),
            const Tab(text: 'Special'),
            const Tab(text: 'Social'),
            const Tab(text: 'Premium'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Overview
          statsAsync.when(
            data: (stats) => _buildStatsOverview(stats),
            loading: () => _buildStatsLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Achievements Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsGrid(achievementsAsync, null),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.gettingStarted),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.streaks),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.completions),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.timeBased),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.special),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.social),
                _buildAchievementsGrid(achievementsAsync, AchievementCategory.premium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> stats) {
    final total = stats['total'] ?? 0;
    final unlocked = stats['unlocked'] ?? 0;
    final completionRate = stats['completionRate'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              '$total',
              Icons.emoji_events,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Unlocked',
              '$unlocked',
              Icons.check_circle,
              AppColors.greenPrimary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Progress',
              '${(completionRate * 100).toInt()}%',
              Icons.trending_up,
              AppColors.bluePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(AsyncValue<List<Achievement>> achievementsAsync, AchievementCategory? category) {
    return achievementsAsync.when(
      data: (achievements) {
        final filteredAchievements = category != null
            ? achievements.where((a) => a.category == category).toList()
            : achievements;

        if (filteredAchievements.isEmpty) {
          return _buildEmptyState(category);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredAchievements.length,
          itemBuilder: (context, index) {
            final achievement = filteredAchievements[index];
            return AchievementCard(
              achievement: achievement,
              onTap: () => _showAchievementDetail(achievement),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load achievements',
              style: AppTextStyles.h6.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => ref.invalidate(achievementsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AchievementCategory? category) {
    final categoryName = category?.categoryDisplayName ?? 'achievements';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No $categoryName yet',
            style: AppTextStyles.h6.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete habits to unlock achievements!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.md),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Achievement Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked 
                            ? AppColors.getRarityColor(achievement.rarity.name).withOpacity(0.1)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Center(
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Achievement Name
                    Text(
                      achievement.name,
                      style: AppTextStyles.h4.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Achievement Description
                    Text(
                      achievement.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Progress/Rarity Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoChip(
                          'Category',
                          achievement.categoryDisplayName,
                          Icons.category,
                        ),
                        _buildInfoChip(
                          'Rarity',
                          achievement.rarityDisplayName,
                          Icons.star,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Rewards
                    if (achievement.isUnlocked) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.greenPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRewardItem('XP', '${achievement.xpReward}', Icons.trending_up),
                            _buildRewardItem('Coins', '${achievement.coinReward}', Icons.monetization_on),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Progress Bar
                      Column(
                        children: [
                          Text(
                            achievement.progressText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: achievement.progress,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.getRarityColor(achievement.rarity.name),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.greenPrimary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.greenPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.greenPrimary,
          ),
        ),
      ],
    );
  }
}
