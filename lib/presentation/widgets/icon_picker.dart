import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class IconPickerBottomSheet extends StatefulWidget {
  final String? selectedIcon;
  final Function(String) onIconSelected;

  const IconPickerBottomSheet({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<IconPickerBottomSheet> createState() => _IconPickerBottomSheetState();
}

class _IconPickerBottomSheetState extends State<IconPickerBottomSheet> {
  String _searchQuery = '';
  String? _selectedIcon;

  // Helper function to convert IconData to string name
  String _getIconName(IconData icon) {
    switch (icon) {
      case Icons.fitness_center:
        return 'fitness_center';
      case Icons.water_drop:
        return 'water_drop';
      case Icons.book:
        return 'book';
      case Icons.self_improvement:
        return 'self_improvement';
      case Icons.bedtime:
        return 'bedtime';
      case Icons.wb_sunny:
        return 'wake';
      case Icons.restaurant:
        return 'restaurant';
      case Icons.coffee:
        return 'coffee';
      case Icons.work:
        return 'work';
      case Icons.school:
        return 'school';
      case Icons.home:
        return 'home';
      case Icons.directions_walk:
        return 'directions_walk';
      case Icons.directions_run:
        return 'directions_run';
      case Icons.pool:
        return 'pool';
      case Icons.bike_scooter:
        return 'bike_scooter';
      case Icons.psychology:
        return 'psychology';
      case Icons.volunteer_activism:
        return 'volunteer_activism';
      case Icons.music_note:
        return 'music_note';
      case Icons.palette:
        return 'palette';
      case Icons.camera_alt:
        return 'camera_alt';
      case Icons.games:
        return 'games';
      case Icons.movie:
        return 'movie';
      case Icons.shopping_cart:
        return 'shopping_cart';
      case Icons.cleaning_services:
        return 'cleaning_services';
      case Icons.pets:
        return 'pets';
      case Icons.family_restroom:
        return 'family_restroom';
      case Icons.favorite:
        return 'favorite';
      case Icons.health_and_safety:
        return 'health_and_safety';
      case Icons.eco:
        return 'eco';
      case Icons.star:
        return 'star';
      case Icons.celebration:
        return 'celebration';
      case Icons.travel_explore:
        return 'travel_explore';
      case Icons.language:
        return 'language';
      case Icons.code:
        return 'code';
      case Icons.brush:
        return 'brush';
      case Icons.sports_tennis:
        return 'sports_tennis';
      case Icons.sports_basketball:
        return 'sports_basketball';
      case Icons.sports_soccer:
        return 'sports_soccer';
      case Icons.sports_volleyball:
        return 'sports_volleyball';
      case Icons.sports_esports:
        return 'sports_esports';
      case Icons.sports_golf:
        return 'sports_golf';
      case Icons.sports_motorsports:
        return 'sports_motorsports';
      case Icons.sports_handball:
        return 'sports_handball';
      case Icons.sports_kabaddi:
        return 'sports_kabaddi';
      case Icons.sports_mma:
        return 'sports_mma';
      case Icons.sports_rugby:
        return 'sports_rugby';
      case Icons.sports_cricket:
        return 'sports_cricket';
      case Icons.sports_baseball:
        return 'sports_baseball';
      case Icons.sports_hockey:
        return 'sports_hockey';
      case Icons.sports_football:
        return 'sports_football';
      case Icons.sports:
        return 'sports';
      case Icons.sports_gymnastics:
        return 'sports_gymnastics';
      default:
        return 'check_circle_outline';
    }
  }

  // Curated list of icons for habits
  static const List<IconData> _habitIcons = [
    Icons.fitness_center,
    Icons.water_drop,
    Icons.book,
    Icons.self_improvement,
    Icons.bedtime,
    Icons.wb_sunny,
    Icons.restaurant,
    Icons.coffee,
    Icons.work,
    Icons.school,
    Icons.home,
    Icons.directions_walk,
    Icons.directions_run,
    Icons.pool,
    Icons.bike_scooter,
    Icons.psychology,
    Icons.volunteer_activism,
    Icons.music_note,
    Icons.palette,
    Icons.camera_alt,
    Icons.games,
    Icons.movie,
    Icons.shopping_cart,
    Icons.cleaning_services,
    Icons.pets,
    Icons.family_restroom,
    Icons.favorite,
    Icons.health_and_safety,
    Icons.eco,
    Icons.star,
    Icons.celebration,
    Icons.travel_explore,
    Icons.language,
    Icons.code,
    Icons.brush,
    Icons.sports_tennis,
    Icons.sports_basketball,
    Icons.sports_soccer,
    Icons.sports_volleyball,
    Icons.sports_esports,
    Icons.sports_golf,
    Icons.sports_motorsports,
    Icons.sports_handball,
    Icons.sports_kabaddi,
    Icons.sports_mma,
    Icons.sports_rugby,
    Icons.sports_cricket,
    Icons.sports_baseball,
    Icons.sports_hockey,
    Icons.sports_football,
    Icons.sports,
    Icons.sports_gymnastics,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  List<IconData> get _filteredIcons {
    if (_searchQuery.isEmpty) return _habitIcons;
    
    // Simple search by icon name (you could enhance this with icon names mapping)
    return _habitIcons.where((icon) {
      final iconName = icon.toString().toLowerCase();
      return iconName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text(
                  'Choose Icon',
                  style: AppTextStyles.h5,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _selectedIcon != null
                      ? () {
                          widget.onIconSelected(_selectedIcon!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.oceanPrimary),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Icons grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: _filteredIcons.length,
              itemBuilder: (context, index) {
                final icon = _filteredIcons[index];
                final iconName = _getIconName(icon);
                final isSelected = _selectedIcon == iconName;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconName;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.oceanPrimary.withOpacity(0.1)
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.oceanPrimary
                            : AppColors.grey200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected 
                          ? AppColors.oceanPrimary
                          : AppColors.grey600,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show icon picker
Future<String?> showIconPicker(
  BuildContext context, {
  String? selectedIcon,
}) async {
  String? result;
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => IconPickerBottomSheet(
      selectedIcon: selectedIcon,
      onIconSelected: (icon) {
        result = icon;
      },
    ),
  );
  
  return result;
}
