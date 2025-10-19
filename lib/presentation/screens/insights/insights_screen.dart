import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/insight.dart';
import '../../providers/insights_provider.dart';
import '../../widgets/insight_card.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  InsightCategory? _selectedType;
  InsightPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(insightsProvider);
    final stats = ref.watch(insightsStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights',
          style: AppTextStyles.h4,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(insightsProvider.notifier).refreshInsights(),
            tooltip: 'Refresh insights',
          ),
          PopupMenuButton<String>(
            onSelected: _handleFilterAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_filters',
                child: Text('Clear Filters'),
              ),
              const PopupMenuItem(
                value: 'dismiss_all',
                child: Text('Dismiss All'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            _buildTab('All', Icons.dashboard, stats['total'] ?? 0),
            _buildTab('Performance', Icons.analytics, stats['byType']?[InsightType.performance] ?? 0),
            _buildTab('Behavioral', Icons.psychology, stats['byType']?[InsightType.behavioral] ?? 0),
            _buildTab('Predictive', Icons.trending_up, stats['byType']?[InsightType.predictive] ?? 0),
            _buildTab('Motivational', Icons.emoji_events, stats['byType']?[InsightType.motivational] ?? 0),
            _buildTab('Recommendations', Icons.lightbulb, stats['byType']?[InsightType.recommendation] ?? 0),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsOverview(stats),
          
          // Priority Filter
          _buildPriorityFilter(),
          
          // Insights List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInsightsList(insights, null),
                _buildInsightsList(insights, InsightCategory.performance),
                _buildInsightsList(insights, InsightCategory.behavioral),
                _buildInsightsList(insights, InsightCategory.predictive),
                _buildInsightsList(insights, InsightCategory.motivational),
                _buildInsightsList(insights, InsightCategory.recommendation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> stats) {
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
              '${stats['total'] ?? 0}',
              Icons.insights,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Urgent',
              '${stats['urgent'] ?? 0}',
              Icons.warning,
              const Color(0xFFF44336),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'High',
              '${stats['high'] ?? 0}',
              Icons.priority_high,
              const Color(0xFFFF9800),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Unread',
              '${stats['unreadCount'] ?? 0}',
              Icons.mark_email_unread,
              const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h6.copyWith(
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

  Widget _buildPriorityFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null, null),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('Urgent', null, InsightPriority.urgent),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('High', null, InsightPriority.high),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('Medium', null, InsightPriority.medium),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('Low', null, InsightPriority.low),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, InsightCategory? type, InsightPriority? priority) {
    final isSelected = (type != null && _selectedType == type) ||
        (priority != null && _selectedPriority == priority) ||
        (type == null && priority == null && _selectedType == null && _selectedPriority == null);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (type != null) {
            _selectedType = selected ? type : null;
          } else if (priority != null) {
            _selectedPriority = selected ? priority : null;
          } else {
            _selectedType = null;
            _selectedPriority = null;
          }
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildInsightsList(AsyncValue<List<Insight>> insights, InsightCategory? type) {
    return insights.when(
      data: (insightsList) {
        // Filter by type if specified
        var filteredInsights = insightsList.where((insight) => !insight.isDismissed).toList();
        
        if (type != null) {
          filteredInsights = filteredInsights.where((insight) => insight.category == type).toList();
        }
        
        // Filter by priority if selected
        if (_selectedPriority != null) {
          filteredInsights = filteredInsights.where((insight) => insight.priority == _selectedPriority).toList();
        }
        
        if (filteredInsights.isEmpty) {
          return _buildEmptyState(type);
        }

        // Group by priority
        final urgentInsights = filteredInsights.where((i) => i.isUrgent).toList();
        final highInsights = filteredInsights.where((i) => i.priority == InsightPriority.high).toList();
        final otherInsights = filteredInsights.where((i) => !i.isUrgent && i.priority != InsightPriority.high).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            // Urgent insights
            if (urgentInsights.isNotEmpty) ...[
              _buildSectionHeader('Urgent', urgentInsights.length, const Color(0xFFF44336)),
              ...urgentInsights.map((insight) => InsightCard(
                insight: insight,
                onDismiss: () => _dismissInsight(insight.id),
                onAction: () => _executeAction(insight.id),
              )),
              const SizedBox(height: AppSpacing.md),
            ],
            
            // High priority insights
            if (highInsights.isNotEmpty) ...[
              _buildSectionHeader('High Priority', highInsights.length, const Color(0xFFFF9800)),
              ...highInsights.map((insight) => InsightCard(
                insight: insight,
                onDismiss: () => _dismissInsight(insight.id),
                onAction: () => _executeAction(insight.id),
              )),
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Other insights
            if (otherInsights.isNotEmpty) ...[
              if (urgentInsights.isNotEmpty || highInsights.isNotEmpty)
                _buildSectionHeader('Other Insights', otherInsights.length, Theme.of(context).colorScheme.primary),
              ...otherInsights.map((insight) => InsightCard(
                insight: insight,
                onDismiss: () => _dismissInsight(insight.id),
                onAction: () => _executeAction(insight.id),
              )),
            ],
          ],
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
              'Failed to load insights',
              style: AppTextStyles.h6.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => ref.read(insightsProvider.notifier).refreshInsights(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(InsightCategory? type) {
    final typeName = type?.displayName ?? 'insights';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No $typeName yet',
            style: AppTextStyles.h6.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete more habits to unlock insights!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleFilterAction(String action) {
    switch (action) {
      case 'clear_filters':
        setState(() {
          _selectedType = null;
          _selectedPriority = null;
        });
        break;
      case 'dismiss_all':
        _showDismissAllDialog();
        break;
    }
  }

  void _showDismissAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss All Insights'),
        content: const Text('Are you sure you want to dismiss all insights? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement dismiss all functionality
            },
            child: const Text('Dismiss All'),
          ),
        ],
      ),
    );
  }

  void _dismissInsight(String id) {
    ref.read(insightsProvider.notifier).dismissInsight(id);
  }

  void _executeAction(String id) {
    ref.read(insightsProvider.notifier).executeAction(id);
  }
}
