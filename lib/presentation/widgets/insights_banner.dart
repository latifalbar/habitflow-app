import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/insight.dart';
import '../providers/insights_provider.dart';

class InsightsBanner extends ConsumerWidget {
  final VoidCallback? onViewAll;
  final VoidCallback? onDismiss;

  const InsightsBanner({
    super.key,
    this.onViewAll,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(highPriorityInsightsProvider);
    final urgentInsights = ref.watch(urgentInsightsProvider);
    final unreadCount = ref.watch(insightsProvider).whenData(
      (insights) => insights.where((i) => !i.isDismissed && !(i.metadata['isRead'] ?? false)).length
    ).valueOrNull ?? 0;

    // Show urgent insights first, then high priority
    final displayInsights = urgentInsights.isNotEmpty ? urgentInsights : insights;
    
    if (displayInsights.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show top 2 insights
    final topInsights = displayInsights.take(2).toList();
    final hasMore = displayInsights.length > 2;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          // Main banner
          _buildMainBanner(context, topInsights.first, unreadCount, hasMore),
          
          // Second insight if available
          if (topInsights.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSecondaryBanner(context, topInsights[1]),
          ],
        ],
      ),
    );
  }

  Widget _buildMainBanner(
    BuildContext context,
    Insight insight,
    int unreadCount,
    bool hasMore,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradientForPriority(insight.priority),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: [
          BoxShadow(
            color: insight.priority.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Center(
                    child: Text(
                      insight.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            insight.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (insight.isUrgent) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(AppSpacing.xs),
                              ),
                              child: Text(
                                'URGENT',
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
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        insight.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: AppSpacing.sm),
                
                // Action buttons
                Column(
                  children: [
                    if (onViewAll != null)
                      TextButton(
                        onPressed: onViewAll,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                        child: Text(
                          hasMore ? 'View All ($unreadCount)' : 'View',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (onDismiss != null)
                      IconButton(
                        onPressed: onDismiss,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    ).slideX(
      begin: -0.3,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildSecondaryBanner(BuildContext context, Insight insight) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: insight.priority.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: insight.priority.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Center(
                    child: Text(
                      insight.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.sm),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        insight.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: AppSpacing.sm),
                
                // Priority indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: insight.priority.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 200),
    ).slideX(
      begin: -0.2,
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 200),
    );
  }

  LinearGradient _getGradientForPriority(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.urgent:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF5252), Color(0xFFF44336)],
        );
      case InsightPriority.high:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
        );
      case InsightPriority.medium:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        );
      case InsightPriority.low:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
        );
    }
  }
}

// Compact version for smaller spaces
class CompactInsightsBanner extends ConsumerWidget {
  final VoidCallback? onTap;

  const CompactInsightsBanner({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgentInsights = ref.watch(urgentInsightsProvider);
    final unreadCount = ref.watch(insightsProvider).whenData(
      (insights) => insights.where((i) => !i.isDismissed && !(i.metadata['isRead'] ?? false)).length
    ).valueOrNull ?? 0;

    if (urgentInsights.isEmpty && unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: urgentInsights.isNotEmpty 
                  ? const Color(0xFFFF5252).withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: urgentInsights.isNotEmpty
                  ? Border.all(
                      color: const Color(0xFFFF5252).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  urgentInsights.isNotEmpty ? Icons.warning : Icons.insights,
                  color: urgentInsights.isNotEmpty 
                      ? const Color(0xFFFF5252)
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    urgentInsights.isNotEmpty
                        ? '${urgentInsights.length} urgent insight${urgentInsights.length > 1 ? 's' : ''}'
                        : '$unreadCount insight${unreadCount > 1 ? 's' : ''} available',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 300),
    ).slideY(
      begin: -0.2,
      duration: const Duration(milliseconds: 300),
    );
  }
}
