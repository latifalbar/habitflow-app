import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/sync_provider.dart';

/// Sync status indicator for app bar
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);
    
    // Only show for premium users with sync enabled
    if (!syncState.isEnabled) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () => _showSyncDetails(context, ref, syncState),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(syncState.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(syncState.status).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (syncState.isLoading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(syncState.status),
                  ),
                ),
              )
            else
              Icon(
                _getStatusIcon(syncState.status),
                size: 12,
                color: _getStatusColor(syncState.status),
              ),
            const SizedBox(width: 4),
            Text(
              _getStatusText(syncState.status),
              style: AppTextStyles.bodySmall.copyWith(
                color: _getStatusColor(syncState.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return AppColors.success;
      case SyncStatus.syncing:
        return AppColors.warning;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.pending:
        return AppColors.warning;
      case SyncStatus.disabled:
        return AppColors.textSecondary;
      case SyncStatus.idle:
        return AppColors.primary;
    }
  }
  
  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.check_circle;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.pending:
        return Icons.schedule;
      case SyncStatus.disabled:
        return Icons.cloud_off;
      case SyncStatus.idle:
        return Icons.cloud;
    }
  }
  
  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.disabled:
        return 'Disabled';
      case SyncStatus.idle:
        return 'Ready';
    }
  }
  
  void _showSyncDetails(BuildContext context, WidgetRef ref, SyncState syncState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Row(
                children: [
                  Icon(
                    Icons.cloud_sync,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cloud Sync Status',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Status details
              _buildStatusDetails(syncState),
              
              const SizedBox(height: 16),
              
              // Action buttons
              _buildActionButtons(context, ref, syncState),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusDetails(SyncState syncState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(syncState.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(syncState.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(syncState.status),
                color: _getStatusColor(syncState.status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(syncState.status),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(syncState.status),
                ),
              ),
            ],
          ),
          if (syncState.lastSyncTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last synced: ${_formatLastSync(syncState.lastSyncTime!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (syncState.error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${syncState.error}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, SyncState syncState) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: syncState.canSync
                ? () {
                    ref.read(syncNotifierProvider.notifier).manualSync();
                    Navigator.pop(context);
                  }
                : null,
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(syncNotifierProvider.notifier).forceSyncAll();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Force Sync'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
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
