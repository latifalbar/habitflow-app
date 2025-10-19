import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/conflict_resolver.dart';
import '../providers/sync_provider.dart';

/// Conflict resolution dialog for handling data conflicts
class ConflictResolutionDialog extends ConsumerWidget {
  final ConflictData conflict;
  
  const ConflictResolutionDialog({
    Key? key,
    required this.conflict,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data Conflict Detected',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Conflict description
            Text(
              'This ${_getConflictTypeName(conflict.type)} has been modified on both your device and in the cloud. Please choose which version to keep.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Conflict details
            _buildConflictDetails(),
            
            const SizedBox(height: 24),
            
            // Resolution options
            _buildResolutionOptions(context, ref),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConflictDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conflict Details',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Timestamps
          Row(
            children: [
              Expanded(
                child: _buildTimestampCard(
                  'Local Version',
                  conflict.localTimestamp,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimestampCard(
                  'Cloud Version',
                  conflict.cloudTimestamp,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Differences
          if (conflict.differences.isNotEmpty) ...[
            Text(
              'Changes detected:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...conflict.differences.take(3).map((diff) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $diff',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )),
            if (conflict.differences.length > 3)
              Text(
                '... and ${conflict.differences.length - 3} more changes',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTimestampCard(String title, DateTime timestamp, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(timestamp),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResolutionOptions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose resolution:',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Keep Local option
        _buildResolutionOption(
          context: context,
          ref: ref,
          title: 'Keep Local Version',
          description: 'Use the version from your device',
          icon: Icons.phone_android,
          color: AppColors.primary,
          resolution: ConflictResolution.keepLocal,
        ),
        
        const SizedBox(height: 8),
        
        // Keep Cloud option
        _buildResolutionOption(
          context: context,
          ref: ref,
          title: 'Keep Cloud Version',
          description: 'Use the version from the cloud',
          icon: Icons.cloud,
          color: AppColors.secondary,
          resolution: ConflictResolution.keepCloud,
        ),
        
        const SizedBox(height: 8),
        
        // Merge option (if applicable)
        if (_canMerge(conflict))
          _buildResolutionOption(
            context: context,
            ref: ref,
            title: 'Smart Merge',
            description: 'Combine both versions intelligently',
            icon: Icons.merge,
            color: AppColors.success,
            resolution: ConflictResolution.merge,
          ),
      ],
    );
  }
  
  Widget _buildResolutionOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ConflictResolution resolution,
  }) {
    return InkWell(
      onTap: () => _resolveConflict(context, ref, resolution),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  void _resolveConflict(BuildContext context, WidgetRef ref, ConflictResolution resolution) {
    ref.read(syncNotifierProvider.notifier).resolveConflict(
      conflictId: conflict.id,
      resolution: resolution,
    );
    
    Navigator.pop(context);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conflict resolved using ${_getResolutionName(resolution)}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  String _getConflictTypeName(ConflictType type) {
    switch (type) {
      case ConflictType.habit:
        return 'habit';
      case ConflictType.habitLog:
        return 'habit log';
      case ConflictType.userProgress:
        return 'progress';
      case ConflictType.achievement:
        return 'achievement';
      case ConflictType.plant:
        return 'plant';
    }
  }
  
  String _getResolutionName(ConflictResolution resolution) {
    switch (resolution) {
      case ConflictResolution.keepLocal:
        return 'local version';
      case ConflictResolution.keepCloud:
        return 'cloud version';
      case ConflictResolution.merge:
        return 'smart merge';
    }
  }
  
  bool _canMerge(ConflictData conflict) {
    // Only allow merge for certain types
    return conflict.type == ConflictType.habit || 
           conflict.type == ConflictType.userProgress;
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
