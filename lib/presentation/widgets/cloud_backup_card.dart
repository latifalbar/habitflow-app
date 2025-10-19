import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/premium_checker.dart';
import '../../data/services/sync_service.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';

/// Cloud backup card widget for settings
class CloudBackupCard extends ConsumerWidget {
  const CloudBackupCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final isPremium = ref.watch(isPremiumProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_sync,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Backup & Sync',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isPremium) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Premium Feature',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isPremium && syncState.isEnabled)
                  Switch(
                    value: syncState.isEnabled,
                    onChanged: (value) {
                      if (value) {
                        ref.read(syncNotifierProvider.notifier).enableSync();
                      } else {
                        ref.read(syncNotifierProvider.notifier).disableSync();
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              isPremium 
                ? 'Automatically backup your habits, progress, and achievements to the cloud. Access your data from any device.'
                : 'Keep your habits safe with automatic cloud backup. Upgrade to Premium to enable this feature.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            if (isPremium) ...[
              const SizedBox(height: 16),
              
              // Sync status
              _buildSyncStatus(context, ref, syncState),
              
              const SizedBox(height: 12),
              
              // Action buttons
              _buildActionButtons(context, ref, syncState, authState),
            ] else ...[
              const SizedBox(height: 16),
              
              // Upgrade button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to premium screen
                    _showPremiumPrompt(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Upgrade to Premium',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSyncStatus(BuildContext context, WidgetRef ref, SyncState syncState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(syncState.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(syncState.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(syncState.status),
            color: _getStatusColor(syncState.status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(syncState.status),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(syncState.status),
                  ),
                ),
                if (syncState.lastSyncTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Last synced: ${_formatLastSync(syncState.lastSyncTime!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (syncState.isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(
    BuildContext context, 
    WidgetRef ref, 
    SyncState syncState, 
    AuthState authState,
  ) {
    if (!authState.isAuthenticated) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to login screen
            _showLoginPrompt(context);
          },
          icon: const Icon(Icons.login, size: 18),
          label: const Text('Sign In to Enable Backup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
    
    if (!syncState.isEnabled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            ref.read(syncNotifierProvider.notifier).enableSync();
          },
          icon: const Icon(Icons.cloud_upload, size: 18),
          label: const Text('Enable Cloud Backup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: syncState.canSync
                ? () {
                    ref.read(syncNotifierProvider.notifier).manualSync();
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
              ref.read(syncNotifierProvider.notifier).disableSync();
            },
            icon: const Icon(Icons.cloud_off, size: 18),
            label: const Text('Disable'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
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
        return 'All synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync failed';
      case SyncStatus.pending:
        return 'Waiting for connection';
      case SyncStatus.disabled:
        return 'Backup disabled';
      case SyncStatus.idle:
        return 'Ready to sync';
    }
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
  
  void _showPremiumPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'Cloud Backup & Sync is a premium feature. Upgrade to Premium to keep your habits safe in the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to premium screen
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
  
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'You need to sign in to enable cloud backup. This keeps your data safe and allows you to access it from any device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to login screen
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
