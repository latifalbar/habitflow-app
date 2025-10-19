import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/analytics/time_range_selector.dart';
import '../../widgets/analytics/analytics_overview_card.dart';
import '../../widgets/analytics/completion_trend_chart.dart';
import '../../widgets/analytics/habit_comparison_chart.dart';
import '../../widgets/analytics/category_distribution_chart.dart';
import '../../widgets/analytics/heatmap_calendar.dart';
import '../../widgets/analytics/habit_analytics_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _showAllHabits = false;

  @override
  void initState() {
    super.initState();
    // Refresh analytics when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);
    
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          title: Text(
            'Analytics',
            style: AppTextStyles.h4,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(analyticsProvider.notifier).refresh();
              },
              tooltip: 'Refresh analytics',
            ),
          ],
        ),
        
        // Time Range Selector
        const SliverToBoxAdapter(
          child: TimeRangeSelector(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
        
        // Overview Cards
        const SliverToBoxAdapter(
          child: AnalyticsOverviewCard(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.lg),
        ),
        
        // Charts Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Charts & Trends',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
        
        // Completion Trend Chart
        const SliverToBoxAdapter(
          child: CompletionTrendChart(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
        
        // Habit Comparison Chart
        const SliverToBoxAdapter(
          child: HabitComparisonChart(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
        
        // Category Distribution Chart
        const SliverToBoxAdapter(
          child: CategoryDistributionChart(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.lg),
        ),
        
        // Heatmap Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Activity Calendar',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
        
        // Heatmap Calendar
        const SliverToBoxAdapter(
          child: HeatmapCalendar(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.lg),
        ),
        
        // Individual Habits Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Individual Habits',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
        
        // Individual Habit Analytics
        _buildHabitAnalyticsList(analytics),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xl),
        ),
      ],
    );
  }

  Widget _buildHabitAnalyticsList(AsyncValue<AnalyticsData> analytics) {
    return analytics.when(
      data: (data) => _buildHabitAnalyticsContent(data),
      loading: () => SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: List.generate(3, (index) => _buildLoadingHabitCard()),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.redPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Failed to load habit analytics',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.redPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitAnalyticsContent(AnalyticsData data) {
    final habitAnalytics = data.habitAnalytics;
    
    // Sort by completion rate (best performers first)
    final sortedHabits = List<HabitAnalytics>.from(habitAnalytics)
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));
    
    // Show top 3 or all based on state
    final habitsToShow = _showAllHabits 
        ? sortedHabits 
        : sortedHabits.take(3).toList();
    
    if (habitAnalytics.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppColors.grey400,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No habits to analyze',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Create some habits to see detailed analytics',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Show habit cards
          if (index < habitsToShow.length) {
            final habit = habitsToShow[index];
            return HabitAnalyticsCard(habit: habit);
          }
          
          // Show "View All" button if there are more habits
          if (index == habitsToShow.length && !_showAllHabits && habitAnalytics.length > 3) {
            return _buildViewAllButton(habitAnalytics.length);
          }
          
          // Show "Show Less" button if showing all
          if (index == habitsToShow.length && _showAllHabits && habitAnalytics.length > 3) {
            return _buildShowLessButton();
          }
          
          return const SizedBox.shrink();
        },
        childCount: habitsToShow.length + (habitAnalytics.length > 3 ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingHabitCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _buildLoadingStatItem()),
                Expanded(child: _buildLoadingStatItem()),
                Expanded(child: _buildLoadingStatItem()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatItem() {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 30,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 50,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(int totalHabits) {
    final remainingCount = totalHabits - 3;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showAllHabits = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.oceanPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View All Habits',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '+$remainingCount',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowLessButton() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _showAllHabits = false;
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.oceanPrimary,
          side: BorderSide(color: AppColors.oceanPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_arrow_up,
              color: AppColors.oceanPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Show Less',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.oceanPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
