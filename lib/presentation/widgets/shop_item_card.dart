import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../screens/shop/shop_screen.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final Function(ShopItem) onPurchase;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: item.isOwned ? 2 : 4,
      child: InkWell(
        onTap: item.isOwned ? null : () => onPurchase(item),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            gradient: item.isOwned
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.greenPrimary.withOpacity(0.1),
                      AppColors.greenPrimary.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Item Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.isOwned
                      ? AppColors.greenPrimary.withOpacity(0.2)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Item Name
              Text(
                item.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // Item Description
              Text(
                item.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Price or Status
              if (item.isOwned) ...[
                // Owned Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.greenPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Owned',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.greenPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: AppColors.amberPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${item.price}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.amberPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: AppSpacing.xs),
              
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text(
                  _getCategoryDisplayName(item.category),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getCategoryColor(item.category),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'theme':
        return AppColors.purplePrimary;
      case 'icon':
        return AppColors.bluePrimary;
      case 'powerup':
        return AppColors.orangePrimary;
      case 'garden':
        return AppColors.greenPrimary;
      case 'profile':
        return AppColors.pinkPrimary;
      default:
        return AppColors.greyPrimary;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'theme':
        return 'Theme';
      case 'icon':
        return 'Icon';
      case 'powerup':
        return 'Power-up';
      case 'garden':
        return 'Garden';
      case 'profile':
        return 'Profile';
      default:
        return 'Item';
    }
  }
}
