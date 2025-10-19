import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/coins_provider.dart';
import '../../widgets/shop_item_card.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coinsAsync = ref.watch(coinsProvider);
    final statsAsync = ref.watch(coinsStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop',
          style: AppTextStyles.h4,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Coins Display
          coinsAsync.when(
            data: (coins) => Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.amberPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: AppColors.amberPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$coins',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.amberPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Themes'),
            Tab(text: 'Icons'),
            Tab(text: 'Power-ups'),
            Tab(text: 'Garden'),
            Tab(text: 'Profile'),
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
          
          // Shop Items
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThemesTab(),
                _buildIconsTab(),
                _buildPowerUpsTab(),
                _buildGardenTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> stats) {
    final current = stats['current'] ?? 0;
    final earned = stats['earned'] ?? 0;
    final spent = stats['spent'] ?? 0;

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
              'Current',
              '$current',
              Icons.account_balance_wallet,
              AppColors.amberPrimary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Earned',
              '$earned',
              Icons.trending_up,
              AppColors.greenPrimary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Spent',
              '$spent',
              Icons.trending_down,
              AppColors.redPrimary,
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

  Widget _buildThemesTab() {
    final themes = [
      ShopItem(
        id: 'theme_dark',
        name: 'Dark Theme',
        description: 'Elegant dark theme for night owls',
        price: 500,
        icon: '🌙',
        category: 'theme',
        isOwned: false,
      ),
      ShopItem(
        id: 'theme_blue',
        name: 'Ocean Blue',
        description: 'Calming blue theme inspired by the ocean',
        price: 300,
        icon: '🌊',
        category: 'theme',
        isOwned: false,
      ),
      ShopItem(
        id: 'theme_green',
        name: 'Forest Green',
        description: 'Natural green theme for nature lovers',
        price: 300,
        icon: '🌲',
        category: 'theme',
        isOwned: false,
      ),
      ShopItem(
        id: 'theme_purple',
        name: 'Royal Purple',
        description: 'Regal purple theme for royalty',
        price: 400,
        icon: '👑',
        category: 'theme',
        isOwned: false,
      ),
    ];

    return _buildShopGrid(themes);
  }

  Widget _buildIconsTab() {
    final icons = [
      ShopItem(
        id: 'icon_fire',
        name: 'Fire Icon',
        description: 'Burning passion for habits',
        price: 200,
        icon: '🔥',
        category: 'icon',
        isOwned: false,
      ),
      ShopItem(
        id: 'icon_star',
        name: 'Star Icon',
        description: 'Shine bright like a star',
        price: 200,
        icon: '⭐',
        category: 'icon',
        isOwned: false,
      ),
      ShopItem(
        id: 'icon_heart',
        name: 'Heart Icon',
        description: 'Love your habits',
        price: 200,
        icon: '❤️',
        category: 'icon',
        isOwned: false,
      ),
      ShopItem(
        id: 'icon_rocket',
        name: 'Rocket Icon',
        description: 'Launch your success',
        price: 250,
        icon: '🚀',
        category: 'icon',
        isOwned: false,
      ),
    ];

    return _buildShopGrid(icons);
  }

  Widget _buildPowerUpsTab() {
    final powerUps = [
      ShopItem(
        id: 'streak_freeze',
        name: 'Streak Freeze',
        description: 'Protect your streak for one day',
        price: 100,
        icon: '🧊',
        category: 'powerup',
        isOwned: false,
      ),
      ShopItem(
        id: 'double_xp',
        name: 'Double XP',
        description: 'Earn double XP for 24 hours',
        price: 150,
        icon: '⚡',
        category: 'powerup',
        isOwned: false,
      ),
      ShopItem(
        id: 'bonus_coins',
        name: 'Coin Magnet',
        description: 'Earn 50% more coins for 24 hours',
        price: 200,
        icon: '🧲',
        category: 'powerup',
        isOwned: false,
      ),
    ];

    return _buildShopGrid(powerUps);
  }

  Widget _buildGardenTab() {
    final gardenItems = [
      ShopItem(
        id: 'plant_rose',
        name: 'Rose Plant',
        description: 'Beautiful red roses for your garden',
        price: 100,
        icon: '🌹',
        category: 'garden',
        isOwned: false,
      ),
      ShopItem(
        id: 'plant_sunflower',
        name: 'Sunflower',
        description: 'Bright yellow sunflowers',
        price: 120,
        icon: '🌻',
        category: 'garden',
        isOwned: false,
      ),
      ShopItem(
        id: 'plant_tulip',
        name: 'Tulip',
        description: 'Elegant tulips in various colors',
        price: 80,
        icon: '🌷',
        category: 'garden',
        isOwned: false,
      ),
      ShopItem(
        id: 'garden_fountain',
        name: 'Garden Fountain',
        description: 'Decorative fountain for your garden',
        price: 300,
        icon: '⛲',
        category: 'garden',
        isOwned: false,
      ),
    ];

    return _buildShopGrid(gardenItems);
  }

  Widget _buildProfileTab() {
    final profileItems = [
      ShopItem(
        id: 'avatar_frame_gold',
        name: 'Gold Frame',
        description: 'Luxurious gold frame for your avatar',
        price: 200,
        icon: '🖼️',
        category: 'profile',
        isOwned: false,
      ),
      ShopItem(
        id: 'title_habit_master',
        name: 'Habit Master',
        description: 'Show off your dedication',
        price: 500,
        icon: '🎖️',
        category: 'profile',
        isOwned: false,
      ),
      ShopItem(
        id: 'title_streak_king',
        name: 'Streak King',
        description: 'Prove your consistency',
        price: 400,
        icon: '👑',
        category: 'profile',
        isOwned: false,
      ),
    ];

    return _buildShopGrid(profileItems);
  }

  Widget _buildShopGrid(List<ShopItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ShopItemCard(
          item: item,
          onPurchase: (item) => _handlePurchase(item),
        );
      },
    );
  }

  Future<void> _handlePurchase(ShopItem item) async {
    final coinsAsync = ref.read(coinsProvider);
    final currentCoins = await coinsAsync.when(
      data: (coins) => coins,
      loading: () => 0,
      error: (_, __) => 0,
    );

    if (currentCoins < item.price) {
      _showInsufficientCoinsDialog();
      return;
    }

    final confirmed = await _showPurchaseConfirmation(item);
    if (confirmed) {
      // TODO: Implement actual purchase logic
      _showPurchaseSuccess(item);
    }
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Insufficient Coins',
          style: AppTextStyles.h6.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'You don\'t have enough coins to purchase this item. Complete more habits to earn coins!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showPurchaseConfirmation(ShopItem item) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Purchase',
          style: AppTextStyles.h6.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${item.icon} ${item.name}',
              style: AppTextStyles.h6.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                  color: AppColors.amberPrimary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${item.price} coins',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.amberPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Purchase'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showPurchaseSuccess(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(item.icon),
            const SizedBox(width: AppSpacing.sm),
            Text('${item.name} purchased successfully!'),
          ],
        ),
        backgroundColor: AppColors.greenPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String icon;
  final String category;
  final bool isOwned;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
    this.isOwned = false,
  });
}
