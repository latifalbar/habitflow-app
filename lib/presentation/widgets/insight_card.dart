import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/insight.dart';

class InsightCard extends StatefulWidget {
  final Insight insight;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final bool isExpanded;
  final bool showDismissButton;

  const InsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.onDismiss,
    this.onAction,
    this.isExpanded = false,
    this.showDismissButton = true,
  });

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _pulseController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _isExpanded = widget.isExpanded;
    if (_isExpanded) {
      _expandController.forward();
    }
    
    // Start pulse animation for urgent insights
    if (widget.insight.isUrgent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.insight.isUrgent ? 8 : 4,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          gradient: _getGradientForPriority(widget.insight.priority),
          border: widget.insight.isUrgent
              ? Border.all(
                  color: widget.insight.priority.color,
                  width: 2,
                )
              : null,
        ),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: widget.insight.isUrgent
                    ? 0.8 + (0.2 * _pulseController.value)
                    : 1.0,
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildContent(),
                  if (_isExpanded) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildExpandedContent(),
                  ],
                  if (widget.insight.isActionable) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildActionButton(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideX(
      begin: 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.insight.priority.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Center(
            child: Text(
              widget.insight.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.sm),
        
        // Title and type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.insight.title,
                style: AppTextStyles.h6.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.insight.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      widget.insight.categoryDisplayName,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: widget.insight.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.insight.priority.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      widget.insight.priorityDisplayName,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: widget.insight.priority.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Expand/collapse button
        if (widget.insight.metadata.isNotEmpty)
          IconButton(
            onPressed: _toggleExpanded,
            icon: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        
        // Dismiss button
        if (widget.showDismissButton)
          IconButton(
            onPressed: widget.onDismiss,
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      widget.insight.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: _isExpanded ? null : 3,
      overflow: _isExpanded ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.insight.metadata.isNotEmpty) ...[
            Text(
              'Details',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...widget.insight.metadata.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Generated: ${_formatDateTime(widget.insight.generatedAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onAction,
        icon: Icon(
          _getActionIcon(),
          size: 16,
        ),
        label: Text(widget.insight.actionText),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.insight.priority.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
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

  IconData _getActionIcon() {
    switch (widget.insight.category) {
      case InsightCategory.performance:
        return Icons.analytics;
      case InsightCategory.behavioral:
        return Icons.psychology;
      case InsightCategory.predictive:
        return Icons.trending_up;
      case InsightCategory.motivational:
        return Icons.emoji_events;
      case InsightCategory.recommendation:
        return Icons.lightbulb;
      case InsightCategory.backup:
        return Icons.cloud_upload;
    }
  }

  void _handleTap() {
    if (widget.insight.metadata.isNotEmpty) {
      _toggleExpanded();
    }
    widget.onTap?.call();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// Extension for InsightCategory to get color
extension InsightCategoryColor on InsightCategory {
  Color get color {
    switch (this) {
      case InsightCategory.performance:
        return const Color(0xFF2196F3); // Blue
      case InsightCategory.behavioral:
        return const Color(0xFF9C27B0); // Purple
      case InsightCategory.predictive:
        return const Color(0xFF673AB7); // Deep Purple
      case InsightCategory.motivational:
        return const Color(0xFFFF9800); // Orange
      case InsightCategory.recommendation:
        return const Color(0xFF4CAF50); // Green
      case InsightCategory.backup:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}
